------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date:    11:23:34 10/17/2013 
---- Design Name: 
---- Module Name:    fullpulsegen - Behavioral 
---- Project Name: 
---- Target Devices: 
---- Tool versions: 
---- Description: 
----
---- Dependencies: 
----
---- Revision: 
---- Revision 0.01 - File Created
---- Additional Comments: 
----
------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;


library UNISIM;
use UNISIM.VComponents.all;
use work.common.all;

entity fullpulsegen is
  
  port (
    channel       : out std_logic_vector (15 downto 0);
    start_time    : in  time_array;
    do_once       : in  std_logic;
    initiate      : in  std_logic;
    CLK           : in  std_logic;
    TP6, TP7, TP9 : out std_logic;
    cperiod       : in  period;
    pulse_period  : in  period);

end fullpulsegen;

architecture Behavioral of fullpulsegen is

  signal counter      : std_logic_vector (16 downto 0) := (others => '0');
  signal enable       : std_logic                      := '0';
  signal initiate_reg : std_logic                      := '0';
  signal channel_reg  : std_logic_vector (15 downto 0) := (others => '0');
  signal start        : std_logic                      := '0';
  signal go_enable    : std_logic                      := '0';
  signal go_counter   : std_logic_vector (23 downto 0) := (others => '0');

  constant GO_CNTR_MAX : std_logic_vector (20 downto 0) := "100110001001011010000";
  --constant GO_CNTR_MAX : std_logic_vector (20 downto 0) := "111111111111111111111";
  
begin

  channel <= channel_reg;

  go_count : process (CLK)
  begin  -- process go_count
    if rising_edge(CLK) then
      if go_counter = pulse_period(2)(3 downto 0) & pulse_period(1) & pulse_period(0) then
        if initiate = '1' then
          go_enable <= '1';
        elsif initiate = '0' then
          go_enable <= '0';
        end if;
        go_counter <= (others => '0');
      else
        go_counter <= go_counter + 1;
        go_enable  <= '0';
      end if;
    end if;
  end process go_count;
 
  TP9 <= initiate;

  enable_pros : process (CLK)
  begin
    if rising_edge(CLK) then
      if go_enable = '1' or do_once = '1' then
        enable <= '1';
      elsif counter = cperiod(2)(0) & cperiod(1) & cperiod(0) then
        enable <= '0';
      else
        enable <= enable;
      end if;
    end if;
  end process;

  counter_process : process (CLK)
  begin
    if rising_edge(CLK) then
      if enable = '1' then
        if counter = cperiod(2)(0) & cperiod(1) & cperiod(0) then
          counter <= "00000000000000000";
        else
          counter <= counter + 1;
        end if;
      end if;
    end if;
  end process;

  TP6_process : process (CLK)
  begin
    if rising_edge(CLK) then
      if enable = '1' then
        if (start_time(15, 2)(0) & start_time(15, 1) & start_time(15, 0) = counter) then
          TP6 <= '1';
        elsif counter = cperiod(2)(0) & cperiod(1) & cperiod(0) then
          TP6 <= '0';
        end if;
      else
        TP6 <= '0';
      end if;
    end if;
  end process;

  TP7 <= '1' when counter(16 downto 0) = "00000000000000000" and enable = '1' else '0';
--TP6 <= '0';

  gen_pulses : for I in 0 to 15 generate
    generate_pulses : process (CLK)
    begin
      if rising_edge(CLK) then
        if enable = '1' then
          if (start_time(I, 2)(0) & start_time(I, 1) & start_time(I, 0) = counter) then
            channel_reg(I) <= '1';
          elsif counter = cperiod(2)(0) & cperiod(1) & cperiod(0) then
            channel_reg(I) <= '0';
          end if;
        else
          channel_reg(I) <= '0';
        end if;
      end if;
    end process;
  end generate gen_pulses;

end Behavioral;


