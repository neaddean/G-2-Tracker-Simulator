-------------------------------------------------------------------------------
-- uart_top.vhd : top-level block for serial control block via UART
-- N.B. this block runs on 125MHz clock
--
-- Prototype TRM design using picoblaze and USB uart
--
-- port addresses for PicoBlaze uC:
-- 00 : UART status (read only)
--       bit 0 = uart_tx_data_present;
--       bit 1 = uart_tx_half_full;
--       bit 2 = uart_tx_full;
--       bit 3 = uart_rx_data_present;
--       bit 4 = uart_rx_half_full;
--       bit 5 = uart_rx_full;
-- 01 : UART data (read/write)
-- 02 : LEDs/Switches on eval board (read/write, different functions)
-- 03 : Data FIFO data (read only, also advance to next word)
-- 04 : Data FIFO flags/status (read only)
--       bit 0 = FIFO empty
--       bit 1 = FIFO full
--       bit 2 = K char in FIFO top
-- 05 : C5 output (write only)
--       bits 0-3 = output code
--       bit 4 = '1' for control, '0' for data
-- 06 : control register
--       bit 0 = '1' for internal fake TDC loop-back
-- 07 : trigger register for fake TDC
-- 08 : fake TDC data length LSB
-- 09 : fake TDC data length MSB
-- 0a : trigger register to clear data FIFO
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;
use IEEE.std_logic_misc.all;
use work.common.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity uart_top is

  port (
    clk125                    : in     std_logic;
    rst_n                     : in     std_logic;
    c5_output_data            : out    std_logic_vector(4 downto 0);
    c5_write_strobe           : out    std_logic;
    d_fifo_rd                 : out    std_logic;
    d_fifo_d                  : in     std_logic_vector(7 downto 0);
    d_fifo_k                  : in     std_logic;
    d_fifo_empty              : in     std_logic;
    d_fifo_full               : in     std_logic;
    d_fifo_clr                : out    std_logic;
    tdc_loop                  : out    std_logic;
    fake_tdc_length           : out    std_logic_vector(11 downto 0);
    fake_tdc_trig             : out    std_logic;
    Led                       : out    std_logic_vector(2 downto 0);
    ser_in                    : in     std_logic;
    ser_out                   : out    std_logic;
    spi_clk, spi_mosi, spi_cs : out    std_logic;
    initiate                  : buffer std_logic;
    do_once                   : out    std_logic;
    start_time                : out    time_array;
    TP8                       : out    std_logic;
    cperiod                   : out    period;
    pulse_period              : out    period);

end entity uart_top;

architecture arch of uart_top is

  component kcpsm6 is
    generic (
      hwbuild                 : std_logic_vector(7 downto 0);
      interrupt_vector        : std_logic_vector(11 downto 0);
      scratch_pad_memory_size : integer);
    port (
      address        : out std_logic_vector(11 downto 0);
      instruction    : in  std_logic_vector(17 downto 0);
      bram_enable    : out std_logic;
      in_port        : in  std_logic_vector(7 downto 0);
      out_port       : out std_logic_vector(7 downto 0);
      port_id        : out std_logic_vector(7 downto 0);
      write_strobe   : out std_logic;
      k_write_strobe : out std_logic;
      read_strobe    : out std_logic;
      interrupt      : in  std_logic;
      interrupt_ack  : out std_logic;
      sleep          : in  std_logic;
      reset          : in  std_logic;
      clk            : in  std_logic);
  end component kcpsm6;

  component uart_test is
    generic (
      C_FAMILY             : string;
      C_RAM_SIZE_KWORDS    : integer;
      C_JTAG_LOADER_ENABLE : integer);
    port (
      address     : in  std_logic_vector(11 downto 0);
      instruction : out std_logic_vector(17 downto 0);
      enable      : in  std_logic;
      rdl         : out std_logic;
      clk         : in  std_logic);
  end component uart_test;

  component uart_tx6 is
    port (
      data_in             : in  std_logic_vector(7 downto 0);
      en_16_x_baud        : in  std_logic;
      serial_out          : out std_logic;
      buffer_write        : in  std_logic;
      buffer_data_present : out std_logic;
      buffer_half_full    : out std_logic;
      buffer_full         : out std_logic;
      buffer_reset        : in  std_logic;
      clk                 : in  std_logic);
  end component uart_tx6;

  component uart_rx6 is
    port (
      serial_in           : in  std_logic;
      en_16_x_baud        : in  std_logic;
      data_out            : out std_logic_vector(7 downto 0);
      buffer_read         : in  std_logic;
      buffer_data_present : out std_logic;
      buffer_half_full    : out std_logic;
      buffer_full         : out std_logic;
      buffer_reset        : in  std_logic;
      clk                 : in  std_logic);
  end component uart_rx6;

