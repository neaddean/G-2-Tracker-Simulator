-------------------------------------------------------------------------------
-- datarec.vhd : top-level data recovery
-- use mask produced by decoder blocks to pick a bit from shift register
--
-- seems to work ok
-- 15 Aug 2013, esh - add extra register on output
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
-- use IEEE.STD_LOGIC_ARITH.all;
-- use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;
use IEEE.std_logic_misc.all;

entity datarec is

  generic (
    W : integer := 10;                  -- input transition window width
    M : integer := 5);                  -- oversampling factor

  port (
    clk   : in  std_logic;              -- oversampling (125MHz) clock
    rst_n : in  std_logic;              -- active low reset
    ser   : in  std_logic;              -- serial input
    dv    : out std_logic;              -- data valid
    test  : out std_logic_vector(4 downto 0);
    d     : out std_logic);             -- recovered data

end entity datarec;

architecture arch of datarec is

  component edge is
    generic (
      M : integer);
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      ser   : in  std_logic;
      en    : out std_logic;
      sreg  : out std_logic_vector(M-1 downto 0);
      edges : out std_logic_vector(M-1 downto 0));
  end component edge;

  component deblock is
    generic (
      W   : integer;
      ENO : integer;
      M   : integer);
    port (
      clk     : in  std_logic;
      rst_n   : in  std_logic;
      en      : in  std_logic;
      edges   : in  std_logic_vector(M-1 downto 0);
      aligned : out std_logic);
  end component deblock;

  signal en        : std_logic;
  signal edges     : std_logic_vector(M-1 downto 0);
  signal bit_valid : std_logic_vector(M-1 downto 0);
  signal sreg      : std_logic_vector(M-1 downto 0);

  signal d_r, dv_r : std_logic;

begin  -- architecture arch

  test <= edges;

  -- edge detector
  edge_1 : entity work.edge
    generic map (
      M => M)
    port map (
      clk   => clk,
      rst_n => rst_n,
      ser   => ser,
      en    => en,
      sreg  => sreg,
      edges => edges);

  -- M decoder blocks to check bit alignment
  f1 : for k in 0 to M-1 generate
    deblock_1 : entity work.deblock
      generic map (
        W   => W,
        ENO => k,
        M   => M)
      port map (
        clk     => clk,
        rst_n   => rst_n,
        en      => en,
        edges   => edges,
        aligned => bit_valid(k));
  end generate f1;

  -- 1 of M in bit_valid should be set
  process (clk) is
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge

      d  <= d_r;
      dv <= dv_r;  -- extra register in output to ease timing

      dv_r <= '0';
      if or_reduce(bit_valid) = '1' and en = '1' then
        dv_r <= '1';
        d_r  <= or_reduce(bit_valid and sreg);
      end if;
    end if;
  end process;

end architecture arch;
