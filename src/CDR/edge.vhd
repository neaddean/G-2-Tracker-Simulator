-------------------------------------------------------------------------------
-- edge.vhd : edge detector
--
-- sample ser using clk.  Every M clocks, output a vector
-- with '1' if there was a transition in that clock
-- also output en=1 for one clk every M clocks
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

entity edge is

  generic (
    SOFF : integer := 2;                -- sampling offset
    M : integer := 5);                  -- oversampling factor

  port (
    clk   : in  std_logic;              -- oversampling clock
    rst_n : in  std_logic;              -- active low reset
    ser   : in  std_logic;              -- serial input
    en    : out std_logic;              -- enable active every Mth clock
    sreg  : out std_logic_vector(M-1 downto 0);   -- shifted bit stream out
    edges : out std_logic_vector(M-1 downto 0));  -- edge detect output

end edge;

architecture arch of edge is

  signal sr   : std_logic_vector(M+SOFF downto 0); -- SR for edge detect and sampling
  signal sr1  : std_logic_vector(M-2 downto 0);  -- SR to count bits
  signal xors : std_logic_vector(M-1 downto 0);  -- XOR of successive samples

begin  -- arch

  process (clk, rst_n)
  begin  -- process

    if rst_n = '0' then                 -- asynchronous reset (active low)

      sr  <= (others => '0');
      sr1 <= (others => '0');

    elsif clk'event and clk = '1' then  -- rising clock edge

      sr  <= sr(M+SOFF-1 downto 0) & ser;    -- shift in data
      sr1 <= sr1(M-3 downto 0) & '1';   -- shift in 1 (counter)
      if sr1(M-2) = '1' then            -- if M bits shifted...
        en    <= '1';                   --   set en=1
        edges <= xors;                  --   latch edges
        sr1   <= (others => '0');       --   clear conter
        sreg <= sr(M+SOFF-1 downto SOFF);       -- latch out SR
      else
        en <= '0';
      end if;

    end if;
  end process;

  -- generate xor of successive samples (asynchronous)
  f1 : for i in 0 to M-1 generate
    xors(i) <= sr(i) xor sr(i+1);
  end generate f1;

end arch;