--
-- Signals for connection of KCPSM6 and Program Memory.
--
  signal address              : std_logic_vector(11 downto 0);
  signal instruction          : std_logic_vector(17 downto 0);
  signal bram_enable          : std_logic;
  signal in_port              : std_logic_vector(7 downto 0);
  signal out_port             : std_logic_vector(7 downto 0);
  signal port_id              : std_logic_vector(7 downto 0);
  signal write_strobe         : std_logic;
  signal k_write_strobe       : std_logic;
  signal read_strobe          : std_logic;
  signal interrupt            : std_logic;
  signal interrupt_ack        : std_logic;
  signal kcpsm6_sleep         : std_logic;
  signal kcpsm6_reset         : std_logic;
--
  signal cpu_reset            : std_logic;
  signal rdl                  : std_logic;
--
  signal int_request          : std_logic;
--
-- Signals used to connect UART_TX6
--
  signal uart_tx_data_in      : std_logic_vector(7 downto 0);
  signal write_to_uart_tx     : std_logic;
  signal uart_tx_data_present : std_logic;
  signal uart_tx_half_full    : std_logic;
  signal uart_tx_full         : std_logic;
  signal uart_tx_reset        : std_logic;
--
-- Signals used to connect UART_RX6
--
  signal uart_rx_data_out     : std_logic_vector(7 downto 0);
  signal read_from_uart_rx    : std_logic;
  signal uart_rx_data_present : std_logic;
  signal uart_rx_half_full    : std_logic;
  signal uart_rx_full         : std_logic;
  signal uart_rx_reset        : std_logic;

  signal en_16_x_baud : std_logic;

  signal misc_ctrl   : std_logic_vector(7 downto 0);
  signal fake_length : std_logic_vector(11 downto 0);

