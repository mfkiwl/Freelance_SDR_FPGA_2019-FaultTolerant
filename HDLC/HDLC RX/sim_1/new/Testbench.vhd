
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Testbench is
  Port ( CLK : in std_logic;
         BUSY_Out : out std_logic;
         Data_Valid_Out : out std_logic;
         Serial_Data_Out : out std_logic
         );
end Testbench;

architecture Behavioral of Testbench is

component HDLC_RX is
 Port ( CLK : in std_logic;
        Serial_Data : in std_logic;
        ENABLE      : in std_logic;
        ASYNC_RESET : in std_logic;
        BUSY_Out : out std_logic;
        Data_Valid_Out : out std_logic;
        Serial_Data_Out : out std_logic
       );
end component HDLC_RX;

signal Serial_Data : std_logic ;
signal ENABLE : std_logic;
signal ASYNC_RESET : std_logic := '0';

signal Packet : std_logic_vector(423 downto 0) := x"041103cc4500002f731c00007f114447c0a80129c0a801e11a701a71001b9f580800050000130064d055b21f00010c04e531267ACC";

signal Bit_Stuffing_State : integer range 0 to 5 := 0;

signal Counter : integer range 0 to 424 := 0;

signal Beginning : integer range 0 to 7 := 0;
signal Beginning_Frame : std_logic_vector(7 downto 0) := x"7E";

begin

process(CLK)
begin
if rising_edge(CLK) then
    case Beginning is
    when 0 =>
        ASYNC_RESET <= '0';
        ENABLE <= '1';
        if Counter < 7 then
            Serial_Data <= Beginning_Frame(7 - Counter);
            Counter <= Counter + 1;
         else
            Serial_Data <= Beginning_Frame(7 - Counter);
            Counter <= 0;
            Beginning <= 1;
         end if;
    when 1 =>
    if Counter < 423 then
        case(Bit_Stuffing_State) is
            when 0 =>
                if Packet(423 - Counter) = '1' then
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;
                ENABLE <= '1';
                Serial_Data <= Packet(423 - Counter);
                Counter <= Counter + 1;
                
            when 1 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);       
                Counter <= Counter + 1;     
            
            when 2 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);         
                Counter <= Counter + 1;              
            
            when 3 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);      
                Counter <= Counter + 1;      
            
            when 4 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);  
                Counter <= Counter + 1;    
                      
            when 5 =>
                Serial_Data <= '0';
                ENABLE <= '1';
                Bit_Stuffing_State <= 0;
        end case;
      elsif Counter = 423 then
        Counter <= Counter + 1;
        ENABLE <= '1';
        Serial_Data <= not Packet(423 - Counter);
      else
        ENABLE <= '0';
        Counter <= 0;
        Serial_Data <= '0';
        Bit_Stuffing_State <= 0;
        Beginning <= 2;
      end if;
    
    when 2 =>
        if Counter < 424 then
            Counter <= Counter + 1;
        else
            Counter <= 0;
            Beginning <= 3;
        end if;
    when 3 =>
         ENABLE <= '1';
         if Counter < 7 then
             Serial_Data <= Beginning_Frame(7 - Counter);
             Counter <= Counter + 1;
         else
             Serial_Data <= Beginning_Frame(7 - Counter);
             Counter <= 0;
             Beginning <= 4;
         end if;
        
    when 4 =>
      if Counter < 424 then
        case(Bit_Stuffing_State) is
            when 0 =>
                if Packet(423 - Counter) = '1' then
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;
                ENABLE <= '1';
                Serial_Data <= Packet(423 - Counter);
                Counter <= Counter + 1;
                
            when 1 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);       
                Counter <= Counter + 1;     
            
            when 2 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);         
                Counter <= Counter + 1;              
            
            when 3 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);      
                Counter <= Counter + 1;      
            
            when 4 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);  
                Counter <= Counter + 1;    
                      
            when 5 =>
                Serial_Data <= '0';
                ENABLE <= '1';
                Bit_Stuffing_State <= 0;
        end case;
      else
        ENABLE <= '0';
        Counter <= 0;
        Serial_Data <= '0';
        Bit_Stuffing_State <= 0;
        Beginning <= 5;
      end if;
    
    when 5 =>
        if Counter < 200 then
            Counter <= Counter + 1;
        else
            ASYNC_RESET <= '1';
            ENABLE <= '0';
            Counter <= 0;
            Beginning <= 6;
        end if;
    
    when 6 =>
    ASYNC_RESET <= '0';
    ENABLE <= '1';
    if Counter < 7 then
        Serial_Data <= Beginning_Frame(7 - Counter);
        Counter <= Counter + 1;
     else
        Serial_Data <= Beginning_Frame(7 - Counter);
        Counter <= 0;
        Beginning <= 7;
     end if;
    
    when 7 =>
            if Counter < 424 then
        case(Bit_Stuffing_State) is
            when 0 =>
                if Packet(423 - Counter) = '1' then
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;
                ENABLE <= '1';
                Serial_Data <= Packet(423 - Counter);
                Counter <= Counter + 1;
                
            when 1 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);       
                Counter <= Counter + 1;     
            
            when 2 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);         
                Counter <= Counter + 1;              
            
            when 3 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);      
                Counter <= Counter + 1;      
            
            when 4 =>
                if Packet(423 - Counter) = '1' then              
                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                    else
                    Bit_Stuffing_State <= 0;
                end if;                                          
                ENABLE <= '1';                                   
                Serial_Data <= Packet(423 - Counter);  
                Counter <= Counter + 1;    
                      
            when 5 =>
                Serial_Data <= '0';
                ENABLE <= '1';
                Bit_Stuffing_State <= 0;
        end case;
      else
        ENABLE <= '0';
        Serial_Data <= '0';
        Bit_Stuffing_State <= 0;
        assert false report "Simulation completed." severity failure;
      end if;

    end case;
  end if;
end process;

HDLC_RX_INST : HDLC_RX
 Port Map(
    CLK => CLK,
    Serial_Data => Serial_Data,
    ENABLE => ENABLE,
    ASYNC_RESET => ASYNC_RESET,

    BUSY_Out => BUSY_Out,
    Data_Valid_Out => Data_Valid_Out,
    Serial_Data_Out => Serial_Data_Out
 );

end Behavioral;
