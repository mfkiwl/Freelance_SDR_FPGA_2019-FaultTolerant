library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;


entity Main is
  Port ( 
         clk                : in std_logic;
         Serial_Data       : in std_logic;
         Sync_Word          : in std_logic_vector(31 downto 0);
         Byte_Length_of_Sync_Word     : in std_logic_vector(2 downto 0);
         Packet_Length : in std_logic_vector(15 downto 0);
         Chip_Enable : in std_logic;
         
         Out_Serial_Data : out std_logic;
         Out_Lock          : out std_logic;
         Out_Data_Valid    : out std_logic;
         Out_Spectrum_inversion : out std_logic;
         Reg_Byte_Length_of_Sync_Word : out std_logic_vector(2 downto 0);
         Reg_Sync_Word : out std_logic_vector(31 downto 0)
        );
end Main;

architecture Behavioral of Main is

signal Lock : std_logic := '0';
signal Data_Valid : std_logic := '0';
signal Spectrum_inversion : std_logic := '0';

signal Flag_Sync_Word : integer range 0 to 1 := 0; -- Status Flag

-- 8 BÝT COUNTERS
signal bit8_Detector_Counter0,bit8_Detector_Counter1,bit8_Detector_Counter2,bit8_Detector_Counter3 : integer range 0 to 7 := 0;
signal bit8_Detector_Counter4,bit8_Detector_Counter5,bit8_Detector_Counter6,bit8_Detector_Counter7 : integer range 0 to 7 := 0;

signal bit8_Error_Counter0,bit8_Error_Counter1,bit8_Error_Counter2,bit8_Error_Counter3,bit8_Error_Counter4,bit8_Error_Counter5,bit8_Error_Counter6,bit8_Error_Counter7 : std_logic_vector(2 downto 0) := "000";

signal bit8_Lock_Counter : integer range 0 to 14 := 0;

-- END
-- 16 BÝT COUNTERS
signal bit16_Detector_Counter0, bit16_Detector_Counter1, bit16_Detector_Counter2, bit16_Detector_Counter3 : integer range 0 to  15 := 0;
signal bit16_Detector_Counter4, bit16_Detector_Counter5, bit16_Detector_Counter6, bit16_Detector_Counter7 : integer range 0 to  15 := 0;
signal bit16_Detector_Counter8, bit16_Detector_Counter9, bit16_Detector_Counter10,bit16_Detector_Counter11 : integer range 0 to 15 := 0;
signal bit16_Detector_Counter12,bit16_Detector_Counter13,bit16_Detector_Counter14,bit16_Detector_Counter15 : integer range 0 to 15 := 0;

signal bit16_Error_Counter0, bit16_Error_Counter1, bit16_Error_Counter2, bit16_Error_Counter3, bit16_Error_Counter4, bit16_Error_Counter5, bit16_Error_Counter6, bit16_Error_Counter7 : std_logic_vector(3 downto 0) := "0000";
signal bit16_Error_Counter8, bit16_Error_Counter9, bit16_Error_Counter10,bit16_Error_Counter11,bit16_Error_Counter12,bit16_Error_Counter13,bit16_Error_Counter14,bit16_Error_Counter15 : std_logic_vector(3 downto 0) := "0000";

signal bit16_Lock_Counter : integer range 0 to 30 := 0;

-- END
-- 24 BÝT COUNTERS
signal bit24_Detector_Counter0, bit24_Detector_Counter1, bit24_Detector_Counter2, bit24_Detector_Counter3 : integer range 0 to  23 := 0;
signal bit24_Detector_Counter4, bit24_Detector_Counter5, bit24_Detector_Counter6, bit24_Detector_Counter7 : integer range 0 to  23 := 0;
signal bit24_Detector_Counter8, bit24_Detector_Counter9, bit24_Detector_Counter10,bit24_Detector_Counter11 : integer range 0 to 23 := 0;
signal bit24_Detector_Counter12,bit24_Detector_Counter13,bit24_Detector_Counter14,bit24_Detector_Counter15 : integer range 0 to 23 := 0;
signal bit24_Detector_Counter16,bit24_Detector_Counter17,bit24_Detector_Counter18,bit24_Detector_Counter19 : integer range 0 to 23 := 0;
signal bit24_Detector_Counter20,bit24_Detector_Counter21,bit24_Detector_Counter22,bit24_Detector_Counter23 : integer range 0 to 23 := 0;

signal bit24_Error_Counter0, bit24_Error_Counter1, bit24_Error_Counter2, bit24_Error_Counter3, bit24_Error_Counter4, bit24_Error_Counter5, bit24_Error_Counter6, bit24_Error_Counter7 : std_logic_vector(4 downto 0) := "00000";
signal bit24_Error_Counter8, bit24_Error_Counter9, bit24_Error_Counter10,bit24_Error_Counter11,bit24_Error_Counter12,bit24_Error_Counter13,bit24_Error_Counter14,bit24_Error_Counter15 : std_logic_vector(4 downto 0) := "00000";
signal bit24_Error_Counter16,bit24_Error_Counter17,bit24_Error_Counter18,bit24_Error_Counter19,bit24_Error_Counter20,bit24_Error_Counter21,bit24_Error_Counter22,bit24_Error_Counter23 : std_logic_vector(4 downto 0) := "00000";

signal bit24_Lock_Counter : integer range 0 to 46 := 0;
-- END
-- 32 BÝT COUNTERS
signal Detector_Counter0,Detector_Counter1,Detector_Counter2,Detector_Counter3 : integer range 0 to 31 := 0;
signal Detector_Counter4,Detector_Counter5,Detector_Counter6,Detector_Counter7 : integer range 0 to 31 := 0;
signal Detector_Counter8,Detector_Counter9,Detector_Counter10,Detector_Counter11 : integer range 0 to 31 := 0;
signal Detector_Counter12,Detector_Counter13,Detector_Counter14,Detector_Counter15 : integer range 0 to 31 := 0;
signal Detector_Counter16,Detector_Counter17,Detector_Counter18,Detector_Counter19 : integer range 0 to 31 := 0;
signal Detector_Counter20,Detector_Counter21,Detector_Counter22,Detector_Counter23 : integer range 0 to 31 := 0;
signal Detector_Counter24,Detector_Counter25,Detector_Counter26,Detector_Counter27 : integer range 0 to 31 := 0;
signal Detector_Counter28,Detector_Counter29,Detector_Counter30,Detector_Counter31 : integer range 0 to 31 := 0;

signal Error_Counter0,Error_Counter1,Error_Counter2,Error_Counter3,Error_Counter4,Error_Counter5,Error_Counter6,Error_Counter7 : std_logic_vector(4 downto 0) := "00000";
signal Error_Counter8,Error_Counter9,Error_Counter10,Error_Counter11,Error_Counter12,Error_Counter13,Error_Counter14,Error_Counter15 : std_logic_vector(4 downto 0) := "00000";
signal Error_Counter16,Error_Counter17,Error_Counter18,Error_Counter19,Error_Counter20,Error_Counter21,Error_Counter22,Error_Counter23 : std_logic_vector(4 downto 0) := "00000";
signal Error_Counter24,Error_Counter25,Error_Counter26,Error_Counter27,Error_Counter28,Error_Counter29,Error_Counter30,Error_Counter31 : std_logic_vector(4 downto 0) := "00000";

signal Lock_Counter : integer range 0 to 62 := 0; -- Status Register for flag case 0
-- END

signal Packet_Bit_Counter : std_logic_vector(15 downto 0) := (others => '0');



signal Beginning_Clock : std_logic := '1';

begin


