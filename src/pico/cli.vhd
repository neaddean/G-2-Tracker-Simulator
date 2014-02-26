--
-------------------------------------------------------------------------------------------
-- Copyright © 2010-2013, Xilinx, Inc.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
-------------------------------------------------------------------------------------------
--
-- Disclaimer:
-- This disclaimer is not a license and does not grant any rights to the materials
-- distributed herewith. Except as otherwise provided in a valid license issued to
-- you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
-- MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
-- DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
-- INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
-- OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
-- (whether in contract or tort, including negligence, or under any other theory
-- of liability) for any loss or damage of any kind or nature related to, arising
-- under or in connection with these materials, including for any direct, or any
-- indirect, special, incidental, or consequential loss or damage (including loss
-- of data, profits, goodwill, or any type of loss or damage suffered as a result
-- of any action brought by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-safe, or for use in any
-- application requiring fail-safe performance, such as life-support or safety
-- devices or systems, Class III medical devices, nuclear facilities, applications
-- related to the deployment of airbags, or any other applications that could lead
-- to death, personal injury, or severe property or environmental damage
-- (individually and collectively, "Critical Applications"). Customer assumes the
-- sole risk and liability of any use of Xilinx products in Critical Applications,
-- subject only to applicable laws and regulations governing limitations on product
-- liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------------------
--
--
-- Definition of a program memory for KCPSM6 including generic parameters for the 
-- convenient selection of device family, program memory size and the ability to include 
-- the JTAG Loader hardware for rapid software development.
--
-- This file is primarily for use during code development and it is recommended that the 
-- appropriate simplified program memory definition be used in a final production design. 
--
--    Generic                  Values             Comments
--    Parameter                Supported
--  
--    C_FAMILY                 "S6"               Spartan-6 device
--                             "V6"               Virtex-6 device
--                             "7S"               7-Series device 
--                                                  (Artix-7, Kintex-7, Virtex-7 or Zynq)
--
--    C_RAM_SIZE_KWORDS        1, 2 or 4          Size of program memory in K-instructions
--
--    C_JTAG_LOADER_ENABLE     0 or 1             Set to '1' to include JTAG Loader
--
-- Notes
--
-- If your design contains MULTIPLE KCPSM6 instances then only one should have the 
-- JTAG Loader enabled at a time (i.e. make sure that C_JTAG_LOADER_ENABLE is only set to 
-- '1' on one instance of the program memory). Advanced users may be interested to know 
-- that it is possible to connect JTAG Loader to multiple memories and then to use the 
-- JTAG Loader utility to specify which memory contents are to be modified. However, 
-- this scheme does require some effort to set up and the additional connectivity of the 
-- multiple BRAMs can impact the placement, routing and performance of the complete 
-- design. Please contact the author at Xilinx for more detailed information. 
--
-- Regardless of the size of program memory specified by C_RAM_SIZE_KWORDS, the complete 
-- 12-bit address bus is connected to KCPSM6. This enables the generic to be modified 
-- without requiring changes to the fundamental hardware definition. However, when the 
-- program memory is 1K then only the lower 10-bits of the address are actually used and 
-- the valid address range is 000 to 3FF hex. Likewise, for a 2K program only the lower 
-- 11-bits of the address are actually used and the valid address range is 000 to 7FF hex.
--
-- Programs are stored in Block Memory (BRAM) and the number of BRAM used depends on the 
-- size of the program and the device family. 
--
-- In a Spartan-6 device a BRAM is capable of holding 1K instructions. Hence a 2K program 
-- will require 2 BRAMs to be used and a 4K program will require 4 BRAMs to be used. It 
-- should be noted that a 4K program is not such a natural fit in a Spartan-6 device and 
-- the implementation also requires a small amount of logic resulting in slightly lower 
-- performance. A Spartan-6 BRAM can also be split into two 9k-bit memories suggesting 
-- that a program containing up to 512 instructions could be implemented. However, there 
-- is a silicon errata which makes this unsuitable and therefore it is not supported by 
-- this file.
--
-- In a Virtex-6 or any 7-Series device a BRAM is capable of holding 2K instructions so 
-- obviously a 2K program requires only a single BRAM. Each BRAM can also be divided into 
-- 2 smaller memories supporting programs of 1K in half of a 36k-bit BRAM (generally 
-- reported as being an 18k-bit BRAM). For a program of 4K instructions, 2 BRAMs are used.
--
--
-- Program defined by 'Z:\home\dean\public_html\Xilinx\testpulses\src\pico\cli.psm'.
--
-- Generated by KCPSM6 Assembler: 24 Feb 2014 - 12:27:01. 
--
-- Assembler used ROM_form template: ROM_form_JTAGLoader_14March13.vhd
--
-- Standard IEEE libraries
--
--
package jtag_loader_pkg is
 function addr_width_calc (size_in_k: integer) return integer;
end jtag_loader_pkg;
--
package body jtag_loader_pkg is
  function addr_width_calc (size_in_k: integer) return integer is
   begin
    if (size_in_k = 1) then return 10;
      elsif (size_in_k = 2) then return 11;
      elsif (size_in_k = 4) then return 12;
      else report "Invalid BlockRAM size. Please set to 1, 2 or 4 K words." severity FAILURE;
    end if;
    return 0;
  end function addr_width_calc;
end package body;
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.jtag_loader_pkg.ALL;
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--  
library unisim;
use unisim.vcomponents.all;
--
--
entity cli is
  generic(             C_FAMILY : string := "S6"; 
              C_RAM_SIZE_KWORDS : integer := 1;
           C_JTAG_LOADER_ENABLE : integer := 0);
  Port (      address : in std_logic_vector(11 downto 0);
          instruction : out std_logic_vector(17 downto 0);
               enable : in std_logic;
                  rdl : out std_logic;                    
                  clk : in std_logic);
  end cli;
--
architecture low_level_definition of cli is
--
signal       address_a : std_logic_vector(15 downto 0);
signal        pipe_a11 : std_logic;
signal       data_in_a : std_logic_vector(35 downto 0);
signal      data_out_a : std_logic_vector(35 downto 0);
signal    data_out_a_l : std_logic_vector(35 downto 0);
signal    data_out_a_h : std_logic_vector(35 downto 0);
signal   data_out_a_ll : std_logic_vector(35 downto 0);
signal   data_out_a_lh : std_logic_vector(35 downto 0);
signal   data_out_a_hl : std_logic_vector(35 downto 0);
signal   data_out_a_hh : std_logic_vector(35 downto 0);
signal       address_b : std_logic_vector(15 downto 0);
signal       data_in_b : std_logic_vector(35 downto 0);
signal     data_in_b_l : std_logic_vector(35 downto 0);
signal    data_in_b_ll : std_logic_vector(35 downto 0);
signal    data_in_b_hl : std_logic_vector(35 downto 0);
signal      data_out_b : std_logic_vector(35 downto 0);
signal    data_out_b_l : std_logic_vector(35 downto 0);
signal   data_out_b_ll : std_logic_vector(35 downto 0);
signal   data_out_b_hl : std_logic_vector(35 downto 0);
signal     data_in_b_h : std_logic_vector(35 downto 0);
signal    data_in_b_lh : std_logic_vector(35 downto 0);
signal    data_in_b_hh : std_logic_vector(35 downto 0);
signal    data_out_b_h : std_logic_vector(35 downto 0);
signal   data_out_b_lh : std_logic_vector(35 downto 0);
signal   data_out_b_hh : std_logic_vector(35 downto 0);
signal        enable_b : std_logic;
signal           clk_b : std_logic;
signal            we_b : std_logic_vector(7 downto 0);
signal          we_b_l : std_logic_vector(3 downto 0);
signal          we_b_h : std_logic_vector(3 downto 0);
-- 
signal       jtag_addr : std_logic_vector(11 downto 0);
signal         jtag_we : std_logic;
signal       jtag_we_l : std_logic;
signal       jtag_we_h : std_logic;
signal        jtag_clk : std_logic;
signal        jtag_din : std_logic_vector(17 downto 0);
signal       jtag_dout : std_logic_vector(17 downto 0);
signal     jtag_dout_1 : std_logic_vector(17 downto 0);
signal         jtag_en : std_logic_vector(0 downto 0);
-- 
signal picoblaze_reset : std_logic_vector(0 downto 0);
signal         rdl_bus : std_logic_vector(0 downto 0);
--
constant BRAM_ADDRESS_WIDTH  : integer := addr_width_calc(C_RAM_SIZE_KWORDS);
--
--
component jtag_loader_6
generic(                C_JTAG_LOADER_ENABLE : integer := 1;
                                    C_FAMILY : string  := "V6";
                             C_NUM_PICOBLAZE : integer := 1;
                       C_BRAM_MAX_ADDR_WIDTH : integer := 10;
          C_PICOBLAZE_INSTRUCTION_DATA_WIDTH : integer := 18;
                                C_JTAG_CHAIN : integer := 2;
                              C_ADDR_WIDTH_0 : integer := 10;
                              C_ADDR_WIDTH_1 : integer := 10;
                              C_ADDR_WIDTH_2 : integer := 10;
                              C_ADDR_WIDTH_3 : integer := 10;
                              C_ADDR_WIDTH_4 : integer := 10;
                              C_ADDR_WIDTH_5 : integer := 10;
                              C_ADDR_WIDTH_6 : integer := 10;
                              C_ADDR_WIDTH_7 : integer := 10);
port(              picoblaze_reset : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                           jtag_en : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                          jtag_din : out STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                         jtag_addr : out STD_LOGIC_VECTOR(C_BRAM_MAX_ADDR_WIDTH-1 downto 0);
                          jtag_clk : out std_logic;
                           jtag_we : out std_logic;
                       jtag_dout_0 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_1 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_2 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_3 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_4 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_5 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_6 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_7 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0));
