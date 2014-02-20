----------------------------------------------------------------------------------
-- dec10b -- 8b10b decoder adapted from opencores.org project
--
-- decode 10b symbols on clk rising edge when d_in=1
-- output 8b+KO symbols on next clk rising edge
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity dec10b is
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    d_in  : in  std_logic_vector(9 downto 0);
    d_out : out std_logic_vector(7 downto 0);
    KO    : out std_logic);
end dec10b;

architecture Behavioral of dec10b is
  signal ANEB, CNED, EEI, P13, P22, P31                  : std_logic;  -- Figure 10 Signals
  signal IKA, IKB, IKC                                   : std_logic;  -- Figure 11 Signals
  signal XA, XB, XC, XD, XE                              : std_logic;  -- Figure 12 Signals
  signal OR121, OR122, OR123, OR124, OR125, OR126, OR127 : std_logic;
  signal XF, XG, XH                                      : std_logic;  -- Figure 13 Signals
  signal OR131, OR132, OR133, OR134, IOR134              : std_logic;

begin
  -- 6b Input Function (Reference: Figure 10)
  --begin
  -- One 1 and three 0's
  P13 <= (ANEB and (not d_in(2) and not d_in(3)))or
         (CNED and (not d_in(0) and not d_in(1)));

  ---- Three 1's and one 0              
  P31 <= (ANEB and d_in(2) and d_in(3))
         or (CNED and d_in(0) and d_in(1));
  ---- Two 1's and two 0's
  P22 <= (d_in(0) and d_in(1) and (not d_in(2) and not d_in(3)))
         or (d_in(2) and d_in(3) and (not d_in(0) and not d_in(1)))
         or (ANEB and CNED);
--  P31 <= (ANEB and (not d_in(3) and not d_in(4)));
  -- Intermediate term for "d_in(0) is Not Equal to d_in(1)"
  ANEB <= d_in(0) xor d_in(1);

  -- Intermediate term for "d_in(2) is Not Equal to d_in(3)"
  CNED <= d_in(2) xor d_in(3);

  -- Intermediate term for "E is Equal to I"
  EEI <= d_in(4) xnor d_in(5);

  --
  -- K Decoder - Figure 11
  --

  -- Intermediate terms
  IKA <= (d_in(2) and d_in(3) and d_in(4) and d_in(5))
         or (not d_in(2) and not d_in(3) and not d_in(4) and not d_in(5));
  IKB <= P13 and (not d_in(4) and d_in(5) and d_in(7) and d_in(8) and d_in(9));
  IKC <= P31 and (d_in(4) and not d_in(5) and not d_in(7) and not d_in(8) and not d_in(9));

  -- PROCESS: KFN; Determine K output
  KFN : process (rst_n, clk, IKA, IKB, IKC)
  begin
    if rst_n = '0' then
      KO <= '0';
    elsif clk'event and clk = '1' then
      KO <= IKA or IKB or IKC;
    end if;

  end process KFN;

  --
  -- 5b Decoder Figure 12
  --

  -- Logic to determine complimenting A,B,C,D,E,I inputs
  OR121 <= (P22 and (not d_in(0) and not d_in(2) and EEI))
           or (P13 and not d_in(4));
  OR122 <= (d_in(0) and d_in(1) and d_in(4) and d_in(5))
           or (not d_in(2) and not d_in(3) and not d_in(4) and not d_in(5))
           or (P31 and d_in(5));
  OR123 <= (P31 and d_in(5))
           or (P22 and d_in(1) and d_in(2) and EEI)
           or (P13 and d_in(3) and d_in(4) and d_in(5));
  OR124 <= (P22 and d_in(0) and d_in(2) and EEI)
           or (P13 and not d_in(4));
  OR125 <= (P13 and not d_in(4))
           or (not d_in(2) and not d_in(3) and not d_in(4) and not d_in(5))
           or (not d_in(0) and not d_in(1) and not d_in(4) and not d_in(5));
  OR126 <= (P22 and not d_in(0) and not d_in(2) and EEI)
           or (P13 and not d_in(5));
  OR127 <= (P13 and d_in(3) and d_in(4) and d_in(5))
           or (P22 and not d_in(1) and not d_in(2) and EEI);
  
  XA <= OR127
        or OR121
        or OR122;
  XB <= OR122
        or OR123
        or OR124;
  XC <= OR121
        or OR123
        or OR125;
  XD <= OR122
        or OR124
        or OR127;
  XE <= OR125
        or OR126
        or OR127;

  -- PROCESS: DEC5B; Generate and latch LS 5 decoded bits
  DEC5B : process (rst_n, clk, XA, XB, XC, XD, XE, d_in(0), d_in(1), d_in(2), d_in(3), d_in(4))
  begin
    
    if rst_n = '0' then
      d_out(0) <= '0';
      d_out(1) <= '0';
      d_out(2) <= '0';
      d_out(3) <= '0';
      d_out(4) <= '0';
    elsif clk'event and clk = '1' then
      d_out(0) <= XA xor d_in(0);       -- Least significant bit 0
      d_out(1) <= XB xor d_in(1);
      d_out(2) <= XC xor d_in(2);
      d_out(3) <= XD xor d_in(3);
      d_out(4) <= XE xor d_in(4);       -- Most significant bit 1
    end if;
  end process DEC5B;


  --
  -- 3b Decoder - Figure 13
  --

  -- Logic for complimenting F,G,H outputs
  OR131 <= (d_in(7) and d_in(8) and d_in(9))
           or (d_in(6) and d_in(8) and d_in(9))
           or (IOR134);
  OR132 <= (d_in(6) and d_in(7) and d_in(9))
           or (not d_in(6) and not d_in(7) and not d_in(8))
           or (not d_in(6) and not d_in(7) and d_in(8) and d_in(9));
  OR133 <= (not d_in(6) and not d_in(8) and not d_in(9))
           or (IOR134)
           or (not d_in(7) and not d_in(8) and not d_in(9));
  OR134 <= (not d_in(7) and not d_in(8) and not d_in(9))
           or (d_in(6) and d_in(8) and d_in(9))
           or (IOR134);
  IOR134 <= (not (d_in(8) and d_in(9)))
            and (not (not d_in(8) and not d_in(9)))
            and (not d_in(2) and not d_in(3) and not d_in(4) and not d_in(5));
  
  XF <= OR131
        or OR132;
  XG <= OR132
        or OR133;
  XH <= OR132
        or OR134;

  -- PROCESS: DEC3B; Generate and latch MS 3 decoded bits
  DEC3B : process (rst_n, clk, XF, XG, XH, d_in(6), d_in(7), d_in(8))
  begin
    if rst_n = '0' then
      d_out(5) <= '0';
      d_out(6) <= '0';
      d_out(7) <= '0';
    elsif clk'event and clk = '1' then
      d_out(5) <= XF xor d_in(6);       -- Least significant bit 7
      d_out(6) <= XG xor d_in(7);
      d_out(7) <= XH xor d_in(8);       -- Most significant bit 10          
    end if;
  end process DEC3B;

end Behavioral;

