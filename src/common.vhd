library IEEE;
use IEEE.STD_LOGIC_1164.all;

package common is

  type time_array is array (integer range 15 downto 0, integer range 2 downto 0)
    of std_logic_vector (7 downto 0);
  type period is array (integer range 2 downto 0)
    of std_logic_vector (7 downto 0);
  -- time_array (address, data)(bit) <= bit
  -- time_array (address, data) <= byte

end common;
