-------------------------------------------------------------------------------
-- Title      : top
-- Project    : 
-------------------------------------------------------------------------------
-- File       : top.vhd
-- Author     :   <dean@weber>
-- Company    : 
-- Created    : 2013-11-06
-- Last update: 2014-02-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-11-06  1.0      Dean    Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.all;

library unisim;                         
use unisim.vcomponents.all;
use work.common.all;
use IEEE.numeric_std.all;
use ieee.std_logic_signed."+";
use ieee.std_logic_signed."=";
use IEEE.std_logic_misc.all;
--
-------------------------------------------------------------------------------------------
--
--

entity top is
  port (uart_rx                   : in  std_logic;
        uart_tx                   : out std_logic;
        clk125_P                  : in  std_logic;
        clk125_N                  : in  std_logic;
        spi_clk, spi_mosi, spi_cs : out std_logic;
        RS, LDAC                  : out std_logic;
        LED                       : out std_logic_vector (2 downto 0);
        channels                  : out std_logic_vector (15 downto 0);
        TP6, TP7, TP8, TP9        : out std_logic;
        -- LVDS I/Os on VHDCI connector
        c5_out_p                  : out std_logic;
        c5_out_n                  : out std_logic;
        tdc_8b10b_p               : in  std_logic;
        tdc_8b10b_n               : in  std_logic);
end top;

architecture Behavioral of top is

  ---- outputs of "clocking"
  --signal clk25, clk125 : std_logic;

  --component clk_gen
  --  port
  --    (                                 -- Clock in ports
  --      clk125_P : in  std_logic;
  --      clk125_N : in  std_logic;
  --      -- Clock out ports
  --      clk25    : out std_logic;
  --      clk125   : out std_logic);
  --end component;

  component uart_top
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
  end component;

  component c5_top is
    port (
      clk125 : in  std_logic;
      clk40  : in  std_logic;
      rst_n  : in  std_logic;
      din    : in  std_logic_vector(4 downto 0);
      c5_en  : in  std_logic;
      c5_out : out std_logic);
  end component c5_top;

  component rec_8b10b_top
    port (
      clk125     : in  std_logic;
      rst_n      : in  std_logic;
      serial     : in  std_logic;
      data_out   : out std_logic_vector(7 downto 0);
      fifo_full  : out std_logic;
      fifo_empty : out std_logic;
      k_char     : out std_logic;
      locked     : out std_logic;
      err        : out std_logic;
      fifo_wr    : out std_logic;
      test       : out std_logic_vector(3 downto 0);
      fifo_clr   : in  std_logic;
      fifo_rd    : in  std_logic);
  end component;

  --  component clk125Dto100 is
  --  port
  --    (                                 -- Clock in ports
  --      clk125_P : in  std_logic;
  --      clk125_N : in  std_logic;
  --      -- Clock out ports
  --      clk100   : out std_logic;
  --      -- Status and control signals
  --      RESET    : in  std_logic;
  --      LOCKED   : out std_logic
  --      );
  --end component;

  signal initiate     : std_logic;
  signal start_time   : time_array;
  signal cperiod      : period := ((others => (others => '1')));
  signal pulse_period : period := ("00010011", "00010010", "11010000");
  signal do_once      : std_logic;

  signal clk100_in : std_logic;         -- input clock
  signal clk125    : std_logic;         -- synthesized 125MHz clock
  signal clk125_D  : std_logic;         -- 180 deg 125MHz clock
  signal clk40     : std_logic;         -- synthesized 40MHz clock
  signal clk40_n   : std_logic;         -- synthesized 40MHz clock  
  signal rst_n     : std_logic;

  signal c5_output_data  : std_logic_vector(4 downto 0);
  signal c5_write_strobe : std_logic;

  signal d_fifo_rd    : std_logic;
  signal d_fifo_d     : std_logic_vector(7 downto 0);
  signal d_fifo_empty : std_logic;
  signal d_fifo_full  : std_logic;
  signal d_fifo_clr   : std_logic;

  signal serial_mux  : std_logic;
  signal serial_reg  : std_logic;
  signal serial_neg  : std_logic;
  signal tdc_loop    : std_logic;

  signal d_fifo_k : std_logic;

  signal rec_test : std_logic_vector(4 downto 0);

  signal clk125_lck : std_logic;
  signal clk40_lck  : std_logic;

  signal c5_out_s : std_logic;
  signal tdc_in_s : std_logic;

  signal rst_ctr : std_logic_vector(3 downto 0);
  signal rst_req : std_logic;
  signal rst_reg : std_logic;

  signal rst_C5_n : std_logic;

  component fullpulsegen
    port (
      channel       : out std_logic_vector (15 downto 0);
      start_time    : in  time_array;
      initiate      : in  std_logic;
      do_once       : in  std_logic;
      CLK           : in  std_logic;
      TP6, TP7, TP9 : out std_logic;
      cperiod       : in  period;
      pulse_period  : in  period);
  end component;



  --component pulsegen
  --  port (
  --    channel : out std_logic_vector (15 downto 0);
  --    CLK     : in  std_logic;
  --    TP6     : out std_logic);
  --end component;

  component clk_gen is
    port
      (                                 -- Clock in ports
        clk125_P : in  std_logic;
        clk125_N : in  std_logic;
        -- Clock out ports
        clk100_in   : out std_logic);
  end component;

