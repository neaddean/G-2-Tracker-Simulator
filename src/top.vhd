-------------------------------------------------------------------------------
-- Title      : top
-- Project    : 
-------------------------------------------------------------------------------
-- File       : top.vhd
-- Author     :   <dean@weber>
-- Company    : 
-- Created    : 2013-11-06
-- Last update: 2014-01-17
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
use IEEE.STD_LOGIC_UNSIGNED.all;
--
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--
library unisim;
use unisim.vcomponents.all;
use work.common.all;
use IEEE.numeric_std.all;
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
        high_z_pin                : out std_logic);
end top;

architecture Behavioral of top is

  -- outputs of "clocking"
  signal clk25, clk125 : std_logic;

  component clk_gen
    port
      (                                 -- Clock in ports
        clk125_P : in  std_logic;
        clk125_N : in  std_logic;
        -- Clock out ports
        clk25    : out std_logic;
        clk125   : out std_logic);
  end component;

  component uart_top
    port (
      clk                       : in     std_logic;
      uart_tx                   : out    std_logic;
      uart_rx                   : in     std_logic;
      LED                       : out    std_logic_vector (2 downto 0);
      spi_clk, spi_mosi, spi_cs : out    std_logic;
      initiate                  : buffer std_logic;
      do_once                   : out    std_logic;
      start_times                : out    time_array;
      TP8                       : out    std_logic;
      cperiod                   : out    period;
      pulse_period              : out    period);
  end component;

  signal initiate     : std_logic;
  signal start_times  : time_array;
  signal cperiod      : period := ((others => (others => '1')));
  signal pulse_period : period := ("00010011", "00010010", "11010000");
  signal do_once      : std_logic;

  component fullpulsegen
    port (
      channel       : out std_logic_vector (15 downto 0);
      start_times   : in  time_array;
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

begin

  high_z_pin <= 'Z';

  RS   <= '1';
  LDAC <= '0';

  clocking : clk_gen
    port map
    (                                   -- Clock in ports
      clk125_P => clk125_P,
      clk125_N => clk125_N,
      -- Clock out ports
      clk25    => clk25,
      clk125   => clk125);

  -- instance "uart_top_2"
  uart_top_1 : uart_top
    port map (
      clk          => clk25,
      uart_tx      => uart_tx,
      uart_rx      => uart_rx,
      LED          => LED,
      spi_clk      => spi_clk,
      spi_mosi     => spi_mosi,
      do_once      => do_once,
      spi_cs       => spi_cs,
      initiate     => initiate,
      start_times   => start_times,
      TP8          => TP8,
      cperiod      => cperiod,
      pulse_period => pulse_period);

  --instance "fullpulsegen_1"
  fullpulsegen_1 : fullpulsegen
    port map (
      channel      => channels,
      start_times  => start_times,
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

end Behavioral;
