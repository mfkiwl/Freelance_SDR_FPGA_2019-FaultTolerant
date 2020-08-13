

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HDLC_Testbench is
  Port (    
  TEST_CLK         : in std_logic;
  
  TEST_Data_Valid_Out : out std_logic;
  TEST_BUSY_OUT        : out std_logic; 
  TEST_DATA_OUT    : out std_logic
        );
end HDLC_Testbench;

architecture Behavioral of HDLC_Testbench is

component HLDC_Main is
  Port (    
            ASYNC_RESET : in std_logic;
            CLK         : in std_logic;
            DATA_IN     : in std_logic; 
            Data_Valid_In      : in std_logic;
            Start_Of_Frame : in std_logic;
            End_Of_Frame : in std_logic;
            REQ         : in std_logic;
            
            READY       : out std_logic;
            Data_Valid_Out : out std_logic;
            BUSY_OUT        : out std_logic; 
            DATA_OUT    : out std_logic
        );
end component HLDC_Main;

signal Packet : std_logic_vector(375 downto 0) := x"4500002f731c00007f114447c0a80129c0a801e11a701a71001b9f580800050000130064d055b21f00010c04e53126";

signal Counter : integer range 0 to 376 := 0;
signal Second_Counter : integer range 0 to 376 := 0;
signal Third_Counter : integer range 0 to 376 := 0;
signal Fourth_Counter : integer range 0 to 500 := 0;

signal Delay_Counter : integer range 0 to 500 := 0;
signal Second_Delay_Counter : integer range 0 to 50 := 0;

signal Loop_Counter : integer range 0 to 3 := 0;

signal TEST_READY : std_logic;
signal TEST_Start_Of_Frame : std_logic;
signal TEST_End_Of_Frame : std_logic;
signal TEST_REQ : std_logic;
signal TEST_Data_Valid_In : std_logic;
signal TEST_ASYNC_RESET : std_logic;
signal TEST_DATA_IN : std_logic;


begin

process(TEST_CLK, TEST_ASYNC_RESET)
begin
if rising_edge(TEST_CLK) then
  if Counter < 376 then
    TEST_ASYNC_RESET <= '0';
    TEST_Data_Valid_In <= '1';
    TEST_DATA_IN <= Packet(375 - Counter);
    Counter <= Counter + 1;
    if (Counter = 0) then
        Test_Start_Of_Frame <= '1';
        else
        Test_Start_Of_Frame <= '0';
    end if;
    
    if (Counter = 375) then
        Test_End_Of_Frame <= '1';
        else
        Test_End_Of_Frame <= '0';
    end if;

  else
        if Delay_Counter < 500 then
        Test_End_Of_Frame <= '0';
            if (Loop_Counter < 2) then              -- TEST ÝÇÝN AYARLANABÝLÝR REQ DELAY SAYACI
            Loop_Counter <= Loop_Counter + 1;       --
            TEST_REQ <= '0';                        --
            else                                    --
            TEST_REQ <= '1';                        --
            Delay_Counter <= Delay_Counter + 1;     --
            Loop_Counter <= 0;                      --
            end if;                                 --
        TEST_DATA_IN <= '0';
        TEST_Data_Valid_In <= '0';
        else
            if Second_Counter < 376 then
                TEST_REQ <= '0';
                TEST_Data_Valid_In <= '1';
                TEST_DATA_IN <= Packet(375 - Second_Counter);
                Second_Counter <= Second_Counter + 1;
                if (Second_Counter = 0) then
                    Test_Start_Of_Frame <= '1';
                    else
                    Test_Start_Of_Frame <= '0';
                end if;
                
                if (Second_Counter = 375) then
                    Test_End_Of_Frame <= '1';
                    else
                    Test_End_Of_Frame <= '0';
                end if;
                
            else
                if Second_Delay_Counter < 20 then
                Test_End_Of_Frame <= '0';
                TEST_Data_Valid_In <= '0';
                TEST_DATA_IN <= '0';
                TEST_ASYNC_RESET <= '0';
                Second_Delay_Counter <= Second_Delay_Counter + 1;
                    elsif Second_Delay_Counter < 50 then
                    TEST_ASYNC_RESET <= '1';
                    TEST_Data_Valid_In <= '0';
                    TEST_DATA_IN <= '0';
                    Second_Delay_Counter <= Second_Delay_Counter + 1;
                    elsif Second_Delay_Counter = 50 then
                    TEST_ASYNC_RESET <= '0';
                        if Third_Counter < 376 then
                            if Third_Counter = 0 then
                                Test_Start_Of_Frame <= '1';
                            else
                                Test_Start_Of_Frame <= '0';
                            end if;
                            if Third_Counter = 375 then      
                                Test_End_Of_Frame <= '1';
                            else                           
                                Test_End_Of_Frame <= '0';
                            end if;                        
                            TEST_Data_Valid_In <= '1';
                            TEST_DATA_IN <= Packet(375 - Third_Counter);
                            Third_Counter <= Third_Counter + 1;
                            else
                            Test_End_Of_Frame <= '0';
                            TEST_Data_Valid_In <= '0';
                            if Fourth_Counter < 500 then
                               Fourth_Counter <= Fourth_Counter + 1;
                               Test_REQ <= '1';
                            else
                               Test_REQ <= '0'; assert false report "Simulation completed." severity failure;
                            end if;
                        end if;                end if;
            end if;    
        end if;
  end if;
end if;
end process;

HDLC_INST : HLDC_Main
Port Map(
    ASYNC_RESET => TEST_ASYNC_RESET,
    CLK         => TEST_CLK,
    DATA_IN     => TEST_DATA_IN,
    Data_Valid_In      => TEST_Data_Valid_In,
    Start_Of_Frame => TEST_Start_Of_Frame,
    End_Of_Frame => TEST_End_Of_Frame,
    REQ => TEST_REQ,
    
    READY => TEST_READY,
    Data_Valid_Out => TEST_Data_Valid_Out,
    BUSY_OUT    => TEST_BUSY_OUT,
    DATA_OUT    => TEST_DATA_OUT
);

end Behavioral;
