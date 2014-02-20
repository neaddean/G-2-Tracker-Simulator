-------------------------------------------------------------------------------
-- rec_8b10b_top.vhd : receive 8b10b code from TDC to FIFO
--
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
    clk125     : in  std_logic;         -- system clock
    rst_n      : in  std_logic;         -- active low reset
    serial     : in  std_logic;         -- serial data in
    data_out   : out std_logic_vector(7 downto 0);  -- output data
    fifo_full  : out std_logic;         -- fifo full flag
    fifo_empty : out std_logic;         -- fifo empty flag
    k_char     : out std_logic;         -- K char at FIFO top
    locked     : out std_logic;         -- 8b10b comma aligned
    err        : out std_logic;         -- 8b10b input error
    fifo_wr    : out std_logic;         -- fifo write output for debug
    fifo_clr   : in  std_logic;         -- fifo clear
    test       : out std_logic_vector(4 downto 0);
    fifo_rd    : in  std_logic          -- fifo read strobe
    );

end entity rec_8b10b_top;


architecture arch of rec_8b10b_top is

  component data_fifo
    port (
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      rd_clk : in  std_logic;
      din    : in  std_logic_vector(8 downto 0);
      wr_en  : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(8 downto 0);
      full   : out std_logic;
      empty  : out std_logic
      );
  end component;

  component deser_8b10b_sync
    port (
      clk     : in  std_logic;
      rst_n   : in  std_logic;
      dv      : in  std_logic;
      d_out   : out std_logic_vector (7 downto 0);
      KO      : out std_logic;
      d       : in  std_logic;
      K28     : out std_logic;
      in_sync : out std_logic;
      dav_out : out std_logic);
  end component;

  component datarec
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      ser   : in  std_logic;
      dv    : out std_logic;
      test  : out std_logic_vector(4 downto 0);
      d     : out std_logic);
  end component;

  signal rec_dv : std_logic;
  signal rec_d  : std_logic;

  signal dv8b : std_logic;

  signal fifo_din  : std_logic_vector(8 downto 0);
  signal fifo_dout : std_logic_vector(8 downto 0);

  signal in_sync     : std_logic;
  signal fifo_full_s : std_logic;
  signal fifo_wr_s   : std_logic;

  signal hdr_wait : std_logic;          -- waiting for header
  signal stopped  : std_logic;          -- FIFO was once full, stopped

begin  -- architecture arch

   test(0) <= dv8b;
--   test(1) <= K28
   test(2) <= '0';
   test(3) <= '0';

  data_out <= fifo_dout(7 downto 0);
  k_char   <= fifo_dout(8);

  datarec_1 : datarec
    port map (
      clk   => clk125,
      rst_n => rst_n,
      ser   => serial,
      dv    => rec_dv,
      test  => open,
      d     => rec_d);

  deser_8b10b_sync_1 : deser_8b10b_sync
    port map (
      clk     => clk125,
      rst_n   => rst_n,
      dv      => rec_dv,
      d       => rec_d,
      d_out   => fifo_din(7 downto 0),
      KO      => fifo_din(8),
      K28     => test(1),
      in_sync => in_sync,
      dav_out => dv8b);

  fifo_wr   <= fifo_wr_s;
  fifo_wr_s <= in_sync and dv8b and not fifo_full_s and not stopped and not hdr_wait;
  fifo_full <= fifo_full_s;

  locked <= in_sync;



  data_fifo_1 : entity work.data_fifo
    port map (
      rst    => fifo_clr,
      wr_clk => clk125,
      rd_clk => clk125,
      din    => fifo_din,
      wr_en  => fifo_wr_s,
      rd_en  => fifo_rd,
      dout   => fifo_dout,
      full   => fifo_full_s,
      empty  => fifo_empty);

  -- event capture logic
  process (clk125, rst_n) is
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      hdr_wait <= '1';
      stopped  <= '0';
    elsif clk125'event and clk125 = '1' then  -- rising clock edge

      if fifo_clr = '1' then
        hdr_wait <= '1';
        stopped  <= '0';
      end if;

      if hdr_wait = '1' and fifo_din(8) = '1' and dv8b = '1' then  -- saw a K character
        hdr_wait <= '0';
      end if;

      if fifo_full_s = '1' then
        stopped <= '1';
      end if;

    end if;
  end process;

end architecture arch;