begin

  RS   <= '1';
  LDAC <= '0';

  clocking : clk_gen
    port map
    (                                   -- Clock in ports
      clk125_P => clk125_P,
      clk125_N => clk125_N,
      -- Clock out ports
      clk100_in   => clk100_in);

  --clocking : clk_gen
  --  port map
  --  (                                   -- Clock in ports
  --    clk125_P => clk125_P,
  --    clk125_N => clk125_N,
  --    -- Clock out ports
  --    clk25    => clk25,
  --    clk125   => clk125);

  -- drive C5 to both LVCMOS and LVDS outputs
  --c5_out <= c5_out_s;

  lvds_o1 : OBUFDS
    port map (
      I  => c5_out_s,
      O  => c5_out_p,
      OB => c5_out_n);

  -- multiplexor for TDC loop-back
  --with tdc_loop select
  --  serial_mux <=
  --  tdc_sim_out when '1',
  --  tdc_in_s    when others;
serial_mux <= tdc_in_s;
  -- LVDS input buffer for TDC 8b10b input
  lvds1 : IBUFDS_LVDS_33
    port map (
      O  => tdc_in_s,
      I  => tdc_8b10b_p,
      IB => tdc_8b10b_n);

  -- generate 15-clock reset synchronized to 125MHz on
  -- external reset (BTND button) or USB (d_fifo_clr)
  --
  process (clk125) is
  begin  -- process
    if clk125'event and clk125 = '1' then  -- rising clock edge
      rst_req <= d_fifo_clr;
      rst_reg <= rst_req;
      rst_n   <= '1';
      -- rising edge on reset
      if rst_reg = '0' and rst_req = '1' then
        rst_ctr <= (others => '0');
      else
        if rst_ctr /= "1111" then
          rst_n   <= '0';
          rst_ctr <= rst_ctr + 1;
        end if;
      end if;
    end if;
  end process;



  --instance "fullpulsegen_1"
  fullpulsegen_1 : fullpulsegen
    port map (
      channel      => channels,
      start_time   => start_time,
      do_once      => do_once,
      initiate     => initiate,
      CLK          => CLK125,
      TP6          => TP6,
      TP7          => TP7,
      TP9          => TP9,
      cperiod      => cperiod,
      pulse_period => pulse_period);


