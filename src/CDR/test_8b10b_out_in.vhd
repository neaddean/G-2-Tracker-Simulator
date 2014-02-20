

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed."+";
use ieee.std_logic_signed."=";

entity test_8b10b_out_in is
  
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    trig    : in  std_logic;
    d8b     : out std_logic_vector(7 downto 0);
    k       : out std_logic;
    K28     : out std_logic;
    dv8b    : out std_logic;
    in_sync : out std_logic;
    test    : out std_logic
    );

end test_8b10b_out_in;

architecture arch of test_8b10b_out_in is

  component fake_TDC
    port (
      clk     : in  std_logic;
      rst_n   : in  std_logic;
      trig    : in  std_logic;
      test    : out std_logic;
      length  : in  std_logic_vector(11 downto 0);
      ser_out : out std_logic);
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
      d     : out std_logic);
  end component;

  signal serial : std_logic;
  signal rec_dv : std_logic;
  signal rec_d  : std_logic;

begin  -- arch

  fake_TDC_1 : fake_TDC
    port map (
      clk     => clk,
      rst_n   => rst_n,
      trig    => trig,
      test    => test,
      length  => X"000",
      ser_out => serial);

  datarec_1 : datarec
    port map (
      clk   => clk,
      rst_n => rst_n,
      ser   => serial,
      dv    => rec_dv,
      d     => rec_d);

  deser_8b10b_sync_1 : deser_8b10b_sync
    port map (
      clk     => clk,
      rst_n   => rst_n,
      dv      => rec_dv,
      d       => rec_d,
      d_out   => d8b,
      KO      => k,
      K28     => K28,
      in_sync => in_sync,
      dav_out => dv8b);

end arch;
