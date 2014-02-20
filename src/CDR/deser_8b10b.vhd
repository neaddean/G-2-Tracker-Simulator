----------------------------------------------------------------------------------
-- deser_8b10b_sync -- receive and decode serial 8b10b data
--
-- input data sampled on dv=1
-- decoded data on d_out, KO
-- in_sync asserted after first K.28.1 seen
-- dav_out validates output data
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity deser_8b10b_sync is
  port (clk     : in  std_logic;         -- oversampling clock
        rst_n   : in  std_logic;         -- asynchronous reset
        dv      : in  std_logic;  -- input data valid obatained from Data recovery module
        d_out   : out std_logic_vector (7 downto 0);  -- decoded data out 
        KO      : out std_logic;         --control character seen
        d       : in  std_logic;         --serial bits in 
        K28     : out std_logic;         -- K.28.1 sequence detected
        in_sync : out std_logic;         --synchronized
        dav_out : out std_logic);
end deser_8b10b_sync;

architecture Behavioral of deser_8b10b_sync is

  signal q_temp : std_logic_vector (9 downto 0);
  signal sync_dav : std_logic;

  component bytesynch
    port (
      clk     : in  std_logic;
      rst_n   : in  std_logic;
      d       : in  std_logic;
      dv      : in  std_logic;
      K       : out std_logic;
      in_sync : out std_logic;
      dav_out : out std_logic;
      q       : out std_logic_vector (9 downto 0));
  end component;

  component dec10b is
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      d_in  : in  std_logic_vector(9 downto 0);
      d_out : out std_logic_vector(7 downto 0);
      KO    : out std_logic);
  end component dec10b;
  
begin

--  delay_dv: process(clk)
--  begin 
--	 if clk'event and clk='1' then
--		dav_out <= sync_dav;
--	 end if;
--  end process delay_dv;
  dav_out <= sync_dav;

  shift : bytesynch
    port map (
      clk     => clk,
      rst_n   => rst_n,
      d       => d,
      dv      => dv,
      K       => K28,
      in_sync => in_sync,
      dav_out => sync_dav,
      q       => q_temp);

  KFN : dec10b
    port map (
      clk   => clk,
      rst_n => rst_n,
      d_in  => q_temp,
      KO    => KO,
      d_out => d_out);

end Behavioral;















