-------------------------------------------------------------------------------
-- inferred FIFO
--
-- inputs:
--    clk    clock
--  rst_n    asynchronous reset
--    clr    synchronous reset
--    din    data in
--   dout    data out
--  empty    empty flag
--   full    full flag
--     wr    write enable
--     rd    read enable
--
-- FIFO operates in "first word fall thru" mode where the first value written
-- appears on the output one clock after it is written
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed."+";

entity ififo is

  generic (
    wide  : integer := 9;               -- data width
    deep  : integer := 4096;            -- FIFO depth (must be 2^abits)
    abits : integer := 12);             -- address width (must be log2(deep))

  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    din   : in  std_logic_vector(wide-1 downto 0);
    dout  : out std_logic_vector(wide-1 downto 0);
    empty : out std_logic;
    full  : out std_logic;
    wr    : in  std_logic;
    rd    : in  std_logic;
    clr   : in  std_logic);

end entity ififo;

architecture arch of ififo is

  type ram_type is array (0 to deep-1) of std_logic_vector(wide-1 downto 0);
  signal RAM : ram_type;

  signal s_full, s_empty : std_logic;

  signal wr_ptr : std_logic_vector(abits-1 downto 0);
  signal rd_ptr : std_logic_vector(abits-1 downto 0);

begin  -- architecture arch

  process (clk, rst_n) is
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      wr_ptr <= (others => '0');
      rd_ptr <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      if clr = '1' then
        wr_ptr <= (others => '0');
        rd_ptr <= (others => '0');
      end if;

      if wr = '1' and s_full = '0' then
        RAM(TO_INTEGER(unsigned(wr_ptr))) <= din;
        wr_ptr                            <= wr_ptr + 1;
      end if;
      if rd = '1' and s_empty = '0' then
        rd_ptr <= rd_ptr + 1;
      end if;
    end if;
  end process;

  s_empty <= '1' when rd_ptr = wr_ptr       else '0';
  s_full  <= '1' when (wr_ptr + 1) = rd_ptr else '0';

  dout  <= RAM(TO_INTEGER(unsigned(rd_ptr)));
  empty <= s_empty;
  full  <= s_full;

end architecture arch;