begin  -- architecture arch

  uart_rx_reset <= '0';                 -- turn off reset of the UART RX
  uart_tx_reset <= '0';                 -- same for TX

  tdc_loop        <= misc_ctrl(0);      -- wire up control register
  fake_tdc_length <= fake_length;       -- wire up length register

  processor : kcpsm6
    generic map (hwbuild                 => X"00",
                 interrupt_vector        => X"3FF",
                 scratch_pad_memory_size => 64)
    port map(address        => address,
             instruction    => instruction,
             bram_enable    => bram_enable,
             port_id        => port_id,
             write_strobe   => write_strobe,
             k_write_strobe => k_write_strobe,
             out_port       => out_port,
             read_strobe    => read_strobe,
             in_port        => in_port,
             interrupt      => interrupt,
             interrupt_ack  => interrupt_ack,
             sleep          => kcpsm6_sleep,
             reset          => kcpsm6_reset,
             clk            => clk125);

  -- don't sleep, default iack
  kcpsm6_sleep <= '0';
  interrupt    <= interrupt_ack;

  program_rom : uart_test                     --Name to match your PSM file
    generic map(C_FAMILY             => "S6",  --Family 'S6', 'V6' or '7S'
                C_RAM_SIZE_KWORDS    => 1,  --Program size '1', '2' or '4'
                C_JTAG_LOADER_ENABLE => 1)  --Include JTAG Loader when set to '1' 
    port map(address     => address,
             instruction => instruction,
             enable      => bram_enable,
             rdl         => kcpsm6_reset,
             clk         => clk125);


  -----------------------------------------------------------------------------
  -- input ports
  -----------------------------------------------------------------------------

  input_ports : process(clk125)
  begin
    if clk125'event and clk125 = '1' then
      d_fifo_rd <= '0';                 -- default fifo read strobe off
      case port_id(3 downto 0) is
        -- Read UART status at port address 00 hex
        when "0000" => in_port(0) <= uart_tx_data_present;
                       in_port(1) <= uart_tx_half_full;
                       in_port(2) <= uart_tx_full;
                       in_port(3) <= uart_rx_data_present;
                       in_port(4) <= uart_rx_half_full;
                       in_port(5) <= uart_rx_full;
        -- Read UART_RX6 data at port address 01 hex
        -- (see 'buffer_read' pulse generation below) 
        when "0001" => in_port <= uart_rx_data_out;
        -- Read 8 general purpose switches at port address 02 hex
        when "0011" => in_port <= d_fifo_d;
                       if (read_strobe = '1') and (port_id(3 downto 0) = "0011") then
                         d_fifo_rd <= '1';  -- enable read strobe to be sent to the fifo
                       end if;
        when "0100" => in_port <= "00000" & d_fifo_k & d_fifo_full & d_fifo_empty;
        when others => in_port <= "XXXXXXXX";
      end case;

      -- Generate 'buffer_read' pulse following read from port address 01

      if (read_strobe = '1') and (port_id(3 downto 0) = "0001") then
        read_from_uart_rx <= '1';
      else
        read_from_uart_rx <= '0';
      end if;

    end if;
  end process input_ports;

  output_ports : process(clk125)
  begin
    if clk125'event and clk125 = '1' then
      -- 'write_strobe' is used to qualify all writes to general output ports.
      if write_strobe = '1' then
        if port_id(7) = '0' then
          case port_id(6 downto 0) is
            when "0000010" => LED     <= out_port(2 downto 0);
            when "0000011" => spi_clk <= out_port(0);
                              spi_cs   <= out_port(1);
                              spi_mosi <= out_port(7);
            when "0001001" => do_once  <= out_port(0);
            when "0001000" => initiate <= out_port(0);
                              TP8 <= out_port(0);
            when "1000000" => cperiod(2)               <= out_port;
            when "1000001" => cperiod(1)               <= out_port;
            when "1000010" => cperiod(0)               <= out_port;
            when "1000100" => pulse_period(2)          <= out_port;
            when "1000101" => pulse_period(1)          <= out_port;
            when "1000110" => pulse_period(0)          <= out_port;
            when "0100000" => misc_ctrl                <= out_port;
            when "0100001" => fake_length(7 downto 0)  <= out_port;
            when "0100010" => fake_length(11 downto 8) <= out_port(3 downto 0);
            when others    => out_port                 <= "XXXXXXXX";
          end case;
        elsif port_id(7) = '1' then
          start_time(conv_integer(port_id(5 downto 2)), conv_integer(port_id(1 downto 0)))
            <= out_port;
        end if;
      end if;
    end if;
  end process output_ports;

  --
  -- Write directly to the FIFO buffer within 'uart_tx6' macro at port address 01 hex.
  -- Note the direct connection of 'out_port' to the UART transmitter macro and the 
  -- way that a single clock cycle write pulse is generated to capture the data.
  -- 

  uart_tx_data_in <= out_port;

  write_to_uart_tx <= '1' when (write_strobe = '1') and (port_id = "00000001")
                      else '0';

  -- write logic for C5 interface
  c5_output_data  <= out_port(4 downto 0);
  c5_write_strobe <= '1' when (write_strobe = '1') and (port_id = "11100000")
                     else '0';

  -- trigger logic for fake TDC
  fake_tdc_trig <= '1' when (write_strobe = '1') and (port_id = "111000001")
                   else '0';

  -- trigger logic for data fifo clear
  d_fifo_clr <= '1' when (write_strobe = '1') and (port_id = "11100010")
                else '0';

  -- baud rate 125MHz / (115200*16) = 68
  process (clk125) is
    variable bcnt : integer range 0 to 67 := 0;
  begin  -- process
    if clk125'event and clk125 = '1' then  -- rising clock edge
      if bcnt = 67 then
        en_16_x_baud <= '1';
        bcnt         := 0;
      else
        en_16_x_baud <= '0';
        bcnt         := bcnt + 1;
      end if;
    end if;
  end process;

  --
  -- UART transmitter macro with 16 byte buffer
  --
  tx : uart_tx6
    port map (data_in             => uart_tx_data_in,
              en_16_x_baud        => en_16_x_baud,
              serial_out          => ser_out,
              buffer_write        => write_to_uart_tx,
              buffer_data_present => uart_tx_data_present,
              buffer_half_full    => uart_tx_half_full,
              buffer_full         => uart_tx_full,
              buffer_reset        => uart_tx_reset,
              clk                 => clk125);

  --
  -- UART Receiver with integral 16 byte FIFO buffer
  --
  rx : uart_rx6
    port map (serial_in           => ser_in,
              en_16_x_baud        => en_16_x_baud,
              data_out            => uart_rx_data_out,
              buffer_read         => read_from_uart_rx,
              buffer_data_present => uart_rx_data_present,
              buffer_half_full    => uart_rx_half_full,
              buffer_full         => uart_rx_full,
              buffer_reset        => uart_rx_reset,
              clk                 => clk125);

end architecture arch;