end component;
--
begin
  --
  --  
  ram_1k_generate : if (C_RAM_SIZE_KWORDS = 1) generate
 
    s6: if (C_FAMILY = "S6") generate 
      --
      address_a(13 downto 0) <= address(9 downto 0) & "0000";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "0000000000000000000000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "0000";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB16BWER
      generic map ( DATA_WIDTH_A => 18,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 18,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"90005000D008900020069000D008DF029F04900020021000D004900023310091",
                    INIT_01 => X"003100205000D00290005000D01090005000D00490005000D02090005000D001",
                    INIT_02 => X"400E100050000030400E10010300E02E0031001043064306430643060300E02E",
                    INIT_03 => X"1000A042D010100AA03F902AA042D010100AA03F9011A042D00AA03F90305000",
                    INIT_04 => X"1137310F01009207204DE04DD2411237420E420E420E420E020050005000400E",
                    INIT_05 => X"0002110AD1010002110D5000D1010002D20100020043500091072054E054D141",
                    INIT_06 => X"1710500020663B001A01D1010002206ED1004BA05000D101113E00025000D101",
                    INIT_07 => X"D6030085560150000085D6035601160260709701007D4C004D06D603368006C0",
                    INIT_08 => X"113A115611201149114C11435000608798012087184050000085D603008536FE",
                    INIT_09 => X"0043100100661A8A1B00B001B03100A76094BB00BE009F011BFF1EFF1FFF1100",
                    INIT_0A => X"5480040040064006B02C5000F023F020100050000062005BD1010002D2010002",
                    INIT_0B => X"10005000D00810FF5000C040A01011011401C040A01011011401C040A0101130",
                    INIT_0C => X"005B005590045000D0091000D00910FF5000006FAC001001AD00102C5000D008",
                    INIT_0D => X"900400F40055103C1801A7001001A600102C20DB1620170020D7D001B0235000",
                    INIT_0E => X"5000005BD0011058500060DEB7009601005B60DE380318010055900360EC3001",
                    INIT_0F => X"1B025000D0E0B02C5000D0E05010B02C500060F59F011FFF5000DF021F00D0E2",
                    INIT_10 => X"005B21013B001A03005B21013B001A01D1010002210FD1FF210BD1004BA01A14",
                    INIT_11 => X"0043A030D00110200002D001103A0002D1010002D20100020043003013005000",
                    INIT_12 => X"01885000005B2112005B611ED003300313010030212DD3FFD1010002D2010002",
                    INIT_13 => X"11011401C040A010112C144050000188030502B60210B12BB227A139D004B023",
                    INIT_14 => X"1401C040A01011011401C040A010112C14445000C040A01011011401C040A010",
                    INIT_15 => X"11661166117511425000D00910005000D00910FF500000915000C040A0101101",
                    INIT_16 => X"113A1174116E1175116F1163112011641172116F115711001120113A11721165",
                    INIT_17 => X"112011201120113A11731165117A11691173112011641172116F115711001120",
                    INIT_18 => X"0002E194C120B220110000661A5C1B011100112011641172116F115711001120",
                    INIT_19 => X"D1010002D201000200430020D00110280002D00110200002218D1101D001A010",
                    INIT_1A => X"1300B423D1010002D20100020043B023000200661A651B01005BD00110290002",
                    INIT_1B => X"D1010002D20100020043A01001301124D00110400002D00110200002E1C2C340",
                    INIT_1C => X"A01001301128D00110200002E1D7C3401300B42300661A721B01005B21B01301",
                    INIT_1D => X"00661A821B01005BE1FAC3401300B423005B21C81301D1010002D20100020043",
                    INIT_1E => X"16030650152C4506450613010530D00110200002D1010002D201000200430030",
                    INIT_1F => X"11565000D020B02C5000005B21F09601D1010002D20100020043A060A1DAC650",
                    INIT_20 => X"D20100020043100100661AFF1B0111001120113A116E116F1169117311721165",
                    INIT_21 => X"116D112F1101110011671172116111691174116C1175116D5000005BD1010002",
                    INIT_22 => X"11011100117411651173116511721111110111001170116D11751164116D1165",
                    INIT_23 => X"11011100117311791173110911021100116E116F116911731172116511761154",
                    INIT_24 => X"11AB11001100116311C211001100116411FF110011001170116C116511681188",
                    INIT_25 => X"11BC110011001161115911011100116D115611011100116E11C8110011001173",
                    INIT_26 => X"11001100114311431147110111001174113A11011100117011BF11001100117A",
                    INIT_27 => X"1100115211D111001100114411CD11001100114611FC110011001144114311F8",
                    INIT_28 => X"B02022B2D1FF22A5D1004BA012001A141B0211FF11FC11011100114D11F01100",
                    INIT_29 => X"3B001A0122A1D10022B2D1FF4BA0228A3B001A0112016299C010A020E299C200",
                    INIT_2A => X"00A742104BA03B001A0102104BA03B001A01030502B6228A12003B001A032299",
                    INIT_2B => X"9201E2B800311201A020E2E0C210B120F02310005000006202ED00A750000062",
                    INIT_2C => X"22D5C3200310A2CEC310B12013080320E21001001123F02322E0D0051001B023",
                    INIT_2D => X"22B8E30090011028B0238300A01091011124B123032022CE1201E2D50031A020",
                    INIT_2E => X"00661AE11B0211001164116E1161116D116D116F116311201164116111425000",
                    INIT_2F => X"00020043002000661AF21B0211001120113A1172116F1172117211455000005B",
                    INIT_30 => X"C400B0231400A308C1201101E0101000112C120412385000005BD1010002D201",
                    INIT_31 => X"C650A30E96021401172C4706470607400650A61001401128A50000401024E330",
                    INIT_32 => X"230EE0700031A060630EC6501601231D1701E070001E9601A1601601A260A329",
                    INIT_33 => X"1176114F233182870350E348D120F1201101B120E0101100B120900100065000",
                    INIT_34 => X"2331006200A7005B00661A3E1B03005B110011211177116F116C116611721165",
                    INIT_35 => X"400C1000F0209001B020E361D120236DD1082366D10A2366D10DA1009001B020",
                    INIT_36 => X"A37C9002B0205000400C1001F0209001B020005B5000400C1000D10100025000",
                    INIT_37 => X"1000F0209001B020F0209001B020D10111080002D10111200002D10111080002",
                    INIT_38 => X"000000000000000000000000000000000000000000000000000000005000400C",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A2A0D960296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B20B0A",
                   INITP_01 => X"28A0B4A2A8B5B18C280420D2A288A10A28A16160052A2AAA882AD502AAAB62A8",
                   INITP_02 => X"AAAAAAAAAAAAAAAAAAA28AA161602858580AA434AAB44DAA88A2AA82A5A5ADD8",
                   INITP_03 => X"A8A9AA8D45522AA882D0A6AA122D0829AA848A2D0AA8A0A2AA88A298B420AAAA",
                   INITP_04 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA882AAAA",
                   INITP_05 => X"A20AAAAA82AAAAAAA5114278D34492D479348AAAA9496A165DDA574D37602AAA",
                   INITP_06 => X"249228A2D249292A49377744AA82AAAAABB6490AA8D6691375544413435812AA",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000009")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a(31 downto 0),
                  DOPA => data_out_a(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b(31 downto 0),
                  DOPB => data_out_b(35 downto 32), 
                   DIB => data_in_b(31 downto 0),
                  DIPB => data_in_b(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --               
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a(13 downto 0) <= address(9 downto 0) & "1111";
      instruction <= data_out_a(17 downto 0);
      data_in_a(17 downto 0) <= "0000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(17 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b(17 downto 0) <= data_out_b(17 downto 0);
        address_b(13 downto 0) <= "11111111111111";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b(17 downto 0) <= jtag_din(17 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "1111";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      -- 
      kcpsm6_rom: RAMB18E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => "000000000000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"90005000D008900020069000D008DF029F04900020021000D004900023310091",
                    INIT_01 => X"003100205000D00290005000D01090005000D00490005000D02090005000D001",
                    INIT_02 => X"400E100050000030400E10010300E02E0031001043064306430643060300E02E",
                    INIT_03 => X"1000A042D010100AA03F902AA042D010100AA03F9011A042D00AA03F90305000",
                    INIT_04 => X"1137310F01009207204DE04DD2411237420E420E420E420E020050005000400E",
                    INIT_05 => X"0002110AD1010002110D5000D1010002D20100020043500091072054E054D141",
                    INIT_06 => X"1710500020663B001A01D1010002206ED1004BA05000D101113E00025000D101",
                    INIT_07 => X"D6030085560150000085D6035601160260709701007D4C004D06D603368006C0",
                    INIT_08 => X"113A115611201149114C11435000608798012087184050000085D603008536FE",
                    INIT_09 => X"0043100100661A8A1B00B001B03100A76094BB00BE009F011BFF1EFF1FFF1100",
                    INIT_0A => X"5480040040064006B02C5000F023F020100050000062005BD1010002D2010002",
                    INIT_0B => X"10005000D00810FF5000C040A01011011401C040A01011011401C040A0101130",
                    INIT_0C => X"005B005590045000D0091000D00910FF5000006FAC001001AD00102C5000D008",
                    INIT_0D => X"900400F40055103C1801A7001001A600102C20DB1620170020D7D001B0235000",
                    INIT_0E => X"5000005BD0011058500060DEB7009601005B60DE380318010055900360EC3001",
                    INIT_0F => X"1B025000D0E0B02C5000D0E05010B02C500060F59F011FFF5000DF021F00D0E2",
                    INIT_10 => X"005B21013B001A03005B21013B001A01D1010002210FD1FF210BD1004BA01A14",
                    INIT_11 => X"0043A030D00110200002D001103A0002D1010002D20100020043003013005000",
                    INIT_12 => X"01885000005B2112005B611ED003300313010030212DD3FFD1010002D2010002",
                    INIT_13 => X"11011401C040A010112C144050000188030502B60210B12BB227A139D004B023",
                    INIT_14 => X"1401C040A01011011401C040A010112C14445000C040A01011011401C040A010",
                    INIT_15 => X"11661166117511425000D00910005000D00910FF500000915000C040A0101101",
                    INIT_16 => X"113A1174116E1175116F1163112011641172116F115711001120113A11721165",
                    INIT_17 => X"112011201120113A11731165117A11691173112011641172116F115711001120",
                    INIT_18 => X"0002E194C120B220110000661A5C1B011100112011641172116F115711001120",
                    INIT_19 => X"D1010002D201000200430020D00110280002D00110200002218D1101D001A010",
                    INIT_1A => X"1300B423D1010002D20100020043B023000200661A651B01005BD00110290002",
                    INIT_1B => X"D1010002D20100020043A01001301124D00110400002D00110200002E1C2C340",
                    INIT_1C => X"A01001301128D00110200002E1D7C3401300B42300661A721B01005B21B01301",
                    INIT_1D => X"00661A821B01005BE1FAC3401300B423005B21C81301D1010002D20100020043",
                    INIT_1E => X"16030650152C4506450613010530D00110200002D1010002D201000200430030",
                    INIT_1F => X"11565000D020B02C5000005B21F09601D1010002D20100020043A060A1DAC650",
                    INIT_20 => X"D20100020043100100661AFF1B0111001120113A116E116F1169117311721165",
                    INIT_21 => X"116D112F1101110011671172116111691174116C1175116D5000005BD1010002",
                    INIT_22 => X"11011100117411651173116511721111110111001170116D11751164116D1165",
                    INIT_23 => X"11011100117311791173110911021100116E116F116911731172116511761154",
                    INIT_24 => X"11AB11001100116311C211001100116411FF110011001170116C116511681188",
                    INIT_25 => X"11BC110011001161115911011100116D115611011100116E11C8110011001173",
                    INIT_26 => X"11001100114311431147110111001174113A11011100117011BF11001100117A",
                    INIT_27 => X"1100115211D111001100114411CD11001100114611FC110011001144114311F8",
                    INIT_28 => X"B02022B2D1FF22A5D1004BA012001A141B0211FF11FC11011100114D11F01100",
                    INIT_29 => X"3B001A0122A1D10022B2D1FF4BA0228A3B001A0112016299C010A020E299C200",
                    INIT_2A => X"00A742104BA03B001A0102104BA03B001A01030502B6228A12003B001A032299",
                    INIT_2B => X"9201E2B800311201A020E2E0C210B120F02310005000006202ED00A750000062",
                    INIT_2C => X"22D5C3200310A2CEC310B12013080320E21001001123F02322E0D0051001B023",
                    INIT_2D => X"22B8E30090011028B0238300A01091011124B123032022CE1201E2D50031A020",
                    INIT_2E => X"00661AE11B0211001164116E1161116D116D116F116311201164116111425000",
                    INIT_2F => X"00020043002000661AF21B0211001120113A1172116F1172117211455000005B",
                    INIT_30 => X"C400B0231400A308C1201101E0101000112C120412385000005BD1010002D201",
                    INIT_31 => X"C650A30E96021401172C4706470607400650A61001401128A50000401024E330",
                    INIT_32 => X"230EE0700031A060630EC6501601231D1701E070001E9601A1601601A260A329",
                    INIT_33 => X"1176114F233182870350E348D120F1201101B120E0101100B120900100065000",
                    INIT_34 => X"2331006200A7005B00661A3E1B03005B110011211177116F116C116611721165",
                    INIT_35 => X"400C1000F0209001B020E361D120236DD1082366D10A2366D10DA1009001B020",
                    INIT_36 => X"A37C9002B0205000400C1001F0209001B020005B5000400C1000D10100025000",
                    INIT_37 => X"1000F0209001B020F0209001B020D10111080002D10111200002D10111080002",
                    INIT_38 => X"000000000000000000000000000000000000000000000000000000005000400C",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A2A0D960296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B20B0A",
                   INITP_01 => X"28A0B4A2A8B5B18C280420D2A288A10A28A16160052A2AAA882AD502AAAB62A8",
                   INITP_02 => X"AAAAAAAAAAAAAAAAAAA28AA161602858580AA434AAB44DAA88A2AA82A5A5ADD8",
                   INITP_03 => X"A8A9AA8D45522AA882D0A6AA122D0829AA848A2D0AA8A0A2AA88A298B420AAAA",
                   INITP_04 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA882AAAA",
                   INITP_05 => X"A20AAAAA82AAAAAAA5114278D34492D479348AAAA9496A165DDA574D37602AAA",
                   INITP_06 => X"249228A2D249292A49377744AA82AAAAABB6490AA8D6691375544413435812AA",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000009")
      port map(   ADDRARDADDR => address_a(13 downto 0),
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(15 downto 0),
                      DOPADOP => data_out_a(17 downto 16), 
                        DIADI => data_in_a(15 downto 0),
                      DIPADIP => data_in_a(17 downto 16), 
                          WEA => "00",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b(13 downto 0),
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(15 downto 0),
                      DOPBDOP => data_out_b(17 downto 16), 
                        DIBDI => data_in_b(15 downto 0),
                      DIPBDIP => data_in_b(17 downto 16), 
                        WEBWE => we_b(3 downto 0),
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a(13 downto 0) <= address(9 downto 0) & "1111";
      instruction <= data_out_a(17 downto 0);
      data_in_a(17 downto 0) <= "0000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(17 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b(17 downto 0) <= data_out_b(17 downto 0);
        address_b(13 downto 0) <= "11111111111111";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b(17 downto 0) <= jtag_din(17 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "1111";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      -- 
      kcpsm6_rom: RAMB18E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => "000000000000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"90005000D008900020069000D008DF029F04900020021000D004900023310091",
                    INIT_01 => X"003100205000D00290005000D01090005000D00490005000D02090005000D001",
                    INIT_02 => X"400E100050000030400E10010300E02E0031001043064306430643060300E02E",
                    INIT_03 => X"1000A042D010100AA03F902AA042D010100AA03F9011A042D00AA03F90305000",
                    INIT_04 => X"1137310F01009207204DE04DD2411237420E420E420E420E020050005000400E",
                    INIT_05 => X"0002110AD1010002110D5000D1010002D20100020043500091072054E054D141",
                    INIT_06 => X"1710500020663B001A01D1010002206ED1004BA05000D101113E00025000D101",
                    INIT_07 => X"D6030085560150000085D6035601160260709701007D4C004D06D603368006C0",
                    INIT_08 => X"113A115611201149114C11435000608798012087184050000085D603008536FE",
                    INIT_09 => X"0043100100661A8A1B00B001B03100A76094BB00BE009F011BFF1EFF1FFF1100",
                    INIT_0A => X"5480040040064006B02C5000F023F020100050000062005BD1010002D2010002",
                    INIT_0B => X"10005000D00810FF5000C040A01011011401C040A01011011401C040A0101130",
                    INIT_0C => X"005B005590045000D0091000D00910FF5000006FAC001001AD00102C5000D008",
                    INIT_0D => X"900400F40055103C1801A7001001A600102C20DB1620170020D7D001B0235000",
                    INIT_0E => X"5000005BD0011058500060DEB7009601005B60DE380318010055900360EC3001",
                    INIT_0F => X"1B025000D0E0B02C5000D0E05010B02C500060F59F011FFF5000DF021F00D0E2",
                    INIT_10 => X"005B21013B001A03005B21013B001A01D1010002210FD1FF210BD1004BA01A14",
                    INIT_11 => X"0043A030D00110200002D001103A0002D1010002D20100020043003013005000",
                    INIT_12 => X"01885000005B2112005B611ED003300313010030212DD3FFD1010002D2010002",
                    INIT_13 => X"11011401C040A010112C144050000188030502B60210B12BB227A139D004B023",
                    INIT_14 => X"1401C040A01011011401C040A010112C14445000C040A01011011401C040A010",
                    INIT_15 => X"11661166117511425000D00910005000D00910FF500000915000C040A0101101",
                    INIT_16 => X"113A1174116E1175116F1163112011641172116F115711001120113A11721165",
                    INIT_17 => X"112011201120113A11731165117A11691173112011641172116F115711001120",
                    INIT_18 => X"0002E194C120B220110000661A5C1B011100112011641172116F115711001120",
                    INIT_19 => X"D1010002D201000200430020D00110280002D00110200002218D1101D001A010",
                    INIT_1A => X"1300B423D1010002D20100020043B023000200661A651B01005BD00110290002",
                    INIT_1B => X"D1010002D20100020043A01001301124D00110400002D00110200002E1C2C340",
                    INIT_1C => X"A01001301128D00110200002E1D7C3401300B42300661A721B01005B21B01301",
                    INIT_1D => X"00661A821B01005BE1FAC3401300B423005B21C81301D1010002D20100020043",
                    INIT_1E => X"16030650152C4506450613010530D00110200002D1010002D201000200430030",
                    INIT_1F => X"11565000D020B02C5000005B21F09601D1010002D20100020043A060A1DAC650",
                    INIT_20 => X"D20100020043100100661AFF1B0111001120113A116E116F1169117311721165",
                    INIT_21 => X"116D112F1101110011671172116111691174116C1175116D5000005BD1010002",
                    INIT_22 => X"11011100117411651173116511721111110111001170116D11751164116D1165",
                    INIT_23 => X"11011100117311791173110911021100116E116F116911731172116511761154",
                    INIT_24 => X"11AB11001100116311C211001100116411FF110011001170116C116511681188",
                    INIT_25 => X"11BC110011001161115911011100116D115611011100116E11C8110011001173",
                    INIT_26 => X"11001100114311431147110111001174113A11011100117011BF11001100117A",
                    INIT_27 => X"1100115211D111001100114411CD11001100114611FC110011001144114311F8",
                    INIT_28 => X"B02022B2D1FF22A5D1004BA012001A141B0211FF11FC11011100114D11F01100",
                    INIT_29 => X"3B001A0122A1D10022B2D1FF4BA0228A3B001A0112016299C010A020E299C200",
                    INIT_2A => X"00A742104BA03B001A0102104BA03B001A01030502B6228A12003B001A032299",
                    INIT_2B => X"9201E2B800311201A020E2E0C210B120F02310005000006202ED00A750000062",
                    INIT_2C => X"22D5C3200310A2CEC310B12013080320E21001001123F02322E0D0051001B023",
                    INIT_2D => X"22B8E30090011028B0238300A01091011124B123032022CE1201E2D50031A020",
                    INIT_2E => X"00661AE11B0211001164116E1161116D116D116F116311201164116111425000",
                    INIT_2F => X"00020043002000661AF21B0211001120113A1172116F1172117211455000005B",
                    INIT_30 => X"C400B0231400A308C1201101E0101000112C120412385000005BD1010002D201",
                    INIT_31 => X"C650A30E96021401172C4706470607400650A61001401128A50000401024E330",
                    INIT_32 => X"230EE0700031A060630EC6501601231D1701E070001E9601A1601601A260A329",
                    INIT_33 => X"1176114F233182870350E348D120F1201101B120E0101100B120900100065000",
                    INIT_34 => X"2331006200A7005B00661A3E1B03005B110011211177116F116C116611721165",
                    INIT_35 => X"400C1000F0209001B020E361D120236DD1082366D10A2366D10DA1009001B020",
                    INIT_36 => X"A37C9002B0205000400C1001F0209001B020005B5000400C1000D10100025000",
                    INIT_37 => X"1000F0209001B020F0209001B020D10111080002D10111200002D10111080002",
                    INIT_38 => X"000000000000000000000000000000000000000000000000000000005000400C",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A2A0D960296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B20B0A",
                   INITP_01 => X"28A0B4A2A8B5B18C280420D2A288A10A28A16160052A2AAA882AD502AAAB62A8",
                   INITP_02 => X"AAAAAAAAAAAAAAAAAAA28AA161602858580AA434AAB44DAA88A2AA82A5A5ADD8",
                   INITP_03 => X"A8A9AA8D45522AA882D0A6AA122D0829AA848A2D0AA8A0A2AA88A298B420AAAA",
                   INITP_04 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA882AAAA",
                   INITP_05 => X"A20AAAAA82AAAAAAA5114278D34492D479348AAAA9496A165DDA574D37602AAA",
                   INITP_06 => X"249228A2D249292A49377744AA82AAAAABB6490AA8D6691375544413435812AA",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000009")
      port map(   ADDRARDADDR => address_a(13 downto 0),
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(15 downto 0),
                      DOPADOP => data_out_a(17 downto 16), 
                        DIADI => data_in_a(15 downto 0),
                      DIPADIP => data_in_a(17 downto 16), 
                          WEA => "00",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b(13 downto 0),
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(15 downto 0),
                      DOPBDOP => data_out_b(17 downto 16), 
                        DIBDI => data_in_b(15 downto 0),
                      DIPBDIP => data_in_b(17 downto 16), 
                        WEBWE => we_b(3 downto 0),
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0');
      --
    end generate akv7;
    --
  end generate ram_1k_generate;
  --
  --
  --
  ram_2k_generate : if (C_RAM_SIZE_KWORDS = 2) generate
    --
    --
    s6: if (C_FAMILY = "S6") generate
      --
      address_a(13 downto 0) <= address(10 downto 0) & "000";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b(13 downto 0) <= jtag_addr(10 downto 0) & "000";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"3120000200001000000400002000000100000800060008020400020004003191",
                    INIT_01 => X"0042100A3F2A42100A3F11420A3F30000E0000300E01002E311006060606002E",
                    INIT_02 => X"020A01020D0001020102430007545441370F00074D4D41370E0E0E0E0000000E",
                    INIT_03 => X"038501008503010270017D00060380C0100066000101026E00A000013E020001",
                    INIT_04 => X"4301668A000131A794000001FFFFFF003A5620494C43008701874000850385FE",
                    INIT_05 => X"000008FF004010010140100101401030800006062C0023200000625B01020102",
                    INIT_06 => X"04F4553C010001002CDB2000D70123005B550400090009FF006F0001002C0008",
                    INIT_07 => X"0200E02C00E0102C00F501FF000200E2005B015800DE00015BDE03015503EC01",
                    INIT_08 => X"4330012002013A0201020102433000005B0100035B01000101020FFF0B00A014",
                    INIT_09 => X"010140102C40008805B6102B2739042388005B125B1E030301302DFF01020102",
                    INIT_0A => X"666675420009000009FF009100401001014010010140102C4400401001014010",
                    INIT_0B => X"2020203A73657A69732064726F5700203A746E756F632064726F5700203A7265",
                    INIT_0C => X"0102010243200128020120028D0101100294202000665C01002064726F570020",
                    INIT_0D => X"0102010243103024014002012002C2400023010201024323026665015B012902",
                    INIT_0E => X"6682015BFA4000235BC8010102010243103028012002D74000236672015BB001",
                    INIT_0F => X"5600202C005BF001010201024360DA5003502C06060130012002010201024330",
                    INIT_10 => X"6D2F010067726169746C756D005B01020102430166FF0100203A6E6F69737265",
                    INIT_11 => X"01007379730902006E6F69737265765401007465736572110100706D75646D65",
                    INIT_12 => X"BC0000615901006D5601006EC8000073AB000063C2000064FF0000706C656888",
                    INIT_13 => X"0052D1000044CD000046FC00004443F800004343470100743A010070BF00007A",
                    INIT_14 => X"0001A100B2FFA08A000101991020990020B2FFA500A0001402FFFC01004DF000",
                    INIT_15 => X"01B8310120E0102023000062EDA70062A710A0000110A0000105B68A00000399",
                    INIT_16 => X"B800012823001001242320CE01D53120D52010CE1020082010002323E0050123",
                    INIT_17 => X"02432066F20200203A726F727245005B66E10200646E616D6D6F632064614200",
                    INIT_18 => X"500E02012C060640501040280040243000230008200110002C0438005B010201",
                    INIT_19 => X"764F31875048202001201000200106000E7031600E50011D01701E0160016029",
                    INIT_1A => X"0C0020012061206D08660A660D0001203162A75B663E035B0021776F6C667265",
                    INIT_1B => X"002001202001200108020120020108027C0220000C012001205B000C00010200",
                    INIT_1C => X"000000000000000000000000000000000000000000000000000000000000000C",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"803602000410000801110008085BFC00004894D96A09E0000000023E00000182",
                   INITP_01 => X"82823E202E70638B8303A010800C69FFFFFFFFFFF0011108899494B8008266BE",
                   INITP_02 => X"07FC3FFE45E06F600100334496802CFFFFFFFFFFFFFFFFFFFFFFFFFFFFF203FF",
                   INITP_03 => X"0000000000000000000000000000000001B6800407FC82FFEFD889894F391C84",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_l(31 downto 0),
                  DOPA => data_out_a_l(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_l(31 downto 0),
                  DOPB => data_out_b_l(35 downto 32), 
                   DIB => data_in_b_l(31 downto 0),
                  DIPB => data_in_b_l(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      -- 
      kcpsm6_rom_h: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"000028684828684828684828684828684828684810C8686F4F48108868481100",
                    INIT_01 => X"08D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0",
                    INIT_02 => X"000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A0",
                    INIT_03 => X"6B002B28006B2B0BB0CB00A6A66B1B030B28109D8D680090E825286808002868",
                    INIT_04 => X"0008000D0D585800B0DDDFCF0D0F0F0808080808080828B0CC100C28006B001B",
                    INIT_05 => X"08286808286050888A6050888A6050082A02A0A0582878780828000068006900",
                    INIT_06 => X"480000080C53885308100B0B90E8582800004828680868082800568856082868",
                    INIT_07 => X"0D2868582868285828B0CF0F286F0F682800680828B0DBCB00B01C8C0048B018",
                    INIT_08 => X"0050680800680800680069000000092800109D8D00109D8D680090E890E8250D",
                    INIT_09 => X"888A6050080A28000101815859D0E8580028001000B0E818890090E968006900",
                    INIT_0A => X"080808082868082868082800286050888A6050888A6050080A286050888A6050",
                    INIT_0B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_0C => X"6800690000006808006808001088685000F0E05908000D0D0808080808080808",
                    INIT_0D => X"6800690000508008680800680800F0E1095A68006900005800000D0D00680800",
                    INIT_0E => X"000D0D00F0E1095A0010896800690000508008680800F0E1095A000D0D001089",
                    INIT_0F => X"08286858280010CB680069000050D0E38B038AA2A28902680800680069000000",
                    INIT_10 => X"0808080808080808080808082800680069000008000D0D080808080808080808",
                    INIT_11 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_12 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_14 => X"9D8D91E891E825119D8D89B1E050F1E15891E891E825090D0D08080808080808",
                    INIT_15 => X"C9F1008950F1E15878082800010028000021259D8D01259D8D010111099D8D11",
                    INIT_16 => X"1171C88858C150C88858011189F1005091E101D1E15889017180087891E88858",
                    INIT_17 => X"000000000D0D08080808080808082800000D0D08080808080808080808080828",
                    INIT_18 => X"E3D1CB8A8BA3A30383538008528008F1E2580AD1E08870080889092800680069",
                    INIT_19 => X"080811C101F1E878885870885848002811700050B1E38B118B7000CB508B51D1",
                    INIT_1A => X"A00878C858F1E891E891E891E850C85811000000000D0D000808080808080808",
                    INIT_1B => X"0878C85878C858680800680800680800D1C85828A00878C8580028A008680028",
                    INIT_1C => X"00000000000000000000000000000000000000000000000000000000000028A0",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"6CCDECCA6049DAC36C44077FA781FF5EDCA46777B7F60C064A552181A4924D33",
                   INITP_01 => X"EEFA017E98DF1626F8B63ECDFADAC4FFFFFFFFFFFDBC446223C4FC2FADF9CCEA",
                   INITP_02 => X"D3FF9FFFC016909864BFE2712B12547FFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9FF",
                   INITP_03 => X"00000000000000000000000000000002496D92672550F9FFFD23E9614001121F",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_h(31 downto 0),
                  DOPA => data_out_a_h(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_h(31 downto 0),
                  DOPB => data_out_b_h(35 downto 32), 
                   DIB => data_in_b_h(31 downto 0),
                  DIPB => data_in_b_h(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a <= '1' & address(10 downto 0) & "1111";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b <= '1' & jtag_addr(10 downto 0) & "1111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB36E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"90005000D008900020069000D008DF029F04900020021000D004900023310091",
                    INIT_01 => X"003100205000D00290005000D01090005000D00490005000D02090005000D001",
                    INIT_02 => X"400E100050000030400E10010300E02E0031001043064306430643060300E02E",
                    INIT_03 => X"1000A042D010100AA03F902AA042D010100AA03F9011A042D00AA03F90305000",
                    INIT_04 => X"1137310F01009207204DE04DD2411237420E420E420E420E020050005000400E",
                    INIT_05 => X"0002110AD1010002110D5000D1010002D20100020043500091072054E054D141",
                    INIT_06 => X"1710500020663B001A01D1010002206ED1004BA05000D101113E00025000D101",
                    INIT_07 => X"D6030085560150000085D6035601160260709701007D4C004D06D603368006C0",
                    INIT_08 => X"113A115611201149114C11435000608798012087184050000085D603008536FE",
                    INIT_09 => X"0043100100661A8A1B00B001B03100A76094BB00BE009F011BFF1EFF1FFF1100",
                    INIT_0A => X"5480040040064006B02C5000F023F020100050000062005BD1010002D2010002",
                    INIT_0B => X"10005000D00810FF5000C040A01011011401C040A01011011401C040A0101130",
                    INIT_0C => X"005B005590045000D0091000D00910FF5000006FAC001001AD00102C5000D008",
                    INIT_0D => X"900400F40055103C1801A7001001A600102C20DB1620170020D7D001B0235000",
                    INIT_0E => X"5000005BD0011058500060DEB7009601005B60DE380318010055900360EC3001",
                    INIT_0F => X"1B025000D0E0B02C5000D0E05010B02C500060F59F011FFF5000DF021F00D0E2",
                    INIT_10 => X"005B21013B001A03005B21013B001A01D1010002210FD1FF210BD1004BA01A14",
                    INIT_11 => X"0043A030D00110200002D001103A0002D1010002D20100020043003013005000",
                    INIT_12 => X"01885000005B2112005B611ED003300313010030212DD3FFD1010002D2010002",
                    INIT_13 => X"11011401C040A010112C144050000188030502B60210B12BB227A139D004B023",
                    INIT_14 => X"1401C040A01011011401C040A010112C14445000C040A01011011401C040A010",
                    INIT_15 => X"11661166117511425000D00910005000D00910FF500000915000C040A0101101",
                    INIT_16 => X"113A1174116E1175116F1163112011641172116F115711001120113A11721165",
                    INIT_17 => X"112011201120113A11731165117A11691173112011641172116F115711001120",
                    INIT_18 => X"0002E194C120B220110000661A5C1B011100112011641172116F115711001120",
                    INIT_19 => X"D1010002D201000200430020D00110280002D00110200002218D1101D001A010",
                    INIT_1A => X"1300B423D1010002D20100020043B023000200661A651B01005BD00110290002",
                    INIT_1B => X"D1010002D20100020043A01001301124D00110400002D00110200002E1C2C340",
                    INIT_1C => X"A01001301128D00110200002E1D7C3401300B42300661A721B01005B21B01301",
                    INIT_1D => X"00661A821B01005BE1FAC3401300B423005B21C81301D1010002D20100020043",
                    INIT_1E => X"16030650152C4506450613010530D00110200002D1010002D201000200430030",
                    INIT_1F => X"11565000D020B02C5000005B21F09601D1010002D20100020043A060A1DAC650",
                    INIT_20 => X"D20100020043100100661AFF1B0111001120113A116E116F1169117311721165",
                    INIT_21 => X"116D112F1101110011671172116111691174116C1175116D5000005BD1010002",
                    INIT_22 => X"11011100117411651173116511721111110111001170116D11751164116D1165",
                    INIT_23 => X"11011100117311791173110911021100116E116F116911731172116511761154",
                    INIT_24 => X"11AB11001100116311C211001100116411FF110011001170116C116511681188",
                    INIT_25 => X"11BC110011001161115911011100116D115611011100116E11C8110011001173",
                    INIT_26 => X"11001100114311431147110111001174113A11011100117011BF11001100117A",
                    INIT_27 => X"1100115211D111001100114411CD11001100114611FC110011001144114311F8",
                    INIT_28 => X"B02022B2D1FF22A5D1004BA012001A141B0211FF11FC11011100114D11F01100",
                    INIT_29 => X"3B001A0122A1D10022B2D1FF4BA0228A3B001A0112016299C010A020E299C200",
                    INIT_2A => X"00A742104BA03B001A0102104BA03B001A01030502B6228A12003B001A032299",
                    INIT_2B => X"9201E2B800311201A020E2E0C210B120F02310005000006202ED00A750000062",
                    INIT_2C => X"22D5C3200310A2CEC310B12013080320E21001001123F02322E0D0051001B023",
                    INIT_2D => X"22B8E30090011028B0238300A01091011124B123032022CE1201E2D50031A020",
                    INIT_2E => X"00661AE11B0211001164116E1161116D116D116F116311201164116111425000",
                    INIT_2F => X"00020043002000661AF21B0211001120113A1172116F1172117211455000005B",
                    INIT_30 => X"C400B0231400A308C1201101E0101000112C120412385000005BD1010002D201",
                    INIT_31 => X"C650A30E96021401172C4706470607400650A61001401128A50000401024E330",
                    INIT_32 => X"230EE0700031A060630EC6501601231D1701E070001E9601A1601601A260A329",
                    INIT_33 => X"1176114F233182870350E348D120F1201101B120E0101100B120900100065000",
                    INIT_34 => X"2331006200A7005B00661A3E1B03005B110011211177116F116C116611721165",
                    INIT_35 => X"400C1000F0209001B020E361D120236DD1082366D10A2366D10DA1009001B020",
                    INIT_36 => X"A37C9002B0205000400C1001F0209001B020005B5000400C1000D10100025000",
                    INIT_37 => X"1000F0209001B020F0209001B020D10111080002D10111200002D10111080002",
                    INIT_38 => X"000000000000000000000000000000000000000000000000000000005000400C",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A2A0D960296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B20B0A",
                   INITP_01 => X"28A0B4A2A8B5B18C280420D2A288A10A28A16160052A2AAA882AD502AAAB62A8",
                   INITP_02 => X"AAAAAAAAAAAAAAAAAAA28AA161602858580AA434AAB44DAA88A2AA82A5A5ADD8",
                   INITP_03 => X"A8A9AA8D45522AA882D0A6AA122D0829AA848A2D0AA8A0A2AA88A298B420AAAA",
                   INITP_04 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA882AAAA",
                   INITP_05 => X"A20AAAAA82AAAAAAA5114278D34492D479348AAAA9496A165DDA574D37602AAA",
                   INITP_06 => X"249228A2D249292A49377744AA82AAAAABB6490AA8D6691375544413435812AA",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000009",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(31 downto 0),
                      DOPADOP => data_out_a(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(31 downto 0),
                      DOPBDOP => data_out_b(35 downto 32), 
                        DIBDI => data_in_b(31 downto 0),
                      DIPBDIP => data_in_b(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a <= '1' & address(10 downto 0) & "1111";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b <= '1' & jtag_addr(10 downto 0) & "1111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB36E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"90005000D008900020069000D008DF029F04900020021000D004900023310091",
                    INIT_01 => X"003100205000D00290005000D01090005000D00490005000D02090005000D001",
                    INIT_02 => X"400E100050000030400E10010300E02E0031001043064306430643060300E02E",
                    INIT_03 => X"1000A042D010100AA03F902AA042D010100AA03F9011A042D00AA03F90305000",
                    INIT_04 => X"1137310F01009207204DE04DD2411237420E420E420E420E020050005000400E",
                    INIT_05 => X"0002110AD1010002110D5000D1010002D20100020043500091072054E054D141",
                    INIT_06 => X"1710500020663B001A01D1010002206ED1004BA05000D101113E00025000D101",
                    INIT_07 => X"D6030085560150000085D6035601160260709701007D4C004D06D603368006C0",
                    INIT_08 => X"113A115611201149114C11435000608798012087184050000085D603008536FE",
                    INIT_09 => X"0043100100661A8A1B00B001B03100A76094BB00BE009F011BFF1EFF1FFF1100",
                    INIT_0A => X"5480040040064006B02C5000F023F020100050000062005BD1010002D2010002",
                    INIT_0B => X"10005000D00810FF5000C040A01011011401C040A01011011401C040A0101130",
                    INIT_0C => X"005B005590045000D0091000D00910FF5000006FAC001001AD00102C5000D008",
                    INIT_0D => X"900400F40055103C1801A7001001A600102C20DB1620170020D7D001B0235000",
                    INIT_0E => X"5000005BD0011058500060DEB7009601005B60DE380318010055900360EC3001",
                    INIT_0F => X"1B025000D0E0B02C5000D0E05010B02C500060F59F011FFF5000DF021F00D0E2",
                    INIT_10 => X"005B21013B001A03005B21013B001A01D1010002210FD1FF210BD1004BA01A14",
                    INIT_11 => X"0043A030D00110200002D001103A0002D1010002D20100020043003013005000",
                    INIT_12 => X"01885000005B2112005B611ED003300313010030212DD3FFD1010002D2010002",
                    INIT_13 => X"11011401C040A010112C144050000188030502B60210B12BB227A139D004B023",
                    INIT_14 => X"1401C040A01011011401C040A010112C14445000C040A01011011401C040A010",
                    INIT_15 => X"11661166117511425000D00910005000D00910FF500000915000C040A0101101",
                    INIT_16 => X"113A1174116E1175116F1163112011641172116F115711001120113A11721165",
                    INIT_17 => X"112011201120113A11731165117A11691173112011641172116F115711001120",
                    INIT_18 => X"0002E194C120B220110000661A5C1B011100112011641172116F115711001120",
                    INIT_19 => X"D1010002D201000200430020D00110280002D00110200002218D1101D001A010",
                    INIT_1A => X"1300B423D1010002D20100020043B023000200661A651B01005BD00110290002",
                    INIT_1B => X"D1010002D20100020043A01001301124D00110400002D00110200002E1C2C340",
                    INIT_1C => X"A01001301128D00110200002E1D7C3401300B42300661A721B01005B21B01301",
                    INIT_1D => X"00661A821B01005BE1FAC3401300B423005B21C81301D1010002D20100020043",
                    INIT_1E => X"16030650152C4506450613010530D00110200002D1010002D201000200430030",
                    INIT_1F => X"11565000D020B02C5000005B21F09601D1010002D20100020043A060A1DAC650",
                    INIT_20 => X"D20100020043100100661AFF1B0111001120113A116E116F1169117311721165",
                    INIT_21 => X"116D112F1101110011671172116111691174116C1175116D5000005BD1010002",
                    INIT_22 => X"11011100117411651173116511721111110111001170116D11751164116D1165",
                    INIT_23 => X"11011100117311791173110911021100116E116F116911731172116511761154",
                    INIT_24 => X"11AB11001100116311C211001100116411FF110011001170116C116511681188",
                    INIT_25 => X"11BC110011001161115911011100116D115611011100116E11C8110011001173",
                    INIT_26 => X"11001100114311431147110111001174113A11011100117011BF11001100117A",
                    INIT_27 => X"1100115211D111001100114411CD11001100114611FC110011001144114311F8",
                    INIT_28 => X"B02022B2D1FF22A5D1004BA012001A141B0211FF11FC11011100114D11F01100",
                    INIT_29 => X"3B001A0122A1D10022B2D1FF4BA0228A3B001A0112016299C010A020E299C200",
                    INIT_2A => X"00A742104BA03B001A0102104BA03B001A01030502B6228A12003B001A032299",
                    INIT_2B => X"9201E2B800311201A020E2E0C210B120F02310005000006202ED00A750000062",
                    INIT_2C => X"22D5C3200310A2CEC310B12013080320E21001001123F02322E0D0051001B023",
                    INIT_2D => X"22B8E30090011028B0238300A01091011124B123032022CE1201E2D50031A020",
                    INIT_2E => X"00661AE11B0211001164116E1161116D116D116F116311201164116111425000",
                    INIT_2F => X"00020043002000661AF21B0211001120113A1172116F1172117211455000005B",
                    INIT_30 => X"C400B0231400A308C1201101E0101000112C120412385000005BD1010002D201",
                    INIT_31 => X"C650A30E96021401172C4706470607400650A61001401128A50000401024E330",
                    INIT_32 => X"230EE0700031A060630EC6501601231D1701E070001E9601A1601601A260A329",
                    INIT_33 => X"1176114F233182870350E348D120F1201101B120E0101100B120900100065000",
                    INIT_34 => X"2331006200A7005B00661A3E1B03005B110011211177116F116C116611721165",
                    INIT_35 => X"400C1000F0209001B020E361D120236DD1082366D10A2366D10DA1009001B020",
                    INIT_36 => X"A37C9002B0205000400C1001F0209001B020005B5000400C1000D10100025000",
                    INIT_37 => X"1000F0209001B020F0209001B020D10111080002D10111200002D10111080002",
                    INIT_38 => X"000000000000000000000000000000000000000000000000000000005000400C",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A2A0D960296B6A2A8A2AAA7D41F5552935DD7776484785538820820820B20B0A",
                   INITP_01 => X"28A0B4A2A8B5B18C280420D2A288A10A28A16160052A2AAA882AD502AAAB62A8",
                   INITP_02 => X"AAAAAAAAAAAAAAAAAAA28AA161602858580AA434AAB44DAA88A2AA82A5A5ADD8",
                   INITP_03 => X"A8A9AA8D45522AA882D0A6AA122D0829AA848A2D0AA8A0A2AA88A298B420AAAA",
                   INITP_04 => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA882AAAA",
                   INITP_05 => X"A20AAAAA82AAAAAAA5114278D34492D479348AAAA9496A165DDA574D37602AAA",
                   INITP_06 => X"249228A2D249292A49377744AA82AAAAABB6490AA8D6691375544413435812AA",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000009",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(31 downto 0),
                      DOPADOP => data_out_a(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(31 downto 0),
                      DOPBDOP => data_out_b(35 downto 32), 
                        DIBDI => data_in_b(31 downto 0),
                      DIPBDIP => data_in_b(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate akv7;
    --
  end generate ram_2k_generate;
  --
  --	
  ram_4k_generate : if (C_RAM_SIZE_KWORDS = 4) generate
    s6: if (C_FAMILY = "S6") generate
      --
      address_a(13 downto 0) <= address(10 downto 0) & "000";
      data_in_a <= "000000000000000000000000000000000000";
      --
      s6_a11_flop: FD
      port map (  D => address(11),
                  Q => pipe_a11,
                  C => clk);
      --
      s6_4k_mux0_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(0),
                I1 => data_out_a_hl(0),
                I2 => data_out_a_ll(1),
                I3 => data_out_a_hl(1),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(0),
                O6 => instruction(1));
      --
      s6_4k_mux2_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(2),
                I1 => data_out_a_hl(2),
                I2 => data_out_a_ll(3),
                I3 => data_out_a_hl(3),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(2),
                O6 => instruction(3));
      --
      s6_4k_mux4_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(4),
                I1 => data_out_a_hl(4),
                I2 => data_out_a_ll(5),
                I3 => data_out_a_hl(5),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(4),
                O6 => instruction(5));
      --
      s6_4k_mux6_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(6),
                I1 => data_out_a_hl(6),
                I2 => data_out_a_ll(7),
                I3 => data_out_a_hl(7),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(6),
                O6 => instruction(7));
      --
      s6_4k_mux8_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(32),
                I1 => data_out_a_hl(32),
                I2 => data_out_a_lh(0),
                I3 => data_out_a_hh(0),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(8),
                O6 => instruction(9));
      --
      s6_4k_mux10_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(1),
                I1 => data_out_a_hh(1),
                I2 => data_out_a_lh(2),
                I3 => data_out_a_hh(2),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(10),
                O6 => instruction(11));
      --
      s6_4k_mux12_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(3),
                I1 => data_out_a_hh(3),
                I2 => data_out_a_lh(4),
                I3 => data_out_a_hh(4),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(12),
                O6 => instruction(13));
      --
      s6_4k_mux14_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(5),
                I1 => data_out_a_hh(5),
                I2 => data_out_a_lh(6),
                I3 => data_out_a_hh(6),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(14),
                O6 => instruction(15));
      --
      s6_4k_mux16_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(7),
                I1 => data_out_a_hh(7),
                I2 => data_out_a_lh(32),
                I3 => data_out_a_hh(32),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(16),
                O6 => instruction(17));
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_ll <= "000" & data_out_b_ll(32) & "000000000000000000000000" & data_out_b_ll(7 downto 0);
        data_in_b_lh <= "000" & data_out_b_lh(32) & "000000000000000000000000" & data_out_b_lh(7 downto 0);
        data_in_b_hl <= "000" & data_out_b_hl(32) & "000000000000000000000000" & data_out_b_hl(7 downto 0);
        data_in_b_hh <= "000" & data_out_b_hh(32) & "000000000000000000000000" & data_out_b_hh(7 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b_l(3 downto 0) <= "0000";
        we_b_h(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
        jtag_dout <= data_out_b_lh(32) & data_out_b_lh(7 downto 0) & data_out_b_ll(32) & data_out_b_ll(7 downto 0);
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_lh <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_ll <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        data_in_b_hh <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_hl <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b(13 downto 0) <= jtag_addr(10 downto 0) & "000";
        --
        s6_4k_jtag_we_lut: LUT6_2
        generic map (INIT => X"8000000020000000")
        port map( I0 => jtag_we,
                  I1 => jtag_addr(11),
                  I2 => '1',
                  I3 => '1',
                  I4 => '1',
                  I5 => '1',
                  O5 => jtag_we_l,
                  O6 => jtag_we_h);
        --
        we_b_l(3 downto 0) <= jtag_we_l & jtag_we_l & jtag_we_l & jtag_we_l;
        we_b_h(3 downto 0) <= jtag_we_h & jtag_we_h & jtag_we_h & jtag_we_h;
        --
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
        --
        s6_4k_jtag_mux0_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(0),
                  I1 => data_out_b_hl(0),
                  I2 => data_out_b_ll(1),
                  I3 => data_out_b_hl(1),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(0),
                  O6 => jtag_dout(1));
        --
        s6_4k_jtag_mux2_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(2),
                  I1 => data_out_b_hl(2),
                  I2 => data_out_b_ll(3),
                  I3 => data_out_b_hl(3),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(2),
                  O6 => jtag_dout(3));
        --
        s6_4k_jtag_mux4_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(4),
                  I1 => data_out_b_hl(4),
                  I2 => data_out_b_ll(5),
                  I3 => data_out_b_hl(5),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(4),
                  O6 => jtag_dout(5));
        --
        s6_4k_jtag_mux6_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(6),
                  I1 => data_out_b_hl(6),
                  I2 => data_out_b_ll(7),
                  I3 => data_out_b_hl(7),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(6),
                  O6 => jtag_dout(7));
        --
        s6_4k_jtag_mux8_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(32),
                  I1 => data_out_b_hl(32),
                  I2 => data_out_b_lh(0),
                  I3 => data_out_b_hh(0),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(8),
                  O6 => jtag_dout(9));
        --
        s6_4k_jtag_mux10_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(1),
                  I1 => data_out_b_hh(1),
                  I2 => data_out_b_lh(2),
                  I3 => data_out_b_hh(2),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(10),
                  O6 => jtag_dout(11));
        --
        s6_4k_jtag_mux12_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(3),
                  I1 => data_out_b_hh(3),
                  I2 => data_out_b_lh(4),
                  I3 => data_out_b_hh(4),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(12),
                  O6 => jtag_dout(13));
        --
        s6_4k_jtag_mux14_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(5),
                  I1 => data_out_b_hh(5),
                  I2 => data_out_b_lh(6),
                  I3 => data_out_b_hh(6),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(14),
                  O6 => jtag_dout(15));
        --
        s6_4k_jtag_mux16_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(7),
                  I1 => data_out_b_hh(7),
                  I2 => data_out_b_lh(32),
                  I3 => data_out_b_hh(32),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(16),
                  O6 => jtag_dout(17));
      --
      end generate loader;
      --
      kcpsm6_rom_ll: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"3120000200001000000400002000000100000800060008020400020004003191",
                    INIT_01 => X"0042100A3F2A42100A3F11420A3F30000E0000300E01002E311006060606002E",
                    INIT_02 => X"020A01020D0001020102430007545441370F00074D4D41370E0E0E0E0000000E",
                    INIT_03 => X"038501008503010270017D00060380C0100066000101026E00A000013E020001",
                    INIT_04 => X"4301668A000131A794000001FFFFFF003A5620494C43008701874000850385FE",
                    INIT_05 => X"000008FF004010010140100101401030800006062C0023200000625B01020102",
                    INIT_06 => X"04F4553C010001002CDB2000D70123005B550400090009FF006F0001002C0008",
                    INIT_07 => X"0200E02C00E0102C00F501FF000200E2005B015800DE00015BDE03015503EC01",
                    INIT_08 => X"4330012002013A0201020102433000005B0100035B01000101020FFF0B00A014",
                    INIT_09 => X"010140102C40008805B6102B2739042388005B125B1E030301302DFF01020102",
                    INIT_0A => X"666675420009000009FF009100401001014010010140102C4400401001014010",
                    INIT_0B => X"2020203A73657A69732064726F5700203A746E756F632064726F5700203A7265",
                    INIT_0C => X"0102010243200128020120028D0101100294202000665C01002064726F570020",
                    INIT_0D => X"0102010243103024014002012002C2400023010201024323026665015B012902",
                    INIT_0E => X"6682015BFA4000235BC8010102010243103028012002D74000236672015BB001",
                    INIT_0F => X"5600202C005BF001010201024360DA5003502C06060130012002010201024330",
                    INIT_10 => X"6D2F010067726169746C756D005B01020102430166FF0100203A6E6F69737265",
                    INIT_11 => X"01007379730902006E6F69737265765401007465736572110100706D75646D65",
                    INIT_12 => X"BC0000615901006D5601006EC8000073AB000063C2000064FF0000706C656888",
                    INIT_13 => X"0052D1000044CD000046FC00004443F800004343470100743A010070BF00007A",
                    INIT_14 => X"0001A100B2FFA08A000101991020990020B2FFA500A0001402FFFC01004DF000",
                    INIT_15 => X"01B8310120E0102023000062EDA70062A710A0000110A0000105B68A00000399",
                    INIT_16 => X"B800012823001001242320CE01D53120D52010CE1020082010002323E0050123",
                    INIT_17 => X"02432066F20200203A726F727245005B66E10200646E616D6D6F632064614200",
                    INIT_18 => X"500E02012C060640501040280040243000230008200110002C0438005B010201",
                    INIT_19 => X"764F31875048202001201000200106000E7031600E50011D01701E0160016029",
                    INIT_1A => X"0C0020012061206D08660A660D0001203162A75B663E035B0021776F6C667265",
                    INIT_1B => X"002001202001200108020120020108027C0220000C012001205B000C00010200",
                    INIT_1C => X"000000000000000000000000000000000000000000000000000000000000000C",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"803602000410000801110008085BFC00004894D96A09E0000000023E00000182",
                   INITP_01 => X"82823E202E70638B8303A010800C69FFFFFFFFFFF0011108899494B8008266BE",
                   INITP_02 => X"07FC3FFE45E06F600100334496802CFFFFFFFFFFFFFFFFFFFFFFFFFFFFF203FF",
                   INITP_03 => X"0000000000000000000000000000000001B6800407FC82FFEFD889894F391C84",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_ll(31 downto 0),
                  DOPA => data_out_a_ll(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_ll(31 downto 0),
                  DOPB => data_out_b_ll(35 downto 32), 
                   DIB => data_in_b_ll(31 downto 0),
                  DIPB => data_in_b_ll(35 downto 32), 
                   WEB => we_b_l(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      -- 
      kcpsm6_rom_lh: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"000028684828684828684828684828684828684810C8686F4F48108868481100",
                    INIT_01 => X"08D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0",
                    INIT_02 => X"000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A0",
                    INIT_03 => X"6B002B28006B2B0BB0CB00A6A66B1B030B28109D8D680090E825286808002868",
                    INIT_04 => X"0008000D0D585800B0DDDFCF0D0F0F0808080808080828B0CC100C28006B001B",
                    INIT_05 => X"08286808286050888A6050888A6050082A02A0A0582878780828000068006900",
                    INIT_06 => X"480000080C53885308100B0B90E8582800004828680868082800568856082868",
                    INIT_07 => X"0D2868582868285828B0CF0F286F0F682800680828B0DBCB00B01C8C0048B018",
                    INIT_08 => X"0050680800680800680069000000092800109D8D00109D8D680090E890E8250D",
                    INIT_09 => X"888A6050080A28000101815859D0E8580028001000B0E818890090E968006900",
                    INIT_0A => X"080808082868082868082800286050888A6050888A6050080A286050888A6050",
                    INIT_0B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_0C => X"6800690000006808006808001088685000F0E05908000D0D0808080808080808",
                    INIT_0D => X"6800690000508008680800680800F0E1095A68006900005800000D0D00680800",
                    INIT_0E => X"000D0D00F0E1095A0010896800690000508008680800F0E1095A000D0D001089",
                    INIT_0F => X"08286858280010CB680069000050D0E38B038AA2A28902680800680069000000",
                    INIT_10 => X"0808080808080808080808082800680069000008000D0D080808080808080808",
                    INIT_11 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_12 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_14 => X"9D8D91E891E825119D8D89B1E050F1E15891E891E825090D0D08080808080808",
                    INIT_15 => X"C9F1008950F1E15878082800010028000021259D8D01259D8D010111099D8D11",
                    INIT_16 => X"1171C88858C150C88858011189F1005091E101D1E15889017180087891E88858",
                    INIT_17 => X"000000000D0D08080808080808082800000D0D08080808080808080808080828",
                    INIT_18 => X"E3D1CB8A8BA3A30383538008528008F1E2580AD1E08870080889092800680069",
                    INIT_19 => X"080811C101F1E878885870885848002811700050B1E38B118B7000CB508B51D1",
                    INIT_1A => X"A00878C858F1E891E891E891E850C85811000000000D0D000808080808080808",
                    INIT_1B => X"0878C85878C858680800680800680800D1C85828A00878C8580028A008680028",
                    INIT_1C => X"00000000000000000000000000000000000000000000000000000000000028A0",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"6CCDECCA6049DAC36C44077FA781FF5EDCA46777B7F60C064A552181A4924D33",
                   INITP_01 => X"EEFA017E98DF1626F8B63ECDFADAC4FFFFFFFFFFFDBC446223C4FC2FADF9CCEA",
                   INITP_02 => X"D3FF9FFFC016909864BFE2712B12547FFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9FF",
                   INITP_03 => X"00000000000000000000000000000002496D92672550F9FFFD23E9614001121F",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_lh(31 downto 0),
                  DOPA => data_out_a_lh(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_lh(31 downto 0),
                  DOPB => data_out_b_lh(35 downto 32), 
                   DIB => data_in_b_lh(31 downto 0),
                  DIPB => data_in_b_lh(35 downto 32), 
                   WEB => we_b_l(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      --
      kcpsm6_rom_hl: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_hl(31 downto 0),
                  DOPA => data_out_a_hl(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_hl(31 downto 0),
                  DOPB => data_out_b_hl(35 downto 32), 
                   DIB => data_in_b_hl(31 downto 0),
                  DIPB => data_in_b_hl(35 downto 32), 
                   WEB => we_b_h(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      -- 
      kcpsm6_rom_hh: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_hh(31 downto 0),
                  DOPA => data_out_a_hh(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_hh(31 downto 0),
                  DOPB => data_out_b_hh(35 downto 32), 
                   DIB => data_in_b_hh(31 downto 0),
                  DIPB => data_in_b_hh(35 downto 32), 
                   WEB => we_b_h(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a <= '1' & address(11 downto 0) & "111";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "000000000000000000000000000000000000";
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b <= '1' & jtag_addr(11 downto 0) & "111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"3120000200001000000400002000000100000800060008020400020004003191",
                    INIT_01 => X"0042100A3F2A42100A3F11420A3F30000E0000300E01002E311006060606002E",
                    INIT_02 => X"020A01020D0001020102430007545441370F00074D4D41370E0E0E0E0000000E",
                    INIT_03 => X"038501008503010270017D00060380C0100066000101026E00A000013E020001",
                    INIT_04 => X"4301668A000131A794000001FFFFFF003A5620494C43008701874000850385FE",
                    INIT_05 => X"000008FF004010010140100101401030800006062C0023200000625B01020102",
                    INIT_06 => X"04F4553C010001002CDB2000D70123005B550400090009FF006F0001002C0008",
                    INIT_07 => X"0200E02C00E0102C00F501FF000200E2005B015800DE00015BDE03015503EC01",
                    INIT_08 => X"4330012002013A0201020102433000005B0100035B01000101020FFF0B00A014",
                    INIT_09 => X"010140102C40008805B6102B2739042388005B125B1E030301302DFF01020102",
                    INIT_0A => X"666675420009000009FF009100401001014010010140102C4400401001014010",
                    INIT_0B => X"2020203A73657A69732064726F5700203A746E756F632064726F5700203A7265",
                    INIT_0C => X"0102010243200128020120028D0101100294202000665C01002064726F570020",
                    INIT_0D => X"0102010243103024014002012002C2400023010201024323026665015B012902",
                    INIT_0E => X"6682015BFA4000235BC8010102010243103028012002D74000236672015BB001",
                    INIT_0F => X"5600202C005BF001010201024360DA5003502C06060130012002010201024330",
                    INIT_10 => X"6D2F010067726169746C756D005B01020102430166FF0100203A6E6F69737265",
                    INIT_11 => X"01007379730902006E6F69737265765401007465736572110100706D75646D65",
                    INIT_12 => X"BC0000615901006D5601006EC8000073AB000063C2000064FF0000706C656888",
                    INIT_13 => X"0052D1000044CD000046FC00004443F800004343470100743A010070BF00007A",
                    INIT_14 => X"0001A100B2FFA08A000101991020990020B2FFA500A0001402FFFC01004DF000",
                    INIT_15 => X"01B8310120E0102023000062EDA70062A710A0000110A0000105B68A00000399",
                    INIT_16 => X"B800012823001001242320CE01D53120D52010CE1020082010002323E0050123",
                    INIT_17 => X"02432066F20200203A726F727245005B66E10200646E616D6D6F632064614200",
                    INIT_18 => X"500E02012C060640501040280040243000230008200110002C0438005B010201",
                    INIT_19 => X"764F31875048202001201000200106000E7031600E50011D01701E0160016029",
                    INIT_1A => X"0C0020012061206D08660A660D0001203162A75B663E035B0021776F6C667265",
                    INIT_1B => X"002001202001200108020120020108027C0220000C012001205B000C00010200",
                    INIT_1C => X"000000000000000000000000000000000000000000000000000000000000000C",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"803602000410000801110008085BFC00004894D96A09E0000000023E00000182",
                   INITP_01 => X"82823E202E70638B8303A010800C69FFFFFFFFFFF0011108899494B8008266BE",
                   INITP_02 => X"07FC3FFE45E06F600100334496802CFFFFFFFFFFFFFFFFFFFFFFFFFFFFF203FF",
                   INITP_03 => X"0000000000000000000000000000000001B6800407FC82FFEFD889894F391C84",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_l(31 downto 0),
                      DOPADOP => data_out_a_l(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_l(31 downto 0),
                      DOPBDOP => data_out_b_l(35 downto 32), 
                        DIBDI => data_in_b_l(31 downto 0),
                      DIPBDIP => data_in_b_l(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
      kcpsm6_rom_h: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"000028684828684828684828684828684828684810C8686F4F48108868481100",
                    INIT_01 => X"08D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0",
                    INIT_02 => X"000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A0",
                    INIT_03 => X"6B002B28006B2B0BB0CB00A6A66B1B030B28109D8D680090E825286808002868",
                    INIT_04 => X"0008000D0D585800B0DDDFCF0D0F0F0808080808080828B0CC100C28006B001B",
                    INIT_05 => X"08286808286050888A6050888A6050082A02A0A0582878780828000068006900",
                    INIT_06 => X"480000080C53885308100B0B90E8582800004828680868082800568856082868",
                    INIT_07 => X"0D2868582868285828B0CF0F286F0F682800680828B0DBCB00B01C8C0048B018",
                    INIT_08 => X"0050680800680800680069000000092800109D8D00109D8D680090E890E8250D",
                    INIT_09 => X"888A6050080A28000101815859D0E8580028001000B0E818890090E968006900",
                    INIT_0A => X"080808082868082868082800286050888A6050888A6050080A286050888A6050",
                    INIT_0B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_0C => X"6800690000006808006808001088685000F0E05908000D0D0808080808080808",
                    INIT_0D => X"6800690000508008680800680800F0E1095A68006900005800000D0D00680800",
                    INIT_0E => X"000D0D00F0E1095A0010896800690000508008680800F0E1095A000D0D001089",
                    INIT_0F => X"08286858280010CB680069000050D0E38B038AA2A28902680800680069000000",
                    INIT_10 => X"0808080808080808080808082800680069000008000D0D080808080808080808",
                    INIT_11 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_12 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_14 => X"9D8D91E891E825119D8D89B1E050F1E15891E891E825090D0D08080808080808",
                    INIT_15 => X"C9F1008950F1E15878082800010028000021259D8D01259D8D010111099D8D11",
                    INIT_16 => X"1171C88858C150C88858011189F1005091E101D1E15889017180087891E88858",
                    INIT_17 => X"000000000D0D08080808080808082800000D0D08080808080808080808080828",
                    INIT_18 => X"E3D1CB8A8BA3A30383538008528008F1E2580AD1E08870080889092800680069",
                    INIT_19 => X"080811C101F1E878885870885848002811700050B1E38B118B7000CB508B51D1",
                    INIT_1A => X"A00878C858F1E891E891E891E850C85811000000000D0D000808080808080808",
                    INIT_1B => X"0878C85878C858680800680800680800D1C85828A00878C8580028A008680028",
                    INIT_1C => X"00000000000000000000000000000000000000000000000000000000000028A0",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"6CCDECCA6049DAC36C44077FA781FF5EDCA46777B7F60C064A552181A4924D33",
                   INITP_01 => X"EEFA017E98DF1626F8B63ECDFADAC4FFFFFFFFFFFDBC446223C4FC2FADF9CCEA",
                   INITP_02 => X"D3FF9FFFC016909864BFE2712B12547FFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9FF",
                   INITP_03 => X"00000000000000000000000000000002496D92672550F9FFFD23E9614001121F",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_h(31 downto 0),
                      DOPADOP => data_out_a_h(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_h(31 downto 0),
                      DOPBDOP => data_out_b_h(35 downto 32), 
                        DIBDI => data_in_b_h(31 downto 0),
                      DIPBDIP => data_in_b_h(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a <= '1' & address(11 downto 0) & "111";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "000000000000000000000000000000000000";
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b <= '1' & jtag_addr(11 downto 0) & "111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"3120000200001000000400002000000100000800060008020400020004003191",
                    INIT_01 => X"0042100A3F2A42100A3F11420A3F30000E0000300E01002E311006060606002E",
                    INIT_02 => X"020A01020D0001020102430007545441370F00074D4D41370E0E0E0E0000000E",
                    INIT_03 => X"038501008503010270017D00060380C0100066000101026E00A000013E020001",
                    INIT_04 => X"4301668A000131A794000001FFFFFF003A5620494C43008701874000850385FE",
                    INIT_05 => X"000008FF004010010140100101401030800006062C0023200000625B01020102",
                    INIT_06 => X"04F4553C010001002CDB2000D70123005B550400090009FF006F0001002C0008",
                    INIT_07 => X"0200E02C00E0102C00F501FF000200E2005B015800DE00015BDE03015503EC01",
                    INIT_08 => X"4330012002013A0201020102433000005B0100035B01000101020FFF0B00A014",
                    INIT_09 => X"010140102C40008805B6102B2739042388005B125B1E030301302DFF01020102",
                    INIT_0A => X"666675420009000009FF009100401001014010010140102C4400401001014010",
                    INIT_0B => X"2020203A73657A69732064726F5700203A746E756F632064726F5700203A7265",
                    INIT_0C => X"0102010243200128020120028D0101100294202000665C01002064726F570020",
                    INIT_0D => X"0102010243103024014002012002C2400023010201024323026665015B012902",
                    INIT_0E => X"6682015BFA4000235BC8010102010243103028012002D74000236672015BB001",
                    INIT_0F => X"5600202C005BF001010201024360DA5003502C06060130012002010201024330",
                    INIT_10 => X"6D2F010067726169746C756D005B01020102430166FF0100203A6E6F69737265",
                    INIT_11 => X"01007379730902006E6F69737265765401007465736572110100706D75646D65",
                    INIT_12 => X"BC0000615901006D5601006EC8000073AB000063C2000064FF0000706C656888",
                    INIT_13 => X"0052D1000044CD000046FC00004443F800004343470100743A010070BF00007A",
                    INIT_14 => X"0001A100B2FFA08A000101991020990020B2FFA500A0001402FFFC01004DF000",
                    INIT_15 => X"01B8310120E0102023000062EDA70062A710A0000110A0000105B68A00000399",
                    INIT_16 => X"B800012823001001242320CE01D53120D52010CE1020082010002323E0050123",
                    INIT_17 => X"02432066F20200203A726F727245005B66E10200646E616D6D6F632064614200",
                    INIT_18 => X"500E02012C060640501040280040243000230008200110002C0438005B010201",
                    INIT_19 => X"764F31875048202001201000200106000E7031600E50011D01701E0160016029",
                    INIT_1A => X"0C0020012061206D08660A660D0001203162A75B663E035B0021776F6C667265",
                    INIT_1B => X"002001202001200108020120020108027C0220000C012001205B000C00010200",
                    INIT_1C => X"000000000000000000000000000000000000000000000000000000000000000C",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"803602000410000801110008085BFC00004894D96A09E0000000023E00000182",
                   INITP_01 => X"82823E202E70638B8303A010800C69FFFFFFFFFFF0011108899494B8008266BE",
                   INITP_02 => X"07FC3FFE45E06F600100334496802CFFFFFFFFFFFFFFFFFFFFFFFFFFFFF203FF",
                   INITP_03 => X"0000000000000000000000000000000001B6800407FC82FFEFD889894F391C84",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_l(31 downto 0),
                      DOPADOP => data_out_a_l(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_l(31 downto 0),
                      DOPBDOP => data_out_b_l(35 downto 32), 
                        DIBDI => data_in_b_l(31 downto 0),
                      DIPBDIP => data_in_b_l(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
      kcpsm6_rom_h: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"000028684828684828684828684828684828684810C8686F4F48108868481100",
                    INIT_01 => X"08D0E888D0C8D0E888D0C8D0E8D0C828A0082800A00881F00000A1A1A1A101F0",
                    INIT_02 => X"000868000828680069000028C890F0E8881800C990F0E989A1A1A1A1012828A0",
                    INIT_03 => X"6B002B28006B2B0BB0CB00A6A66B1B030B28109D8D680090E825286808002868",
                    INIT_04 => X"0008000D0D585800B0DDDFCF0D0F0F0808080808080828B0CC100C28006B001B",
                    INIT_05 => X"08286808286050888A6050888A6050082A02A0A0582878780828000068006900",
                    INIT_06 => X"480000080C53885308100B0B90E8582800004828680868082800568856082868",
                    INIT_07 => X"0D2868582868285828B0CF0F286F0F682800680828B0DBCB00B01C8C0048B018",
                    INIT_08 => X"0050680800680800680069000000092800109D8D00109D8D680090E890E8250D",
                    INIT_09 => X"888A6050080A28000101815859D0E8580028001000B0E818890090E968006900",
                    INIT_0A => X"080808082868082868082800286050888A6050888A6050080A286050888A6050",
                    INIT_0B => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_0C => X"6800690000006808006808001088685000F0E05908000D0D0808080808080808",
                    INIT_0D => X"6800690000508008680800680800F0E1095A68006900005800000D0D00680800",
                    INIT_0E => X"000D0D00F0E1095A0010896800690000508008680800F0E1095A000D0D001089",
                    INIT_0F => X"08286858280010CB680069000050D0E38B038AA2A28902680800680069000000",
                    INIT_10 => X"0808080808080808080808082800680069000008000D0D080808080808080808",
                    INIT_11 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_12 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_13 => X"0808080808080808080808080808080808080808080808080808080808080808",
                    INIT_14 => X"9D8D91E891E825119D8D89B1E050F1E15891E891E825090D0D08080808080808",
                    INIT_15 => X"C9F1008950F1E15878082800010028000021259D8D01259D8D010111099D8D11",
                    INIT_16 => X"1171C88858C150C88858011189F1005091E101D1E15889017180087891E88858",
                    INIT_17 => X"000000000D0D08080808080808082800000D0D08080808080808080808080828",
                    INIT_18 => X"E3D1CB8A8BA3A30383538008528008F1E2580AD1E08870080889092800680069",
                    INIT_19 => X"080811C101F1E878885870885848002811700050B1E38B118B7000CB508B51D1",
                    INIT_1A => X"A00878C858F1E891E891E891E850C85811000000000D0D000808080808080808",
                    INIT_1B => X"0878C85878C858680800680800680800D1C85828A00878C8580028A008680028",
                    INIT_1C => X"00000000000000000000000000000000000000000000000000000000000028A0",
                    INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"6CCDECCA6049DAC36C44077FA781FF5EDCA46777B7F60C064A552181A4924D33",
                   INITP_01 => X"EEFA017E98DF1626F8B63ECDFADAC4FFFFFFFFFFFDBC446223C4FC2FADF9CCEA",
                   INITP_02 => X"D3FF9FFFC016909864BFE2712B12547FFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9FF",
                   INITP_03 => X"00000000000000000000000000000002496D92672550F9FFFD23E9614001121F",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_h(31 downto 0),
                      DOPADOP => data_out_a_h(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_h(31 downto 0),
                      DOPBDOP => data_out_b_h(35 downto 32), 
                        DIBDI => data_in_b_h(31 downto 0),
                      DIPBDIP => data_in_b_h(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate akv7;
    --
  end generate ram_4k_generate;	              
  --
  --
  --
  --
  -- JTAG Loader
  --
  instantiate_loader : if (C_JTAG_LOADER_ENABLE = 1) generate
  --
    jtag_loader_6_inst : jtag_loader_6
    generic map(              C_FAMILY => C_FAMILY,
                       C_NUM_PICOBLAZE => 1,
                  C_JTAG_LOADER_ENABLE => C_JTAG_LOADER_ENABLE,
                 C_BRAM_MAX_ADDR_WIDTH => BRAM_ADDRESS_WIDTH,
	                  C_ADDR_WIDTH_0 => BRAM_ADDRESS_WIDTH)
    port map( picoblaze_reset => rdl_bus,
                      jtag_en => jtag_en,
                     jtag_din => jtag_din,
                    jtag_addr => jtag_addr(BRAM_ADDRESS_WIDTH-1 downto 0),
                     jtag_clk => jtag_clk,
                      jtag_we => jtag_we,
                  jtag_dout_0 => jtag_dout,
                  jtag_dout_1 => jtag_dout, -- ports 1-7 are not used
                  jtag_dout_2 => jtag_dout, -- in a 1 device debug 
                  jtag_dout_3 => jtag_dout, -- session.  However, Synplify
                  jtag_dout_4 => jtag_dout, -- etc require all ports to
                  jtag_dout_5 => jtag_dout, -- be connected
                  jtag_dout_6 => jtag_dout,
                  jtag_dout_7 => jtag_dout);
    --  
  end generate instantiate_loader;
  --
end low_level_definition;
--
--
-------------------------------------------------------------------------------------------
--
-- JTAG Loader 
--
-------------------------------------------------------------------------------------------
--
--
-- JTAG Loader 6 - Version 6.00
-- Kris Chaplin 4 February 2010
-- Ken Chapman 15 August 2011 - Revised coding style
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
library unisim;
use unisim.vcomponents.all;
--
entity jtag_loader_6 is
generic(              C_JTAG_LOADER_ENABLE : integer := 1;
                                  C_FAMILY : string := "V6";
                           C_NUM_PICOBLAZE : integer := 1;
                     C_BRAM_MAX_ADDR_WIDTH : integer := 10;
        C_PICOBLAZE_INSTRUCTION_DATA_WIDTH : integer := 18;
                              C_JTAG_CHAIN : integer := 2;
                            C_ADDR_WIDTH_0 : integer := 10;
                            C_ADDR_WIDTH_1 : integer := 10;
                            C_ADDR_WIDTH_2 : integer := 10;
                            C_ADDR_WIDTH_3 : integer := 10;
                            C_ADDR_WIDTH_4 : integer := 10;
                            C_ADDR_WIDTH_5 : integer := 10;
                            C_ADDR_WIDTH_6 : integer := 10;
                            C_ADDR_WIDTH_7 : integer := 10);
port(   picoblaze_reset : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                jtag_en : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
               jtag_din : out std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0) := (others => '0');
              jtag_addr : out std_logic_vector(C_BRAM_MAX_ADDR_WIDTH-1 downto 0) := (others => '0');
               jtag_clk : out std_logic := '0';
                jtag_we : out std_logic := '0';
            jtag_dout_0 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_1 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_2 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_3 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_4 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_5 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_6 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_7 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0));
end jtag_loader_6;
--
architecture Behavioral of jtag_loader_6 is
  --
  signal num_picoblaze       : std_logic_vector(2 downto 0);
  signal picoblaze_instruction_data_width : std_logic_vector(4 downto 0);
  --
  signal drck                : std_logic;
  signal shift_clk           : std_logic;
  signal shift_din           : std_logic;
  signal shift_dout          : std_logic;
  signal shift               : std_logic;
  signal capture             : std_logic;
  --
  signal control_reg_ce      : std_logic;
  signal bram_ce             : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
  signal bus_zero            : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
  signal jtag_en_int         : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
  signal jtag_en_expanded    : std_logic_vector(7 downto 0) := (others => '0');
  signal jtag_addr_int       : std_logic_vector(C_BRAM_MAX_ADDR_WIDTH-1 downto 0);
  signal jtag_din_int        : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal control_din         : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0):= (others => '0');
  signal control_dout        : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0):= (others => '0');
  signal control_dout_int    : std_logic_vector(7 downto 0):= (others => '0');
  signal bram_dout_int       : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0) := (others => '0');
  signal jtag_we_int         : std_logic;
  signal jtag_clk_int        : std_logic;
  signal bram_ce_valid       : std_logic;
  signal din_load            : std_logic;
  --
  signal jtag_dout_0_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_1_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_2_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_3_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_4_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_5_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_6_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_7_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal picoblaze_reset_int : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
  --        
begin
  bus_zero <= (others => '0');
  --
  jtag_loader_gen: if (C_JTAG_LOADER_ENABLE = 1) generate
    --
    -- Insert BSCAN primitive for target device architecture.
    --
    BSCAN_SPARTAN6_gen: if (C_FAMILY="S6") generate
    begin
      BSCAN_BLOCK_inst : BSCAN_SPARTAN6
      generic map ( JTAG_CHAIN => C_JTAG_CHAIN)
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_SPARTAN6_gen;   
    --
    BSCAN_VIRTEX6_gen: if (C_FAMILY="V6") generate
    begin
      BSCAN_BLOCK_inst: BSCAN_VIRTEX6
      generic map(    JTAG_CHAIN => C_JTAG_CHAIN,
                    DISABLE_JTAG => FALSE)
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_VIRTEX6_gen;   
    --
    BSCAN_7SERIES_gen: if (C_FAMILY="7S") generate
    begin
      BSCAN_BLOCK_inst: BSCANE2
      generic map(    JTAG_CHAIN => C_JTAG_CHAIN,
                    DISABLE_JTAG => "FALSE")
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_7SERIES_gen;   
    --
    --
    -- Insert clock buffer to ensure reliable shift operations.
    --
    upload_clock: BUFG
    port map( I => drck,
              O => shift_clk);
    --        
    --        
    --  Shift Register      
    --        
    --
    control_reg_ce_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk = '1' then
        if (shift = '1') then
          control_reg_ce <= shift_din;
        end if;
      end if;
    end process control_reg_ce_shift;
    --        
    bram_ce_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          if(C_NUM_PICOBLAZE > 1) then
            for i in 0 to C_NUM_PICOBLAZE-2 loop
              bram_ce(i+1) <= bram_ce(i);
            end loop;
          end if;
          bram_ce(0) <= control_reg_ce;
        end if;
      end if;
    end process bram_ce_shift;
    --        
    bram_we_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          jtag_we_int <= bram_ce(C_NUM_PICOBLAZE-1);
        end if;
      end if;
    end process bram_we_shift;
    --        
    bram_a_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          for i in 0 to C_BRAM_MAX_ADDR_WIDTH-2 loop
            jtag_addr_int(i+1) <= jtag_addr_int(i);
          end loop;
          jtag_addr_int(0) <= jtag_we_int;
        end if;
      end if;
    end process bram_a_shift;
    --        
    bram_d_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (din_load = '1') then
          jtag_din_int <= bram_dout_int;
         elsif (shift = '1') then
          for i in 0 to C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-2 loop
            jtag_din_int(i+1) <= jtag_din_int(i);
          end loop;
          jtag_din_int(0) <= jtag_addr_int(C_BRAM_MAX_ADDR_WIDTH-1);
        end if;
      end if;
    end process bram_d_shift;
    --
    shift_dout <= jtag_din_int(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1);
    --
    --
    din_load_select:process (bram_ce, din_load, capture, bus_zero, control_reg_ce) 
    begin
      if ( bram_ce = bus_zero ) then
        din_load <= capture and control_reg_ce;
       else
        din_load <= capture;
      end if;
    end process din_load_select;
    --
    --
    -- Control Registers 
    --
    num_picoblaze <= conv_std_logic_vector(C_NUM_PICOBLAZE-1,3);
    picoblaze_instruction_data_width <= conv_std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1,5);
    --	
    control_registers: process(jtag_clk_int) 
    begin
      if (jtag_clk_int'event and jtag_clk_int = '1') then
        if (bram_ce_valid = '1') and (jtag_we_int = '0') and (control_reg_ce = '1') then
          case (jtag_addr_int(3 downto 0)) is 
            when "0000" => -- 0 = version - returns (7 downto 4) illustrating number of PB
                           --               and (3 downto 0) picoblaze instruction data width
                           control_dout_int <= num_picoblaze & picoblaze_instruction_data_width;
            when "0001" => -- 1 = PicoBlaze 0 reset / status
                           if (C_NUM_PICOBLAZE >= 1) then 
                            control_dout_int <= picoblaze_reset_int(0) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_0-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0010" => -- 2 = PicoBlaze 1 reset / status
                           if (C_NUM_PICOBLAZE >= 2) then 
                             control_dout_int <= picoblaze_reset_int(1) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_1-1,5) );
                            else 
                             control_dout_int <= (others => '0');
                           end if;
            when "0011" => -- 3 = PicoBlaze 2 reset / status
                           if (C_NUM_PICOBLAZE >= 3) then 
                            control_dout_int <= picoblaze_reset_int(2) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_2-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0100" => -- 4 = PicoBlaze 3 reset / status
                           if (C_NUM_PICOBLAZE >= 4) then 
                            control_dout_int <= picoblaze_reset_int(3) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_3-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0101" => -- 5 = PicoBlaze 4 reset / status
                           if (C_NUM_PICOBLAZE >= 5) then 
                            control_dout_int <= picoblaze_reset_int(4) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_4-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0110" => -- 6 = PicoBlaze 5 reset / status
                           if (C_NUM_PICOBLAZE >= 6) then 
                            control_dout_int <= picoblaze_reset_int(5) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_5-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0111" => -- 7 = PicoBlaze 6 reset / status
                           if (C_NUM_PICOBLAZE >= 7) then 
                            control_dout_int <= picoblaze_reset_int(6) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_6-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "1000" => -- 8 = PicoBlaze 7 reset / status
                           if (C_NUM_PICOBLAZE >= 8) then 
                            control_dout_int <= picoblaze_reset_int(7) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_7-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "1111" => control_dout_int <= conv_std_logic_vector(C_BRAM_MAX_ADDR_WIDTH -1,8);
            when others => control_dout_int <= (others => '1');
          end case;
        else 
          control_dout_int <= (others => '0');
        end if;
      end if;
    end process control_registers;
    -- 
    control_dout(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-8) <= control_dout_int;
    --
    pb_reset: process(jtag_clk_int) 
    begin
      if (jtag_clk_int'event and jtag_clk_int = '1') then
        if (bram_ce_valid = '1') and (jtag_we_int = '1') and (control_reg_ce = '1') then
          picoblaze_reset_int(C_NUM_PICOBLAZE-1 downto 0) <= control_din(C_NUM_PICOBLAZE-1 downto 0);
        end if;
      end if;
    end process pb_reset;    
    --
    --
    -- Assignments 
    --
    control_dout (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-9 downto 0) <= (others => '0') when (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH > 8);
    --
    -- Qualify the blockram CS signal with bscan select output
    jtag_en_int <= bram_ce when bram_ce_valid = '1' else (others => '0');
    --      
    jtag_en_expanded(C_NUM_PICOBLAZE-1 downto 0) <= jtag_en_int;
    jtag_en_expanded(7 downto C_NUM_PICOBLAZE) <= (others => '0') when (C_NUM_PICOBLAZE < 8);
    --        
    bram_dout_int <= control_dout or jtag_dout_0_masked or jtag_dout_1_masked or jtag_dout_2_masked or jtag_dout_3_masked or jtag_dout_4_masked or jtag_dout_5_masked or jtag_dout_6_masked or jtag_dout_7_masked;
    --
    control_din <= jtag_din_int;
    --        
    jtag_dout_0_masked <= jtag_dout_0 when jtag_en_expanded(0) = '1' else (others => '0');
    jtag_dout_1_masked <= jtag_dout_1 when jtag_en_expanded(1) = '1' else (others => '0');
    jtag_dout_2_masked <= jtag_dout_2 when jtag_en_expanded(2) = '1' else (others => '0');
    jtag_dout_3_masked <= jtag_dout_3 when jtag_en_expanded(3) = '1' else (others => '0');
    jtag_dout_4_masked <= jtag_dout_4 when jtag_en_expanded(4) = '1' else (others => '0');
    jtag_dout_5_masked <= jtag_dout_5 when jtag_en_expanded(5) = '1' else (others => '0');
    jtag_dout_6_masked <= jtag_dout_6 when jtag_en_expanded(6) = '1' else (others => '0');
    jtag_dout_7_masked <= jtag_dout_7 when jtag_en_expanded(7) = '1' else (others => '0');
    --
    jtag_en <= jtag_en_int;
    jtag_din <= jtag_din_int;
    jtag_addr <= jtag_addr_int;
    jtag_clk <= jtag_clk_int;
    jtag_we <= jtag_we_int;
    picoblaze_reset <= picoblaze_reset_int;
    --        
  end generate jtag_loader_gen;
--
end Behavioral;
--
--
------------------------------------------------------------------------------------
--
-- END OF FILE cli.vhd
--
------------------------------------------------------------------------------------
