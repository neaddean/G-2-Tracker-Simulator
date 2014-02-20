----------------------------------------------------------------------------------
-- pulsegen.vhd : generate wide, normal, narrow pulses for C5 coding
-- inputs:
--   clk40   40MHz clock
--   rst_n   active low asynchronous reset
--    Yout   four-bit pattern to shift out MSB first
--    trig   latch pattern and send
-- outputs:
--      c5   encoder output
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;

entity pulsegen is
  port (
    clk40 : in  std_logic;
    rst_n : in  std_logic;
    trig  : in  std_logic;
    Yout  : in  std_logic_vector (3 downto 0);
    c5    : out std_logic);
end pulsegen;

architecture behavioral of pulsegen is
  signal sr : std_logic_vector(3 downto 0);
begin


  pulsetype : process (clk40, rst_n) is  --, trig, narrow, wide) is
  begin  -- process

    if rst_n = '0' then
      sr <= (others => '0');
    elsif clk40'event and clk40 = '1' then
      if trig = '1' then
        sr <= Yout;
      else
        sr <= sr(2 downto 0) & '0';
      end if;
    end if;
  end process;

  c5 <= sr(3);

end behavioral;