process(clk) -- |||||||||||| ANA DURUM BELÝRLEYÝCÝ ||||||||||||
begin
if rising_edge(clk) then
if Chip_Enable = '1' then
Reg_Byte_Length_of_Sync_Word <= Byte_Length_of_Sync_Word;
Reg_Sync_Word <= Sync_Word;
  case(Byte_Length_of_Sync_Word) is
    when "001" =>
    Lock_Counter <= 0;            
    Detector_Counter0 <=  0;
    Detector_Counter1 <=  0;
    Detector_Counter2 <=  0;
    Detector_Counter3 <=  0;
    Detector_Counter4 <=  0;
    Detector_Counter5 <=  0;
    Detector_Counter6 <=  0;
    Detector_Counter7 <=  0;
    Detector_Counter8 <=  0;
    Detector_Counter9 <=  0;
    Detector_Counter10 <= 0;
    Detector_Counter11 <= 0;
    Detector_Counter12 <= 0;
    Detector_Counter13 <= 0;
    Detector_Counter14 <= 0;
    Detector_Counter15 <= 0;
    Detector_Counter16 <= 0;
    Detector_Counter17 <= 0;
    Detector_Counter18 <= 0;
    Detector_Counter19 <= 0;
    Detector_Counter20 <= 0;
    Detector_Counter21 <= 0;
    Detector_Counter22 <= 0;
    Detector_Counter23 <= 0;
    Detector_Counter24 <= 0;
    Detector_Counter25 <= 0;
    Detector_Counter26 <= 0;
    Detector_Counter27 <= 0;
    Detector_Counter28 <= 0;
    Detector_Counter29 <= 0;
    Detector_Counter30 <= 0;
    Detector_Counter31 <= 0;
    Error_Counter0 <=  "00000";
    Error_Counter1 <=  "00000";
    Error_Counter2 <=  "00000";
    Error_Counter3 <=  "00000";
    Error_Counter4 <=  "00000";
    Error_Counter5 <=  "00000";
    Error_Counter6 <=  "00000";
    Error_Counter7 <=  "00000";
    Error_Counter8 <=  "00000";
    Error_Counter9 <=  "00000";
    Error_Counter10 <= "00000";
    Error_Counter11 <= "00000";
    Error_Counter12 <= "00000";
    Error_Counter13 <= "00000";
    Error_Counter14 <= "00000";
    Error_Counter15 <= "00000";
    Error_Counter16 <= "00000";
    Error_Counter17 <= "00000";
    Error_Counter18 <= "00000";
    Error_Counter19 <= "00000";
    Error_Counter20 <= "00000";
    Error_Counter21 <= "00000";
    Error_Counter22 <= "00000";
    Error_Counter23 <= "00000";
    Error_Counter24 <= "00000";
    Error_Counter25 <= "00000";
    Error_Counter26 <= "00000";
    Error_Counter27 <= "00000";
    Error_Counter28 <= "00000";
    Error_Counter29 <= "00000";
    Error_Counter30 <= "00000";
    Error_Counter31 <= "00000";
    bit24_Lock_Counter <= 0;            
    bit24_Detector_Counter0 <=  0;
    bit24_Detector_Counter1 <=  0;
    bit24_Detector_Counter2 <=  0;
    bit24_Detector_Counter3 <=  0;
    bit24_Detector_Counter4 <=  0;
    bit24_Detector_Counter5 <=  0;
    bit24_Detector_Counter6 <=  0;
    bit24_Detector_Counter7 <=  0;
    bit24_Detector_Counter8 <=  0;
    bit24_Detector_Counter9 <=  0;
    bit24_Detector_Counter10 <= 0;
    bit24_Detector_Counter11 <= 0;
    bit24_Detector_Counter12 <= 0;
    bit24_Detector_Counter13 <= 0;
    bit24_Detector_Counter14 <= 0;
    bit24_Detector_Counter15 <= 0;
    bit24_Detector_Counter16 <= 0;
    bit24_Detector_Counter17 <= 0;
    bit24_Detector_Counter18 <= 0;
    bit24_Detector_Counter19 <= 0;
    bit24_Detector_Counter20 <= 0;
    bit24_Detector_Counter21 <= 0;
    bit24_Detector_Counter22 <= 0;
    bit24_Detector_Counter23 <= 0;
    bit24_Error_Counter0 <=  "00000";
    bit24_Error_Counter1 <=  "00000";
    bit24_Error_Counter2 <=  "00000";
    bit24_Error_Counter3 <=  "00000";
    bit24_Error_Counter4 <=  "00000";
    bit24_Error_Counter5 <=  "00000";
    bit24_Error_Counter6 <=  "00000";
    bit24_Error_Counter7 <=  "00000";
    bit24_Error_Counter8 <=  "00000";
    bit24_Error_Counter9 <=  "00000";
    bit24_Error_Counter10 <= "00000";
    bit24_Error_Counter11 <= "00000";
    bit24_Error_Counter12 <= "00000";
    bit24_Error_Counter13 <= "00000";
    bit24_Error_Counter14 <= "00000";
    bit24_Error_Counter15 <= "00000";
    bit24_Error_Counter16 <= "00000";
    bit24_Error_Counter17 <= "00000";
    bit24_Error_Counter18 <= "00000";
    bit24_Error_Counter19 <= "00000";
    bit24_Error_Counter20 <= "00000";
    bit24_Error_Counter21 <= "00000";
    bit24_Error_Counter22 <= "00000";
    bit24_Error_Counter23 <= "00000";
    bit16_Lock_Counter <= 0;            
    bit16_Detector_Counter0 <=  0;
    bit16_Detector_Counter1 <=  0;
    bit16_Detector_Counter2 <=  0;
    bit16_Detector_Counter3 <=  0;
    bit16_Detector_Counter4 <=  0;
    bit16_Detector_Counter5 <=  0;
    bit16_Detector_Counter6 <=  0;
    bit16_Detector_Counter7 <=  0;
    bit16_Detector_Counter8 <=  0;
    bit16_Detector_Counter9 <=  0;
    bit16_Detector_Counter10 <=  0;
    bit16_Detector_Counter11 <=  0;
    bit16_Detector_Counter12 <=  0;
    bit16_Detector_Counter13 <=  0;
    bit16_Detector_Counter14 <=  0;
    bit16_Detector_Counter15 <=  0;
    bit16_Error_Counter0 <=  "0000";
    bit16_Error_Counter1 <=  "0000";
    bit16_Error_Counter2 <=  "0000";
    bit16_Error_Counter3 <=  "0000";
    bit16_Error_Counter4 <=  "0000";
    bit16_Error_Counter5 <=  "0000";
    bit16_Error_Counter6 <=  "0000";
    bit16_Error_Counter7 <=  "0000";
    bit16_Error_Counter8 <=  "0000";
    bit16_Error_Counter9 <=  "0000";
    bit16_Error_Counter10 <=  "0000";
    bit16_Error_Counter11 <=  "0000";
    bit16_Error_Counter12 <=  "0000";
    bit16_Error_Counter13 <=  "0000";
    bit16_Error_Counter14 <=  "0000";
    bit16_Error_Counter15 <=  "0000";
    case(Flag_Sync_Word) is
        when 0 =>
            case(bit8_Lock_Counter) is
                when 0 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    
                    if(Beginning_Clock = '1') then
                        Spectrum_inversion <= '0';
                        Lock <= '0';
                        Data_Valid <= '0';
                        Beginning_Clock <= '0';
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                        bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
                    
                 when 1 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1;
                    end if;
                    
                 when 2 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
                
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1;
                    end if;
                
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1;
                    end if;
                 
                 when 3 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1;
                    end if;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1;
                    end if;
                 
                 when 4 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
                    bit8_Detector_Counter4 <= bit8_Detector_Counter4 + 1;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1;
                    end if;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1;
                    end if;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             bit8_Error_Counter4 <= bit8_Error_Counter4 + 1;
                    end if;
                    
                 when 5 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
                    bit8_Detector_Counter4 <= bit8_Detector_Counter4 + 1;
                    bit8_Detector_Counter5 <= bit8_Detector_Counter5 + 1;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1;
                    end if;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1;
                    end if;
 
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             bit8_Error_Counter4 <= bit8_Error_Counter4 + 1;
                    end if;
             
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter5)) then
                             bit8_Error_Counter5 <= bit8_Error_Counter5 + 1;
                    end if;
                    
                 when 6 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
                    bit8_Detector_Counter4 <= bit8_Detector_Counter4 + 1;
                    bit8_Detector_Counter5 <= bit8_Detector_Counter5 + 1;
                    bit8_Detector_Counter6 <= bit8_Detector_Counter6 + 1;

                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             bit8_Error_Counter4 <= bit8_Error_Counter4 + 1;
                    end if;
          
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter5)) then
                             bit8_Error_Counter5 <= bit8_Error_Counter5 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter6)) then
                             bit8_Error_Counter6 <= bit8_Error_Counter6 + 1;
                    end if;

                when 7 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= 0;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
                    bit8_Detector_Counter4 <= bit8_Detector_Counter4 + 1;
                    bit8_Detector_Counter5 <= bit8_Detector_Counter5 + 1;
                    bit8_Detector_Counter6 <= bit8_Detector_Counter6 + 1;
                    bit8_Detector_Counter7 <= bit8_Detector_Counter7 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             if(bit8_Error_Counter0 < 1) then
                                bit8_Error_Counter0 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit8_Error_Counter0 > 5) then
                                bit8_Error_Counter0 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                             else
                                Lock <= '0';
                                bit8_Error_Counter0 <= "000";
                             end if;
                    else
                            if(bit8_Error_Counter0 < 2) then
                                bit8_Error_Counter0 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit8_Error_Counter0 > 6) then
                                bit8_Error_Counter0 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                            else
                                Lock <= '0';
                                bit8_Error_Counter0 <= "000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1;
                    end if;
               
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1;
                    end if;
               
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             bit8_Error_Counter4 <= bit8_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter5)) then
                             bit8_Error_Counter5 <= bit8_Error_Counter5 + 1;
                    end if;
               
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter6)) then
                             bit8_Error_Counter6 <= bit8_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter7)) then
                             bit8_Error_Counter7 <= bit8_Error_Counter7 + 1;
                    end if;
                 
                 when 8 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= 0;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
                    bit8_Detector_Counter4 <= bit8_Detector_Counter4 + 1;
                    bit8_Detector_Counter5 <= bit8_Detector_Counter5 + 1;
                    bit8_Detector_Counter6 <= bit8_Detector_Counter6 + 1;
                    bit8_Detector_Counter7 <= bit8_Detector_Counter7 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             if(bit8_Error_Counter1 < 1) then
                                bit8_Error_Counter1 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit8_Error_Counter1 > 5) then
                                bit8_Error_Counter1 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                             else
                                Lock <= '0';
                                bit8_Error_Counter1 <= "000";
                             end if;
                    else
                            if(bit8_Error_Counter1 < 2) then
                                bit8_Error_Counter1 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit8_Error_Counter1 > 6) then
                                bit8_Error_Counter1 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                            else
                                Lock <= '0';
                                bit8_Error_Counter1 <= "000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             bit8_Error_Counter4 <= bit8_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter5)) then
                             bit8_Error_Counter5 <= bit8_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter6)) then
                             bit8_Error_Counter6 <= bit8_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter7)) then
                             bit8_Error_Counter7 <= bit8_Error_Counter7 + 1;
                    end if;
                 
                 when 9 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= 0;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
                    bit8_Detector_Counter4 <= bit8_Detector_Counter4 + 1;
                    bit8_Detector_Counter5 <= bit8_Detector_Counter5 + 1;
                    bit8_Detector_Counter6 <= bit8_Detector_Counter6 + 1;
                    bit8_Detector_Counter7 <= bit8_Detector_Counter7 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1; 
                    end if;
                                                                   
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             if(bit8_Error_Counter2 < 1) then
                                bit8_Error_Counter2 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit8_Error_Counter2 > 5) then
                                bit8_Error_Counter2 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                             else
                                Lock <= '0';
                                bit8_Error_Counter2 <= "000";
                             end if;
                    else
                            if(bit8_Error_Counter2 < 2) then
                                bit8_Error_Counter2 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit8_Error_Counter2 > 6) then
                                bit8_Error_Counter2 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                            else
                                Lock <= '0';
                                bit8_Error_Counter2 <= "000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             bit8_Error_Counter4 <= bit8_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter5)) then
                             bit8_Error_Counter5 <= bit8_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter6)) then
                             bit8_Error_Counter6 <= bit8_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter7)) then
                             bit8_Error_Counter7 <= bit8_Error_Counter7 + 1;
                    end if;
                    
                 when 10 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= 0;
                    bit8_Detector_Counter4 <= bit8_Detector_Counter4 + 1;
                    bit8_Detector_Counter5 <= bit8_Detector_Counter5 + 1;
                    bit8_Detector_Counter6 <= bit8_Detector_Counter6 + 1;
                    bit8_Detector_Counter7 <= bit8_Detector_Counter7 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1; 
                    end if;
                                                                   
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             if(bit8_Error_Counter3 < 1) then
                                bit8_Error_Counter3 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit8_Error_Counter3 > 5) then
                                bit8_Error_Counter3 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                             else
                                Lock <= '0';
                                bit8_Error_Counter3 <= "000";
                             end if;
                    else
                            if(bit8_Error_Counter3 < 2) then
                                bit8_Error_Counter3 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit8_Error_Counter3 > 6) then
                                bit8_Error_Counter3 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                            else
                                Lock <= '0';
                                bit8_Error_Counter3 <= "000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             bit8_Error_Counter4 <= bit8_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter5)) then
                             bit8_Error_Counter5 <= bit8_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter6)) then
                             bit8_Error_Counter6 <= bit8_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter7)) then
                             bit8_Error_Counter7 <= bit8_Error_Counter7 + 1;
                    end if;
                 
                 when 11 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
                    bit8_Detector_Counter4 <= 0;
                    bit8_Detector_Counter5 <= bit8_Detector_Counter5 + 1;
                    bit8_Detector_Counter6 <= bit8_Detector_Counter6 + 1;
                    bit8_Detector_Counter7 <= bit8_Detector_Counter7 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1; 
                    end if;                    
                                                                   
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             if(bit8_Error_Counter4 < 1) then
                                bit8_Error_Counter4 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit8_Error_Counter4 > 5) then
                                bit8_Error_Counter4 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                             else
                                Lock <= '0';
                                bit8_Error_Counter4 <= "000";
                             end if;
                    else
                            if(bit8_Error_Counter4 < 2) then
                                bit8_Error_Counter4 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit8_Error_Counter4 > 6) then
                                bit8_Error_Counter4 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                            else
                                Lock <= '0';
                                bit8_Error_Counter4 <= "000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter5)) then
                             bit8_Error_Counter5 <= bit8_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter6)) then
                             bit8_Error_Counter6 <= bit8_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter7)) then
                             bit8_Error_Counter7 <= bit8_Error_Counter7 + 1;
                    end if;
                 
                 when 12 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
                    bit8_Detector_Counter4 <= bit8_Detector_Counter4 + 1;
                    bit8_Detector_Counter5 <= 0;
                    bit8_Detector_Counter6 <= bit8_Detector_Counter6 + 1;
                    bit8_Detector_Counter7 <= bit8_Detector_Counter7 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             bit8_Error_Counter4 <= bit8_Error_Counter4 + 1; 
                    end if;
                                                                   
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter5)) then
                             if(bit8_Error_Counter5 < 1) then
                                bit8_Error_Counter5 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit8_Error_Counter5 > 5) then
                                bit8_Error_Counter5 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                             else
                                Lock <= '0';
                                bit8_Error_Counter5 <= "000";
                             end if;
                    else
                            if(bit8_Error_Counter5 < 2) then
                                bit8_Error_Counter5 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit8_Error_Counter5 > 6) then
                                bit8_Error_Counter5 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                            else
                                Lock <= '0';
                                bit8_Error_Counter5 <= "000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter6)) then
                             bit8_Error_Counter6 <= bit8_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter7)) then
                             bit8_Error_Counter7 <= bit8_Error_Counter7 + 1;
                    end if;
                    
                 when 13 =>
                    bit8_Lock_Counter <= bit8_Lock_Counter + 1;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
                    bit8_Detector_Counter4 <= bit8_Detector_Counter4 + 1;
                    bit8_Detector_Counter5 <= bit8_Detector_Counter5 + 1;
                    bit8_Detector_Counter6 <= 0;
                    bit8_Detector_Counter7 <= bit8_Detector_Counter7 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             bit8_Error_Counter4 <= bit8_Error_Counter4 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter5)) then
                             bit8_Error_Counter5 <= bit8_Error_Counter5 + 1; 
                    end if;
                                                                   
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter6)) then
                             if(bit8_Error_Counter6 < 1) then
                                bit8_Error_Counter6 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit8_Error_Counter6 > 5) then
                                bit8_Error_Counter6 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                             else
                                Lock <= '0';
                                bit8_Error_Counter6 <= "000";
                             end if;
                    else
                            if(bit8_Error_Counter6 < 2) then
                                bit8_Error_Counter6 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit8_Error_Counter6 > 6) then
                                bit8_Error_Counter6 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                            else
                                Lock <= '0';
                                bit8_Error_Counter6 <= "000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter7)) then
                             bit8_Error_Counter7 <= bit8_Error_Counter7 + 1;
                    end if;

                 when 14 =>
                    bit8_Lock_Counter <= 7;          
                    bit8_Detector_Counter0 <= bit8_Detector_Counter0 + 1;
                    bit8_Detector_Counter1 <= bit8_Detector_Counter1 + 1;
                    bit8_Detector_Counter2 <= bit8_Detector_Counter2 + 1;
                    bit8_Detector_Counter3 <= bit8_Detector_Counter3 + 1;
                    bit8_Detector_Counter4 <= bit8_Detector_Counter4 + 1;
                    bit8_Detector_Counter5 <= bit8_Detector_Counter5 + 1;
                    bit8_Detector_Counter6 <= bit8_Detector_Counter6 + 1;
                    bit8_Detector_Counter7 <= 0;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter0)) then
                             bit8_Error_Counter0 <= bit8_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter1)) then
                             bit8_Error_Counter1 <= bit8_Error_Counter1 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter2)) then
                             bit8_Error_Counter2 <= bit8_Error_Counter2 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter3)) then
                             bit8_Error_Counter3 <= bit8_Error_Counter3 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter4)) then
                             bit8_Error_Counter4 <= bit8_Error_Counter4 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter5)) then
                             bit8_Error_Counter5 <= bit8_Error_Counter5 + 1; 
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter6)) then
                             bit8_Error_Counter6 <= bit8_Error_Counter6 + 1; 
                    end if;
                                                                   
                    if(Serial_Data /= Sync_Word(bit8_Detector_Counter7)) then
                             if(bit8_Error_Counter7 < 1) then
                                bit8_Error_Counter7 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit8_Error_Counter7 > 5) then
                                   bit8_Error_Counter7 <= "000";   
                                   Lock <= '1';                    
                                   Data_Valid <= '1';              
                                   Flag_Sync_Word <= 1;            
                                   Spectrum_inversion <= '1';      
                             else
                                Lock <= '0';
                                bit8_Error_Counter7 <= "000";
                             end if;
                    else
                            if(bit8_Error_Counter7 < 2) then
                                bit8_Error_Counter7 <= "000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit8_Error_Counter7 > 6) then
                               bit8_Error_Counter7 <= "000";   
                               Lock <= '1';                    
                               Data_Valid <= '1';              
                               Flag_Sync_Word <= 1;            
                               Spectrum_inversion <= '1';      
                            else
                                Lock <= '0';
                                bit8_Error_Counter7 <= "000";
                            end if;
                    end if;
            end case;
        when 1 =>
                if(Packet_Bit_Counter = (Packet_Length - 9)) then -- Paket Sayacý
                Data_Valid <= '0';
                Packet_Bit_Counter <= (others => '0');
                Flag_Sync_Word <= 0;
                Spectrum_inversion <= '0';
            else
                Packet_Bit_Counter <= Packet_Bit_Counter + 1;
            end if;            
            
            bit8_Lock_Counter <= 0;            
            bit8_Detector_Counter0 <=  0;
            bit8_Detector_Counter1 <=  0;
            bit8_Detector_Counter2 <=  0;
            bit8_Detector_Counter3 <=  0;
            bit8_Detector_Counter4 <=  0;
            bit8_Detector_Counter5 <=  0;
            bit8_Detector_Counter6 <=  0;
            bit8_Detector_Counter7 <=  0;
            bit8_Error_Counter0 <=  "000";
            bit8_Error_Counter1 <=  "000";
            bit8_Error_Counter2 <=  "000";
            bit8_Error_Counter3 <=  "000";
            bit8_Error_Counter4 <=  "000";
            bit8_Error_Counter5 <=  "000";
            bit8_Error_Counter6 <=  "000";
            bit8_Error_Counter7 <=  "000";
    end case;
    
    when "010" =>
    Lock_Counter <= 0;            
    Detector_Counter0 <=  0;
    Detector_Counter1 <=  0;
    Detector_Counter2 <=  0;
    Detector_Counter3 <=  0;
    Detector_Counter4 <=  0;
    Detector_Counter5 <=  0;
    Detector_Counter6 <=  0;
    Detector_Counter7 <=  0;
    Detector_Counter8 <=  0;
    Detector_Counter9 <=  0;
    Detector_Counter10 <= 0;
    Detector_Counter11 <= 0;
    Detector_Counter12 <= 0;
    Detector_Counter13 <= 0;
    Detector_Counter14 <= 0;
    Detector_Counter15 <= 0;
    Detector_Counter16 <= 0;
    Detector_Counter17 <= 0;
    Detector_Counter18 <= 0;
    Detector_Counter19 <= 0;
    Detector_Counter20 <= 0;
    Detector_Counter21 <= 0;
    Detector_Counter22 <= 0;
    Detector_Counter23 <= 0;
    Detector_Counter24 <= 0;
    Detector_Counter25 <= 0;
    Detector_Counter26 <= 0;
    Detector_Counter27 <= 0;
    Detector_Counter28 <= 0;
    Detector_Counter29 <= 0;
    Detector_Counter30 <= 0;
    Detector_Counter31 <= 0;
    Error_Counter0 <=  "00000";
    Error_Counter1 <=  "00000";
    Error_Counter2 <=  "00000";
    Error_Counter3 <=  "00000";
    Error_Counter4 <=  "00000";
    Error_Counter5 <=  "00000";
    Error_Counter6 <=  "00000";
    Error_Counter7 <=  "00000";
    Error_Counter8 <=  "00000";
    Error_Counter9 <=  "00000";
    Error_Counter10 <= "00000";
    Error_Counter11 <= "00000";
    Error_Counter12 <= "00000";
    Error_Counter13 <= "00000";
    Error_Counter14 <= "00000";
    Error_Counter15 <= "00000";
    Error_Counter16 <= "00000";
    Error_Counter17 <= "00000";
    Error_Counter18 <= "00000";
    Error_Counter19 <= "00000";
    Error_Counter20 <= "00000";
    Error_Counter21 <= "00000";
    Error_Counter22 <= "00000";
    Error_Counter23 <= "00000";
    Error_Counter24 <= "00000";
    Error_Counter25 <= "00000";
    Error_Counter26 <= "00000";
    Error_Counter27 <= "00000";
    Error_Counter28 <= "00000";
    Error_Counter29 <= "00000";
    Error_Counter30 <= "00000";
    Error_Counter31 <= "00000";
    bit24_Lock_Counter <= 0;            
    bit24_Detector_Counter0 <=  0;
    bit24_Detector_Counter1 <=  0;
    bit24_Detector_Counter2 <=  0;
    bit24_Detector_Counter3 <=  0;
    bit24_Detector_Counter4 <=  0;
    bit24_Detector_Counter5 <=  0;
    bit24_Detector_Counter6 <=  0;
    bit24_Detector_Counter7 <=  0;
    bit24_Detector_Counter8 <=  0;
    bit24_Detector_Counter9 <=  0;
    bit24_Detector_Counter10 <= 0;
    bit24_Detector_Counter11 <= 0;
    bit24_Detector_Counter12 <= 0;
    bit24_Detector_Counter13 <= 0;
    bit24_Detector_Counter14 <= 0;
    bit24_Detector_Counter15 <= 0;
    bit24_Detector_Counter16 <= 0;
    bit24_Detector_Counter17 <= 0;
    bit24_Detector_Counter18 <= 0;
    bit24_Detector_Counter19 <= 0;
    bit24_Detector_Counter20 <= 0;
    bit24_Detector_Counter21 <= 0;
    bit24_Detector_Counter22 <= 0;
    bit24_Detector_Counter23 <= 0;
    bit24_Error_Counter0 <=  "00000";
    bit24_Error_Counter1 <=  "00000";
    bit24_Error_Counter2 <=  "00000";
    bit24_Error_Counter3 <=  "00000";
    bit24_Error_Counter4 <=  "00000";
    bit24_Error_Counter5 <=  "00000";
    bit24_Error_Counter6 <=  "00000";
    bit24_Error_Counter7 <=  "00000";
    bit24_Error_Counter8 <=  "00000";
    bit24_Error_Counter9 <=  "00000";
    bit24_Error_Counter10 <= "00000";
    bit24_Error_Counter11 <= "00000";
    bit24_Error_Counter12 <= "00000";
    bit24_Error_Counter13 <= "00000";
    bit24_Error_Counter14 <= "00000";
    bit24_Error_Counter15 <= "00000";
    bit24_Error_Counter16 <= "00000";
    bit24_Error_Counter17 <= "00000";
    bit24_Error_Counter18 <= "00000";
    bit24_Error_Counter19 <= "00000";
    bit24_Error_Counter20 <= "00000";
    bit24_Error_Counter21 <= "00000";
    bit24_Error_Counter22 <= "00000";
    bit24_Error_Counter23 <= "00000";
    bit8_Lock_Counter <= 0;            
    bit8_Detector_Counter0 <=  0;
    bit8_Detector_Counter1 <=  0;
    bit8_Detector_Counter2 <=  0;
    bit8_Detector_Counter3 <=  0;
    bit8_Detector_Counter4 <=  0;
    bit8_Detector_Counter5 <=  0;
    bit8_Detector_Counter6 <=  0;
    bit8_Detector_Counter7 <=  0;
    bit8_Error_Counter0 <=  "000";
    bit8_Error_Counter1 <=  "000";
    bit8_Error_Counter2 <=  "000";
    bit8_Error_Counter3 <=  "000";
    bit8_Error_Counter4 <=  "000";
    bit8_Error_Counter5 <=  "000";
    bit8_Error_Counter6 <=  "000";
    bit8_Error_Counter7 <=  "000";


    case(Flag_Sync_Word) is
        when 0 =>
            case(bit16_Lock_Counter) is
                when 0 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    if(Beginning_Clock = '1') then
                        Spectrum_inversion <= '0';
                        Lock <= '0';
                        Data_Valid <= '0';
                        Beginning_Clock <= '0';
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                        bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                
                when 1 =>
                  bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                  bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                  bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                  
                  if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                           bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                  end if;
                  
                  if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                           bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                  end if;
                  
                when 2 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                when 3 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                
                when 4 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                when 5 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                   bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                            bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                   end if;
                   
                when 6 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                   bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                   bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                            bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                            bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                   end if;
                
                when 7 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                   bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                   bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                   bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                            bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                            bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                            bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                   end if;
                   
                when 8 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                   bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                   bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                   bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                   bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                            bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                            bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                            bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                            bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                   end if;
                   
                when 9 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                   bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                   bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                   bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                   bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                   bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                            bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                            bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                            bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                            bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                            bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                   end if;
                   
                when 10 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                   bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                   bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                   bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                   bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                   bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                   bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                            bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                            bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                            bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                            bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                            bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                            bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                   end if;
                   
                when 11 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                   bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                   bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                   bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                   bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                   bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                   bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                   bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                            bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                            bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                            bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                            bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                            bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                            bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                            bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                   end if;
                   
                when 12 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                   bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                   bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                   bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                   bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                   bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                   bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                   bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                   bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
   
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                            bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                            bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                            bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                            bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                            bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                            bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                            bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                            bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                   end if;
                   
                when 13 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                   bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                   bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                   bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                   bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                   bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                   bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                   bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                   bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                   bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                            bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                            bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                            bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                            bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                            bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                            bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                            bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                            bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                            bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                   end if;
                   
                when 14 =>
                   bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                   bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                   bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                   bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                   bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                   bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                   bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                   bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                   bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                   bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                   bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                   bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                   bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                   bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                   bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                   bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                            bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                            bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                            bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                            bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                            bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                            bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                            bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                            bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                            bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                            bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                            bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                            bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                            bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                            bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                   end if;
                   
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                            bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                   end if;

                when 15 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= 0;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             if(bit16_Error_Counter0 < 2) then
                                bit16_Error_Counter0 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter0 > 12) then
                                bit16_Error_Counter0 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                                Spectrum_inversion <= '1';
                             else
                                Lock <= '0';
                                bit16_Error_Counter0 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter0 < 3) then
                                bit16_Error_Counter0 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter0 > 13) then
                               bit16_Error_Counter0 <= "0000";   
                               Lock <= '1';                      
                               Data_Valid <= '1';                
                               Flag_Sync_Word <= 1;              
                               Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter0 <= "0000";
                            end if;
                    end if;
                    
                   if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;
                
                 when 16 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= 0;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             if(bit16_Error_Counter1 < 2) then
                                bit16_Error_Counter1 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter1 > 12) then
                                bit16_Error_Counter1 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                             else
                                Lock <= '0';
                                bit16_Error_Counter1 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter1 < 3) then
                                bit16_Error_Counter1 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter1 > 13) then
                                bit16_Error_Counter1 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter1 <= "0000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;
                 
                 when 17 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= 0;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             if(bit16_Error_Counter2 < 2) then
                                bit16_Error_Counter2 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter2 > 12) then
                                bit16_Error_Counter2 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                             else
                                Lock <= '0';
                                bit16_Error_Counter2 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter2 < 3) then
                                bit16_Error_Counter2 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter2 > 13) then
                                bit16_Error_Counter2 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter2 <= "0000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;

                 when 18 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= 0;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             if(bit16_Error_Counter3 < 2) then
                                bit16_Error_Counter3 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter3 > 12) then
                                bit16_Error_Counter3 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                             else
                                Lock <= '0';
                                bit16_Error_Counter3 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter3 < 3) then
                                bit16_Error_Counter3 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter3 > 13) then
                                bit16_Error_Counter3 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter3 <= "0000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;

                 when 19 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= 0;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             if(bit16_Error_Counter4 < 2) then
                                bit16_Error_Counter4 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter4 > 12) then
                                bit16_Error_Counter4 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                             else
                                Lock <= '0';
                                bit16_Error_Counter4 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter4 < 3) then
                                bit16_Error_Counter4 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter4 > 13) then
                                bit16_Error_Counter4 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter4 <= "0000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;
                
                 when 20 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= 0;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             if(bit16_Error_Counter5 < 2) then
                                bit16_Error_Counter5 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter5 > 12) then
                                bit16_Error_Counter5 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                             else
                                Lock <= '0';
                                bit16_Error_Counter5 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter5 < 3) then
                                bit16_Error_Counter5 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter5 > 13) then
                                bit16_Error_Counter5 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter5 <= "0000";
                            end if;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;
                    
                 when 21 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= 0;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             if(bit16_Error_Counter6 < 2) then
                                bit16_Error_Counter6 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter6 > 12) then
                                bit16_Error_Counter6 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                             else
                                Lock <= '0';
                                bit16_Error_Counter6 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter6 < 3) then
                                bit16_Error_Counter6 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter6 > 13) then
                                bit16_Error_Counter6 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter6 <= "0000";
                            end if;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;
                    
                 when 22 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= 0;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             if(bit16_Error_Counter7 < 2) then
                                bit16_Error_Counter7 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter7 > 12) then
                                bit16_Error_Counter7 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                             else
                                Lock <= '0';
                                bit16_Error_Counter7 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter7 < 3) then
                                bit16_Error_Counter7 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter7 > 13) then
                                bit16_Error_Counter7 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter7 <= "0000";
                            end if;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;
                    
                 when 23 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= 0;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             if(bit16_Error_Counter8 < 2) then
                                bit16_Error_Counter8 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter8 > 12) then
                                bit16_Error_Counter8 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                             else
                                Lock <= '0';
                                bit16_Error_Counter8 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter8 < 3) then
                                bit16_Error_Counter8 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter8 > 13) then
                               bit16_Error_Counter8 <= "0000";   
                               Lock <= '1';                      
                               Data_Valid <= '1';                
                               Flag_Sync_Word <= 1;              
                               Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter8 <= "0000";
                            end if;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;
                    
                 when 24 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= 0;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             if(bit16_Error_Counter9 < 2) then
                                bit16_Error_Counter9 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter9 > 12) then
                                bit16_Error_Counter9 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                             else
                                Lock <= '0';
                                bit16_Error_Counter9 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter9 < 3) then
                                bit16_Error_Counter9 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter9 > 13) then
                               bit16_Error_Counter9 <= "0000";   
                               Lock <= '1';                      
                               Data_Valid <= '1';                
                               Flag_Sync_Word <= 1;              
                               Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter9 <= "0000";
                            end if;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;
                    
                 when 25 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= 0;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             if(bit16_Error_Counter10 < 2) then
                                bit16_Error_Counter10 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter10 > 12) then
                                bit16_Error_Counter10 <= "0000";   
                                Lock <= '1';                      
                                Data_Valid <= '1';                
                                Flag_Sync_Word <= 1;              
                                Spectrum_inversion <= '1';        
                             else
                                Lock <= '0';
                                bit16_Error_Counter10 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter10 < 3) then
                                bit16_Error_Counter10 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter10 > 13) then
                               bit16_Error_Counter10 <= "0000";   
                               Lock <= '1';                      
                               Data_Valid <= '1';                
                               Flag_Sync_Word <= 1;              
                               Spectrum_inversion <= '1';        
                            else
                                Lock <= '0';
                                bit16_Error_Counter10 <= "0000";
                            end if;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;
                    
                 when 26 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= 0;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             if(bit16_Error_Counter11 < 2) then
                                bit16_Error_Counter11 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter11 > 12) then
                                bit16_Error_Counter11 <= "0000";   
                                Lock <= '1';                       
                                Data_Valid <= '1';                 
                                Flag_Sync_Word <= 1;               
                                Spectrum_inversion <= '1';         
                             else
                                Lock <= '0';
                                bit16_Error_Counter11 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter11 < 3) then
                                bit16_Error_Counter11 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter11 > 13) then
                                bit16_Error_Counter11 <= "0000";   
                                Lock <= '1';                       
                                Data_Valid <= '1';                 
                                Flag_Sync_Word <= 1;               
                                Spectrum_inversion <= '1';         
                            else
                                Lock <= '0';
                                bit16_Error_Counter11 <= "0000";
                            end if;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;
                    
                 when 27 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= 0;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             if(bit16_Error_Counter12 < 2) then
                                bit16_Error_Counter12 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter12 > 12) then
                                bit16_Error_Counter12 <= "0000";   
                                Lock <= '1';                       
                                Data_Valid <= '1';                 
                                Flag_Sync_Word <= 1;               
                                Spectrum_inversion <= '1';         
                             else
                                Lock <= '0';
                                bit16_Error_Counter12 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter12 < 3) then
                                bit16_Error_Counter12 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter12 > 13) then
                               bit16_Error_Counter12 <= "0000";   
                               Lock <= '1';                       
                               Data_Valid <= '1';                 
                               Flag_Sync_Word <= 1;               
                               Spectrum_inversion <= '1';         
                            else
                                Lock <= '0';
                                bit16_Error_Counter12 <= "0000";
                            end if;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;

                 when 28 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= 0;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             if(bit16_Error_Counter13 < 2) then
                                bit16_Error_Counter13 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter13 > 12) then
                                bit16_Error_Counter13 <= "0000";   
                                Lock <= '1';                       
                                Data_Valid <= '1';                 
                                Flag_Sync_Word <= 1;               
                                Spectrum_inversion <= '1';         
                             else
                                Lock <= '0';
                                bit16_Error_Counter13 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter13 < 3) then
                                bit16_Error_Counter13 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter13 > 13) then
                               bit16_Error_Counter13 <= "0000";   
                               Lock <= '1';                       
                               Data_Valid <= '1';                 
                               Flag_Sync_Word <= 1;               
                               Spectrum_inversion <= '1';         
                            else
                                Lock <= '0';
                                bit16_Error_Counter13 <= "0000";
                            end if;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                    
                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;

                 when 29 =>
                    bit16_Lock_Counter <= bit16_Lock_Counter + 1;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= 0;
                    bit16_Detector_Counter15 <= bit16_Detector_Counter15 + 1;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             if(bit16_Error_Counter14 < 2) then
                                bit16_Error_Counter14 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter14 > 12) then
                                bit16_Error_Counter14 <= "0000";   
                                Lock <= '1';                       
                                Data_Valid <= '1';                 
                                Flag_Sync_Word <= 1;               
                                Spectrum_inversion <= '1';         
                             else
                                Lock <= '0';
                                bit16_Error_Counter14 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter14 < 3) then
                                bit16_Error_Counter14 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter14 > 13) then
                               bit16_Error_Counter14 <= "0000";   
                               Lock <= '1';                       
                               Data_Valid <= '1';                 
                               Flag_Sync_Word <= 1;               
                               Spectrum_inversion <= '1';         
                            else
                                Lock <= '0';
                                bit16_Error_Counter14 <= "0000";
                            end if;
                    end if;

                     if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             bit16_Error_Counter15 <= bit16_Error_Counter15 + 1;
                    end if;

                 when 30 =>
                    bit16_Lock_Counter <= 15;
                    bit16_Detector_Counter0 <= bit16_Detector_Counter0 + 1;
                    bit16_Detector_Counter1 <= bit16_Detector_Counter1 + 1;
                    bit16_Detector_Counter2 <= bit16_Detector_Counter2 + 1;
                    bit16_Detector_Counter3 <= bit16_Detector_Counter3 + 1;
                    bit16_Detector_Counter4 <= bit16_Detector_Counter4 + 1;
                    bit16_Detector_Counter5 <= bit16_Detector_Counter5 + 1;
                    bit16_Detector_Counter6 <= bit16_Detector_Counter6 + 1;
                    bit16_Detector_Counter7 <= bit16_Detector_Counter7 + 1;
                    bit16_Detector_Counter8 <= bit16_Detector_Counter8 + 1;
                    bit16_Detector_Counter9 <= bit16_Detector_Counter9 + 1;
                    bit16_Detector_Counter10 <= bit16_Detector_Counter10 + 1;
                    bit16_Detector_Counter11 <= bit16_Detector_Counter11 + 1;
                    bit16_Detector_Counter12 <= bit16_Detector_Counter12 + 1;
                    bit16_Detector_Counter13 <= bit16_Detector_Counter13 + 1;
                    bit16_Detector_Counter14 <= bit16_Detector_Counter14 + 1;
                    bit16_Detector_Counter15 <= 0;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter0)) then
                             bit16_Error_Counter0 <= bit16_Error_Counter0 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter1)) then
                             bit16_Error_Counter1 <= bit16_Error_Counter1 + 1;
                    end if;

                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter2)) then
                             bit16_Error_Counter2 <= bit16_Error_Counter2 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter3)) then
                             bit16_Error_Counter3 <= bit16_Error_Counter3 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter4)) then
                             bit16_Error_Counter4 <= bit16_Error_Counter4 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter5)) then
                             bit16_Error_Counter5 <= bit16_Error_Counter5 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter6)) then
                             bit16_Error_Counter6 <= bit16_Error_Counter6 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter7)) then
                             bit16_Error_Counter7 <= bit16_Error_Counter7 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter8)) then
                             bit16_Error_Counter8 <= bit16_Error_Counter8 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter9)) then
                             bit16_Error_Counter9 <= bit16_Error_Counter9 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter10)) then
                             bit16_Error_Counter10 <= bit16_Error_Counter10 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter11)) then
                             bit16_Error_Counter11 <= bit16_Error_Counter11 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter12)) then
                             bit16_Error_Counter12 <= bit16_Error_Counter12 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter13)) then
                             bit16_Error_Counter13 <= bit16_Error_Counter13 + 1;
                    end if;
                    
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter14)) then
                             bit16_Error_Counter14 <= bit16_Error_Counter14 + 1;
                    end if;
                
                    if(Serial_Data /= Sync_Word(bit16_Detector_Counter15)) then
                             if(bit16_Error_Counter15 < 2) then
                                bit16_Error_Counter15 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                             elsif(bit16_Error_Counter15 > 12) then
                                   bit16_Error_Counter15 <= "0000";   
                                   Lock <= '1';                       
                                   Data_Valid <= '1';                 
                                   Flag_Sync_Word <= 1;               
                                   Spectrum_inversion <= '1';         
                             else
                                Lock <= '0';
                                bit16_Error_Counter15 <= "0000";
                             end if;
                    else
                            if(bit16_Error_Counter15 < 3) then
                                bit16_Error_Counter15 <= "0000";
                                Lock <= '1';
                                Data_Valid <= '1';
                                Flag_Sync_Word <= 1;
                            elsif(bit16_Error_Counter15 > 13) then
                                   bit16_Error_Counter15 <= "0000";   
                                   Lock <= '1';                       
                                   Data_Valid <= '1';                 
                                   Flag_Sync_Word <= 1;               
                                   Spectrum_inversion <= '1';         
                            else
                                Lock <= '0';
                                bit16_Error_Counter15 <= "0000";
                            end if;
                    end if;

            end case;
        when 1 =>
        
            if(Packet_Bit_Counter = (Packet_Length - 17)) then -- Paket Sayacý
                Data_Valid <= '0';
                Packet_Bit_Counter <= (others => '0');
                Flag_Sync_Word <= 0;
                Spectrum_inversion <= '0';
            else
                Packet_Bit_Counter <= Packet_Bit_Counter + 1;
            end if;            
            
            bit16_Lock_Counter <= 0;            
            bit16_Detector_Counter0 <=  0;
            bit16_Detector_Counter1 <=  0;
            bit16_Detector_Counter2 <=  0;
            bit16_Detector_Counter3 <=  0;
            bit16_Detector_Counter4 <=  0;
            bit16_Detector_Counter5 <=  0;
            bit16_Detector_Counter6 <=  0;
            bit16_Detector_Counter7 <=  0;
            bit16_Detector_Counter8 <=  0;
            bit16_Detector_Counter9 <=  0;
            bit16_Detector_Counter10 <=  0;
            bit16_Detector_Counter11 <=  0;
            bit16_Detector_Counter12 <=  0;
            bit16_Detector_Counter13 <=  0;
            bit16_Detector_Counter14 <=  0;
            bit16_Detector_Counter15 <=  0;
            bit16_Error_Counter0 <=  "0000";
            bit16_Error_Counter1 <=  "0000";
            bit16_Error_Counter2 <=  "0000";
            bit16_Error_Counter3 <=  "0000";
            bit16_Error_Counter4 <=  "0000";
            bit16_Error_Counter5 <=  "0000";
            bit16_Error_Counter6 <=  "0000";
            bit16_Error_Counter7 <=  "0000";
            bit16_Error_Counter8 <=  "0000";
            bit16_Error_Counter9 <=  "0000";
            bit16_Error_Counter10 <=  "0000";
            bit16_Error_Counter11 <=  "0000";
            bit16_Error_Counter12 <=  "0000";
            bit16_Error_Counter13 <=  "0000";
            bit16_Error_Counter14 <=  "0000";
            bit16_Error_Counter15 <=  "0000";

        end case;

    when "011" =>
    Lock_Counter <= 0;            
    Detector_Counter0 <=  0;
    Detector_Counter1 <=  0;
    Detector_Counter2 <=  0;
    Detector_Counter3 <=  0;
    Detector_Counter4 <=  0;
    Detector_Counter5 <=  0;
    Detector_Counter6 <=  0;
    Detector_Counter7 <=  0;
    Detector_Counter8 <=  0;
    Detector_Counter9 <=  0;
    Detector_Counter10 <= 0;
    Detector_Counter11 <= 0;
    Detector_Counter12 <= 0;
    Detector_Counter13 <= 0;
    Detector_Counter14 <= 0;
    Detector_Counter15 <= 0;
    Detector_Counter16 <= 0;
    Detector_Counter17 <= 0;
    Detector_Counter18 <= 0;
    Detector_Counter19 <= 0;
    Detector_Counter20 <= 0;
    Detector_Counter21 <= 0;
    Detector_Counter22 <= 0;
    Detector_Counter23 <= 0;
    Detector_Counter24 <= 0;
    Detector_Counter25 <= 0;
    Detector_Counter26 <= 0;
    Detector_Counter27 <= 0;
    Detector_Counter28 <= 0;
    Detector_Counter29 <= 0;
    Detector_Counter30 <= 0;
    Detector_Counter31 <= 0;
    Error_Counter0 <=  "00000";
    Error_Counter1 <=  "00000";
    Error_Counter2 <=  "00000";
    Error_Counter3 <=  "00000";
    Error_Counter4 <=  "00000";
    Error_Counter5 <=  "00000";
    Error_Counter6 <=  "00000";
    Error_Counter7 <=  "00000";
    Error_Counter8 <=  "00000";
    Error_Counter9 <=  "00000";
    Error_Counter10 <= "00000";
    Error_Counter11 <= "00000";
    Error_Counter12 <= "00000";
    Error_Counter13 <= "00000";
    Error_Counter14 <= "00000";
    Error_Counter15 <= "00000";
    Error_Counter16 <= "00000";
    Error_Counter17 <= "00000";
    Error_Counter18 <= "00000";
    Error_Counter19 <= "00000";
    Error_Counter20 <= "00000";
    Error_Counter21 <= "00000";
    Error_Counter22 <= "00000";
    Error_Counter23 <= "00000";
    Error_Counter24 <= "00000";
    Error_Counter25 <= "00000";
    Error_Counter26 <= "00000";
    Error_Counter27 <= "00000";
    Error_Counter28 <= "00000";
    Error_Counter29 <= "00000";
    Error_Counter30 <= "00000";
    Error_Counter31 <= "00000";
    bit16_Lock_Counter <= 0;            
    bit16_Detector_Counter0 <=  0;
    bit16_Detector_Counter1 <=  0;
    bit16_Detector_Counter2 <=  0;
    bit16_Detector_Counter3 <=  0;
    bit16_Detector_Counter4 <=  0;
    bit16_Detector_Counter5 <=  0;
    bit16_Detector_Counter6 <=  0;
    bit16_Detector_Counter7 <=  0;
    bit16_Detector_Counter8 <=  0;
    bit16_Detector_Counter9 <=  0;
    bit16_Detector_Counter10 <=  0;
    bit16_Detector_Counter11 <=  0;
    bit16_Detector_Counter12 <=  0;
    bit16_Detector_Counter13 <=  0;
    bit16_Detector_Counter14 <=  0;
    bit16_Detector_Counter15 <=  0;
    bit16_Error_Counter0 <=  "0000";
    bit16_Error_Counter1 <=  "0000";
    bit16_Error_Counter2 <=  "0000";
    bit16_Error_Counter3 <=  "0000";
    bit16_Error_Counter4 <=  "0000";
    bit16_Error_Counter5 <=  "0000";
    bit16_Error_Counter6 <=  "0000";
    bit16_Error_Counter7 <=  "0000";
    bit16_Error_Counter8 <=  "0000";
    bit16_Error_Counter9 <=  "0000";
    bit16_Error_Counter10 <=  "0000";
    bit16_Error_Counter11 <=  "0000";
    bit16_Error_Counter12 <=  "0000";
    bit16_Error_Counter13 <=  "0000";
    bit16_Error_Counter14 <=  "0000";
    bit16_Error_Counter15 <=  "0000";
    bit8_Lock_Counter <= 0;            
    bit8_Detector_Counter0 <=  0;
    bit8_Detector_Counter1 <=  0;
    bit8_Detector_Counter2 <=  0;
    bit8_Detector_Counter3 <=  0;
    bit8_Detector_Counter4 <=  0;
    bit8_Detector_Counter5 <=  0;
    bit8_Detector_Counter6 <=  0;
    bit8_Detector_Counter7 <=  0;
    bit8_Error_Counter0 <=  "000";
    bit8_Error_Counter1 <=  "000";
    bit8_Error_Counter2 <=  "000";
    bit8_Error_Counter3 <=  "000";
    bit8_Error_Counter4 <=  "000";
    bit8_Error_Counter5 <=  "000";
    bit8_Error_Counter6 <=  "000";
    bit8_Error_Counter7 <=  "000";

    case(Flag_Sync_Word) is
        when 0 =>
          case(bit24_Lock_Counter) is
            when 0 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                if(Beginning_Clock = '1') then
                    Spectrum_inversion <= '0';
                    Lock <= '0';
                    Data_Valid <= '0';
                    Beginning_Clock <= '0';
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                    bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
             
            when 1 =>
               bit24_Lock_Counter <= bit24_Lock_Counter + 1;
               bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
               bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
               
               if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                        bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
               end if;
               
               if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                        bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
               end if;
               
            when 2 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
             when 3 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
             
             when 4 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
             when 5 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
             when 6 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
             
             when 7 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
             when 8 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
             when 9 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
             when 10 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
             when 11 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
             when 12 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;


                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
             when 13 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
             when 14 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;
                
             when 15 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
             when 16 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
             when 17 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
             when 18 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
             when 19 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
             when 20 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
             when 21 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
             
             when 22 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
             
             when 23 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= 0;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         if(bit24_Error_Counter0 < 3) then
                            bit24_Error_Counter0 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter0 > 19) then
                            bit24_Error_Counter0 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                            Spectrum_inversion <= '1';
                         else
                            Lock <= '0';
                            bit24_Error_Counter0 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter0 < 4) then
                            bit24_Error_Counter0 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter0 > 20) then
                           bit24_Error_Counter0 <= "00000";  
                           Lock <= '1';                      
                           Data_Valid <= '1';                
                           Flag_Sync_Word <= 1;              
                           Spectrum_inversion <= '1';        
                        else
                            Lock <= '0';
                            bit24_Error_Counter0 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 24 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= 0;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         if(bit24_Error_Counter1 < 3) then
                            bit24_Error_Counter1 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter1 > 19) then
                               bit24_Error_Counter1 <= "00000";  
                               Lock <= '1';                      
                               Data_Valid <= '1';                
                               Flag_Sync_Word <= 1;              
                               Spectrum_inversion <= '1';        
                         else
                            Lock <= '0';
                            bit24_Error_Counter1 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter1 < 4) then
                            bit24_Error_Counter1 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter1 > 20) then 
                              bit24_Error_Counter1 <= "00000";
                              Lock <= '1';                    
                              Data_Valid <= '1';              
                              Flag_Sync_Word <= 1;            
                              Spectrum_inversion <= '1';      
                        else
                            Lock <= '0';
                            bit24_Error_Counter1 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 25 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= 0;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         if(bit24_Error_Counter2 < 3) then
                            bit24_Error_Counter2 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter2 > 19) then 
                            bit24_Error_Counter2 <= "00000";
                            Lock <= '1';                    
                            Data_Valid <= '1';              
                            Flag_Sync_Word <= 1;            
                            Spectrum_inversion <= '1';      
                         else
                            Lock <= '0';
                            bit24_Error_Counter2 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter2 < 4) then
                            bit24_Error_Counter2 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter2 > 20) then
                           bit24_Error_Counter2 <= "00000";  
                           Lock <= '1';                      
                           Data_Valid <= '1';                
                           Flag_Sync_Word <= 1;              
                           Spectrum_inversion <= '1';        
                        else
                            Lock <= '0';
                            bit24_Error_Counter2 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 26 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= 0;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         if(bit24_Error_Counter3 < 3) then
                            bit24_Error_Counter3 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter3 > 19) then
                            bit24_Error_Counter3 <= "00000";  
                            Lock <= '1';                      
                            Data_Valid <= '1';                
                            Flag_Sync_Word <= 1;              
                            Spectrum_inversion <= '1';        
                         else
                            Lock <= '0';
                            bit24_Error_Counter3 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter3 < 4) then
                            bit24_Error_Counter3 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter3 > 20) then
                           bit24_Error_Counter3 <= "00000";  
                           Lock <= '1';                      
                           Data_Valid <= '1';                
                           Flag_Sync_Word <= 1;              
                           Spectrum_inversion <= '1';        
                        else
                            Lock <= '0';
                            bit24_Error_Counter3 <= "00000";
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
            
            when 27 => 
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= 0;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         if(bit24_Error_Counter4 < 3) then
                            bit24_Error_Counter4 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter4 > 19) then
                            bit24_Error_Counter4 <= "00000";  
                            Lock <= '1';                      
                            Data_Valid <= '1';                
                            Flag_Sync_Word <= 1;              
                            Spectrum_inversion <= '1';        
                         else
                            Lock <= '0';
                            bit24_Error_Counter4 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter4 < 4) then
                            bit24_Error_Counter4 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter4 > 20) then
                           bit24_Error_Counter4 <= "00000";  
                           Lock <= '1';                      
                           Data_Valid <= '1';                
                           Flag_Sync_Word <= 1;              
                           Spectrum_inversion <= '1';        
                        else
                            Lock <= '0';
                            bit24_Error_Counter4 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 28 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= 0;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         if(bit24_Error_Counter5 < 3) then
                            bit24_Error_Counter5 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter5 > 19) then
                            bit24_Error_Counter5 <= "00000";  
                            Lock <= '1';                      
                            Data_Valid <= '1';                
                            Flag_Sync_Word <= 1;              
                            Spectrum_inversion <= '1';        
                         else
                            Lock <= '0';
                            bit24_Error_Counter5 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter5 < 4) then
                            bit24_Error_Counter5 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter5 > 20) then
                            bit24_Error_Counter5 <= "00000";  
                            Lock <= '1';                      
                            Data_Valid <= '1';                
                            Flag_Sync_Word <= 1;              
                            Spectrum_inversion <= '1';        
                        else
                            Lock <= '0';
                            bit24_Error_Counter5 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
            
            when 29 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= 0;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         if(bit24_Error_Counter6 < 3) then
                            bit24_Error_Counter6 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter6 > 19) then
                            bit24_Error_Counter6 <= "00000";  
                            Lock <= '1';                      
                            Data_Valid <= '1';                
                            Flag_Sync_Word <= 1;              
                            Spectrum_inversion <= '1';        
                         else
                            Lock <= '0';
                            bit24_Error_Counter6 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter6 < 4) then
                            bit24_Error_Counter6 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter6 > 20) then
                           bit24_Error_Counter6 <= "00000";  
                           Lock <= '1';                      
                           Data_Valid <= '1';                
                           Flag_Sync_Word <= 1;              
                           Spectrum_inversion <= '1';        
                        else
                            Lock <= '0';
                            bit24_Error_Counter6 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;

             when 30 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= 0;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         if(bit24_Error_Counter7 < 3) then
                            bit24_Error_Counter7 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter7 > 19) then
                            bit24_Error_Counter7 <= "00000";  
                            Lock <= '1';                      
                            Data_Valid <= '1';                
                            Flag_Sync_Word <= 1;              
                            Spectrum_inversion <= '1';        
                         else
                            Lock <= '0';
                            bit24_Error_Counter7 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter7 < 4) then
                            bit24_Error_Counter7 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter7 > 20) then
                           bit24_Error_Counter7 <= "00000";  
                           Lock <= '1';                      
                           Data_Valid <= '1';                
                           Flag_Sync_Word <= 1;              
                           Spectrum_inversion <= '1';        
                        else
                            Lock <= '0';
                            bit24_Error_Counter7 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 31 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= 0;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         if(bit24_Error_Counter8 < 3) then
                            bit24_Error_Counter8 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter8 > 19) then
                            bit24_Error_Counter8 <= "00000";  
                            Lock <= '1';                      
                            Data_Valid <= '1';                
                            Flag_Sync_Word <= 1;              
                            Spectrum_inversion <= '1';        
                         else
                            Lock <= '0';
                            bit24_Error_Counter8 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter8 < 4) then
                            bit24_Error_Counter8 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter8 > 20) then
                           bit24_Error_Counter8 <= "00000";  
                           Lock <= '1';                      
                           Data_Valid <= '1';                
                           Flag_Sync_Word <= 1;              
                           Spectrum_inversion <= '1';        
                        else
                            Lock <= '0';
                            bit24_Error_Counter8 <= "00000";
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 32 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= 0;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         if(bit24_Error_Counter9 < 3) then
                            bit24_Error_Counter9 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter9 > 19) then
                            bit24_Error_Counter9 <= "00000";  
                            Lock <= '1';                      
                            Data_Valid <= '1';                
                            Flag_Sync_Word <= 1;              
                            Spectrum_inversion <= '1';        
                         else
                            Lock <= '0';
                            bit24_Error_Counter9 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter9 < 4) then
                            bit24_Error_Counter9 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter9 > 20) then
                           bit24_Error_Counter9 <= "00000";  
                           Lock <= '1';                      
                           Data_Valid <= '1';                
                           Flag_Sync_Word <= 1;              
                           Spectrum_inversion <= '1';        
                        else
                            Lock <= '0';
                            bit24_Error_Counter9 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
            
             when 33 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= 0;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         if(bit24_Error_Counter10 < 3) then
                            bit24_Error_Counter10 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter10 > 19) then
                            bit24_Error_Counter10 <= "00000";  
                            Lock <= '1';                      
                            Data_Valid <= '1';                
                            Flag_Sync_Word <= 1;              
                            Spectrum_inversion <= '1';        
                         else
                            Lock <= '0';
                            bit24_Error_Counter10 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter10 < 4) then
                            bit24_Error_Counter10 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter10 > 20) then
                           bit24_Error_Counter10 <= "00000";  
                           Lock <= '1';                       
                           Data_Valid <= '1';                 
                           Flag_Sync_Word <= 1;               
                           Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter10 <= "00000";
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 34 => 
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= 0;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         if(bit24_Error_Counter11 < 3) then
                            bit24_Error_Counter11 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter11 > 19) then
                            bit24_Error_Counter11 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter11 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter11 < 4) then
                            bit24_Error_Counter11 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter11 > 20) then
                            bit24_Error_Counter11 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter11 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 35 => 
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= 0;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         if(bit24_Error_Counter12 < 3) then
                            bit24_Error_Counter12 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter12 > 19) then
                            bit24_Error_Counter12 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter12 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter12 < 4) then
                            bit24_Error_Counter12 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter12 > 20) then
                            bit24_Error_Counter12 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter12 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 36 => 
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= 0;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         if(bit24_Error_Counter13 < 3) then
                            bit24_Error_Counter13 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter13 > 19) then
                            bit24_Error_Counter13 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter13 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter13 < 4) then
                            bit24_Error_Counter13 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter13 > 20) then
                           bit24_Error_Counter13 <= "00000";  
                           Lock <= '1';                       
                           Data_Valid <= '1';                 
                           Flag_Sync_Word <= 1;               
                           Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter13 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
                
             when 37 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= 0;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then
                         if(bit24_Error_Counter14 < 3) then
                            bit24_Error_Counter14 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter14 > 19) then
                            bit24_Error_Counter14 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter14 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter14 < 4) then
                            bit24_Error_Counter14 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter14 > 20) then
                           bit24_Error_Counter14 <= "00000";  
                           Lock <= '1';                       
                           Data_Valid <= '1';                 
                           Flag_Sync_Word <= 1;               
                           Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter14 <= "00000";
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;

             when 38 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= 0;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then 
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then
                         if(bit24_Error_Counter15 < 3) then
                            bit24_Error_Counter15 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter15 > 19) then
                            bit24_Error_Counter15 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter15 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter15 < 4) then
                            bit24_Error_Counter15 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter15 > 20) then
                            bit24_Error_Counter15 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter15 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 39 => 
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= 0;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then 
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then
                         if(bit24_Error_Counter16 < 3) then
                            bit24_Error_Counter16 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter16 > 19) then
                            bit24_Error_Counter16 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter16 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter16 < 4) then
                            bit24_Error_Counter16 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter16 > 20) then
                           bit24_Error_Counter16 <= "00000";  
                           Lock <= '1';                       
                           Data_Valid <= '1';                 
                           Flag_Sync_Word <= 1;               
                           Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter16 <= "00000";
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 40 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= 0;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then 
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then
                         if(bit24_Error_Counter17 < 3) then
                            bit24_Error_Counter17 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter17 > 19) then
                            bit24_Error_Counter17 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter17 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter17 < 4) then
                            bit24_Error_Counter17 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter17 > 20) then
                           bit24_Error_Counter17 <= "00000";  
                           Lock <= '1';                       
                           Data_Valid <= '1';                 
                           Flag_Sync_Word <= 1;               
                           Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter17 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 41 => 
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= 0;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then 
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then
                         if(bit24_Error_Counter18 < 3) then
                            bit24_Error_Counter18 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter18 > 19) then
                            bit24_Error_Counter18 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter18 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter18 < 4) then
                            bit24_Error_Counter18 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter18 > 20) then
                           bit24_Error_Counter18 <= "00000";  
                           Lock <= '1';                       
                           Data_Valid <= '1';                 
                           Flag_Sync_Word <= 1;               
                           Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter18 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
            
             when 42 => 
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= 0;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then 
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then
                         if(bit24_Error_Counter19 < 3) then
                            bit24_Error_Counter19 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter19 > 19) then
                            bit24_Error_Counter19 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter19 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter19 < 4) then
                            bit24_Error_Counter19 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter19 > 20) then
                           bit24_Error_Counter19 <= "00000";  
                           Lock <= '1';                       
                           Data_Valid <= '1';                 
                           Flag_Sync_Word <= 1;               
                           Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter19 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
            
            when 43 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= 0;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then 
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then
                         if(bit24_Error_Counter20 < 3) then
                            bit24_Error_Counter20 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter20 > 19) then
                            bit24_Error_Counter20 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter20 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter20 < 4) then
                            bit24_Error_Counter20 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter20 > 20) then
                           bit24_Error_Counter20 <= "00000";  
                           Lock <= '1';                       
                           Data_Valid <= '1';                 
                           Flag_Sync_Word <= 1;               
                           Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter20 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 44 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= 0;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then 
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then
                         if(bit24_Error_Counter21 < 3) then
                            bit24_Error_Counter21 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter21 > 19) then
                            bit24_Error_Counter21 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter21 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter21 < 4) then
                            bit24_Error_Counter21 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter21 > 20) then
                            bit24_Error_Counter21 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter21 <= "00000";
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 45 =>
                bit24_Lock_Counter <= bit24_Lock_Counter + 1;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= 0;
                bit24_Detector_Counter23 <= bit24_Detector_Counter23 + 1;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then 
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then
                         if(bit24_Error_Counter22 < 3) then
                            bit24_Error_Counter22 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter22 > 19) then
                            bit24_Error_Counter22 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter22 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter22 < 4) then
                            bit24_Error_Counter22 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter22 > 20) then
                           bit24_Error_Counter22 <= "00000";  
                           Lock <= '1';                       
                           Data_Valid <= '1';                 
                           Flag_Sync_Word <= 1;               
                           Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter22 <= "00000";
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then 
                         bit24_Error_Counter23 <= bit24_Error_Counter23 + 1;
                end if;
             
             when 46 => 
                bit24_Lock_Counter <= 23;
                bit24_Detector_Counter0 <= bit24_Detector_Counter0 + 1;
                bit24_Detector_Counter1 <= bit24_Detector_Counter1 + 1;
                bit24_Detector_Counter2 <= bit24_Detector_Counter2 + 1;
                bit24_Detector_Counter3 <= bit24_Detector_Counter3 + 1;
                bit24_Detector_Counter4 <= bit24_Detector_Counter4 + 1;
                bit24_Detector_Counter5 <= bit24_Detector_Counter5 + 1;
                bit24_Detector_Counter6 <= bit24_Detector_Counter6 + 1;
                bit24_Detector_Counter7 <= bit24_Detector_Counter7 + 1;
                bit24_Detector_Counter8 <= bit24_Detector_Counter8 + 1;
                bit24_Detector_Counter9 <= bit24_Detector_Counter9 + 1;
                bit24_Detector_Counter10 <= bit24_Detector_Counter10 + 1;
                bit24_Detector_Counter11 <= bit24_Detector_Counter11 + 1;
                bit24_Detector_Counter12 <= bit24_Detector_Counter12 + 1;
                bit24_Detector_Counter13 <= bit24_Detector_Counter13 + 1;
                bit24_Detector_Counter14 <= bit24_Detector_Counter14 + 1;
                bit24_Detector_Counter15 <= bit24_Detector_Counter15 + 1;
                bit24_Detector_Counter16 <= bit24_Detector_Counter16 + 1;
                bit24_Detector_Counter17 <= bit24_Detector_Counter17 + 1;
                bit24_Detector_Counter18 <= bit24_Detector_Counter18 + 1;
                bit24_Detector_Counter19 <= bit24_Detector_Counter19 + 1;
                bit24_Detector_Counter20 <= bit24_Detector_Counter20 + 1;
                bit24_Detector_Counter21 <= bit24_Detector_Counter21 + 1;
                bit24_Detector_Counter22 <= bit24_Detector_Counter22 + 1;
                bit24_Detector_Counter23 <= 0;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter0)) then
                         bit24_Error_Counter0 <= bit24_Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter1)) then
                         bit24_Error_Counter1 <= bit24_Error_Counter1 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter2)) then
                         bit24_Error_Counter2 <= bit24_Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter3)) then
                         bit24_Error_Counter3 <= bit24_Error_Counter3 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter4)) then
                         bit24_Error_Counter4 <= bit24_Error_Counter4 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter5)) then
                         bit24_Error_Counter5 <= bit24_Error_Counter5 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter6)) then
                         bit24_Error_Counter6 <= bit24_Error_Counter6 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter7)) then
                         bit24_Error_Counter7 <= bit24_Error_Counter7 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter8)) then
                         bit24_Error_Counter8 <= bit24_Error_Counter8 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter9)) then
                         bit24_Error_Counter9 <= bit24_Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter10)) then
                         bit24_Error_Counter10 <= bit24_Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter11)) then
                         bit24_Error_Counter11 <= bit24_Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter12)) then
                         bit24_Error_Counter12 <= bit24_Error_Counter12 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter13)) then
                         bit24_Error_Counter13 <= bit24_Error_Counter13 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter14)) then 
                         bit24_Error_Counter14 <= bit24_Error_Counter14 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter15)) then 
                         bit24_Error_Counter15 <= bit24_Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter16)) then 
                         bit24_Error_Counter16 <= bit24_Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter17)) then 
                         bit24_Error_Counter17 <= bit24_Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter18)) then 
                         bit24_Error_Counter18 <= bit24_Error_Counter18 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter19)) then 
                         bit24_Error_Counter19 <= bit24_Error_Counter19 + 1;
                end if;
                                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter20)) then 
                         bit24_Error_Counter20 <= bit24_Error_Counter20 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter21)) then 
                         bit24_Error_Counter21 <= bit24_Error_Counter21 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(bit24_Detector_Counter22)) then 
                         bit24_Error_Counter22 <= bit24_Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(bit24_Detector_Counter23)) then
                         if(bit24_Error_Counter23 < 3) then
                            bit24_Error_Counter23 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(bit24_Error_Counter23 > 19) then
                            bit24_Error_Counter23 <= "00000";  
                            Lock <= '1';                       
                            Data_Valid <= '1';                 
                            Flag_Sync_Word <= 1;               
                            Spectrum_inversion <= '1';         
                         else
                            Lock <= '0';
                            bit24_Error_Counter23 <= "00000";
                         end if;
                else
                        if(bit24_Error_Counter23 < 4) then
                            bit24_Error_Counter23 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(bit24_Error_Counter23 > 20) then
                           bit24_Error_Counter23 <= "00000";  
                           Lock <= '1';                       
                           Data_Valid <= '1';                 
                           Flag_Sync_Word <= 1;               
                           Spectrum_inversion <= '1';         
                        else
                            Lock <= '0';
                            bit24_Error_Counter23 <= "00000";
                        end if;
                end if;
          end case;
        
        when 1 =>
        if(Packet_Bit_Counter = (Packet_Length - 25)) then -- Paket Sayacý
            Data_Valid <= '0';
            Packet_Bit_Counter <= (others => '0');
            Flag_Sync_Word <= 0;
            Spectrum_inversion <= '0';
        else
            Packet_Bit_Counter <= Packet_Bit_Counter + 1;
        end if;            
        
        bit24_Lock_Counter <= 0;            
        bit24_Detector_Counter0 <=  0;
        bit24_Detector_Counter1 <=  0;
        bit24_Detector_Counter2 <=  0;
        bit24_Detector_Counter3 <=  0;
        bit24_Detector_Counter4 <=  0;
        bit24_Detector_Counter5 <=  0;
        bit24_Detector_Counter6 <=  0;
        bit24_Detector_Counter7 <=  0;
        bit24_Detector_Counter8 <=  0;
        bit24_Detector_Counter9 <=  0;
        bit24_Detector_Counter10 <= 0;
        bit24_Detector_Counter11 <= 0;
        bit24_Detector_Counter12 <= 0;
        bit24_Detector_Counter13 <= 0;
        bit24_Detector_Counter14 <= 0;
        bit24_Detector_Counter15 <= 0;
        bit24_Detector_Counter16 <= 0;
        bit24_Detector_Counter17 <= 0;
        bit24_Detector_Counter18 <= 0;
        bit24_Detector_Counter19 <= 0;
        bit24_Detector_Counter20 <= 0;
        bit24_Detector_Counter21 <= 0;
        bit24_Detector_Counter22 <= 0;
        bit24_Detector_Counter23 <= 0;
        bit24_Error_Counter0 <=  "00000";
        bit24_Error_Counter1 <=  "00000";
        bit24_Error_Counter2 <=  "00000";
        bit24_Error_Counter3 <=  "00000";
        bit24_Error_Counter4 <=  "00000";
        bit24_Error_Counter5 <=  "00000";
        bit24_Error_Counter6 <=  "00000";
        bit24_Error_Counter7 <=  "00000";
        bit24_Error_Counter8 <=  "00000";
        bit24_Error_Counter9 <=  "00000";
        bit24_Error_Counter10 <= "00000";
        bit24_Error_Counter11 <= "00000";
        bit24_Error_Counter12 <= "00000";
        bit24_Error_Counter13 <= "00000";
        bit24_Error_Counter14 <= "00000";
        bit24_Error_Counter15 <= "00000";
        bit24_Error_Counter16 <= "00000";
        bit24_Error_Counter17 <= "00000";
        bit24_Error_Counter18 <= "00000";
        bit24_Error_Counter19 <= "00000";
        bit24_Error_Counter20 <= "00000";
        bit24_Error_Counter21 <= "00000";
        bit24_Error_Counter22 <= "00000";
        bit24_Error_Counter23 <= "00000";

    end case;
    
    
    when "100" =>
        bit24_Lock_Counter <= 0;            
    bit24_Detector_Counter0 <=  0;
    bit24_Detector_Counter1 <=  0;
    bit24_Detector_Counter2 <=  0;
    bit24_Detector_Counter3 <=  0;
    bit24_Detector_Counter4 <=  0;
    bit24_Detector_Counter5 <=  0;
    bit24_Detector_Counter6 <=  0;
    bit24_Detector_Counter7 <=  0;
    bit24_Detector_Counter8 <=  0;
    bit24_Detector_Counter9 <=  0;
    bit24_Detector_Counter10 <= 0;
    bit24_Detector_Counter11 <= 0;
    bit24_Detector_Counter12 <= 0;
    bit24_Detector_Counter13 <= 0;
    bit24_Detector_Counter14 <= 0;
    bit24_Detector_Counter15 <= 0;
    bit24_Detector_Counter16 <= 0;
    bit24_Detector_Counter17 <= 0;
    bit24_Detector_Counter18 <= 0;
    bit24_Detector_Counter19 <= 0;
    bit24_Detector_Counter20 <= 0;
    bit24_Detector_Counter21 <= 0;
    bit24_Detector_Counter22 <= 0;
    bit24_Detector_Counter23 <= 0;
    bit24_Error_Counter0 <=  "00000";
    bit24_Error_Counter1 <=  "00000";
    bit24_Error_Counter2 <=  "00000";
    bit24_Error_Counter3 <=  "00000";
    bit24_Error_Counter4 <=  "00000";
    bit24_Error_Counter5 <=  "00000";
    bit24_Error_Counter6 <=  "00000";
    bit24_Error_Counter7 <=  "00000";
    bit24_Error_Counter8 <=  "00000";
    bit24_Error_Counter9 <=  "00000";
    bit24_Error_Counter10 <= "00000";
    bit24_Error_Counter11 <= "00000";
    bit24_Error_Counter12 <= "00000";
    bit24_Error_Counter13 <= "00000";
    bit24_Error_Counter14 <= "00000";
    bit24_Error_Counter15 <= "00000";
    bit24_Error_Counter16 <= "00000";
    bit24_Error_Counter17 <= "00000";
    bit24_Error_Counter18 <= "00000";
    bit24_Error_Counter19 <= "00000";
    bit24_Error_Counter20 <= "00000";
    bit24_Error_Counter21 <= "00000";
    bit24_Error_Counter22 <= "00000";
    bit24_Error_Counter23 <= "00000";
    bit16_Lock_Counter <= 0;            
    bit16_Detector_Counter0 <=  0;
    bit16_Detector_Counter1 <=  0;
    bit16_Detector_Counter2 <=  0;
    bit16_Detector_Counter3 <=  0;
    bit16_Detector_Counter4 <=  0;
    bit16_Detector_Counter5 <=  0;
    bit16_Detector_Counter6 <=  0;
    bit16_Detector_Counter7 <=  0;
    bit16_Detector_Counter8 <=  0;
    bit16_Detector_Counter9 <=  0;
    bit16_Detector_Counter10 <=  0;
    bit16_Detector_Counter11 <=  0;
    bit16_Detector_Counter12 <=  0;
    bit16_Detector_Counter13 <=  0;
    bit16_Detector_Counter14 <=  0;
    bit16_Detector_Counter15 <=  0;
    bit16_Error_Counter0 <=  "0000";
    bit16_Error_Counter1 <=  "0000";
    bit16_Error_Counter2 <=  "0000";
    bit16_Error_Counter3 <=  "0000";
    bit16_Error_Counter4 <=  "0000";
    bit16_Error_Counter5 <=  "0000";
    bit16_Error_Counter6 <=  "0000";
    bit16_Error_Counter7 <=  "0000";
    bit16_Error_Counter8 <=  "0000";
    bit16_Error_Counter9 <=  "0000";
    bit16_Error_Counter10 <=  "0000";
    bit16_Error_Counter11 <=  "0000";
    bit16_Error_Counter12 <=  "0000";
    bit16_Error_Counter13 <=  "0000";
    bit16_Error_Counter14 <=  "0000";
    bit16_Error_Counter15 <=  "0000";
    bit8_Lock_Counter <= 0;            
    bit8_Detector_Counter0 <=  0;
    bit8_Detector_Counter1 <=  0;
    bit8_Detector_Counter2 <=  0;
    bit8_Detector_Counter3 <=  0;
    bit8_Detector_Counter4 <=  0;
    bit8_Detector_Counter5 <=  0;
    bit8_Detector_Counter6 <=  0;
    bit8_Detector_Counter7 <=  0;
    bit8_Error_Counter0 <=  "000";
    bit8_Error_Counter1 <=  "000";
    bit8_Error_Counter2 <=  "000";
    bit8_Error_Counter3 <=  "000";
    bit8_Error_Counter4 <=  "000";
    bit8_Error_Counter5 <=  "000";
    bit8_Error_Counter6 <=  "000";
    bit8_Error_Counter7 <=  "000";

    case(Flag_Sync_Word) is
        when 0 => -- Sync Word Arayýþ Durumu
          case(Lock_Counter) is
            when 0 =>
                Lock_Counter <= Lock_Counter + 1;
                Detector_Counter0 <= Detector_Counter0 + 1;
                if(Beginning_Clock = '1') then
                    Spectrum_inversion <= '0';
                    Lock <= '0';
                    Data_Valid <= '0';
                    Beginning_Clock <= '0';
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                    Error_Counter0 <= Error_Counter0 + 1;
                end if;
                
            when 1 =>
                Lock_Counter <= Lock_Counter + 1;
                Detector_Counter0 <= Detector_Counter0 + 1;
                Detector_Counter1 <= Detector_Counter1 + 1;
                
                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;
            
            when 2 =>
                Lock_Counter <= Lock_Counter + 1;
                Detector_Counter0 <= Detector_Counter0 + 1;
                Detector_Counter1 <= Detector_Counter1 + 1;
                Detector_Counter2 <= Detector_Counter2 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
            when 3 =>
                Lock_Counter <= Lock_Counter + 1;          
                Detector_Counter0 <= Detector_Counter0 + 1;
                Detector_Counter1 <= Detector_Counter1 + 1;
                Detector_Counter2 <= Detector_Counter2 + 1;
                Detector_Counter3 <= Detector_Counter3 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;
            
            when 4 =>
                Lock_Counter <= Lock_Counter + 1;          
                Detector_Counter0 <= Detector_Counter0 + 1;
                Detector_Counter1 <= Detector_Counter1 + 1;
                Detector_Counter2 <= Detector_Counter2 + 1;
                Detector_Counter3 <= Detector_Counter3 + 1;
                Detector_Counter4 <= Detector_Counter4 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
            when 5 =>
                Lock_Counter <= Lock_Counter + 1;          
                Detector_Counter0 <= Detector_Counter0 + 1;
                Detector_Counter1 <= Detector_Counter1 + 1;
                Detector_Counter2 <= Detector_Counter2 + 1;
                Detector_Counter3 <= Detector_Counter3 + 1;
                Detector_Counter4 <= Detector_Counter4 + 1;
                Detector_Counter5 <= Detector_Counter5 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;            
            
            when 6 =>
                Lock_Counter <= Lock_Counter + 1;          
                Detector_Counter0 <= Detector_Counter0 + 1;
                Detector_Counter1 <= Detector_Counter1 + 1;
                Detector_Counter2 <= Detector_Counter2 + 1;
                Detector_Counter3 <= Detector_Counter3 + 1;
                Detector_Counter4 <= Detector_Counter4 + 1;
                Detector_Counter5 <= Detector_Counter5 + 1;
                Detector_Counter6 <= Detector_Counter6 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
            when 7 =>
                Lock_Counter <= Lock_Counter + 1;          
                Detector_Counter0 <= Detector_Counter0 + 1;
                Detector_Counter1 <= Detector_Counter1 + 1;
                Detector_Counter2 <= Detector_Counter2 + 1;
                Detector_Counter3 <= Detector_Counter3 + 1;
                Detector_Counter4 <= Detector_Counter4 + 1;
                Detector_Counter5 <= Detector_Counter5 + 1;
                Detector_Counter6 <= Detector_Counter6 + 1;
                Detector_Counter7 <= Detector_Counter7 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;            
            
            when 8 =>
                Lock_Counter <= Lock_Counter + 1;          
                Detector_Counter0 <= Detector_Counter0 + 1;
                Detector_Counter1 <= Detector_Counter1 + 1;
                Detector_Counter2 <= Detector_Counter2 + 1;
                Detector_Counter3 <= Detector_Counter3 + 1;
                Detector_Counter4 <= Detector_Counter4 + 1;
                Detector_Counter5 <= Detector_Counter5 + 1;
                Detector_Counter6 <= Detector_Counter6 + 1;
                Detector_Counter7 <= Detector_Counter7 + 1;
                Detector_Counter8 <= Detector_Counter8 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

            
            when 9 =>
                Lock_Counter <= Lock_Counter + 1;          
                Detector_Counter0 <= Detector_Counter0 + 1;
                Detector_Counter1 <= Detector_Counter1 + 1;
                Detector_Counter2 <= Detector_Counter2 + 1;
                Detector_Counter3 <= Detector_Counter3 + 1;
                Detector_Counter4 <= Detector_Counter4 + 1;
                Detector_Counter5 <= Detector_Counter5 + 1;
                Detector_Counter6 <= Detector_Counter6 + 1;
                Detector_Counter7 <= Detector_Counter7 + 1;
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;
            
            when 10 =>
                Lock_Counter <= Lock_Counter + 1;          
                Detector_Counter0 <= Detector_Counter0 + 1;
                Detector_Counter1 <= Detector_Counter1 + 1;
                Detector_Counter2 <= Detector_Counter2 + 1;
                Detector_Counter3 <= Detector_Counter3 + 1;
                Detector_Counter4 <= Detector_Counter4 + 1;
                Detector_Counter5 <= Detector_Counter5 + 1;
                Detector_Counter6 <= Detector_Counter6 + 1;
                Detector_Counter7 <= Detector_Counter7 + 1;
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;
                Detector_Counter10 <= Detector_Counter10 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
        
            when 11 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                
                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;
            
            when 12 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

            when 13 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;
            
            when 14 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;
            
            when 15 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;
            
            when 16 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                
                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;
            
            when 17 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;
            
            when 18 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;
            
            when 19 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;
            
            when 20 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;
            
            when 21 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;          

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;
            
            when 22 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;
            
            when 23 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;
            
            when 24 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;
                
            when 25 =>
                Lock_Counter <= Lock_Counter + 1;             
                Detector_Counter0 <= Detector_Counter0 + 1;   
                Detector_Counter1 <= Detector_Counter1 + 1;   
                Detector_Counter2 <= Detector_Counter2 + 1;   
                Detector_Counter3 <= Detector_Counter3 + 1;   
                Detector_Counter4 <= Detector_Counter4 + 1;   
                Detector_Counter5 <= Detector_Counter5 + 1;   
                Detector_Counter6 <= Detector_Counter6 + 1;   
                Detector_Counter7 <= Detector_Counter7 + 1;   
                Detector_Counter8 <= Detector_Counter8 + 1;   
                Detector_Counter9 <= Detector_Counter9 + 1;   
                Detector_Counter10 <= Detector_Counter10 + 1; 
                Detector_Counter11 <= Detector_Counter11 + 1; 
                Detector_Counter12 <= Detector_Counter12 + 1; 
                Detector_Counter13 <= Detector_Counter13 + 1; 
                Detector_Counter14 <= Detector_Counter14 + 1; 
                Detector_Counter15 <= Detector_Counter15 + 1; 
                Detector_Counter16 <= Detector_Counter16 + 1; 
                Detector_Counter17 <= Detector_Counter17 + 1; 
                Detector_Counter18 <= Detector_Counter18 + 1; 
                Detector_Counter19 <= Detector_Counter19 + 1; 
                Detector_Counter20 <= Detector_Counter20 + 1; 
                Detector_Counter21 <= Detector_Counter21 + 1; 
                Detector_Counter22 <= Detector_Counter22 + 1; 
                Detector_Counter23 <= Detector_Counter23 + 1; 
                Detector_Counter24 <= Detector_Counter24 + 1; 
                Detector_Counter25 <= Detector_Counter25 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;
                
            when 26 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;
                
            when 27 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;
                
            when 28 =>
                Lock_Counter <= Lock_Counter + 1;             
                Detector_Counter0 <= Detector_Counter0 + 1;   
                Detector_Counter1 <= Detector_Counter1 + 1;   
                Detector_Counter2 <= Detector_Counter2 + 1;   
                Detector_Counter3 <= Detector_Counter3 + 1;   
                Detector_Counter4 <= Detector_Counter4 + 1;   
                Detector_Counter5 <= Detector_Counter5 + 1;   
                Detector_Counter6 <= Detector_Counter6 + 1;   
                Detector_Counter7 <= Detector_Counter7 + 1;   
                Detector_Counter8 <= Detector_Counter8 + 1;   
                Detector_Counter9 <= Detector_Counter9 + 1;   
                Detector_Counter10 <= Detector_Counter10 + 1; 
                Detector_Counter11 <= Detector_Counter11 + 1; 
                Detector_Counter12 <= Detector_Counter12 + 1; 
                Detector_Counter13 <= Detector_Counter13 + 1; 
                Detector_Counter14 <= Detector_Counter14 + 1; 
                Detector_Counter15 <= Detector_Counter15 + 1; 
                Detector_Counter16 <= Detector_Counter16 + 1; 
                Detector_Counter17 <= Detector_Counter17 + 1; 
                Detector_Counter18 <= Detector_Counter18 + 1; 
                Detector_Counter19 <= Detector_Counter19 + 1; 
                Detector_Counter20 <= Detector_Counter20 + 1; 
                Detector_Counter21 <= Detector_Counter21 + 1; 
                Detector_Counter22 <= Detector_Counter22 + 1; 
                Detector_Counter23 <= Detector_Counter23 + 1; 
                Detector_Counter24 <= Detector_Counter24 + 1; 
                Detector_Counter25 <= Detector_Counter25 + 1; 
                Detector_Counter26 <= Detector_Counter26 + 1; 
                Detector_Counter27 <= Detector_Counter27 + 1; 
                Detector_Counter28 <= Detector_Counter28 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;
     
            when 29 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                
                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

            when 30 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;
                
            when 31 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= 0;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         if(Error_Counter0 < 4) then
                            Error_Counter0 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter0 > 26) then
                            Error_Counter0 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                            Spectrum_inversion <= '1';
                         else
                            Lock <= '0';
                            Error_Counter0 <= "00000";
                         end if;
                else
                        if(Error_Counter0 < 5) then
                            Error_Counter0 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter0 > 27) then
                           Error_Counter0 <= "00000";  
                           Lock <= '1';                
                           Data_Valid <= '1';          
                           Flag_Sync_Word <= 1;        
                           Spectrum_inversion <= '1';  
                        else
                            Lock <= '0';
                            Error_Counter0 <= "00000";
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;

            when 32 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= 0;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         if(Error_Counter1 < 4) then
                            Error_Counter1 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter1 > 26) then
                            Error_Counter1 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                         else
                            Lock <= '0';
                            Error_Counter1 <= "00000";
                         end if;
                else
                        if(Error_Counter1 < 5) then
                            Error_Counter1 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter1 > 27) then
                            Error_Counter1 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                        else
                            Lock <= '0';
                            Error_Counter1 <= "00000";
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
                
            when 33 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= 0;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         if(Error_Counter2 < 4) then
                            Error_Counter2 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter2 > 26) then
                            Error_Counter2 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                         else
                            Error_Counter2 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter2 < 5) then
                            Error_Counter2 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter2 > 27) then
                           Error_Counter2 <= "00000";  
                           Lock <= '1';                
                           Data_Valid <= '1';          
                           Flag_Sync_Word <= 1;        
                           Spectrum_inversion <= '1';  
                        else
                            Lock <= '0';
                            Error_Counter2 <= "00000";
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;                
                
            when 34 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= 0;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;
                            
                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         if(Error_Counter3 < 4) then
                            Error_Counter3 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter3 > 26) then
                            Error_Counter3 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                         else
                            Error_Counter3 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter3 < 5) then
                            Error_Counter3 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter3 > 27) then
                           Error_Counter3 <= "00000";  
                           Lock <= '1';                
                           Data_Valid <= '1';          
                           Flag_Sync_Word <= 1;        
                           Spectrum_inversion <= '1';  
                        else
                            Lock <= '0';
                            Error_Counter3 <= "00000";
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
                
            when 35 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <=  0;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         if(Error_Counter4 < 4) then
                            Error_Counter4 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter4 > 26) then
                            Error_Counter4 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                         else
                            Error_Counter4 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter4 < 5) then
                            Error_Counter4 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter4 > 27) then
                           Error_Counter4 <= "00000";  
                           Lock <= '1';                
                           Data_Valid <= '1';          
                           Flag_Sync_Word <= 1;        
                           Spectrum_inversion <= '1';  
                        else
                            Error_Counter4 <= "00000";
                            Lock <= '0';
                        end if;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
                
            when 36 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= 0;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         if(Error_Counter5 < 4) then
                            Error_Counter5 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter5 > 26) then
                            Error_Counter5 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                         else
                            Error_Counter5 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter5 < 5) then
                            Error_Counter5 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter5 > 27) then
                           Error_Counter5 <= "00000";  
                           Lock <= '1';                
                           Data_Valid <= '1';          
                           Flag_Sync_Word <= 1;        
                           Spectrum_inversion <= '1';  
                        else
                            Error_Counter5 <= "00000";
                            Lock <= '0';
                        end if;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
                
            when 37 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= 0;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         if(Error_Counter6 < 4) then
                            Error_Counter6 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter6 > 26) then
                            Error_Counter6 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                         else
                            Error_Counter6 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter6 < 5) then
                            Error_Counter6 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter6 > 27) then
                           Error_Counter6 <= "00000";  
                           Lock <= '1';                
                           Data_Valid <= '1';          
                           Flag_Sync_Word <= 1;        
                           Spectrum_inversion <= '1';  
                        else
                            Error_Counter6 <= "00000";
                            Lock <= '0';
                        end if;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
                
            when 38 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= 0;  
                Detector_Counter8 <= Detector_Counter8 + 1;  
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         if(Error_Counter7 < 4) then
                            Error_Counter7 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter7 > 26) then
                            Error_Counter7 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                         else
                            Error_Counter7 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter7 < 5) then
                            Error_Counter7 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter7 > 27) then
                           Error_Counter7 <= "00000";  
                           Lock <= '1';                
                           Data_Valid <= '1';          
                           Flag_Sync_Word <= 1;        
                           Spectrum_inversion <= '1';  
                        else
                            Error_Counter7 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
                
            when 39 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= 0;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         if(Error_Counter8 < 4) then
                            Error_Counter8 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter8 > 26) then
                            Error_Counter8 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                         else
                            Error_Counter8 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter8 < 5) then
                            Error_Counter8 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter8 > 27) then
                           Error_Counter8 <= "00000";  
                           Lock <= '1';                
                           Data_Valid <= '1';          
                           Flag_Sync_Word <= 1;        
                           Spectrum_inversion <= '1';  
                        else
                            Error_Counter8 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
                
            when 40 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= 0;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         if(Error_Counter9 < 4) then
                            Error_Counter9 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter9 > 26) then
                            Error_Counter9 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                         else
                            Error_Counter9 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter9 < 5) then
                            Error_Counter9 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter9 > 27) then
                            Error_Counter9 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                        else
                            Error_Counter9 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
                
            when 41 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= 0;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;           

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         if(Error_Counter10 < 4) then
                            Error_Counter10 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter10 > 26) then
                            Error_Counter10 <= "00000";  
                            Lock <= '1';                
                            Data_Valid <= '1';          
                            Flag_Sync_Word <= 1;        
                            Spectrum_inversion <= '1';  
                         else
                            Error_Counter10 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter10 < 5) then
                            Error_Counter10 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter10 > 27) then
                           Error_Counter10 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter10 <= "00000";
                            Lock <= '0';
                        end if;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
                
            when 42 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= 0;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;                   

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         if(Error_Counter11 < 4) then
                            Error_Counter11 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter11 > 26) then
                            Error_Counter11 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter11 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter11 < 5) then
                            Error_Counter11 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter11 > 27) then
                           Error_Counter11 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter11 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 43 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= 0;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         if(Error_Counter12 < 4) then
                            Error_Counter12 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter12 > 26) then
                            Error_Counter12 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter12 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter12 < 5) then
                            Error_Counter12 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter12 > 27) then
                           Error_Counter12 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter12 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 44 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= 0;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         if(Error_Counter13 < 4) then
                            Error_Counter13 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter13 > 26) then
                            Error_Counter13 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter13 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter13 < 5) then
                            Error_Counter13 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter13 > 27) then
                           Error_Counter13 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter13 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
                
            when 45 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= 0;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;                

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         if(Error_Counter14 < 4) then
                            Error_Counter14 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter14 > 26) then
                            Error_Counter14 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter14 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter14 < 5) then
                            Error_Counter14 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter14 > 27) then
                           Error_Counter14 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter14 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 46 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= 0;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         if(Error_Counter15 < 4) then
                            Error_Counter15 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter15 > 26) then
                            Error_Counter15 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter15 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter15 < 5) then
                            Error_Counter15 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter15 > 27) then
                            Error_Counter15 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                        else
                            Error_Counter15 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 47 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= 0;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;           

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         if(Error_Counter16 < 4) then
                            Error_Counter16 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter16 > 26) then
                            Error_Counter16 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter16 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter16 < 5) then
                            Error_Counter16 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter16 > 27) then
                           Error_Counter16 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter16 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 48 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= 0;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         if(Error_Counter17 < 4) then
                            Error_Counter17 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter17 > 26) then
                            Error_Counter17 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter17 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter17 < 5) then
                            Error_Counter17 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter17 > 27) then
                           Error_Counter17 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter17 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 49 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= 0;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;           

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         if(Error_Counter18 < 4) then
                            Error_Counter18 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter18 > 26) then
                            Error_Counter18 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter18 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter18 < 5) then
                            Error_Counter18 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter18 > 27) then
                           Error_Counter18 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter18 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 50 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= 0;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         if(Error_Counter19 < 4) then
                            Error_Counter19 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter19 > 26) then
                            Error_Counter19 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter19 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter19 < 5) then
                            Error_Counter19 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter19 > 27) then
                           Error_Counter19 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter19 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
          
            when 51 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= 0;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;           

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         if(Error_Counter20 < 4) then
                            Error_Counter20 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter20 > 26) then
                            Error_Counter20 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter20 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter20 < 5) then
                            Error_Counter20 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter20 > 27) then
                           Error_Counter20 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter20 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 52 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= 0;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         if(Error_Counter21 < 4) then
                            Error_Counter21 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter21 > 26) then
                            Error_Counter21 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter21 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter21 < 5) then
                            Error_Counter21 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter21 > 27) then
                            Error_Counter21 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                        else
                            Error_Counter21 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
          
            when 53 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= 0;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         if(Error_Counter22 < 4) then
                            Error_Counter22 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter22 > 26) then
                            Error_Counter22 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter22 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter22 < 5) then
                            Error_Counter22 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter22 > 27) then
                            Error_Counter22 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                        else
                            Error_Counter22 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
          
            when 54 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= 0;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;             

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         if(Error_Counter23 < 4) then
                            Error_Counter23 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter23 > 26) then
                            Error_Counter23 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter23 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter23 < 5) then
                            Error_Counter23 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter23 > 27) then
                           Error_Counter23 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter23 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
          
            when 55 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= 0;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         if(Error_Counter24 < 4) then
                            Error_Counter24 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter24 > 26) then
                            Error_Counter24 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter24 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter24 < 5) then
                            Error_Counter24 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter24 > 27) then
                           Error_Counter24 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter24 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 56 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= 0;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         if(Error_Counter25 < 4) then
                            Error_Counter25 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter25 > 26) then
                            Error_Counter25 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter25 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter25 < 5) then
                            Error_Counter25 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter25 > 27) then
                            Error_Counter25 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                        else
                            Error_Counter25 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 57 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= 0;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         if(Error_Counter26 < 4) then
                            Error_Counter26 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter26 > 26) then
                            Error_Counter26 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter26 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter26 < 5) then
                            Error_Counter26 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter26 > 27) then
                           Error_Counter26 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter26 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 58 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= 0;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         if(Error_Counter27 < 4) then
                            Error_Counter27 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter27 > 26) then
                            Error_Counter27 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter27 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter27 < 5) then
                            Error_Counter27 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter27 > 27) then
                           Error_Counter27 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter27 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
          
            when 59 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= 0;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         if(Error_Counter28 < 4) then
                            Error_Counter28 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter28 > 26) then
                            Error_Counter28 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter28 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter28 < 5) then
                            Error_Counter28 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter28 > 27) then
                            Error_Counter28 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                        else
                            Error_Counter28 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
           
            when 60 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= 0;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         if(Error_Counter29 < 4) then
                            Error_Counter29 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter29 > 26) then
                            Error_Counter29 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter29 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter29 < 5) then
                            Error_Counter29 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter29 > 27) then
                           Error_Counter29 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter29 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;
          
            when 61 =>
                Lock_Counter <= Lock_Counter + 1;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= 0;
                Detector_Counter31 <= Detector_Counter31 + 1;            

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         if(Error_Counter30 < 4) then
                            Error_Counter30 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter30 > 26) then
                            Error_Counter30 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter30 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter30 < 5) then
                            Error_Counter30 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter30 > 27) then
                            Error_Counter30 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                        else
                            Error_Counter30 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         Error_Counter31 <= Error_Counter31 + 1;
                end if;

           
            when 62 =>
                Lock_Counter <= 31;            
                Detector_Counter0 <= Detector_Counter0 + 1;  
                Detector_Counter1 <= Detector_Counter1 + 1;  
                Detector_Counter2 <= Detector_Counter2 + 1;  
                Detector_Counter3 <= Detector_Counter3 + 1;  
                Detector_Counter4 <= Detector_Counter4 + 1;  
                Detector_Counter5 <= Detector_Counter5 + 1;  
                Detector_Counter6 <= Detector_Counter6 + 1;  
                Detector_Counter7 <= Detector_Counter7 + 1;  
                Detector_Counter8 <= Detector_Counter8 + 1;
                Detector_Counter9 <= Detector_Counter9 + 1;  
                Detector_Counter10 <= Detector_Counter10 + 1;
                Detector_Counter11 <= Detector_Counter11 + 1;
                Detector_Counter12 <= Detector_Counter12 + 1;
                Detector_Counter13 <= Detector_Counter13 + 1;
                Detector_Counter14 <= Detector_Counter14 + 1;
                Detector_Counter15 <= Detector_Counter15 + 1;
                Detector_Counter16 <= Detector_Counter16 + 1;
                Detector_Counter17 <= Detector_Counter17 + 1;
                Detector_Counter18 <= Detector_Counter18 + 1;
                Detector_Counter19 <= Detector_Counter19 + 1;
                Detector_Counter20 <= Detector_Counter20 + 1;
                Detector_Counter21 <= Detector_Counter21 + 1;
                Detector_Counter22 <= Detector_Counter22 + 1;
                Detector_Counter23 <= Detector_Counter23 + 1;
                Detector_Counter24 <= Detector_Counter24 + 1;
                Detector_Counter25 <= Detector_Counter25 + 1;
                Detector_Counter26 <= Detector_Counter26 + 1;
                Detector_Counter27 <= Detector_Counter27 + 1;
                Detector_Counter28 <= Detector_Counter28 + 1;
                Detector_Counter29 <= Detector_Counter29 + 1;
                Detector_Counter30 <= Detector_Counter30 + 1;
                Detector_Counter31 <= 0;

                if(Serial_Data /= Sync_Word(Detector_Counter0)) then
                         Error_Counter0 <= Error_Counter0 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter1)) then
                         Error_Counter1 <= Error_Counter1 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter2)) then
                         Error_Counter2 <= Error_Counter2 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter3)) then
                         Error_Counter3 <= Error_Counter3 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter4)) then
                         Error_Counter4 <= Error_Counter4 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter5)) then
                         Error_Counter5 <= Error_Counter5 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter6)) then
                         Error_Counter6 <= Error_Counter6 + 1;
                end if;
            
                if(Serial_Data /= Sync_Word(Detector_Counter7)) then
                         Error_Counter7 <= Error_Counter7 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter8)) then
                         Error_Counter8 <= Error_Counter8 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter9)) then
                         Error_Counter9 <= Error_Counter9 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter10)) then
                         Error_Counter10 <= Error_Counter10 + 1;
                end if;
                
                if(Serial_Data /= Sync_Word(Detector_Counter11)) then
                         Error_Counter11 <= Error_Counter11 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter12)) then
                         Error_Counter12 <= Error_Counter12 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter13)) then
                         Error_Counter13 <= Error_Counter13 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter14)) then
                         Error_Counter14 <= Error_Counter14 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter15)) then
                         Error_Counter15 <= Error_Counter15 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter16)) then
                         Error_Counter16 <= Error_Counter16 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter17)) then
                         Error_Counter17 <= Error_Counter17 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter18)) then
                         Error_Counter18 <= Error_Counter18 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter19)) then
                         Error_Counter19 <= Error_Counter19 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter20)) then
                         Error_Counter20 <= Error_Counter20 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter21)) then
                         Error_Counter21 <= Error_Counter21 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter22)) then
                         Error_Counter22 <= Error_Counter22 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter23)) then
                         Error_Counter23 <= Error_Counter23 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter24)) then
                         Error_Counter24 <= Error_Counter24 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter25)) then
                         Error_Counter25 <= Error_Counter25 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter26)) then
                         Error_Counter26 <= Error_Counter26 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter27)) then
                         Error_Counter27 <= Error_Counter27 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter28)) then
                         Error_Counter28 <= Error_Counter28 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter29)) then
                         Error_Counter29 <= Error_Counter29 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter30)) then
                         Error_Counter30 <= Error_Counter30 + 1;
                end if;

                if(Serial_Data /= Sync_Word(Detector_Counter31)) then
                         if(Error_Counter31 < 4) then
                            Error_Counter31 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                         elsif(Error_Counter31 > 26) then
                            Error_Counter31 <= "00000";  
                            Lock <= '1';                 
                            Data_Valid <= '1';           
                            Flag_Sync_Word <= 1;         
                            Spectrum_inversion <= '1';   
                         else
                            Error_Counter31 <= "00000";
                            Lock <= '0';
                         end if;
                else
                        if(Error_Counter31 < 5) then
                            Error_Counter31 <= "00000";
                            Lock <= '1';
                            Data_Valid <= '1';
                            Flag_Sync_Word <= 1;
                        elsif(Error_Counter31 > 27) then
                           Error_Counter31 <= "00000";  
                           Lock <= '1';                 
                           Data_Valid <= '1';           
                           Flag_Sync_Word <= 1;         
                           Spectrum_inversion <= '1';   
                        else
                            Error_Counter31 <= "00000";
                            Lock <= '0';
                        end if;
                end if;

            
          end case;
            
        when 1 => --Paket alýnma durumu
           if(Packet_Bit_Counter = (Packet_Length - 33)) then -- Paket Sayacý
               Data_Valid <= '0';
               Packet_Bit_Counter <= (others => '0');
               Flag_Sync_Word <= 0;
               Spectrum_inversion <= '0';
           else
               Packet_Bit_Counter <= Packet_Bit_Counter + 1;
           end if;            
           
           Lock_Counter <= 0;            
           Detector_Counter0 <=  0;
           Detector_Counter1 <=  0;
           Detector_Counter2 <=  0;
           Detector_Counter3 <=  0;
           Detector_Counter4 <=  0;
           Detector_Counter5 <=  0;
           Detector_Counter6 <=  0;
           Detector_Counter7 <=  0;
           Detector_Counter8 <=  0;
           Detector_Counter9 <=  0;
           Detector_Counter10 <= 0;
           Detector_Counter11 <= 0;
           Detector_Counter12 <= 0;
           Detector_Counter13 <= 0;
           Detector_Counter14 <= 0;
           Detector_Counter15 <= 0;
           Detector_Counter16 <= 0;
           Detector_Counter17 <= 0;
           Detector_Counter18 <= 0;
           Detector_Counter19 <= 0;
           Detector_Counter20 <= 0;
           Detector_Counter21 <= 0;
           Detector_Counter22 <= 0;
           Detector_Counter23 <= 0;
           Detector_Counter24 <= 0;
           Detector_Counter25 <= 0;
           Detector_Counter26 <= 0;
           Detector_Counter27 <= 0;
           Detector_Counter28 <= 0;
           Detector_Counter29 <= 0;
           Detector_Counter30 <= 0;
           Detector_Counter31 <= 0;
           Error_Counter0 <=  "00000";
           Error_Counter1 <=  "00000";
           Error_Counter2 <=  "00000";
           Error_Counter3 <=  "00000";
           Error_Counter4 <=  "00000";
           Error_Counter5 <=  "00000";
           Error_Counter6 <=  "00000";
           Error_Counter7 <=  "00000";
           Error_Counter8 <=  "00000";
           Error_Counter9 <=  "00000";
           Error_Counter10 <= "00000";
           Error_Counter11 <= "00000";
           Error_Counter12 <= "00000";
           Error_Counter13 <= "00000";
           Error_Counter14 <= "00000";
           Error_Counter15 <= "00000";
           Error_Counter16 <= "00000";
           Error_Counter17 <= "00000";
           Error_Counter18 <= "00000";
           Error_Counter19 <= "00000";
           Error_Counter20 <= "00000";
           Error_Counter21 <= "00000";
           Error_Counter22 <= "00000";
           Error_Counter23 <= "00000";
           Error_Counter24 <= "00000";
           Error_Counter25 <= "00000";
           Error_Counter26 <= "00000";
           Error_Counter27 <= "00000";
           Error_Counter28 <= "00000";
           Error_Counter29 <= "00000";
           Error_Counter30 <= "00000";
           Error_Counter31 <= "00000";
    end case;
    
    when OTHERS =>
    Data_Valid <= '0';
    Packet_Bit_Counter <= (others => '0');
    Spectrum_inversion <= '0';
    Flag_Sync_Word <= 0;
    Lock <= '0';
    Lock_Counter <= 0;            
    Detector_Counter0 <=  0;
    Detector_Counter1 <=  0;
    Detector_Counter2 <=  0;
    Detector_Counter3 <=  0;
    Detector_Counter4 <=  0;
    Detector_Counter5 <=  0;
    Detector_Counter6 <=  0;
    Detector_Counter7 <=  0;
    Detector_Counter8 <=  0;
    Detector_Counter9 <=  0;
    Detector_Counter10 <= 0;
    Detector_Counter11 <= 0;
    Detector_Counter12 <= 0;
    Detector_Counter13 <= 0;
    Detector_Counter14 <= 0;
    Detector_Counter15 <= 0;
    Detector_Counter16 <= 0;
    Detector_Counter17 <= 0;
    Detector_Counter18 <= 0;
    Detector_Counter19 <= 0;
    Detector_Counter20 <= 0;
    Detector_Counter21 <= 0;
    Detector_Counter22 <= 0;
    Detector_Counter23 <= 0;
    Detector_Counter24 <= 0;
    Detector_Counter25 <= 0;
    Detector_Counter26 <= 0;
    Detector_Counter27 <= 0;
    Detector_Counter28 <= 0;
    Detector_Counter29 <= 0;
    Detector_Counter30 <= 0;
    Detector_Counter31 <= 0;
    Error_Counter0 <=  "00000";
    Error_Counter1 <=  "00000";
    Error_Counter2 <=  "00000";
    Error_Counter3 <=  "00000";
    Error_Counter4 <=  "00000";
    Error_Counter5 <=  "00000";
    Error_Counter6 <=  "00000";
    Error_Counter7 <=  "00000";
    Error_Counter8 <=  "00000";
    Error_Counter9 <=  "00000";
    Error_Counter10 <= "00000";
    Error_Counter11 <= "00000";
    Error_Counter12 <= "00000";
    Error_Counter13 <= "00000";
    Error_Counter14 <= "00000";
    Error_Counter15 <= "00000";
    Error_Counter16 <= "00000";
    Error_Counter17 <= "00000";
    Error_Counter18 <= "00000";
    Error_Counter19 <= "00000";
    Error_Counter20 <= "00000";
    Error_Counter21 <= "00000";
    Error_Counter22 <= "00000";
    Error_Counter23 <= "00000";
    Error_Counter24 <= "00000";
    Error_Counter25 <= "00000";
    Error_Counter26 <= "00000";
    Error_Counter27 <= "00000";
    Error_Counter28 <= "00000";
    Error_Counter29 <= "00000";
    Error_Counter30 <= "00000";
    Error_Counter31 <= "00000";
    bit24_Lock_Counter <= 0;            
    bit24_Detector_Counter0 <=  0;
    bit24_Detector_Counter1 <=  0;
    bit24_Detector_Counter2 <=  0;
    bit24_Detector_Counter3 <=  0;
    bit24_Detector_Counter4 <=  0;
    bit24_Detector_Counter5 <=  0;
    bit24_Detector_Counter6 <=  0;
    bit24_Detector_Counter7 <=  0;
    bit24_Detector_Counter8 <=  0;
    bit24_Detector_Counter9 <=  0;
    bit24_Detector_Counter10 <= 0;
    bit24_Detector_Counter11 <= 0;
    bit24_Detector_Counter12 <= 0;
    bit24_Detector_Counter13 <= 0;
    bit24_Detector_Counter14 <= 0;
    bit24_Detector_Counter15 <= 0;
    bit24_Detector_Counter16 <= 0;
    bit24_Detector_Counter17 <= 0;
    bit24_Detector_Counter18 <= 0;
    bit24_Detector_Counter19 <= 0;
    bit24_Detector_Counter20 <= 0;
    bit24_Detector_Counter21 <= 0;
    bit24_Detector_Counter22 <= 0;
    bit24_Detector_Counter23 <= 0;
    bit24_Error_Counter0 <=  "00000";
    bit24_Error_Counter1 <=  "00000";
    bit24_Error_Counter2 <=  "00000";
    bit24_Error_Counter3 <=  "00000";
    bit24_Error_Counter4 <=  "00000";
    bit24_Error_Counter5 <=  "00000";
    bit24_Error_Counter6 <=  "00000";
    bit24_Error_Counter7 <=  "00000";
    bit24_Error_Counter8 <=  "00000";
    bit24_Error_Counter9 <=  "00000";
    bit24_Error_Counter10 <= "00000";
    bit24_Error_Counter11 <= "00000";
    bit24_Error_Counter12 <= "00000";
    bit24_Error_Counter13 <= "00000";
    bit24_Error_Counter14 <= "00000";
    bit24_Error_Counter15 <= "00000";
    bit24_Error_Counter16 <= "00000";
    bit24_Error_Counter17 <= "00000";
    bit24_Error_Counter18 <= "00000";
    bit24_Error_Counter19 <= "00000";
    bit24_Error_Counter20 <= "00000";
    bit24_Error_Counter21 <= "00000";
    bit24_Error_Counter22 <= "00000";
    bit24_Error_Counter23 <= "00000";
    bit16_Lock_Counter <= 0;            
    bit16_Detector_Counter0 <=  0;
    bit16_Detector_Counter1 <=  0;
    bit16_Detector_Counter2 <=  0;
    bit16_Detector_Counter3 <=  0;
    bit16_Detector_Counter4 <=  0;
    bit16_Detector_Counter5 <=  0;
    bit16_Detector_Counter6 <=  0;
    bit16_Detector_Counter7 <=  0;
    bit16_Detector_Counter8 <=  0;
    bit16_Detector_Counter9 <=  0;
    bit16_Detector_Counter10 <=  0;
    bit16_Detector_Counter11 <=  0;
    bit16_Detector_Counter12 <=  0;
    bit16_Detector_Counter13 <=  0;
    bit16_Detector_Counter14 <=  0;
    bit16_Detector_Counter15 <=  0;
    bit16_Error_Counter0 <=  "0000";
    bit16_Error_Counter1 <=  "0000";
    bit16_Error_Counter2 <=  "0000";
    bit16_Error_Counter3 <=  "0000";
    bit16_Error_Counter4 <=  "0000";
    bit16_Error_Counter5 <=  "0000";
    bit16_Error_Counter6 <=  "0000";
    bit16_Error_Counter7 <=  "0000";
    bit16_Error_Counter8 <=  "0000";
    bit16_Error_Counter9 <=  "0000";
    bit16_Error_Counter10 <=  "0000";
    bit16_Error_Counter11 <=  "0000";
    bit16_Error_Counter12 <=  "0000";
    bit16_Error_Counter13 <=  "0000";
    bit16_Error_Counter14 <=  "0000";
    bit16_Error_Counter15 <=  "0000";
    bit8_Lock_Counter <= 0;            
    bit8_Detector_Counter0 <=  0;
    bit8_Detector_Counter1 <=  0;
    bit8_Detector_Counter2 <=  0;
    bit8_Detector_Counter3 <=  0;
    bit8_Detector_Counter4 <=  0;
    bit8_Detector_Counter5 <=  0;
    bit8_Detector_Counter6 <=  0;
    bit8_Detector_Counter7 <=  0;
    bit8_Error_Counter0 <=  "000";
    bit8_Error_Counter1 <=  "000";
    bit8_Error_Counter2 <=  "000";
    bit8_Error_Counter3 <=  "000";
    bit8_Error_Counter4 <=  "000";
    bit8_Error_Counter5 <=  "000";
    bit8_Error_Counter6 <=  "000";
    bit8_Error_Counter7 <=  "000";
    Reg_Byte_Length_of_Sync_Word <= (others => '0');
    Reg_Sync_Word <= (others => '0');
  end case;
