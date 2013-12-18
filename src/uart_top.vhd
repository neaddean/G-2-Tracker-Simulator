----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:07:58 11/06/2013 
-- Design Name: 
-- Module Name:    uart_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.common.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

entity uart_top is
  port (
    clk                       : in     std_logic;
    uart_tx                   : out    std_logic;
    uart_rx                   : in     std_logic;
    LED                       : out    std_logic_vector (2 downto 0);
    spi_clk, spi_mosi, spi_cs : out    std_logic;
    initiate                  : buffer std_logic;
    do_once                   : out    std_logic;
    start_time                : out    time_array;
    TP8                       : out    std_logic;
    period                    : out    period);
end uart_top;

architecture Behavioral of uart_top is

  component kcpsm6
    generic(hwbuild                 : std_logic_vector(7 downto 0)  := X"00";
            interrupt_vector        : std_logic_vector(11 downto 0) := X"3FF";
            scratch_pad_memory_size : integer                       := 64);
    port (address        : out std_logic_vector(11 downto 0);
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
  end component;

--
-- Development Program Memory
--

  component uart_test
    generic(C_FAMILY             : string  := "S6";
            C_RAM_SIZE_KWORDS    : integer := 1;
            C_JTAG_LOADER_ENABLE : integer := 1);
    port (address     : in  std_logic_vector(11 downto 0);
          instruction : out std_logic_vector(17 downto 0);
          enable      : in  std_logic;
          rdl         : out std_logic;
          clk         : in  std_logic);
  end component;

--
-- UART Transmitter with integral 16 byte FIFO buffer
--

  component uart_tx6
    port (data_in             : in  std_logic_vector(7 downto 0);
          en_16_x_baud        : in  std_logic;
          serial_out          : out std_logic;
          buffer_write        : in  std_logic;
          buffer_data_present : out std_logic;
          buffer_half_full    : out std_logic;
          buffer_full         : out std_logic;
          buffer_reset        : in  std_logic;
          clk                 : in  std_logic);
  end component;

--
-- UART Receiver with integral 16 byte FIFO buffer
--

  component uart_rx6
    port (serial_in           : in  std_logic;
          en_16_x_baud        : in  std_logic;
          data_out            : out std_logic_vector(7 downto 0);
          buffer_read         : in  std_logic;
          buffer_data_present : out std_logic;
          buffer_half_full    : out std_logic;
          buffer_full         : out std_logic;
          buffer_reset        : in  std_logic;
          clk                 : in  std_logic);
  end component;
  --
-------------------------------------------------------------------------------------------
--
-- Signals
--
-------------------------------------------------------------------------------------------
-- Signals used to connect KCPSM6
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
  signal rdl                  : std_logic;
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
--
-- Signals used to define baud rate
--
  signal baud_count           : integer range 0 to 13 := 0;
  signal en_16_x_baud         : std_logic             := '0';
--
--                

begin

  processor : kcpsm6
    generic map (hwbuild                 => X"42",  -- 42 hex is ASCII Character "B"
                 interrupt_vector        => X"7F0",
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
             clk            => clk);


  --
  -- Reset connected to JTAG Loader enabled Program Memory 
  --

  kcpsm6_reset <= rdl;


  --
  -- Unused signals tied off until required.
  --

  kcpsm6_sleep <= '0';
  interrupt    <= interrupt_ack;


  --
  -- Development Program Memory 
  --   JTAG Loader enabled for rapid code development. 
  --

  program_rom : uart_test
    generic map(C_FAMILY             => "S6",
                C_RAM_SIZE_KWORDS    => 1,
                C_JTAG_LOADER_ENABLE => 1)
    port map(address     => address,
             instruction => instruction,
             enable      => bram_enable,
             rdl         => rdl,
             clk         => clk);



  --
  -----------------------------------------------------------------------------------------
  -- UART Transmitter with integral 16 byte FIFO buffer
  -----------------------------------------------------------------------------------------
  --
  -- Write to buffer in UART Transmitter at port address 01 hex
  -- 

  tx : uart_tx6
    port map (data_in             => uart_tx_data_in,
              en_16_x_baud        => en_16_x_baud,
              serial_out          => uart_tx,
              buffer_write        => write_to_uart_tx,
              buffer_data_present => uart_tx_data_present,
              buffer_half_full    => uart_tx_half_full,
              buffer_full         => uart_tx_full,
              buffer_reset        => uart_tx_reset,
              clk                 => clk);


  --
  -----------------------------------------------------------------------------------------
  -- UART Receiver with integral 16 byte FIFO buffer
  -----------------------------------------------------------------------------------------
  --
  -- Read from buffer in UART Receiver at port address 01 hex.
  --
  -- When KCPMS6 reads data from the receiver a pulse must be generated so that the 
  -- FIFO buffer presents the next character to be read and updates the buffer flags.
  -- 
  
  rx : uart_rx6
    port map (serial_in           => uart_rx,
              en_16_x_baud        => en_16_x_baud,
              data_out            => uart_rx_data_out,
              buffer_read         => read_from_uart_rx,
              buffer_data_present => uart_rx_data_present,
              buffer_half_full    => uart_rx_half_full,
              buffer_full         => uart_rx_full,
              buffer_reset        => uart_rx_reset,
              clk                 => clk);

  --
  -----------------------------------------------------------------------------------------
  -- RS232 (UART) baud rate 
  -----------------------------------------------------------------------------------------
  --
  -- To set serial communication baud rate to 115,200 then en_16_x_baud must pulse 
  -- High at 1,843,200Hz which is every 27.13 cycles at 50MHz. In this implementation 
  -- a pulse is generated every 27 cycles resulting is a baud rate of 115,741 baud which
  -- is only 0.5% high and well within limits.
  --

  baud_rate : process(clk)
  begin
    if clk'event and clk = '1' then
      if baud_count = 13 then           -- counts 27 states including zero
        baud_count   <= 0;
        en_16_x_baud <= '1';            -- single cycle enable pulse
      else
        baud_count   <= baud_count + 1;
        en_16_x_baud <= '0';
      end if;
    end if;
  end process baud_rate;


  --
  -----------------------------------------------------------------------------------------
  -- General Purpose Input Ports. 
  -----------------------------------------------------------------------------------------
  --
  -- Two input ports are used with the UART macros. The first is used to monitor the flags
  -- on both the transmitter and receiver. The second is used to read the data from the 
  -- receiver and generate the 'buffer_read' pulse.
  --

  input_ports : process(clk)
  begin
    if clk'event and clk = '1' then
      case port_id(0) is

        -- Read UART status at port address 00 hex
        when '0' => in_port(0) <= uart_tx_data_present;
                    in_port(1) <= uart_tx_half_full;
                    in_port(2) <= uart_tx_full;
                    in_port(3) <= uart_rx_data_present;
                    in_port(4) <= uart_rx_half_full;
                    in_port(5) <= uart_rx_full;

                    -- Read UART_RX6 data at port address 01 hex
                    -- (see 'buffer_read' pulse generation below) 
        when '1' => in_port <= uart_rx_data_out;

        when others => in_port <= "XXXXXXXX";

      end case;

      -- Generate 'buffer_read' pulse following read from port address 01

      if (read_strobe = '1') and (port_id(0) = '1') then
        read_from_uart_rx <= '1';
      else
        read_from_uart_rx <= '0';
      end if;
      
    end if;
  end process input_ports;



  --
  -----------------------------------------------------------------------------------------
  -- General Purpose Output Ports 
  -----------------------------------------------------------------------------------------
  --
  -- In this simple example there is only one output port and that it involves writing 
  -- directly to the FIFO buffer within 'uart_tx6'. As such the only requirements are to 
  -- connect the 'out_port' to the transmitter macro and generate the write pulse.
  -- 

  gp_output_ports : process (clk)
  begin
    if rising_edge(clk) then
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
            when "1000000" => period(2) <= out_port;
            when "1000001" => period(1) <= out_port;
            when "1000010" => period(0) <= out_port;
            when others    => out_port  <= "XXXXXXXX";
          end case;
        elsif port_id(7) = '1' then
          
          start_time(conv_integer(port_id(5 downto 2)), conv_integer(port_id(1 downto 0)))
 <= out_port;
        end if;
      end if;
    end if;
  end process gp_output_ports;

  uart_tx_data_in <= out_port;

  write_to_uart_tx <= '1' when (write_strobe = '1') and (port_id = "00000001")
                      else '0';

--
-----------------------------------------------------------------------------------------
-- Constant-Optimised Output Ports 
-----------------------------------------------------------------------------------------
--
-- One constant-optimised output port is used to facilitate resetting of the UART macros.
--

  constant_output_ports : process(clk)
  begin
    if clk'event and clk = '1' then
      if k_write_strobe = '1' then
        if port_id = "00000000" then
          uart_tx_reset <= out_port(0);
          uart_rx_reset <= out_port(1);
        end if;
      end if;
    end if;
  end process constant_output_ports;

--
-----------------------------------------------------------------------------------------
--

  --zeros: for I in 0 to 15 generate
  --    start_time(I,2)(7 downto 1) <= (others => '0');
  --end generate zeros;

end Behavioral;
