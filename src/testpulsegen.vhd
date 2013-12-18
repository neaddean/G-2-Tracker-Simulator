----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:23:34 10/17/2013 
-- Design Name: 
-- Module Name:    pulsegen - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;


entity pulsegen is
  
  port (
    channel : out std_logic_vector (15 downto 0);
    CLK     : in  std_logic;
    TP6     : out std_logic);

end pulsegen;

architecture Behavioral of pulsegen is

signal counter : std_logic_vector (31 downto 0) := (others => '0');
  
begin  -- Behavioral

channel <= counter(31 downto 16);
TP6 <= counter(15);

  count: process (CLK)
  begin 
    if rising_edge(CLK) then
      counter <= counter + 1;
    end if;
  end process count;

end Behavioral;
