-------------------------------------------------------------------------------
-- fake data for FIFO filling
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed."+";
use ieee.std_logic_signed."=";
use IEEE.std_logic_misc.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity fake_data is

  generic (
    len : integer := 10);
  
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    dout  : out std_logic_vector(8 downto 0);
    wr    : out std_logic;
    trig  : in  std_logic);

end entity fake_data;

architecture arch of fake_data is

  signal div4   : std_logic_vector(1 downto 0);
  signal wcount : std_logic_vector(11 downto 0);
  signal busy   : std_logic;
  signal k_char : std_logic;

begin  -- architecture arch

  process (clk, rst_n) is
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      div4   <= (others => '0');
      wcount <= (others => '0');
      busy   <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge

      k_char <= '0';
      wr     <= '0';

      if trig = '1' and busy = '0' then
        busy   <= '1';
        div4   <= (others => '0');
        wcount <= (others => '0');
      end if;

      if busy = '1' then
        div4 <= div4 + 1;
        if div4 = "11" then
          if wcount = len then
            wcount <= (others => '0');
            busy   <= '0';
          else
            if wcount = 0 then
              k_char <= '1';
            end if;
            wr <= '1';
            wcount <= wcount + 1;
          end if;
        end if;
      end if;

    end if;
  end process;

  dout <= k_char & wcount(7 downto 0);

end architecture arch;