---- instance "pulsegen_1"
--  pulsegen_1 : pulsegen
--    port map (
--      channel => channels,
--      CLK     => CLK125,
--      TP6     => TP6);

  -- instance "uart_top_1"
  uart_top_1 : entity work.uart_top
    port map (
      clk125          => clk125,
      rst_n           => rst_n,
      c5_output_data  => c5_output_data,
      c5_write_strobe => c5_write_strobe,
      d_fifo_rd       => d_fifo_rd,
      d_fifo_d        => d_fifo_d,
      d_fifo_k        => d_fifo_k,
      d_fifo_empty    => d_fifo_empty,
      d_fifo_full     => d_fifo_full,
      d_fifo_clr      => d_fifo_clr,
      tdc_loop        => tdc_loop,
      fake_tdc_length => open,
      fake_tdc_trig   => open,
      Led             => Led,
      ser_in          => uart_rx,
      ser_out         => uart_tx,
      spi_clk         => spi_clk,
      spi_mosi        => spi_mosi,
      spi_cs          => spi_cs,
      initiate        => initiate,
      do_once         => do_once,
      start_time      => start_time,
      TP8             => TP8,
      cperiod         => cperiod,
      pulse_period    => pulse_period);


  -- instantiate C5 encoder interface
  c5_top_1 : entity work.c5_top
    port map (
      clk125 => clk125,
      clk40  => clk40,
      rst_n  => rst_C5_n,
      din    => c5_output_data,
      c5_en  => c5_write_strobe,
      c5_out => c5_out_s);
  -- set rst_C5_n to '1' so it doesn't reset with the FIFO
  rst_C5_n <= '1';


  -- instantiate 8b10b receiver
  rec_8b10b_top_1 : entity work.rec_8b10b_top
    port map (
      clk125     => clk125,
      rst_n      => rst_n,
      serial     => serial_neg,
      data_out   => d_fifo_d,
      fifo_full  => d_fifo_full,
      fifo_empty => d_fifo_empty,
      k_char     => d_fifo_k,
      locked     => open,
      err        => open,
      fifo_rd    => d_fifo_rd,
      fifo_clr   => d_fifo_clr,
      test       => rec_test,
      fifo_wr    => open
      );

  -- add a register on the serial loop-back
  -- to assist timing closure
  process (clk125) is
  begin  -- process
    if clk125'event and clk125 = '1' then  -- rising clock edge
      serial_reg <= serial_mux;
    end if;
  end process;

  -- add a half-clock additional delay
  -- NOTE:  may need to tweak this depending on delay in final system
  process (clk125_D, rst_n) is
  begin  -- process
    if clk125_D'event and clk125_D = '1' then  -- rising clock edge
      serial_neg <= serial_reg;
    end if;
  end process;

  -- DCM_SP: Digital Clock Manager
  --         Spartan-6
  -- Xilinx HDL Language Template, version 14.4
  -- configure to make 40MHz from 100MHz


  DCM_SP_125 : DCM_SP
    generic map (
      CLKDV_DIVIDE          => 2.0,     -- CLKDV divide value
      -- (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      CLKFX_DIVIDE          => 4,  -- Divide value on CLKFX outputs - D - (1-32)
      CLKFX_MULTIPLY        => 5,  -- Multiply value on CLKFX outputs - M - (2-32)
      CLKIN_DIVIDE_BY_2     => false,   -- CLKIN divide by two (TRUE/FALSE)
      CLKIN_PERIOD          => 10.0,    -- Input clock period specified in nS
      CLKOUT_PHASE_SHIFT    => "NONE",  -- Output phase shift (NONE, FIXED, VARIABLE)
      CLK_FEEDBACK          => "1X",    -- Feedback source (NONE, 1X, 2X)
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      DFS_FREQUENCY_MODE    => "LOW",   -- Unsupported - Do not change value
      DLL_FREQUENCY_MODE    => "LOW",   -- Unsupported - Do not change value
      DSS_MODE              => "NONE",  -- Unsupported - Do not change value
      DUTY_CYCLE_CORRECTION => true,    -- Unsupported - Do not change value
      FACTORY_JF            => X"c080",  -- Unsupported - Do not change value
      PHASE_SHIFT           => 0,  -- Amount of fixed phase shift (-255 to 255)
      STARTUP_WAIT          => false  -- Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
      )
    port map (
      CLK0     => open,                 -- 1-bit output: 0 degree clock output
      CLK180   => open,  -- 1-bit output: 180 degree clock output
      CLK270   => open,  -- 1-bit output: 270 degree clock output
      CLK2X    => open,  -- 1-bit output: 2X clock frequency clock output
      CLK2X180 => open,  -- 1-bit output: 2X clock frequency, 180 degree clock output
      CLK90    => open,                 -- 1-bit output: 90 degree clock output
      CLKDV    => open,                 -- 1-bit output: Divided clock output
      CLKFX    => clk125,  -- 1-bit output: Digital Frequency Synthesizer output (DFS)
      CLKFX180 => clk125_D,        -- 1-bit output: 180 degree CLKFX output
      LOCKED   => clk125_lck,           -- 1-bit output: DCM_SP Lock Output
      PSDONE   => open,  -- 1-bit output: Phase shift done output
      STATUS   => open,                 -- 8-bit output: DCM_SP status output
      CLKFB    => open,                 -- 1-bit input: Clock feedback input
      CLKIN    => clk100_in,            -- 1-bit input: Clock input
      DSSEN    => '0',   -- 1-bit input: Unsupported, specify to GND.
      PSCLK    => '0',                  -- 1-bit input: Phase shift clock input
      PSEN     => '0',                  -- 1-bit input: Phase shift enable
      PSINCDEC => '0',   -- 1-bit input: Phase shift increment/decrement input
      RST      => '0'                   -- 1-bit input: Active high reset input
      );

  DCM_SP_40 : DCM_SP
    generic map (
      CLKDV_DIVIDE          => 2.0,     -- CLKDV divide value
      -- (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      CLKFX_DIVIDE          => 5,  -- Divide value on CLKFX outputs - D - (1-32)
      CLKFX_MULTIPLY        => 2,  -- Multiply value on CLKFX outputs - M - (2-32)
      CLKIN_DIVIDE_BY_2     => false,   -- CLKIN divide by two (TRUE/FALSE)
      CLKIN_PERIOD          => 10.0,    -- Input clock period specified in nS
      CLKOUT_PHASE_SHIFT    => "NONE",  -- Output phase shift (NONE, FIXED, VARIABLE)
      CLK_FEEDBACK          => "1X",    -- Feedback source (NONE, 1X, 2X)
      DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",  -- SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      DFS_FREQUENCY_MODE    => "LOW",   -- Unsupported - Do not change value
      DLL_FREQUENCY_MODE    => "LOW",   -- Unsupported - Do not change value
      DSS_MODE              => "NONE",  -- Unsupported - Do not change value
      DUTY_CYCLE_CORRECTION => true,    -- Unsupported - Do not change value
      FACTORY_JF            => X"c080",  -- Unsupported - Do not change value
      PHASE_SHIFT           => 0,  -- Amount of fixed phase shift (-255 to 255)
      STARTUP_WAIT          => false  -- Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
      )
    port map (
      CLK0     => open,                 -- 1-bit output: 0 degree clock output
      CLK180   => open,  -- 1-bit output: 180 degree clock output
      CLK270   => open,  -- 1-bit output: 270 degree clock output
      CLK2X    => open,  -- 1-bit output: 2X clock frequency clock output
      CLK2X180 => open,  -- 1-bit output: 2X clock frequency, 180 degree clock output
      CLK90    => open,                 -- 1-bit output: 90 degree clock output
      CLKDV    => open,                 -- 1-bit output: Divided clock output
      CLKFX    => clk40,  -- 1-bit output: Digital Frequency Synthesizer output (DFS)
      CLKFX180 => clk40_n,         -- 1-bit output: 180 degree CLKFX output
      LOCKED   => clk40_lck,            -- 1-bit output: DCM_SP Lock Output
      PSDONE   => open,  -- 1-bit output: Phase shift done output
      STATUS   => open,                 -- 8-bit output: DCM_SP status output
      CLKFB    => open,                 -- 1-bit input: Clock feedback input
      CLKIN    => clk100_in,            -- 1-bit input: Clock input
      DSSEN    => '0',   -- 1-bit input: Unsupported, specify to GND.
      PSCLK    => '0',                  -- 1-bit input: Phase shift clock input
      PSEN     => '0',                  -- 1-bit input: Phase shift enable
      PSINCDEC => '0',   -- 1-bit input: Phase shift increment/decrement input
      RST      => '0'                   -- 1-bit input: Active high reset input
      );

end Behavioral;
