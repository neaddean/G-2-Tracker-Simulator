-------------------------------------------------------------------------------
-- c5_sender.vhd : prototype new C5 sender
--
-- inputs:
--    clk40    40MHz clock
--    rst_n    active low asynchronous reset
--       en    load a new pattern to transmit
--        B    binary code 0-15 (modified by cd, q0)
--       cd    when '1' send a control code, when '0' send a data code
--       q0    when '1' send Q0 code (all 50% pulses)
--
-- outputs:
--       c5    encoded output, update on rising clk40 edge
--    frame    indicates transmit is complete
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed."+";
use ieee.std_logic_signed."<";

entity c5_sender is

  port (
    clk40 : in  std_logic;
    rst_n : in  std_logic;
    en    : in  std_logic;
    B     : in  std_logic_vector (3 downto 0);
    cd    : in  std_logic;
    q0    : in  std_logic;
    c5    : out std_logic;
    busy  : out std_logic;
    frame : out std_logic);

end entity c5_sender;

architecture arch of c5_sender is

  component funcgen is
    port (
      cd   : in  std_logic;
      a    : in  std_logic_vector(2 downto 0);
      B    : in  std_logic_vector(3 downto 0);
      q0   : in  std_logic;
      Yout : out std_logic_vector (3 downto 0));
  end component funcgen;

  component pulsegen is
    port (
      clk40 : in  std_logic;
      rst_n : in  std_logic;
      trig  : in  std_logic;
      Yout  : in  std_logic_vector (3 downto 0);
      c5    : out std_logic);
  end component pulsegen;

  signal count  : std_logic_vector(4 downto 0);  -- modulo 20 counter
  signal busy_s : std_logic;                     -- busy state

  signal B_s  : std_logic_vector(3 downto 0);  -- latch for data
  signal cd_s : std_logic;                     -- latch for cd
  signal q0_s : std_logic;                     -- latch for q0

  signal B_i  : std_logic_vector(3 downto 0);  -- input register for data
  signal cd_i : std_logic;                     -- input register for cd
  signal q0_i : std_logic;                     -- input register for q0
  signal en_i : std_logic;                     -- input register for en

  signal q0_or : std_logic;             -- or to disable outputs when idle

  signal pulse_seq : std_logic_vector(3 downto 0);  -- pulse sequence vector
  signal every4    : std_logic;                     -- pulse every 4 clocks

begin  -- architecture arch

  busy <= busy_s;

  -----------------------------------------------------------------------------
  -- handle the main timing cycle
  -- when in idle state (busy_s=0):
  --   count cycles 0-3 with Q0 forced t '1'
  --   outputs normal width pulses
  -- when en='1' seen
  --   set en_i = '1'
  --   wait for end of pulse cycle (count[1:0]="11")
  --   set busy_s='1' to start a new pulse with input data
  -- when busy='1'
  --   count to 19, output pulses from function generator
  -----------------------------------------------------------------------------
  process (clk40, rst_n) is
  begin  -- process
    if rst_n = '0' then                     -- asynchronous reset (active low)
      count  <= (others => '0');
      busy_s <= '0';
    elsif clk40'event and clk40 = '1' then  -- rising clock edge

      frame <= '0';

      -- generate pulse every 4 counts
      if count(1 downto 0) = "10" then
        every4 <= '1';
      else
        every4 <= '0';
      end if;

      -- trigger when not busy on en=1
      if en = '1' and busy_s = '0' then
        en_i <= '1';                    -- note pending enable
        B_i  <= b;                      -- capture inputs
        cd_i <= cd;
        q0_i <= q0;
      end if;

      -- at end of pulse cycle, transfer inputs to active register
      -- and start new cycle
      if every4 = '1' then
        if en_i = '1' then              -- pending enable
          en_i   <= '0';                -- yes, clear it
          busy_s <= '1';                -- set busy on
          B_s    <= B_i;                -- move inputs to active register
          cd_s   <= cd_i;
          q0_s   <= q0_i;
        end if;
      end if;

      -- if busy, go through 20-clock cycle
      if busy_s = '1' then

        if count = "10010" then         -- assert frame at count=18

        end if;

        if count = "10011" then         -- end cycle at count=19
          busy_s <= '0';
          count <= (others => '0');
          frame <= '1';
        else
          count <= count + 1;
        end if;

      else
        -- if not busy, go through 4-clock cycle
        if count(1 downto 0) = "11" then
          count <= (others => '0');
        else
          count <= count + 1;
        end if;
      end if;

    end if;
  end process;

  -- busy=0 forces q0=1
  q0_or <= (not busy_s) or q0_s;

  -- connect up the other blocks
  funcgen_1 : entity work.funcgen
    port map (
      cd   => cd_s,
      a    => count(4 downto 2),
      B    => B_s,
      q0   => q0_or,
      Yout => pulse_seq);

  pulsegen_1 : entity work.pulsegen
    port map (
      clk40 => clk40,
      rst_n => rst_n,
      trig  => every4,
      Yout  => pulse_seq,
      c5    => c5);

end architecture arch;