else
Data_Valid <= '0';
Packet_Bit_Counter <= (others => '0');
Spectrum_inversion <= '0';
Flag_Sync_Word <= 0;
Lock <= '0';
Lock_Counter <= 0;            
Detector_Counter0 <=  0;
Detector_Counter1 <=  0;
Detector_Counter2 <=  0;
Detector_Counter3 <=  0;
Detector_Counter4 <=  0;
Detector_Counter5 <=  0;
Detector_Counter6 <=  0;
Detector_Counter7 <=  0;
Detector_Counter8 <=  0;
Detector_Counter9 <=  0;
Detector_Counter10 <= 0;
Detector_Counter11 <= 0;
Detector_Counter12 <= 0;
Detector_Counter13 <= 0;
Detector_Counter14 <= 0;
Detector_Counter15 <= 0;
Detector_Counter16 <= 0;
Detector_Counter17 <= 0;
Detector_Counter18 <= 0;
Detector_Counter19 <= 0;
Detector_Counter20 <= 0;
Detector_Counter21 <= 0;
Detector_Counter22 <= 0;
Detector_Counter23 <= 0;
Detector_Counter24 <= 0;
Detector_Counter25 <= 0;
Detector_Counter26 <= 0;
Detector_Counter27 <= 0;
Detector_Counter28 <= 0;
Detector_Counter29 <= 0;
Detector_Counter30 <= 0;
Detector_Counter31 <= 0;
Error_Counter0 <=  "00000";
Error_Counter1 <=  "00000";
Error_Counter2 <=  "00000";
Error_Counter3 <=  "00000";
Error_Counter4 <=  "00000";
Error_Counter5 <=  "00000";
Error_Counter6 <=  "00000";
Error_Counter7 <=  "00000";
Error_Counter8 <=  "00000";
Error_Counter9 <=  "00000";
Error_Counter10 <= "00000";
Error_Counter11 <= "00000";
Error_Counter12 <= "00000";
Error_Counter13 <= "00000";
Error_Counter14 <= "00000";
Error_Counter15 <= "00000";
Error_Counter16 <= "00000";
Error_Counter17 <= "00000";
Error_Counter18 <= "00000";
Error_Counter19 <= "00000";
Error_Counter20 <= "00000";
Error_Counter21 <= "00000";
Error_Counter22 <= "00000";
Error_Counter23 <= "00000";
Error_Counter24 <= "00000";
Error_Counter25 <= "00000";
Error_Counter26 <= "00000";
Error_Counter27 <= "00000";
Error_Counter28 <= "00000";
Error_Counter29 <= "00000";
Error_Counter30 <= "00000";
Error_Counter31 <= "00000";
bit24_Lock_Counter <= 0;            
bit24_Detector_Counter0 <=  0;
bit24_Detector_Counter1 <=  0;
bit24_Detector_Counter2 <=  0;
bit24_Detector_Counter3 <=  0;
bit24_Detector_Counter4 <=  0;
bit24_Detector_Counter5 <=  0;
bit24_Detector_Counter6 <=  0;
bit24_Detector_Counter7 <=  0;
bit24_Detector_Counter8 <=  0;
bit24_Detector_Counter9 <=  0;
bit24_Detector_Counter10 <= 0;
bit24_Detector_Counter11 <= 0;
bit24_Detector_Counter12 <= 0;
bit24_Detector_Counter13 <= 0;
bit24_Detector_Counter14 <= 0;
bit24_Detector_Counter15 <= 0;
bit24_Detector_Counter16 <= 0;
bit24_Detector_Counter17 <= 0;
bit24_Detector_Counter18 <= 0;
bit24_Detector_Counter19 <= 0;
bit24_Detector_Counter20 <= 0;
bit24_Detector_Counter21 <= 0;
bit24_Detector_Counter22 <= 0;
bit24_Detector_Counter23 <= 0;
bit24_Error_Counter0 <=  "00000";
bit24_Error_Counter1 <=  "00000";
bit24_Error_Counter2 <=  "00000";
bit24_Error_Counter3 <=  "00000";
bit24_Error_Counter4 <=  "00000";
bit24_Error_Counter5 <=  "00000";
bit24_Error_Counter6 <=  "00000";
bit24_Error_Counter7 <=  "00000";
bit24_Error_Counter8 <=  "00000";
bit24_Error_Counter9 <=  "00000";
bit24_Error_Counter10 <= "00000";
bit24_Error_Counter11 <= "00000";
bit24_Error_Counter12 <= "00000";
bit24_Error_Counter13 <= "00000";
bit24_Error_Counter14 <= "00000";
bit24_Error_Counter15 <= "00000";
bit24_Error_Counter16 <= "00000";
bit24_Error_Counter17 <= "00000";
bit24_Error_Counter18 <= "00000";
bit24_Error_Counter19 <= "00000";
bit24_Error_Counter20 <= "00000";
bit24_Error_Counter21 <= "00000";
bit24_Error_Counter22 <= "00000";
bit24_Error_Counter23 <= "00000";
bit16_Lock_Counter <= 0;            
bit16_Detector_Counter0 <=  0;
bit16_Detector_Counter1 <=  0;
bit16_Detector_Counter2 <=  0;
bit16_Detector_Counter3 <=  0;
bit16_Detector_Counter4 <=  0;
bit16_Detector_Counter5 <=  0;
bit16_Detector_Counter6 <=  0;
bit16_Detector_Counter7 <=  0;
bit16_Detector_Counter8 <=  0;
bit16_Detector_Counter9 <=  0;
bit16_Detector_Counter10 <=  0;
bit16_Detector_Counter11 <=  0;
bit16_Detector_Counter12 <=  0;
bit16_Detector_Counter13 <=  0;
bit16_Detector_Counter14 <=  0;
bit16_Detector_Counter15 <=  0;
bit16_Error_Counter0 <=  "0000";
bit16_Error_Counter1 <=  "0000";
bit16_Error_Counter2 <=  "0000";
bit16_Error_Counter3 <=  "0000";
bit16_Error_Counter4 <=  "0000";
bit16_Error_Counter5 <=  "0000";
bit16_Error_Counter6 <=  "0000";
bit16_Error_Counter7 <=  "0000";
bit16_Error_Counter8 <=  "0000";
bit16_Error_Counter9 <=  "0000";
bit16_Error_Counter10 <=  "0000";
bit16_Error_Counter11 <=  "0000";
bit16_Error_Counter12 <=  "0000";
bit16_Error_Counter13 <=  "0000";
bit16_Error_Counter14 <=  "0000";
bit16_Error_Counter15 <=  "0000";
bit8_Lock_Counter <= 0;            
bit8_Detector_Counter0 <=  0;
bit8_Detector_Counter1 <=  0;
bit8_Detector_Counter2 <=  0;
bit8_Detector_Counter3 <=  0;
bit8_Detector_Counter4 <=  0;
bit8_Detector_Counter5 <=  0;
bit8_Detector_Counter6 <=  0;
bit8_Detector_Counter7 <=  0;
bit8_Error_Counter0 <=  "000";
bit8_Error_Counter1 <=  "000";
bit8_Error_Counter2 <=  "000";
bit8_Error_Counter3 <=  "000";
bit8_Error_Counter4 <=  "000";
bit8_Error_Counter5 <=  "000";
bit8_Error_Counter6 <=  "000";
bit8_Error_Counter7 <=  "000";
Reg_Byte_Length_of_Sync_Word <= (others => '0');
Reg_Sync_Word <= (others => '0');
end if;
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
    Out_Lock <= Lock;
    Out_Data_Valid <= Data_Valid;
    Out_Spectrum_inversion <= Spectrum_inversion;
    case(Data_Valid) is
        when '0' =>
            Out_Serial_Data <= '0';
        when '1' =>
            if Spectrum_inversion = '0' then
                Out_Serial_Data <= Serial_Data;
            elsif Spectrum_inversion = '1' then
                Out_Serial_Data <= not Serial_Data;
            end if;
        when OTHERS =>
            null;
    end case;
end if;
end process;

end Behavioral;
