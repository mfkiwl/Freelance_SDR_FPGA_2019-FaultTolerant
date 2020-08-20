library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity Testbench is
  Port ( 
          clk                : in std_logic;
          
          Out_Serial_Data_test : out std_logic;
          Spectrum_inversion : out std_logic;
          Lock_test          : out std_logic;
          Data_Valid_test    : out std_logic;
          Test_Reg_Byte_Length_of_Sync_Word : out std_logic_vector(2 downto 0);
          Test_Reg_Sync_Word : out std_logic_vector(31 downto 0)
            
        );
end Testbench;

architecture Behavioral of Testbench is

component Main is
port (  
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
end component Main;

signal TEST_DONE_FLAG : std_logic := '0'; -- High when the sending from the Test Bench to Main serial data is done.

signal Test_Chip_Enable : std_logic := '1';

signal signal_one_bit_data : std_logic := '0';
signal Test_Sync_Word : std_logic_vector(31 downto 0) := x"1ACFFC1D"; -- Sync Word
signal Test_Byte_Sync_Word : std_logic_vector(2 downto 0) := "100"; -- Tells how many byte Sync Word is to main
signal test_Data_Valid : std_logic;
signal test_Lock : std_logic;
signal Test_Packet_Length : std_logic_vector(15 downto 0) := "0000000001000000"; -- Packet Lenght including Sync Word

signal Test_Register_Sync_Word :std_logic_vector(31 downto 0);
signal Test_Register_Byte_Sync_Word : std_logic_vector(2 downto 0);

signal test_clk : std_logic;

signal state : integer range 0 to 600 := 0;
signal test_counter : integer range 0 to 63 := 0;

signal Data_Valid_Counter : std_logic_vector(15 downto 0) := "0000000000000000";
signal bit24_Data_Valid_Counter : std_logic_vector(15 downto 0) := "0000000000000000";
signal bit16_Data_Valid_Counter : std_logic_vector(15 downto 0) := "0000000000000000";
signal bit8_Data_Valid_Counter : std_logic_vector(15 downto 0) := "0000000000000000";

begin
Test_Reg_Sync_Word <= Test_Register_Sync_Word;
Test_Reg_Byte_Length_of_Sync_Word <= Test_Register_Byte_Sync_Word;
test_clk <= clk;
Lock_test <= test_Lock;
Data_Valid_test <= test_Data_Valid;

Data_Valid_Counter <= Test_Packet_Length - 32;
bit24_Data_Valid_Counter <= Test_Packet_Length - 24;
bit16_Data_Valid_Counter <= Test_Packet_Length - 16;
bit8_Data_Valid_Counter <= Test_Packet_Length - 8;

Main_inst : Main
port map(
         clk              => test_clk,
         Serial_Data      => signal_one_bit_data,
         Sync_Word        => Test_Sync_Word,
         Byte_Length_of_Sync_Word     => Test_Byte_Sync_Word,
         Packet_Length => Test_Packet_Length,
         Chip_Enable => Test_Chip_Enable,
         
         Out_Serial_Data => Out_Serial_Data_Test,
         Out_Lock          => test_Lock,
         Out_Data_Valid    => test_Data_Valid,
         Out_Spectrum_inversion => Spectrum_inversion,
         Reg_Byte_Length_of_Sync_Word => Test_Register_Byte_Sync_Word,
         Reg_Sync_Word => Test_Register_Sync_Word
);

process(clk)
begin
if rising_edge(clk) then
    case(state) is
    when 0 => signal_one_bit_data <= '0';  state <= state + 1; -- Random first 4 bits
    when 1 => signal_one_bit_data <= '1';  state <= state + 1;
    when 2 => signal_one_bit_data <= '0';  state <= state + 1;
    when 3 => signal_one_bit_data <= '0';  state <= state + 1;
    when 4 => signal_one_bit_data <= Test_Sync_Word(0);  state <= state + 1; -- Starting Sync Word
    when 5 => signal_one_bit_data <= Test_Sync_Word(1);  state <= state + 1;
    when 6 => signal_one_bit_data <= Test_Sync_Word(2);  state <= state + 1;
    when 7 => signal_one_bit_data <= Test_Sync_Word(3);  state <= state + 1;
    when 8 => signal_one_bit_data <= Test_Sync_Word(4);  state <= state + 1;
    when 9 => signal_one_bit_data <= Test_Sync_Word(5);  state <= state + 1;
    when 10 => signal_one_bit_data <=Test_Sync_Word(6); state <= state + 1;
    when 11 => signal_one_bit_data <=Test_Sync_Word(7); state <= state + 1;
    when 12 => signal_one_bit_data <=Test_Sync_Word(8); state <= state + 1;
    when 13 => signal_one_bit_data <=Test_Sync_Word(9); state <= state + 1;
    when 14 => signal_one_bit_data <=Test_Sync_Word(10); state <= state + 1;
    when 15 => signal_one_bit_data <=Test_Sync_Word(11); state <= state + 1;
    when 16 => signal_one_bit_data <= not Test_Sync_Word(12); state <= state + 1; -- first mistake
    when 17 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1; --second mistake
    when 18 => signal_one_bit_data <=Test_Sync_Word(14); state <= state + 1;
    when 19 => signal_one_bit_data <=Test_Sync_Word(15); state <= state + 1;
    when 20 => signal_one_bit_data <=Test_Sync_Word(16); state <= state + 1;
    when 21 => signal_one_bit_data <=Test_Sync_Word(17); state <= state + 1;
    when 22 => signal_one_bit_data <=Test_Sync_Word(18); state <= state + 1;
    when 23 => signal_one_bit_data <=not Test_Sync_Word(19); state <= state + 1; --third mistake
    when 24 => signal_one_bit_data <=Test_Sync_Word(20); state <= state + 1;
    when 25 => signal_one_bit_data <=Test_Sync_Word(21); state <= state + 1;
    when 26 => signal_one_bit_data <=Test_Sync_Word(22); state <= state + 1;
    when 27 => signal_one_bit_data <=not Test_Sync_Word(23); state <= state + 1; -- fourth mistake
    when 28 => signal_one_bit_data <=Test_Sync_Word(24); state <= state + 1;
    when 29 => signal_one_bit_data <=Test_Sync_Word(25); state <= state + 1;
    when 30 => signal_one_bit_data <=Test_Sync_Word(26); state <= state + 1;
    when 31 => signal_one_bit_data <=not Test_Sync_Word(27); state <= state + 1; -- Fifth Mistake.Lock shouldnt get high at the end of the word.
    when 32 => signal_one_bit_data <=Test_Sync_Word(28); state <= state + 1;
    when 33 => signal_one_bit_data <=Test_Sync_Word(29); state <= state + 1;
    when 34 => signal_one_bit_data <=Test_Sync_Word(30); state <= state + 1;
    when 35 => signal_one_bit_data <=Test_Sync_Word(31); state <= state + 1; --  end of the Sync
    when 36 => signal_one_bit_data <= '0'; state <= state + 1; -- random bits
    when 37 => signal_one_bit_data <= '0'; state <= state + 1;
    when 38 => signal_one_bit_data <= '1'; state <= state + 1;
    when 39 => signal_one_bit_data <= '1'; state <= state + 1;
    when 40 => signal_one_bit_data <= '1'; state <= state + 1;
    when 41 => signal_one_bit_data <= '1'; state <= state + 1;
    when 42 => signal_one_bit_data <= '0'; state <= state + 1;
    when 43 => signal_one_bit_data <= '1'; state <= state + 1;
    when 44 => signal_one_bit_data <= '0'; state <= state + 1;
    when 45 => signal_one_bit_data <= '1'; state <= state + 1;
    when 46 => signal_one_bit_data <= '0'; state <= state + 1;
    when 47 => signal_one_bit_data <= '0'; state <= state + 1;
    when 48 => signal_one_bit_data <= Test_Sync_Word(0);  state <= state + 1; -- beginning of the Sync Word
    when 49 => signal_one_bit_data <= Test_Sync_Word(1);  state <= state + 1;    
    when 50 => signal_one_bit_data <= Test_Sync_Word(2);  state <= state + 1;    
    when 51 => signal_one_bit_data <= Test_Sync_Word(3);  state <= state + 1;    
    when 52 => signal_one_bit_data <= Test_Sync_Word(4);  state <= state + 1;    
    when 53 => signal_one_bit_data <= Test_Sync_Word(5);  state <= state + 1;    
    when 54 =>  signal_one_bit_data <=Test_Sync_Word(6); state <= state + 1;     
    when 55 =>  signal_one_bit_data <=Test_Sync_Word(7); state <= state + 1;     
    when 56 =>  signal_one_bit_data <=Test_Sync_Word(8); state <= state + 1;     
    when 57 =>  signal_one_bit_data <=Test_Sync_Word(9); state <= state + 1;     
    when 58 =>  signal_one_bit_data <=Test_Sync_Word(10); state <= state + 1;    
    when 59 =>  signal_one_bit_data <=Test_Sync_Word(11); state <= state + 1;    
    when 60 =>  signal_one_bit_data <= not Test_Sync_Word(12); state <= state + 1; --first mistake
    when 61 =>  signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1; --second mistake
    when 62 =>  signal_one_bit_data <=Test_Sync_Word(14); state <= state + 1;    
    when 63 =>  signal_one_bit_data <=Test_Sync_Word(15); state <= state + 1;    
    when 64 =>  signal_one_bit_data <=Test_Sync_Word(16); state <= state + 1;    
    when 65 =>  signal_one_bit_data <=Test_Sync_Word(17); state <= state + 1;    
    when 66 =>  signal_one_bit_data <=Test_Sync_Word(18); state <= state + 1;    
    when 67 =>  signal_one_bit_data <=not Test_Sync_Word(19); state <= state + 1; --third mistake
    when 68 =>  signal_one_bit_data <=Test_Sync_Word(20); state <= state + 1;    
    when 69 =>  signal_one_bit_data <=Test_Sync_Word(21); state <= state + 1;    
    when 70 =>  signal_one_bit_data <=Test_Sync_Word(22); state <= state + 1;    
    when 71 =>  signal_one_bit_data <= Test_Sync_Word(23); state <= state + 1; 
    when 72 =>  signal_one_bit_data <=Test_Sync_Word(24); state <= state + 1;    
    when 73 =>  signal_one_bit_data <=Test_Sync_Word(25); state <= state + 1;    
    when 74 =>  signal_one_bit_data <=Test_Sync_Word(26); state <= state + 1;    
    when 75 =>  signal_one_bit_data <= not Test_Sync_Word(27); state <= state + 1;--fourth mistake
    when 76 =>  signal_one_bit_data <=Test_Sync_Word(28); state <= state + 1;    
    when 77 =>  signal_one_bit_data <=Test_Sync_Word(29); state <= state + 1;    
    when 78 =>  signal_one_bit_data <=Test_Sync_Word(30); state <= state + 1;    
    when 79 =>  signal_one_bit_data <= Test_Sync_Word(31); state <= state + 1; 
    when 80 => if(test_counter=Data_Valid_Counter) then -- test counter
                test_counter <= 0;
                signal_one_bit_data <= Test_Sync_Word(0); -- Beginning of the Sync Word
                state <= state + 1;
                else 
                test_counter <= test_counter + 1;
                end if;
    when 81 =>  signal_one_bit_data <= Test_Sync_Word(1);  state <= state + 1; 
    when 82 =>            signal_one_bit_data <= Test_Sync_Word(2);  state <= state + 1;                     
    when 83 =>            signal_one_bit_data <= Test_Sync_Word(3);  state <= state + 1;                     
    when 84 =>            signal_one_bit_data <= Test_Sync_Word(4);  state <= state + 1;                     
    when 85 =>            signal_one_bit_data <= Test_Sync_Word(5);  state <= state + 1;                     
    when 86 =>            signal_one_bit_data <= Test_Sync_Word(6);  state <= state + 1;                     
    when 87 =>             signal_one_bit_data <=Test_Sync_Word(7); state <= state + 1;                      
    when 88 =>             signal_one_bit_data <=Test_Sync_Word(8); state <= state + 1;                      
    when 89 =>             signal_one_bit_data <=Test_Sync_Word(9); state <= state + 1;                      
    when 90 =>             signal_one_bit_data <=Test_Sync_Word(10); state <= state + 1;                      
    when 91 =>             signal_one_bit_data <=Test_Sync_Word(11); state <= state + 1;                     
    when 92 =>             signal_one_bit_data <=Test_Sync_Word(12); state <= state + 1;                     
    when 93 =>             signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1; --first mistake
    when 94 =>             signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1; --second mistake
    when 95 =>             signal_one_bit_data <=Test_Sync_Word(15); state <= state + 1;                     
    when 96 =>             signal_one_bit_data <=Test_Sync_Word(16); state <= state + 1;                     
    when 97 =>             signal_one_bit_data <=Test_Sync_Word(17); state <= state + 1;                     
    when 98 =>             signal_one_bit_data <=Test_Sync_Word(18); state <= state + 1;                     
    when 99 =>             signal_one_bit_data <=Test_Sync_Word(19); state <= state + 1;                     
    when 100 =>             signal_one_bit_data <=not Test_Sync_Word(20); state <= state + 1; --third mistake 
    when 101 =>             signal_one_bit_data <=Test_Sync_Word(21); state <= state + 1;                     
    when 102 =>             signal_one_bit_data <=Test_Sync_Word(22); state <= state + 1;                     
    when 103 =>             signal_one_bit_data <=Test_Sync_Word(23); state <= state + 1;                     
    when 104 =>             signal_one_bit_data <= Test_Sync_Word(24); state <= state + 1;                    
    when 105 =>             signal_one_bit_data <=Test_Sync_Word(25); state <= state + 1;                     
    when 106 =>             signal_one_bit_data <=Test_Sync_Word(26); state <= state + 1;                     
    when 107 =>             signal_one_bit_data <=Test_Sync_Word(27); state <= state + 1;                     
    when 108 =>             signal_one_bit_data <= Test_Sync_Word(28); state <= state + 1;                    
    when 109 =>             signal_one_bit_data <=Test_Sync_Word(29); state <= state + 1;                     
    when 110 =>             signal_one_bit_data <= Test_Sync_Word(30); state <= state + 1; --fourth mistake             
    when 111 =>             signal_one_bit_data <= not Test_Sync_Word(31); state <= state + 1;      -- Sync Word done               
    when 112 =>     if(test_counter=Test_Packet_Length) then test_counter <= 0; state <= state + 1;
                    else
                    test_counter <= test_counter + 1;
                    end if;
    when 113 => signal_one_bit_data <= '0' ; state <= state + 1;
    when 114 => signal_one_bit_data <= '0'; state <= state + 1; -- random bits
    when 115 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 116 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 117 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 118 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 119 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 120 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 121 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 122 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 123 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 124 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 125 => signal_one_bit_data <= '0'; state <= state + 1; 
    when 126 => 
    Test_Sync_Word <= x"00A0B0C1";       
    Test_Byte_Sync_Word <= "011";  -- 3 byte sync word 
    signal_one_bit_data <= '1';
    state <= state + 1;
    when 127 => signal_one_bit_data <= Test_Sync_Word(1); state <= state + 1;
    when 128 => signal_one_bit_data <= Test_Sync_Word(2); state <= state + 1;
    when 129 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1; -- MİSTAKE 1
    when 130 => signal_one_bit_data <= Test_Sync_Word(4); state <= state + 1;
    when 131 => signal_one_bit_data <= Test_Sync_Word(5); state <= state + 1;
    when 132 => signal_one_bit_data <= Test_Sync_Word(6); state <= state + 1;
    when 133 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1; -- MİSTAKE 2
    when 134 => signal_one_bit_data <= Test_Sync_Word(8); state <= state + 1;
    when 135 => signal_one_bit_data <= Test_Sync_Word(9); state <= state + 1;
    when 136 => signal_one_bit_data <= Test_Sync_Word(10); state <= state + 1;
    when 137 => signal_one_bit_data <= Test_Sync_Word(11); state <= state + 1;
    when 138 => signal_one_bit_data <= Test_Sync_Word(12); state <= state + 1;
    when 139 => signal_one_bit_data <= Test_Sync_Word(13); state <= state + 1;
    when 140 => signal_one_bit_data <= Test_Sync_Word(14); state <= state + 1;
    when 141 => signal_one_bit_data <= Test_Sync_Word(15); state <= state + 1;
    when 142 => signal_one_bit_data <= Test_Sync_Word(16); state <= state + 1;
    when 143 => signal_one_bit_data <= Test_Sync_Word(17); state <= state + 1;
    when 144 => signal_one_bit_data <= Test_Sync_Word(18); state <= state + 1;
    when 145 => signal_one_bit_data <= Test_Sync_Word(19); state <= state + 1;
    when 146 => signal_one_bit_data <= Test_Sync_Word(20); state <= state + 1;
    when 147 => signal_one_bit_data <= Test_Sync_Word(21); state <= state + 1;
    when 148 => signal_one_bit_data <= Test_Sync_Word(22); state <= state + 1;
    when 149 => signal_one_bit_data <= not Test_Sync_Word(23); state <= state + 1; -- MİSTAKE 3
    when 150 => 
                    if(test_counter=bit24_Data_Valid_Counter) then -- test counter
                    test_counter <= 0;
                    signal_one_bit_data <= Test_Sync_Word(0); -- Beginning of the Sync Word
                    state <= state + 1;
                    else 
                    test_counter <= test_counter + 1;
                    state <= 150;
                    end if;
    when 151 => signal_one_bit_data <= Test_Sync_Word(1); state <= state + 1;
    when 152 => signal_one_bit_data <= Test_Sync_Word(2); state <= state + 1;
    when 153 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1;
    when 154 => signal_one_bit_data <= Test_Sync_Word(4); state <= state + 1;
    when 155 => signal_one_bit_data <= Test_Sync_Word(5); state <= state + 1;
    when 156 => signal_one_bit_data <= Test_Sync_Word(6); state <= state + 1;
    when 157 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;
    when 158 => signal_one_bit_data <= Test_Sync_Word(8); state <= state + 1;
    when 159 => signal_one_bit_data <= Test_Sync_Word(9); state <= state + 1;
    when 160 => signal_one_bit_data <= Test_Sync_Word(10); state <= state + 1;
    when 161 => signal_one_bit_data <= Test_Sync_Word(11); state <= state + 1;
    when 162 => signal_one_bit_data <= Test_Sync_Word(12); state <= state + 1;
    when 163 => signal_one_bit_data <= Test_Sync_Word(13); state <= state + 1;
    when 164 => signal_one_bit_data <= Test_Sync_Word(14); state <= state + 1;
    when 165 => signal_one_bit_data <= Test_Sync_Word(15); state <= state + 1;
    when 166 => signal_one_bit_data <= Test_Sync_Word(16); state <= state + 1;
    when 167 => signal_one_bit_data <= Test_Sync_Word(17); state <= state + 1;
    when 168 => signal_one_bit_data <= Test_Sync_Word(18); state <= state + 1;
    when 169 => signal_one_bit_data <= Test_Sync_Word(19); state <= state + 1;
    when 170 => signal_one_bit_data <= Test_Sync_Word(20); state <= state + 1;
    when 171 => signal_one_bit_data <= Test_Sync_Word(21); state <= state + 1;
    when 172 => signal_one_bit_data <= Test_Sync_Word(22); state <= state + 1;
    when 173 => signal_one_bit_data <= not Test_Sync_Word(23); state <= state + 1;
    when 174 => 
                    if(test_counter=Test_Packet_Length) then test_counter <= 0; state <= state + 1;
                    else
                    test_counter <= test_counter + 1;
                    end if;
    when 175 => signal_one_bit_data <= '0'; state <= state + 1;-- random bits
    when 176 => signal_one_bit_data <= '0'; state <= state + 1; 
    when 177 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 178 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 179 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 180 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 181 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 182 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 183 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 184 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 185 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 186 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 187 => signal_one_bit_data <= '0'; state <= state + 1; 
    when 188 => signal_one_bit_data <= '0'; state <= state + 1; 
    when 189 =>
        Test_Sync_Word <= x"0000C0B0";       
        Test_Byte_Sync_Word <= "010";  
        signal_one_bit_data <= '0';
        state <= state + 1;
    when 190 => signal_one_bit_data <= Test_Sync_Word(1); state <= state + 1;
    when 191 => signal_one_bit_data <= Test_Sync_Word(2); state <= state + 1;
    when 192 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1; -- MİSTAKE 1
    when 193 => signal_one_bit_data <= Test_Sync_Word(4); state <= state + 1;
    when 194 => signal_one_bit_data <= Test_Sync_Word(5); state <= state + 1;
    when 195 => signal_one_bit_data <= Test_Sync_Word(6); state <= state + 1;
    when 196 => signal_one_bit_data <= Test_Sync_Word(7); state <= state + 1;
    when 197 => signal_one_bit_data <= Test_Sync_Word(8); state <= state + 1;
    when 198 => signal_one_bit_data <= Test_Sync_Word(9); state <= state + 1;
    when 199 => signal_one_bit_data <= Test_Sync_Word(10); state <= state + 1;
    when 200 => signal_one_bit_data <= Test_Sync_Word(11); state <= state + 1;
    when 201 => signal_one_bit_data <= Test_Sync_Word(12); state <= state + 1;
    when 202 => signal_one_bit_data <= Test_Sync_Word(13); state <= state + 1;
    when 203 => signal_one_bit_data <= Test_Sync_Word(14); state <= state + 1;
    when 204 => signal_one_bit_data <= not Test_Sync_Word(15); state <= state + 1;-- MİSTAKE 2
    when 205 => 
        if(test_counter=bit16_Data_Valid_Counter) then -- test counter
        test_counter <= 0;
        signal_one_bit_data <= Test_Sync_Word(0); -- Beginning of the Sync Word
        state <= state + 1;
        else 
        test_counter <= test_counter + 1;
        state <= 205;
        end if;
    when 206 => signal_one_bit_data <= Test_Sync_Word(1); state <= state + 1;
    when 207 => signal_one_bit_data <= Test_Sync_Word(2); state <= state + 1;
    when 208 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1; -- MİSTAKE 1
    when 209 => signal_one_bit_data <= Test_Sync_Word(4); state <= state + 1;
    when 210 => signal_one_bit_data <= Test_Sync_Word(5); state <= state + 1;
    when 211 => signal_one_bit_data <= Test_Sync_Word(6); state <= state + 1;
    when 212 => signal_one_bit_data <= Test_Sync_Word(7); state <= state + 1;
    when 213 => signal_one_bit_data <= Test_Sync_Word(8); state <= state + 1;
    when 214 => signal_one_bit_data <= Test_Sync_Word(9); state <= state + 1;
    when 215 => signal_one_bit_data <= Test_Sync_Word(10); state <= state + 1;
    when 216 => signal_one_bit_data <= Test_Sync_Word(11); state <= state + 1;
    when 217 => signal_one_bit_data <= Test_Sync_Word(12); state <= state + 1;
    when 218 => signal_one_bit_data <= Test_Sync_Word(13); state <= state + 1;
    when 219 => signal_one_bit_data <= Test_Sync_Word(14); state <= state + 1;
    when 220 => signal_one_bit_data <= not Test_Sync_Word(15); state <= state + 1;-- MİSTAKE 2
    when 221 =>                     
            if(test_counter=Test_Packet_Length) then test_counter <= 0; state <= state + 1;
            else
            test_counter <= test_counter + 1;
            end if;
    when 222 => signal_one_bit_data <= '0'; state <= state + 1;-- random bits
    when 223 => signal_one_bit_data <= '0'; state <= state + 1; 
    when 224 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 225 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 226 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 227 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 228 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 229 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 230 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 231 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 232 => signal_one_bit_data <= '1'; state <= state + 1;               
    when 233 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 234 => signal_one_bit_data <= '0'; state <= state + 1; 
    when 235 =>         
            Test_Sync_Word <= x"000000DA";       -- 1101 1010
            Test_Byte_Sync_Word <= "001";  
            signal_one_bit_data <= '0';
            state <= state + 1;
    when 236 => signal_one_bit_data <= Test_Sync_Word(1); state <= state + 1;
    when 237 => signal_one_bit_data <= Test_Sync_Word(2); state <= state + 1;
    when 238 => signal_one_bit_data <= Test_Sync_Word(3) ; state <= state + 1;
    when 239 => signal_one_bit_data <= Test_Sync_Word(4); state <= state + 1;
    when 240 => signal_one_bit_data <= Test_Sync_Word(5); state <= state + 1;
    when 241 => signal_one_bit_data <= Test_Sync_Word(6); state <= state + 1;
    when 242 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;-- MİSTAKE 1
    when 243 =>         
            if(test_counter=bit8_Data_Valid_Counter) then -- test counter
            test_counter <= 0;
            signal_one_bit_data <= Test_Sync_Word(0); -- Beginning of the Sync Word
            state <= state + 1;
            else 
            test_counter <= test_counter + 1;
            state <= 243;
            end if;
    when 244 => signal_one_bit_data <= Test_Sync_Word(1); state <= state + 1;
    when 245 => signal_one_bit_data <= Test_Sync_Word(2); state <= state + 1;
    when 246 => signal_one_bit_data <= Test_Sync_Word(3) ; state <= state + 1; 
    when 247 => signal_one_bit_data <= Test_Sync_Word(4); state <= state + 1;
    when 248 => signal_one_bit_data <= Test_Sync_Word(5); state <= state + 1;
    when 249 => signal_one_bit_data <= Test_Sync_Word(6); state <= state + 1;
    when 250 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;
    when 251 =>
            if(test_counter=Test_Packet_Length) then 
            test_counter <= 0; state <= state + 1;
            else
            test_counter <= test_counter + 1;
            end if;
    when 252 => signal_one_bit_data <= '0'; state <= state + 1;-- random bits
    when 253 => signal_one_bit_data <= '0'; state <= state + 1; 
    when 254 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 255 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 256 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 257 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 258 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 259 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 260 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 261 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 262 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 263 => signal_one_bit_data <= '0'; state <= state + 1;               
    when 264 => signal_one_bit_data <= '0'; state <= state + 1; 
    when 265 => signal_one_bit_data <= Test_Sync_Word(0); state <= state + 1;-- MİSTAKE TESTS
    when 266 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 267 => signal_one_bit_data <= Test_Sync_Word(2); state <= state + 1;
    when 268 => signal_one_bit_data <= Test_Sync_Word(3); state <= state + 1;
    when 269 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 270 => signal_one_bit_data <= Test_Sync_Word(5); state <= state + 1;
    when 271 => signal_one_bit_data <= Test_Sync_Word(6); state <= state + 1;
    when 272 => signal_one_bit_data <= Test_Sync_Word(7); state <= state + 1;
    when 273 => if(test_counter=Test_Packet_Length) then 
                test_counter <= 0; state <= state + 1;
                else
                test_counter <= test_counter + 1;
                end if;
    when 274 => Test_Sync_Word <= x"0000C0B0";       
                Test_Byte_Sync_Word <= "010";  
                signal_one_bit_data <= '0';
                state <= state + 1;
    when 275 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 276 => signal_one_bit_data <= Test_Sync_Word(2); state <= state + 1;
    when 277 => signal_one_bit_data <= Test_Sync_Word(3); state <= state + 1;
    when 278 => signal_one_bit_data <= Test_Sync_Word(4); state <= state + 1;
    when 279 => signal_one_bit_data <= Test_Sync_Word(5); state <= state + 1;
    when 280 => signal_one_bit_data <= not Test_Sync_Word(6); state <= state + 1;
    when 281 => signal_one_bit_data <= Test_Sync_Word(7); state <= state + 1;
    when 282 => signal_one_bit_data <= Test_Sync_Word(8); state <= state + 1;
    when 283 => signal_one_bit_data <= not Test_Sync_Word(9); state <= state + 1;
    when 284 => signal_one_bit_data <= Test_Sync_Word(10); state <= state + 1;
    when 285 => signal_one_bit_data <= Test_Sync_Word(11); state <= state + 1;
    when 286 => signal_one_bit_data <= Test_Sync_Word(12); state <= state + 1;
    when 287 => signal_one_bit_data <= Test_Sync_Word(13); state <= state + 1;
    when 288 => signal_one_bit_data <= Test_Sync_Word(14); state <= state + 1;
    when 289 => signal_one_bit_data <= Test_Sync_Word(15); state <= state + 1;
    when 290 => if(test_counter=Test_Packet_Length) then 
                test_counter <= 0; state <= state + 1;
                else
                test_counter <= test_counter + 1;
                end if;
    when 291 => Test_Sync_Word <= x"00A0B0C1";       
                Test_Byte_Sync_Word <= "011";  -- 3 byte sync word 
                signal_one_bit_data <= '1';
                state <= state + 1;
    when 292 => signal_one_bit_data <= Test_Sync_Word(1); state <= state + 1;
    when 293 => signal_one_bit_data <= Test_Sync_Word(2); state <= state + 1;
    when 294 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1; -- MİSTAKE 1
    when 295 => signal_one_bit_data <= Test_Sync_Word(4); state <= state + 1;
    when 296 => signal_one_bit_data <= Test_Sync_Word(5); state <= state + 1;
    when 297 => signal_one_bit_data <= Test_Sync_Word(6); state <= state + 1;
    when 298 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1; -- MİSTAKE 2
    when 299 => signal_one_bit_data <= Test_Sync_Word(8); state <= state + 1;
    when 300 => signal_one_bit_data <= Test_Sync_Word(9); state <= state + 1;
    when 301 => signal_one_bit_data <= Test_Sync_Word(10); state <= state + 1;
    when 302 => signal_one_bit_data <= Test_Sync_Word(11); state <= state + 1;
    when 303 => signal_one_bit_data <= Test_Sync_Word(12); state <= state + 1;
    when 304 => signal_one_bit_data <= Test_Sync_Word(13); state <= state + 1;
    when 305 => signal_one_bit_data <= Test_Sync_Word(14); state <= state + 1;
    when 306 => signal_one_bit_data <= Test_Sync_Word(15); state <= state + 1;
    when 307 => signal_one_bit_data <= not Test_Sync_Word(16); state <= state + 1; --MİSTAKE 3
    when 308 => signal_one_bit_data <= Test_Sync_Word(17); state <= state + 1;
    when 309 => signal_one_bit_data <= Test_Sync_Word(18); state <= state + 1;
    when 310 => signal_one_bit_data <= Test_Sync_Word(19); state <= state + 1;
    when 311 => signal_one_bit_data <= Test_Sync_Word(20); state <= state + 1;
    when 312 => signal_one_bit_data <= Test_Sync_Word(21); state <= state + 1;
    when 313 => signal_one_bit_data <= Test_Sync_Word(22); state <= state + 1;
    when 314 => signal_one_bit_data <= not Test_Sync_Word(23); state <= state + 1; -- MİSTAKE 4
    when 315 => if(test_counter=Test_Packet_Length) then 
                test_counter <= 0; state <= state + 1;
                else
                test_counter <= test_counter + 1;
                end if;

    when 316 => Test_Sync_Word <= x"00000000";       
                Test_Byte_Sync_Word <= "000";
                state <= state + 1;
    when 317 => Test_Sync_Word <= x"1ACFFC1D"; --0001 1010 1100 1111 1111 1100 0001 1101
                Test_Byte_Sync_Word <= "100";
                signal_one_bit_data <= '1'; -- Test_Sync_Word(0) MİSTAKE 1
                state <= state + 1;
    when 318 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 319 => signal_one_bit_data <= not Test_Sync_Word(2); state <= state + 1;
    when 320 => signal_one_bit_data <= not Test_Sync_Word(3); state <= state + 1;
    when 321 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 322 => signal_one_bit_data <= Test_Sync_Word(5); state <= state + 1; -- MİSTAKE 2
    when 323 => signal_one_bit_data <= not Test_Sync_Word(6); state <= state + 1;
    when 324 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;
    when 325 => signal_one_bit_data <= not Test_Sync_Word(8); state <= state + 1;
    when 326 => signal_one_bit_data <= not Test_Sync_Word(9); state <= state + 1;
    when 327 => signal_one_bit_data <= not Test_Sync_Word(10); state <= state + 1;
    when 328 => signal_one_bit_data <= not Test_Sync_Word(11); state <= state + 1;
    when 329 => signal_one_bit_data <= not Test_Sync_Word(12); state <= state + 1;
    when 330 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1;
    when 331 => signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1;
    when 332 => signal_one_bit_data <= not Test_Sync_Word(15); state <= state + 1;
    when 333 => signal_one_bit_data <= Test_Sync_Word(16); state <= state + 1; -- MİSTAKE 3
    when 334 => signal_one_bit_data <= not Test_Sync_Word(17); state <= state + 1;
    when 335 => signal_one_bit_data <= not Test_Sync_Word(18); state <= state + 1;
    when 336 => signal_one_bit_data <= not Test_Sync_Word(19); state <= state + 1;
    when 337 => signal_one_bit_data <= not Test_Sync_Word(20); state <= state + 1;
    when 338 => signal_one_bit_data <= not Test_Sync_Word(21); state <= state + 1;
    when 339 => signal_one_bit_data <= not Test_Sync_Word(22); state <= state + 1;
    when 340 => signal_one_bit_data <= not Test_Sync_Word(23); state <= state + 1;
    when 341 => signal_one_bit_data <= not Test_Sync_Word(24); state <= state + 1;
    when 342 => signal_one_bit_data <= not Test_Sync_Word(25); state <= state + 1;
    when 343 => signal_one_bit_data <= not Test_Sync_Word(26); state <= state + 1;
    when 344 => signal_one_bit_data <= not Test_Sync_Word(27); state <= state + 1;
    when 345 => signal_one_bit_data <= not Test_Sync_Word(28); state <= state + 1;
    when 346 => signal_one_bit_data <= not Test_Sync_Word(29); state <= state + 1;
    when 347 => signal_one_bit_data <= not Test_Sync_Word(30); state <= state + 1;
    when 348 => signal_one_bit_data <= Test_Sync_Word(31); state <= state + 1; -- MİSTAKE 4
    when 349 => if(test_counter=Data_Valid_Counter) then -- test counter
                    test_counter <= 0;
                    signal_one_bit_data <= Test_Sync_Word(0); -- Beginning of the Sync Word
                    state <= state + 1;
                    else 
                    test_counter <= test_counter + 1;
                    end if;
    when 350 => signal_one_bit_data <= Test_Sync_Word(1);  state <= state + 1; 
    when 351 => signal_one_bit_data <= Test_Sync_Word(2);  state <= state + 1;                     
    when 352 => signal_one_bit_data <= Test_Sync_Word(3);  state <= state + 1;                     
    when 353 => signal_one_bit_data <= Test_Sync_Word(4);  state <= state + 1;                     
    when 354 => signal_one_bit_data <= Test_Sync_Word(5);  state <= state + 1;                     
    when 355 => signal_one_bit_data <= Test_Sync_Word(6);  state <= state + 1;                     
    when 356 => signal_one_bit_data <=Test_Sync_Word(7); state <= state + 1;                      
    when 357 => signal_one_bit_data <=Test_Sync_Word(8); state <= state + 1;                      
    when 358 => signal_one_bit_data <=Test_Sync_Word(9); state <= state + 1;                      
    when 359 => signal_one_bit_data <=Test_Sync_Word(10); state <= state + 1;                      
    when 360 => signal_one_bit_data <=Test_Sync_Word(11); state <= state + 1;                     
    when 361 => signal_one_bit_data <=Test_Sync_Word(12); state <= state + 1;                     
    when 362 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1; --first mistake
    when 363 => signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1; --second mistake
    when 364 => signal_one_bit_data <=Test_Sync_Word(15); state <= state + 1;                     
    when 365 => signal_one_bit_data <=Test_Sync_Word(16); state <= state + 1;                     
    when 366 => signal_one_bit_data <=Test_Sync_Word(17); state <= state + 1;                     
    when 367 => signal_one_bit_data <=Test_Sync_Word(18); state <= state + 1;                     
    when 368 => signal_one_bit_data <=Test_Sync_Word(19); state <= state + 1;                     
    when 369 => signal_one_bit_data <=not Test_Sync_Word(20); state <= state + 1; --third mistake 
    when 370 => signal_one_bit_data <=Test_Sync_Word(21); state <= state + 1;                     
    when 371 => signal_one_bit_data <=Test_Sync_Word(22); state <= state + 1;                     
    when 372 => signal_one_bit_data <=Test_Sync_Word(23); state <= state + 1;                     
    when 373 => signal_one_bit_data <= Test_Sync_Word(24); state <= state + 1;                    
    when 374 => signal_one_bit_data <=Test_Sync_Word(25); state <= state + 1;                     
    when 375 => signal_one_bit_data <=Test_Sync_Word(26); state <= state + 1;                     
    when 376 => signal_one_bit_data <=Test_Sync_Word(27); state <= state + 1;                     
    when 377 => signal_one_bit_data <= Test_Sync_Word(28); state <= state + 1;                    
    when 378 => signal_one_bit_data <=Test_Sync_Word(29); state <= state + 1;                     
    when 379 => signal_one_bit_data <= Test_Sync_Word(30); state <= state + 1; --fourth mistake             
    when 380 => signal_one_bit_data <= not Test_Sync_Word(31); state <= state + 1;      -- Sync Word done               
    when 381 =>     if(test_counter=Test_Packet_Length) then
                    test_counter <= 0; state <= state + 1;
                    else
                    test_counter <= test_counter + 1;
                    signal_one_bit_data <= '0';
                    end if;
    when 382 =>     if(test_counter=Test_Packet_Length) then 
                    test_counter <= 0; state <= state + 1;
                    else
                    test_counter <= test_counter + 1;
                    end if;
                    
    when 383 =>   Test_Sync_Word <= x"00A0B0C1";       
                  Test_Byte_Sync_Word <= "011";  -- 3 byte sync word 
                  signal_one_bit_data <= '1'; -- MİSTAKE 1
                  state <= state + 1;
    when 384 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 385 => signal_one_bit_data <= not Test_Sync_Word(2); state <= state + 1;
    when 386 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1;
    when 387 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 388 => signal_one_bit_data <= not Test_Sync_Word(5); state <= state + 1;
    when 389 => signal_one_bit_data <= not Test_Sync_Word(6); state <= state + 1;
    when 390 => signal_one_bit_data <= Test_Sync_Word(7); state <= state + 1; -- MİSTAKE 2
    when 391 => signal_one_bit_data <= not Test_Sync_Word(8); state <= state + 1;
    when 392 => signal_one_bit_data <= not Test_Sync_Word(9); state <= state + 1;
    when 393 => signal_one_bit_data <= not Test_Sync_Word(10); state <= state + 1;
    when 394 => signal_one_bit_data <= not Test_Sync_Word(11); state <= state + 1;
    when 395 => signal_one_bit_data <= not Test_Sync_Word(12); state <= state + 1;
    when 396 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1;
    when 397 => signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1;
    when 398 => signal_one_bit_data <= not Test_Sync_Word(15); state <= state + 1;
    when 399 => signal_one_bit_data <= not Test_Sync_Word(16); state <= state + 1;
    when 400 => signal_one_bit_data <= not Test_Sync_Word(17); state <= state + 1;
    when 401 => signal_one_bit_data <= not Test_Sync_Word(18); state <= state + 1;
    when 402 => signal_one_bit_data <= not Test_Sync_Word(19); state <= state + 1;
    when 403 => signal_one_bit_data <= not Test_Sync_Word(20); state <= state + 1;
    when 404 => signal_one_bit_data <= not Test_Sync_Word(21); state <= state + 1;
    when 405 => signal_one_bit_data <= not Test_Sync_Word(22); state <= state + 1;
    when 406 => signal_one_bit_data <= Test_Sync_Word(23); state <= state + 1; -- MİSTAKE 3
    when 407 => if(test_counter=bit24_Data_Valid_Counter) then -- test counter
                    test_counter <= 0;
                    signal_one_bit_data <= Test_Sync_Word(0); -- Beginning of the Sync Word -- MİSTAKE 1
                    state <= state + 1;
                    else 
                    test_counter <= test_counter + 1;
                    end if;
    when 408 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 409 => signal_one_bit_data <= not Test_Sync_Word(2); state <= state + 1;
    when 410 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1;
    when 411 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 412 => signal_one_bit_data <= not Test_Sync_Word(5); state <= state + 1;
    when 413 => signal_one_bit_data <= not Test_Sync_Word(6); state <= state + 1;
    when 414 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;
    when 415 => signal_one_bit_data <= Test_Sync_Word(8); state <= state + 1; --  MİSTAKE 2
    when 416 => signal_one_bit_data <= not Test_Sync_Word(9); state <= state + 1;
    when 417 => signal_one_bit_data <= Test_Sync_Word(10); state <= state + 1; -- MİSTAKE 3
    when 418 => signal_one_bit_data <= not Test_Sync_Word(11); state <= state + 1;
    when 419 => signal_one_bit_data <= not Test_Sync_Word(12); state <= state + 1;
    when 420 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1;
    when 421 => signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1;
    when 422 => signal_one_bit_data <= not Test_Sync_Word(15); state <= state + 1;
    when 423 => signal_one_bit_data <= not Test_Sync_Word(16); state <= state + 1;
    when 424 => signal_one_bit_data <= not Test_Sync_Word(17); state <= state + 1;
    when 425 => signal_one_bit_data <= not Test_Sync_Word(18); state <= state + 1;
    when 426 => signal_one_bit_data <= not Test_Sync_Word(19); state <= state + 1;
    when 427 => signal_one_bit_data <= not Test_Sync_Word(20); state <= state + 1;
    when 428 => signal_one_bit_data <= not Test_Sync_Word(21); state <= state + 1;
    when 429 => signal_one_bit_data <= not Test_Sync_Word(22); state <= state + 1;
    when 430 => signal_one_bit_data <= not Test_Sync_Word(23); state <= state + 1;
    when 431 =>     if(test_counter=Test_Packet_Length) then
                    test_counter <= 0; state <= state + 1;
                    else
                    test_counter <= test_counter + 1;
                    end if;
    when 432 => Test_Sync_Word <= x"0000C0B0";       
                Test_Byte_Sync_Word <= "010";  
                signal_one_bit_data <= '0'; -- MİSTAKE 1
                state <= state + 1;
    when 433 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 434 => signal_one_bit_data <= not Test_Sync_Word(2); state <= state + 1;
    when 435 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1;
    when 436 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 437 => signal_one_bit_data <= not Test_Sync_Word(5); state <= state + 1;
    when 438 => signal_one_bit_data <= not Test_Sync_Word(6); state <= state + 1;
    when 439 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;
    when 440 => signal_one_bit_data <= not Test_Sync_Word(8); state <= state + 1;
    when 441 => signal_one_bit_data <= not Test_Sync_Word(9); state <= state + 1;
    when 442 => signal_one_bit_data <= not Test_Sync_Word(10); state <= state + 1;
    when 443 => signal_one_bit_data <= not Test_Sync_Word(11); state <= state + 1;
    when 444 => signal_one_bit_data <= not Test_Sync_Word(12); state <= state + 1;
    when 445 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1;
    when 446 => signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1;
    when 447 => signal_one_bit_data <= Test_Sync_Word(15); state <= state + 1;-- MİSTAKE 2
    when 448 => if(test_counter=bit16_Data_Valid_Counter) then -- test counter
                test_counter <= 0;
                signal_one_bit_data <= not Test_Sync_Word(0); -- Beginning of the Sync Word
                state <= state + 1;
                else 
                test_counter <= test_counter + 1;
                end if;
    when 449 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 450 => signal_one_bit_data <= not Test_Sync_Word(2); state <= state + 1;
    when 451 => signal_one_bit_data <= Test_Sync_Word(3) ; state <= state + 1; -- MİSTAKE 1
    when 452 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 453 => signal_one_bit_data <= not Test_Sync_Word(5); state <= state + 1;
    when 454 => signal_one_bit_data <= not Test_Sync_Word(6); state <= state + 1;
    when 455 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;
    when 456 => signal_one_bit_data <= not Test_Sync_Word(8); state <= state + 1;
    when 457 => signal_one_bit_data <= not Test_Sync_Word(9); state <= state + 1;
    when 458 => signal_one_bit_data <= not Test_Sync_Word(10); state <= state + 1;
    when 459 => signal_one_bit_data <= not Test_Sync_Word(11); state <= state + 1;
    when 460 => signal_one_bit_data <= not Test_Sync_Word(12); state <= state + 1;
    when 461 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1;
    when 462 => signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1;
    when 463 => signal_one_bit_data <= Test_Sync_Word(15); state <= state + 1;-- MİSTAKE 2
    when 464 => if(test_counter=Test_Packet_Length) then
                test_counter <= 0; state <= state + 1;
                else
                test_counter <= test_counter + 1;
                end if;
  
    when 465 =>         
            Test_Sync_Word <= x"000000DA";       -- 1101 1010
            Test_Byte_Sync_Word <= "001";  
            signal_one_bit_data <= '0'; -- MİSTAKE 1
            state <= state + 1;
    when 466 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 467 => signal_one_bit_data <= not Test_Sync_Word(2); state <= state + 1;
    when 468 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1;
    when 469 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 470 => signal_one_bit_data <= not Test_Sync_Word(5); state <= state + 1;
    when 471 => signal_one_bit_data <= not Test_Sync_Word(6); state <= state + 1;
    when 472 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;
    when 473 =>         
            if(test_counter=bit8_Data_Valid_Counter) then -- test counter
            test_counter <= 0;
            signal_one_bit_data <= Test_Sync_Word(0); -- Beginning of the Sync Word -- MİSTAKE 1
            state <= state + 1;
            else 
            test_counter <= test_counter + 1;
            end if;
    when 474 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 475 => signal_one_bit_data <= not Test_Sync_Word(2); state <= state + 1;
    when 476 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1; 
    when 477 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 478 => signal_one_bit_data <= not Test_Sync_Word(5); state <= state + 1;
    when 479 => signal_one_bit_data <= not Test_Sync_Word(6); state <= state + 1;
    when 480 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;
    when 481 =>
            if(test_counter=Test_Packet_Length) then 
            test_counter <= 0; state <= state + 1;
            else
            signal_one_bit_data <= '1';
            test_counter <= test_counter + 1;
            end if;
    
    when 482 => signal_one_bit_data <= not Test_Sync_Word(0); state <= state + 1;-- MİSTAKE TESTS(1's COMPLEMENTS)
    when 483 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 484 => signal_one_bit_data <= not Test_Sync_Word(2); state <= state + 1;
    when 485 => signal_one_bit_data <= not Test_Sync_Word(3); state <= state + 1;
    when 486 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 487 => signal_one_bit_data <= not Test_Sync_Word(5); state <= state + 1;
    when 488 => signal_one_bit_data <= Test_Sync_Word(6); state <= state + 1; --MİSTAKE 1
    when 489 => signal_one_bit_data <= Test_Sync_Word(7); state <= state + 1; --MİSTAKE 1
    when 490 => if(test_counter=Test_Packet_Length) then 
                test_counter <= 0; state <= state + 1;
                else
                test_counter <= test_counter + 1;
                end if;
    when 491 => Test_Sync_Word <= x"0000C0B0";       
                Test_Byte_Sync_Word <= "010";  
                signal_one_bit_data <= '0'; -- MİSTAKE 3
                state <= state + 1;
    when 492 => signal_one_bit_data <= not Test_Sync_Word(1); state <= state + 1;
    when 493 => signal_one_bit_data <= not Test_Sync_Word(2); state <= state + 1;
    when 494 => signal_one_bit_data <= Test_Sync_Word(3); state <= state + 1; --MİSTAKE 1
    when 495 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 496 => signal_one_bit_data <= not Test_Sync_Word(5); state <= state + 1;
    when 497 => signal_one_bit_data <= not Test_Sync_Word(6); state <= state + 1;
    when 498 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;
    when 499 => signal_one_bit_data <= not Test_Sync_Word(8); state <= state + 1;
    when 500 => signal_one_bit_data <= not Test_Sync_Word(9); state <= state + 1;
    when 501 => signal_one_bit_data <= not Test_Sync_Word(10); state <= state + 1;
    when 502 => signal_one_bit_data <= not Test_Sync_Word(11); state <= state + 1;
    when 503 => signal_one_bit_data <= not Test_Sync_Word(12); state <= state + 1;
    when 504 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1;
    when 505 => signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1;
    when 506 => signal_one_bit_data <= Test_Sync_Word(15); state <= state + 1; --MİSTAKE 2
    when 507 => if(test_counter=Test_Packet_Length) then 
                test_counter <= 0; state <= state + 1;
                else
                test_counter <= test_counter + 1;
                end if;
    when 508 => Test_Sync_Word <= x"00A0B0C1";       
                Test_Byte_Sync_Word <= "011";  -- 3 byte sync word 
                signal_one_bit_data <= '1'; -- MİSTAKE 1
                state <= state + 1;
    when 509 => signal_one_bit_data <= Test_Sync_Word(1); state <= state + 1; -- MİSTAKE 2
    when 510 => signal_one_bit_data <= not Test_Sync_Word(2); state <= state + 1;
    when 511 => signal_one_bit_data <= not Test_Sync_Word(3) ; state <= state + 1;
    when 512 => signal_one_bit_data <= not Test_Sync_Word(4); state <= state + 1;
    when 513 => signal_one_bit_data <= not Test_Sync_Word(5); state <= state + 1;
    when 514 => signal_one_bit_data <= not Test_Sync_Word(6); state <= state + 1;
    when 515 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;
    when 516 => signal_one_bit_data <= not Test_Sync_Word(8); state <= state + 1;
    when 517 => signal_one_bit_data <= not Test_Sync_Word(9); state <= state + 1;
    when 518 => signal_one_bit_data <= not Test_Sync_Word(10); state <= state + 1;
    when 519 => signal_one_bit_data <= not Test_Sync_Word(11); state <= state + 1;
    when 520 => signal_one_bit_data <= Test_Sync_Word(12); state <= state + 1; -- MİSTAKE 3
    when 521 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1;
    when 522 => signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1;
    when 523 => signal_one_bit_data <= not Test_Sync_Word(15); state <= state + 1;
    when 524 => signal_one_bit_data <= not Test_Sync_Word(16); state <= state + 1;
    when 525 => signal_one_bit_data <= not Test_Sync_Word(17); state <= state + 1;
    when 526 => signal_one_bit_data <= not Test_Sync_Word(18); state <= state + 1;
    when 527 => signal_one_bit_data <= not Test_Sync_Word(19); state <= state + 1;
    when 528 => signal_one_bit_data <= not Test_Sync_Word(20); state <= state + 1;
    when 529 => signal_one_bit_data <= not Test_Sync_Word(21); state <= state + 1;
    when 530 => signal_one_bit_data <= not Test_Sync_Word(22); state <= state + 1;
    when 531 => signal_one_bit_data <= Test_Sync_Word(23); state <= state + 1; -- MİSTAKE 4
    when 532 => if(test_counter=Test_Packet_Length) then 
                test_counter <= 0; state <= state + 1;
                else
                test_counter <= test_counter + 1;
                end if;
    when 533 => Test_Sync_Word <= x"1ACFFC1D"; --0001 1010 1100 1111 1111 1100 0001 1101 
                Test_Byte_Sync_Word <= "100";                                            
                signal_one_bit_data <= '1'; -- Test_Sync_Word(0) MİSTAKE 1               
                state <= state + 1;                                                      
    when 534 => signal_one_bit_data <= not Test_Sync_Word(1);  state <= state + 1;                            
    when 535 => signal_one_bit_data <= not Test_Sync_Word(2);  state <= state + 1;                            
    when 536 => signal_one_bit_data <= not Test_Sync_Word(3);  state <= state + 1;                            
    when 537 => signal_one_bit_data <= not Test_Sync_Word(4);  state <= state + 1;                            
    when 538 => signal_one_bit_data <= not Test_Sync_Word(5);  state <= state + 1;                            
    when 539 => signal_one_bit_data <= not Test_Sync_Word(6);  state <= state + 1;                            
    when 540 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;                              
    when 541 => signal_one_bit_data <=  Test_Sync_Word(8); state <= state + 1;       --second mistake                       
    when 542 => signal_one_bit_data <= not Test_Sync_Word(9); state <= state + 1;                              
    when 543 => signal_one_bit_data <= not Test_Sync_Word(10); state <= state + 1;                             
    when 544 => signal_one_bit_data <= not Test_Sync_Word(11); state <= state + 1;                             
    when 545 => signal_one_bit_data <= not Test_Sync_Word(12); state <= state + 1;                             
    when 546 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1;      
    when 547 => signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1;        
    when 548 => signal_one_bit_data <= not Test_Sync_Word(15); state <= state + 1;                             
    when 549 => signal_one_bit_data <= not Test_Sync_Word(16); state <= state + 1;                             
    when 550 => signal_one_bit_data <= not Test_Sync_Word(17); state <= state + 1;                             
    when 551 => signal_one_bit_data <= not Test_Sync_Word(18); state <= state + 1;                             
    when 552 => signal_one_bit_data <= not Test_Sync_Word(19); state <= state + 1;                             
    when 553 => signal_one_bit_data <= not Test_Sync_Word(20); state <= state + 1;          
    when 554 => signal_one_bit_data <= not Test_Sync_Word(21); state <= state + 1;                             
    when 555 => signal_one_bit_data <= not Test_Sync_Word(22); state <= state + 1;                             
    when 556 => signal_one_bit_data <= Test_Sync_Word(23); state <= state + 1;  --third mistake                           
    when 557 => signal_one_bit_data <= not Test_Sync_Word(24); state <= state + 1;                            
    when 558 => signal_one_bit_data <= not Test_Sync_Word(25); state <= state + 1;                             
    when 559 => signal_one_bit_data <= not Test_Sync_Word(26); state <= state + 1;                             
    when 560 => signal_one_bit_data <= Test_Sync_Word(27); state <= state + 1;    --fourth mistake                         
    when 561 => signal_one_bit_data <= not Test_Sync_Word(28); state <= state + 1;                            
    when 562 => signal_one_bit_data <= not Test_Sync_Word(29); state <= state + 1;                             
    when 563 => signal_one_bit_data <= not Test_Sync_Word(30); state <= state + 1;            
    when 564 => signal_one_bit_data <= Test_Sync_Word(31); state <= state + 1;   --Fifth Mistake  ||| Sync Word done 
    when 565 => if(test_counter=Test_Packet_Length) then 
                test_counter <= 0; state <= state + 1;
                else
                test_counter <= test_counter + 1;
                end if;
    when 566 => Test_Sync_Word <= x"00000000";       
                Test_Byte_Sync_Word <= "000";
                Test_Chip_Enable <= '0';
                state <= state + 1;            
    
    when 567 => Test_Sync_Word <= x"1ACFFC1D"; --0001 1010 1100 1111 1111 1100 0001 1101 
                                Test_Byte_Sync_Word <= "100";                                            
                                signal_one_bit_data <= '1'; -- Test_Sync_Word(0) MİSTAKE 1               
                                state <= state + 1;                                                      
    when 568 => signal_one_bit_data <= not Test_Sync_Word(1);  state <= state + 1;                            
    when 569 => signal_one_bit_data <= not Test_Sync_Word(2);  state <= state + 1;                            
    when 570 => signal_one_bit_data <= not Test_Sync_Word(3);  state <= state + 1;                            
    when 571 => signal_one_bit_data <= not Test_Sync_Word(4);  state <= state + 1;                            
    when 572 => signal_one_bit_data <= not Test_Sync_Word(5);  state <= state + 1;                            
    when 573 => signal_one_bit_data <= not Test_Sync_Word(6);  state <= state + 1;                            
    when 574 => signal_one_bit_data <= not Test_Sync_Word(7); state <= state + 1;                              
    when 575 => signal_one_bit_data <=  Test_Sync_Word(8); state <= state + 1;       --second mistake                       
    when 576 => signal_one_bit_data <= not Test_Sync_Word(9); state <= state + 1;                              
    when 577 => signal_one_bit_data <= not Test_Sync_Word(10); state <= state + 1;                             
    when 578 => signal_one_bit_data <= not Test_Sync_Word(11); state <= state + 1;                             
    when 579 => signal_one_bit_data <= not Test_Sync_Word(12); state <= state + 1;                             
    when 580 => signal_one_bit_data <= not Test_Sync_Word(13); state <= state + 1;      
    when 581 => signal_one_bit_data <= not Test_Sync_Word(14); state <= state + 1;        
    when 582 => signal_one_bit_data <= not Test_Sync_Word(15); state <= state + 1;                             
    when 583 => signal_one_bit_data <= not Test_Sync_Word(16); state <= state + 1;                             
    when 584 => signal_one_bit_data <= not Test_Sync_Word(17); state <= state + 1;                             
    when 585 => signal_one_bit_data <= not Test_Sync_Word(18); state <= state + 1;                             
    when 586 => signal_one_bit_data <= not Test_Sync_Word(19); state <= state + 1;                             
    when 587 => signal_one_bit_data <= not Test_Sync_Word(20); state <= state + 1;          
    when 588 => signal_one_bit_data <= not Test_Sync_Word(21); state <= state + 1;                             
    when 589 => signal_one_bit_data <= not Test_Sync_Word(22); state <= state + 1;                             
    when 590 => signal_one_bit_data <= Test_Sync_Word(23); state <= state + 1;  --third mistake                           
    when 591 => signal_one_bit_data <= not Test_Sync_Word(24); state <= state + 1;                            
    when 592 => signal_one_bit_data <= not Test_Sync_Word(25); state <= state + 1;                             
    when 593 => signal_one_bit_data <= not Test_Sync_Word(26); state <= state + 1;                             
    when 594 => signal_one_bit_data <= Test_Sync_Word(27); state <= state + 1;    --fourth mistake                         
    when 595 => signal_one_bit_data <= not Test_Sync_Word(28); state <= state + 1;                            
    when 596 => signal_one_bit_data <= not Test_Sync_Word(29); state <= state + 1;                             
    when 597 => signal_one_bit_data <= not Test_Sync_Word(30); state <= state + 1;            
    when 598 => signal_one_bit_data <= not Test_Sync_Word(31); state <= state + 1;  -- Sync Word done 
   
    when 599 => TEST_DONE_FLAG <= '1'; signal_one_bit_data <= '0'; state <= state + 1;

    when 600 => assert false report "Simulation completed." severity failure;
    
    end case;
end if;
end process;
end Behavioral;
