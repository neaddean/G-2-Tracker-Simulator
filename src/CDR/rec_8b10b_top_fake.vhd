-------------------------------------------------------------------------------
-- rec_8b10b_top.vhd : receive 8b10b code from TDC
--
-- dummy block for now
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed."+";
use IEEE.std_logic_misc.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity rec_8b10b_top is

  port (
    clk125     : in  std_logic;                     -- system clock
    rst_n      : in  std_logic;                     -- active low reset
    data_out   : out std_logic_vector(7 downto 0);  -- output data
    fifo_full  : out std_logic;                     -- fifo full flag
    fifo_empty : out std_logic;                     -- fifo empty flag
    k_char     : out std_logic;                     -- K char at FIFO top
    locked     : out std_logic;                     -- 8b10b comma aligned
    err        : out std_logic;                     -- 8b10b input error
    fifo_rd    : in  std_logic;                     -- fifo read strobe
    test       : in  std_logic                      -- trigger test data load
    );

end entity rec_8b10b_top;


architecture arch of rec_8b10b_top is

  component fake_data is
    generic (
      len : integer);
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      dout  : out std_logic_vector(8 downto 0);
      wr    : out std_logic;
      trig  : in  std_logic);
  end component fake_data;

  component ififo is
    generic (
      wide  : integer;
      deep  : integer;
      abits : integer);
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
  end component ififo;

  signal fifo_din  : std_logic_vector(8 downto 0);
  signal fifo_dout : std_logic_vector(8 downto 0);

  signal fifo_wr : std_logic;

begin  -- architecture arch

  data_out <= fifo_dout(7 downto 0);
  k_char   <= fifo_dout(8);

  fake_data_1 : entity work.fake_data
    generic map (
      len => 16)
    port map (
      clk   => clk125,
      rst_n => rst_n,
      dout  => fifo_din,
      wr    => fifo_wr,
      trig  => test);

  ififo_1 : entity work.ififo

    port map (
      clk   => clk125,
      rst_n => rst_n,
      din   => fifo_din,
      dout  => fifo_dout,
      empty => fifo_empty,
      full  => fifo_full,
      wr    => fifo_wr,
      rd    => fifo_rd,
      clr   => '0');

end architecture arch;
