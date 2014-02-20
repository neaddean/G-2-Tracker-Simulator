-------------------------------------------------------------------------------
-- deblock.vhd : decision block
-- count sample periods (flagged by en=1) where only I-th edge is seen
-- when count reaches W output aligned=1
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
-- use IEEE.STD_LOGIC_ARITH.all;
-- use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;
use IEEE.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

entity deblock is

  generic (
    W : integer := 10;                  -- input transition window width
    ENO : integer := 0;                   -- edge# to match (M-1 downto 0)
    M : integer := 5);                  -- oversampling factor

  port (
    clk     : in  std_logic;            -- oversampling clock
    rst_n   : in  std_logic;            -- active low reset
    en      : in  std_logic;            -- edge detector strobe
    edges    : in  std_logic_vector(M-1 downto 0);
    aligned : out std_logic);

end entity deblock;

architecture arch of deblock is

  signal edge_or   : std_logic;
  signal edge_mask : std_logic_vector(M-1 downto 0);
  signal sr        : std_logic_vector(W-1 downto 0);

begin  -- architecture arch

-- the following line doesn't work because XST is broken!
--  edge_mask <= ( ENO => '0', others => '1');  -- form a mask with a '0' in bit position I

-- do it the hard way!
  process (rst_n) is
  begin  -- process
    edge_mask <= (others => '1');
    edge_mask(ENO) <= '0';
  end process;

  edge_or   <= or_reduce(edges and edge_mask);  -- or bits except I-th one

  process (clk, rst_n) is
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      sr <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if en = '1' then
        if edge_or = '1' then           -- if any edge but I-th one is seen
          sr <= (others => '0');        -- reset the counter
        else
          sr <= sr(W-2 downto 0) & '1'; -- else shift in a '1'
        end if;
      end if;
    end if;
  end process;

  aligned <= sr(W-1);                   -- high bit of count indicates success

end architecture arch;
