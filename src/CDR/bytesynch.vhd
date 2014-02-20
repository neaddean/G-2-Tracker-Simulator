----------------------------------------------------------------------------------
-- bytesync.vhd : deserialize 10b stream into symbols
--
-- process incoming bits when dv=1
-- every 10 clocks, present data on q with dav_out=1
-- reset x10 count when K.28.1 seen
--
-- in_sync set =1 when K.28.1 seen
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_misc.all;

entity bytesynch is
  generic (
    M : integer := 10);                 -- bits per symbol

  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    d       : in  std_logic;
    dv      : in  std_logic;
    K       : out std_logic;
    in_sync : out std_logic;
    dav_out : out std_logic;
    q       : out std_logic_vector (M-1 downto 0));
end bytesynch;

architecture Behavioral of bytesynch is
  signal sr           : std_logic_vector(M-1 downto 0);
  signal sr1          : std_logic_vector(M-2 downto 0);  -- SR to count bits
  signal in_sync_temp : std_logic;
  signal qs           : std_logic_vector(M-1 downto 0);
begin

  shift : process (clk, rst_n)
  begin  -- process shift

    if rst_n = '0' then                 -- asynchronous reset (active low)
      sr           <= (others => '0');
      sr1          <= (others => '0');
      qs           <= (others => '0');
      in_sync      <= '0';
      dav_out      <= '0';
      in_sync_temp <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      K       <= '0';
      dav_out <= '0';
      q       <= qs;                    -- extra reg delay in q

      if dv = '1' then
        sr  <= sr(M-2 downto 0) & d;     -- shift in data
        sr1 <= sr1(M-3 downto 0) & '1';  -- shift in 1 (counter)

        if (sr(M-1 downto 0) = "0011111001" or sr(M-1 downto 0) = "1100000110") then
          for i in 0 to 9 loop
            qs(9-i) <= sr(i);
          end loop;  -- i
			 --dav_out <= '1'; -- allow K28.1 to be in the stream
          in_sync      <= '1';
          in_sync_temp <= '1';
          K            <= '1';
          sr1          <= (others => '0');
        end if;

        if sr1(M-2) = '1' then
          sr1 <= (others => '0');
          if in_sync_temp = '1' then
            for i in 0 to 9 loop
              qs(9-i) <= sr(i);
            end loop;  -- i
            dav_out <= '1';
          end if;
        end if;
        
      else
        sr  <= sr(M-1 downto 0);
        sr1 <= sr1(M-2 downto 0);
      end if;
    end if;
  end process shift;
end Behavioral;
