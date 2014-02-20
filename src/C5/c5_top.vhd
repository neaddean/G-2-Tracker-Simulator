-------------------------------------------------------------------------------
-- c5_top.vhd : top-level interface for C5 sender
-- manages clock domain transition from 125 to 40MHz
--
-- may eventually contain serializer for register access
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
-- use IEEE.STD_LOGIC_ARITH.all;
-- use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;
use IEEE.std_logic_misc.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity c5_top is

  port (
    clk125 : in  std_logic;             -- 125MHz clock for computer interface
    clk40  : in  std_logic;             -- 40MHz clock to run C5 output
    rst_n  : in  std_logic;             -- active low reset
    din    : in  std_logic_vector(4 downto 0);  -- data in (0:3) plus CTRL
    c5_en  : in  std_logic;             -- transmit enable
    c5_out : out std_logic);            -- encoded C5 output

end entity c5_top;

architecture arch of c5_top is

  component c5_sender is
    port (
      clk40 : in  std_logic;
      rst_n : in  std_logic;
      en    : in  std_logic;
      B     : in  std_logic_vector (3 downto 0);
      cd    : in  std_logic;
      q0    : in  std_logic;
      c5    : out std_logic;
      busy  : out std_logic;
      frame : out std_logic);
  end component c5_sender;

  component pacd is
    port (
      iPulseA : in  std_logic;
      iClkA   : in  std_logic;
      iRSTAn  : in  std_logic;
      iClkB   : in  std_logic;
      iRSTBn  : in  std_logic;
      oPulseB : out std_logic);
  end component pacd;

  signal data_r : std_logic_vector(3 downto 0);
  signal cd_r   : std_logic;
  signal en40   : std_logic;

begin  -- architecture arch

  -- capture input signals in 125MHz domain
  process (clk125, rst_n) is
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      data_r <= (others => '0');
      cd_r   <= '0';
    elsif clk125'event and clk125 = '1' then  -- rising clock edge
      if c5_en = '1' then
        data_r <= din(3 downto 0);
        cd_r   <= din(4);
      end if;
    end if;
  end process;

  -- synchronize en to 40MHz domain
  pacd_1 : entity work.pacd
    port map (
      iPulseA => c5_en,
      iClkA   => clk125,
      iRSTAn  => rst_n,
      iClkB   => clk40,
      iRSTBn  => rst_n,
      oPulseB => en40);

  c5_sender_2 : entity work.c5_sender
    port map (
      clk40 => clk40,
      rst_n => rst_n,
      en    => en40,
      B     => data_r,
      cd    => cd_r,
      q0    => '0',
      c5    => c5_out,
      busy  => open,
      frame => open);

end architecture arch;
