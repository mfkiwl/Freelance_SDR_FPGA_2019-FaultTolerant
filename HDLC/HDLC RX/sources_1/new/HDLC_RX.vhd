
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HDLC_RX is
 Port ( CLK : in std_logic;
        Serial_Data : in std_logic;
        ENABLE      : in std_logic;
        ASYNC_RESET : in std_logic;

        BUSY_Out : out std_logic;
        Data_Valid_Out : out std_logic;
        Serial_Data_Out : out std_logic
       );
end HDLC_RX;

architecture Behavioral of HDLC_RX is

component single_port_RAM is
  port(
    clk: in std_logic;
    we : in std_logic;
    addr : in std_logic_vector(14-1 downto 0);
    din : in std_logic;
    dout : out std_logic
    );
end component single_port_RAM;


constant BEGINNING_FRAME : std_logic_vector(7 downto 0) := x"7E";

signal BEGINNING_STATE : integer range 0 to 7 := 0;

signal Bit_Stuffing_State : integer range 0 to 5 := 0;

signal FOUND : std_logic := '0';

signal BUSY : std_logic := '0';
signal LOAD : std_logic := '0';

signal CRC_ENABLE_COUNTER : integer range 0 to 7 := 0;
signal CRC_ENABLE : std_logic := '0';
signal CRC16_IN     : std_logic_vector(15 downto 0);
signal CRC16_OUT    : std_logic_vector(15 downto 0);
signal DATA_IN_BYTE : std_logic_vector(7 downto 0) := x"FF";


signal Packet_Counter : integer range 0 to 8239 := 0;

signal FCS_STATE : integer range 0 to 15 := 0;

--PACKET LENGTH PROCESS REGISTERS
signal PACKET_LENGTH : unsigned(15 downto 0) := (others => '1');
signal Packet_Length_as_bit : unsigned(31 downto 0) := (others => '1');
--

--RAM SÝGNALS
signal we : std_logic := '0';
signal addr : std_logic_vector(13 downto 0) := (others => '0');
signal din : std_logic;
signal dout : std_logic;
--

signal Last_Bit : std_logic;

begin

single_port_RAM_INST : single_port_RAM
port map(
    clk => clk,
    we => we,
    din => din,
    dout => dout,
    addr => addr
);

BUSY_Out <= LOAD;

Packet_Length_as_bit <= (8 * Packet_LENGTH) + 33;
addr <= std_logic_vector(to_unsigned(Packet_Counter, addr'length));

LOADING : process(CLK, ASYNC_RESET)
begin
    if ASYNC_RESET = '1' then
    CRC_ENABLE_COUNTER <= 0;
    CRC_ENABLE <= '0';  
    Packet_Counter <= 0;
    FCS_STATE <= 0;
    we <= '0';
    Bit_Stuffing_State <= 0;
    Beginning_State <= 0;
    BUSY <= '0';
    LOAD <= '0';
    FOUND <= '0';
    Data_Valid_Out <= '0';
    Serial_Data_Out <= '0';
    CRC16_IN <= x"FFFF";
    
    elsif rising_edge(CLK) then
      
        case(BUSY) is
        
            when '0' =>
              if ENABLE = '1' then
              
                case(FOUND) is
                
                    when '0' =>
                    Data_Valid_Out <= '0';
                        case(BEGINNING_STATE) is
                            when 0 =>
                                if Serial_Data = BEGINNING_FRAME(7) then
                                    BEGINNING_STATE <= BEGINNING_STATE + 1;
                                else
                                    BEGINNING_STATE <= 0;
                                end if;
                            when 1 =>
                                if Serial_Data = BEGINNING_FRAME(6) then  
                                    BEGINNING_STATE <= BEGINNING_STATE + 1;
                                else                                       
                                    BEGINNING_STATE <= 0;                  
                                end if;                                    
                            when 2 =>
                                if Serial_Data = BEGINNING_FRAME(5) then  
                                    BEGINNING_STATE <= BEGINNING_STATE + 1;
                                else                                       
                                    BEGINNING_STATE <= 0;                  
                                end if;                                    
                            when 3 =>
                                if Serial_Data = BEGINNING_FRAME(4) then  
                                    BEGINNING_STATE <= BEGINNING_STATE + 1;
                                else                                       
                                    BEGINNING_STATE <= 0;                  
                                end if;                                    
                            when 4 =>
                                if Serial_Data = BEGINNING_FRAME(3) then  
                                    BEGINNING_STATE <= BEGINNING_STATE + 1;
                                else                                       
                                    BEGINNING_STATE <= 0;                  
                                end if;                                    
                            when 5 =>
                                if Serial_Data = BEGINNING_FRAME(2) then  
                                    BEGINNING_STATE <= BEGINNING_STATE + 1;
                                else                                       
                                    BEGINNING_STATE <= 0;                  
                                end if;                                    
                            when 6 =>
                                if Serial_Data = BEGINNING_FRAME(1) then  
                                    BEGINNING_STATE <= BEGINNING_STATE + 1;
                                else                                       
                                    BEGINNING_STATE <= 0;                  
                                end if;                                                                
                            when 7 =>
                                BEGINNING_STATE <= 0;
                                if Serial_Data = BEGINNING_FRAME(0) then
                                    Bit_Stuffing_State <= 0;
                                    FOUND <= '1';
                                end if;
                        end case;
                    when '1' =>
                      if Packet_Counter < Packet_Length_as_bit - 2 then
                      
                        case(Bit_Stuffing_State) is
                        
                            when 0 =>
                              Packet_Counter <= Packet_Counter + 1;
                              we <= '1';
                              din <= Serial_Data;
                                if Serial_Data = '1' then
                                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                                else
                                    Bit_Stuffing_State <= 0;
                                end if;
                                if Packet_Counter = 0 then
                                    DATA_IN_BYTE(7) <= Serial_Data;
                                elsif Packet_Counter = 1 then
                                    DATA_IN_BYTE(6) <= Serial_Data;
                                elsif Packet_Counter = 2 then
                                    DATA_IN_BYTE(5) <= Serial_Data;
                                elsif Packet_Counter = 3 then
                                    DATA_IN_BYTE(4) <= Serial_Data;
                                elsif Packet_Counter = 4 then
                                    DATA_IN_BYTE(3) <= Serial_Data;
                                elsif Packet_Counter = 5 then
                                    DATA_IN_BYTE(2) <= Serial_Data;
                                elsif Packet_Counter = 6 then
                                    DATA_IN_BYTE(1) <= Serial_Data;
                                    CRC_ENABLE <= '1';
                                    CRC16_IN <= x"FFFF";
                                    CRC_ENABLE_COUNTER <= 0;
                                elsif Packet_Counter = 7 then
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(7 downto 1 ) & Serial_Data;
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= 1;
                                elsif Packet_Counter = 8 then
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & Serial_Data;
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= 2;
                                elsif Packet_Counter > 8 then
                                    if CRC_ENABLE_COUNTER < 7 then
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= CRC_ENABLE_COUNTER + 1;
                                    else
                                    CRC_ENABLE <= '1';
                                    CRC_ENABLE_COUNTER <= 0;
                                    end if;
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & Serial_Data;
                                end if;
                                
                            when 1 =>
                              Packet_Counter <= Packet_Counter + 1;
                              we <= '1';
                              din <= Serial_Data;
                                if Serial_Data = '1' then                        
                                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                                else                                             
                                    Bit_Stuffing_State <= 0;                     
                                end if;
                                if Packet_Counter = 0 then
                                    DATA_IN_BYTE(7) <= Serial_Data;
                                elsif Packet_Counter = 1 then
                                    DATA_IN_BYTE(6) <= Serial_Data;
                                elsif Packet_Counter = 2 then
                                    DATA_IN_BYTE(5) <= Serial_Data;
                                elsif Packet_Counter = 3 then
                                    DATA_IN_BYTE(4) <= Serial_Data;
                                elsif Packet_Counter = 4 then
                                    DATA_IN_BYTE(3) <= Serial_Data;
                                elsif Packet_Counter = 5 then
                                    DATA_IN_BYTE(2) <= Serial_Data;
                                elsif Packet_Counter = 6 then
                                    DATA_IN_BYTE(1) <= Serial_Data;
                                    CRC_ENABLE <= '1';
                                    CRC16_IN <= x"FFFF";
                                    CRC_ENABLE_COUNTER <= 0;
                                elsif Packet_Counter = 7 then
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(7 downto 1 ) & Serial_Data;
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= 1;
                                elsif Packet_Counter = 8 then
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & Serial_Data;
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= 2;
                                elsif Packet_Counter > 8 then
                                    if CRC_ENABLE_COUNTER < 7 then
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= CRC_ENABLE_COUNTER + 1;
                                    else
                                    CRC_ENABLE <= '1';
                                    CRC_ENABLE_COUNTER <= 0;
                                    end if;
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & Serial_Data;
                                end if;
                                                                  
                            when 2 =>
                              Packet_Counter <= Packet_Counter + 1;        
                              we <= '1';         
                              din <= Serial_Data;
                                if Serial_Data = '1' then                        
                                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                                else                                             
                                    Bit_Stuffing_State <= 0;                     
                                end if;     
                                if Packet_Counter = 0 then
                                    DATA_IN_BYTE(7) <= Serial_Data;
                                elsif Packet_Counter = 1 then
                                    DATA_IN_BYTE(6) <= Serial_Data;
                                elsif Packet_Counter = 2 then
                                    DATA_IN_BYTE(5) <= Serial_Data;
                                elsif Packet_Counter = 3 then
                                    DATA_IN_BYTE(4) <= Serial_Data;
                                elsif Packet_Counter = 4 then
                                    DATA_IN_BYTE(3) <= Serial_Data;
                                elsif Packet_Counter = 5 then
                                    DATA_IN_BYTE(2) <= Serial_Data;
                                elsif Packet_Counter = 6 then
                                    DATA_IN_BYTE(1) <= Serial_Data;
                                    CRC_ENABLE <= '1';
                                    CRC16_IN <= x"FFFF";
                                    CRC_ENABLE_COUNTER <= 0;
                                elsif Packet_Counter = 7 then
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(7 downto 1 ) & Serial_Data;
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= 1;
                                elsif Packet_Counter = 8 then
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & Serial_Data;
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= 2;
                                elsif Packet_Counter > 8 then
                                    if CRC_ENABLE_COUNTER < 7 then
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= CRC_ENABLE_COUNTER + 1;
                                    else
                                    CRC_ENABLE <= '1';
                                    CRC_ENABLE_COUNTER <= 0;
                                    end if;
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & Serial_Data;
                                end if;
                                                                    
                            when 3 =>
                              Packet_Counter <= Packet_Counter + 1;        
                              we <= '1';         
                              din <= Serial_Data;
                                if Serial_Data = '1' then                        
                                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                                else                                             
                                    Bit_Stuffing_State <= 0;                     
                                end if;     
                                if Packet_Counter = 0 then
                                    DATA_IN_BYTE(7) <= Serial_Data;
                                elsif Packet_Counter = 1 then
                                    DATA_IN_BYTE(6) <= Serial_Data;
                                elsif Packet_Counter = 2 then
                                    DATA_IN_BYTE(5) <= Serial_Data;
                                elsif Packet_Counter = 3 then
                                    DATA_IN_BYTE(4) <= Serial_Data;
                                elsif Packet_Counter = 4 then
                                    DATA_IN_BYTE(3) <= Serial_Data;
                                elsif Packet_Counter = 5 then
                                    DATA_IN_BYTE(2) <= Serial_Data;
                                elsif Packet_Counter = 6 then
                                    DATA_IN_BYTE(1) <= Serial_Data;
                                    CRC_ENABLE <= '1';
                                    CRC16_IN <= x"FFFF";
                                    CRC_ENABLE_COUNTER <= 0;
                                elsif Packet_Counter = 7 then
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(7 downto 1 ) & Serial_Data;
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= 1;
                                elsif Packet_Counter = 8 then
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & Serial_Data;
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= 2;
                                elsif Packet_Counter > 8 then
                                    if CRC_ENABLE_COUNTER < 7 then
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= CRC_ENABLE_COUNTER + 1;
                                    else
                                    CRC_ENABLE <= '1';
                                    CRC_ENABLE_COUNTER <= 0;
                                    end if;
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & Serial_Data;
                                end if;
                                
                            when 4 =>
                              Packet_Counter <= Packet_Counter + 1;        
                              we <= '1';         
                              din <= Serial_Data;
                                if Serial_Data = '1' then                        
                                    Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                                else                                             
                                    Bit_Stuffing_State <= 0;                     
                                end if;
                                if Packet_Counter = 0 then
                                    DATA_IN_BYTE(7) <= Serial_Data;
                                elsif Packet_Counter = 1 then
                                    DATA_IN_BYTE(6) <= Serial_Data;
                                elsif Packet_Counter = 2 then
                                    DATA_IN_BYTE(5) <= Serial_Data;
                                elsif Packet_Counter = 3 then
                                    DATA_IN_BYTE(4) <= Serial_Data;
                                elsif Packet_Counter = 4 then
                                    DATA_IN_BYTE(3) <= Serial_Data;
                                elsif Packet_Counter = 5 then
                                    DATA_IN_BYTE(2) <= Serial_Data;
                                elsif Packet_Counter = 6 then
                                    DATA_IN_BYTE(1) <= Serial_Data;
                                    CRC_ENABLE <= '1';
                                    CRC16_IN <= x"FFFF";
                                    CRC_ENABLE_COUNTER <= 0;
                                elsif Packet_Counter = 7 then
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(7 downto 1 ) & Serial_Data;
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= 1;
                                elsif Packet_Counter = 8 then
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & Serial_Data;
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= 2;
                                elsif Packet_Counter > 8 then
                                    if CRC_ENABLE_COUNTER < 7 then
                                    CRC16_IN <= CRC16_OUT;
                                    CRC_ENABLE <= '0';
                                    CRC_ENABLE_COUNTER <= CRC_ENABLE_COUNTER + 1;
                                    else
                                    CRC_ENABLE <= '1';
                                    CRC_ENABLE_COUNTER <= 0;
                                    end if;
                                    DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & Serial_Data;
                                end if;
                                                   
                            when 5 =>
                                we <= '0';
                                CRC_ENABLE <= '0';
                                Bit_Stuffing_State <= 0;
                        end case;
                        
                     else
                        CRC_ENABLE <= '0';
                        CRC_ENABLE_COUNTER <= 0;
                        we <= '0';
                        last_bit <= Serial_Data;
                        Packet_Counter <= 0;
                        FCS_STATE <= 0;
                        BUSY <= '1';
                        FOUND <= '0';
                      end if;
                    when OTHERS => NULL;
                end case;
              else
                  CRC_ENABLE_COUNTER <= 0;
                  CRC_ENABLE <= '0';  
                  CRC16_IN <= x"FFFF";
                  FOUND <= '0';
                  Packet_Counter <= 0;
                  Data_Valid_Out <= '0';
                  Serial_Data_Out <= '0';
                  Bit_Stuffing_State <= 0;
                  we <= '0';
              end if;
              
            when '1' =>
             case(LOAD) is
             when '0' =>
             we <= '0';
              case(Bit_Stuffing_State) is        
              when 0 =>
                if Serial_Data = '1' then
                        Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                      else
                        Bit_Stuffing_State <= 0;
                end if;
                
                case(FCS_STATE) is
                    when 0 =>
                        if Serial_Data = CRC16_OUT(15) then
                            FCS_STATE <= FCS_STATE + 1;
                        else
                            BUSY <= '0';
                            FCS_STATE <= 0;
                        end if;
                    when 1 =>
                        if Serial_Data = CRC16_OUT(14) then
                            FCS_STATE <= FCS_STATE + 1;    
                        else                               
                            BUSY <= '0';                   
                            FCS_STATE <= 0;                
                        end if;                            
                    when 2 =>
                        if Serial_Data = CRC16_OUT(13) then
                            FCS_STATE <= FCS_STATE + 1;    
                        else                               
                            BUSY <= '0';                   
                            FCS_STATE <= 0;                
                        end if;                            
                    when 3 =>
                        if Serial_Data = CRC16_OUT(12) then
                            FCS_STATE <= FCS_STATE + 1;    
                        else                               
                            BUSY <= '0';                   
                            FCS_STATE <= 0;                
                        end if;                            
                    when 4 =>
                        if Serial_Data = CRC16_OUT(11) then
                            FCS_STATE <= FCS_STATE + 1;    
                        else                               
                            BUSY <= '0';                   
                            FCS_STATE <= 0;                
                        end if;                            
                    when 5 =>
                        if Serial_Data = CRC16_OUT(10) then
                            FCS_STATE <= FCS_STATE + 1;    
                        else                               
                            BUSY <= '0';                   
                            FCS_STATE <= 0;                
                        end if;                    
                    when 6 =>
                        if Serial_Data = CRC16_OUT(9) then
                            FCS_STATE <= FCS_STATE + 1;    
                        else                               
                            BUSY <= '0';                   
                            FCS_STATE <= 0;                
                        end if;                            
                    when 7 =>
                        if Serial_Data = CRC16_OUT(8) then
                            FCS_STATE <= FCS_STATE + 1;   
                        else                              
                            BUSY <= '0';                  
                            FCS_STATE <= 0;               
                        end if;                           
                    when 8 =>
                        if Serial_Data = CRC16_OUT(7) then
                            FCS_STATE <= FCS_STATE + 1;   
                        else                              
                            BUSY <= '0';                  
                            FCS_STATE <= 0;               
                        end if;                           
                    when 9 =>
                        if Serial_Data = CRC16_OUT(6) then
                            FCS_STATE <= FCS_STATE + 1;   
                        else                              
                            BUSY <= '0';                  
                            FCS_STATE <= 0;               
                        end if;                           
                    when 10 =>
                        if Serial_Data = CRC16_OUT(5) then 
                            FCS_STATE <= FCS_STATE + 1;    
                        else                               
                            BUSY <= '0';                   
                            FCS_STATE <= 0;                
                        end if;                            
                    when 11 =>
                        if Serial_Data = CRC16_OUT(4) then
                            FCS_STATE <= FCS_STATE + 1;   
                        else                              
                            BUSY <= '0';                  
                            FCS_STATE <= 0;               
                        end if;                           
                    when 12 =>
                        if Serial_Data = CRC16_OUT(3) then
                            FCS_STATE <= FCS_STATE + 1;   
                        else                              
                            BUSY <= '0';                  
                            FCS_STATE <= 0;               
                        end if;                           
                    when 13 =>
                        if Serial_Data = CRC16_OUT(2) then
                            FCS_STATE <= FCS_STATE + 1;   
                        else                              
                            BUSY <= '0';                  
                            FCS_STATE <= 0;               
                        end if;                           
                    when 14 =>
                        if Serial_Data = CRC16_OUT(1) then
                            FCS_STATE <= FCS_STATE + 1;   
                        else                              
                            BUSY <= '0';                  
                            FCS_STATE <= 0;               
                        end if;                           
                    when 15 =>
                        if Serial_Data = CRC16_OUT(0) then
                            FCS_STATE <= 0;
                            LOAD <= '1';
                        else                              
                            BUSY <= '0';                  
                            FCS_STATE <= 0;               
                        end if;                           
                end case;
             
             when 1 =>
             if Serial_Data = '1' then                      
               Bit_Stuffing_State <= Bit_Stuffing_State + 1;
             else                                           
               Bit_Stuffing_State <= 0;                     
             end if;                                        
             case(FCS_STATE) is
                 when 0 =>
                     if Serial_Data = CRC16_OUT(15) then
                         FCS_STATE <= FCS_STATE + 1;
                     else
                         BUSY <= '0';
                         FCS_STATE <= 0;
                     end if;
                 when 1 =>
                     if Serial_Data = CRC16_OUT(14) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 2 =>
                     if Serial_Data = CRC16_OUT(13) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 3 =>
                     if Serial_Data = CRC16_OUT(12) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 4 =>
                     if Serial_Data = CRC16_OUT(11) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 5 =>
                     if Serial_Data = CRC16_OUT(10) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                    
                 when 6 =>
                     if Serial_Data = CRC16_OUT(9) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 7 =>
                     if Serial_Data = CRC16_OUT(8) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 8 =>
                     if Serial_Data = CRC16_OUT(7) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 9 =>
                     if Serial_Data = CRC16_OUT(6) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 10 =>
                     if Serial_Data = CRC16_OUT(5) then 
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 11 =>
                     if Serial_Data = CRC16_OUT(4) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 12 =>
                     if Serial_Data = CRC16_OUT(3) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 13 =>
                     if Serial_Data = CRC16_OUT(2) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 14 =>
                     if Serial_Data = CRC16_OUT(1) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 15 =>
                     if Serial_Data = CRC16_OUT(0) then
                         FCS_STATE <= 0;
                         LOAD <= '1';      
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
             end case;

             when 2 =>
             if Serial_Data = '1' then                      
               Bit_Stuffing_State <= Bit_Stuffing_State + 1;
             else                                           
               Bit_Stuffing_State <= 0;                     
             end if;                                        
             case(FCS_STATE) is
                 when 0 =>
                     if Serial_Data = CRC16_OUT(15) then
                         FCS_STATE <= FCS_STATE + 1;
                     else
                         BUSY <= '0';
                         FCS_STATE <= 0;
                     end if;
                 when 1 =>
                     if Serial_Data = CRC16_OUT(14) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 2 =>
                     if Serial_Data = CRC16_OUT(13) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 3 =>
                     if Serial_Data = CRC16_OUT(12) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 4 =>
                     if Serial_Data = CRC16_OUT(11) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 5 =>
                     if Serial_Data = CRC16_OUT(10) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                    
                 when 6 =>
                     if Serial_Data = CRC16_OUT(9) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 7 =>
                     if Serial_Data = CRC16_OUT(8) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 8 =>
                     if Serial_Data = CRC16_OUT(7) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 9 =>
                     if Serial_Data = CRC16_OUT(6) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 10 =>
                     if Serial_Data = CRC16_OUT(5) then 
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 11 =>
                     if Serial_Data = CRC16_OUT(4) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 12 =>
                     if Serial_Data = CRC16_OUT(3) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 13 =>
                     if Serial_Data = CRC16_OUT(2) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 14 =>
                     if Serial_Data = CRC16_OUT(1) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 15 =>
                     if Serial_Data = CRC16_OUT(0) then
                         FCS_STATE <= 0;
                         LOAD <= '1';    
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
             end case;

             when 3 =>
             if Serial_Data = '1' then                      
               Bit_Stuffing_State <= Bit_Stuffing_State + 1;
             else                                           
               Bit_Stuffing_State <= 0;                     
             end if;                                        
             case(FCS_STATE) is
                 when 0 =>
                     if Serial_Data = CRC16_OUT(15) then
                         FCS_STATE <= FCS_STATE + 1;
                     else
                         BUSY <= '0';
                         FCS_STATE <= 0;
                     end if;
                 when 1 =>
                     if Serial_Data = CRC16_OUT(14) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 2 =>
                     if Serial_Data = CRC16_OUT(13) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 3 =>
                     if Serial_Data = CRC16_OUT(12) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 4 =>
                     if Serial_Data = CRC16_OUT(11) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 5 =>
                     if Serial_Data = CRC16_OUT(10) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                    
                 when 6 =>
                     if Serial_Data = CRC16_OUT(9) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 7 =>
                     if Serial_Data = CRC16_OUT(8) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 8 =>
                     if Serial_Data = CRC16_OUT(7) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 9 =>
                     if Serial_Data = CRC16_OUT(6) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 10 =>
                     if Serial_Data = CRC16_OUT(5) then 
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 11 =>
                     if Serial_Data = CRC16_OUT(4) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 12 =>
                     if Serial_Data = CRC16_OUT(3) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 13 =>
                     if Serial_Data = CRC16_OUT(2) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 14 =>
                     if Serial_Data = CRC16_OUT(1) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 15 =>
                     if Serial_Data = CRC16_OUT(0) then
                         FCS_STATE <= 0;
                         LOAD <= '1';    
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
             end case;

             when 4 =>
             if Serial_Data = '1' then                      
               Bit_Stuffing_State <= Bit_Stuffing_State + 1;
             else                                           
               Bit_Stuffing_State <= 0;                     
             end if;                                        
             case(FCS_STATE) is
                 when 0 =>
                     if Serial_Data = CRC16_OUT(15) then
                         FCS_STATE <= FCS_STATE + 1;
                     else
                         BUSY <= '0';
                         FCS_STATE <= 0;
                     end if;
                 when 1 =>
                     if Serial_Data = CRC16_OUT(14) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 2 =>
                     if Serial_Data = CRC16_OUT(13) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 3 =>
                     if Serial_Data = CRC16_OUT(12) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 4 =>
                     if Serial_Data = CRC16_OUT(11) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 5 =>
                     if Serial_Data = CRC16_OUT(10) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                    
                 when 6 =>
                     if Serial_Data = CRC16_OUT(9) then
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 7 =>
                     if Serial_Data = CRC16_OUT(8) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 8 =>
                     if Serial_Data = CRC16_OUT(7) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 9 =>
                     if Serial_Data = CRC16_OUT(6) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 10 =>
                     if Serial_Data = CRC16_OUT(5) then 
                         FCS_STATE <= FCS_STATE + 1;    
                     else                               
                         BUSY <= '0';                   
                         FCS_STATE <= 0;                
                     end if;                            
                 when 11 =>
                     if Serial_Data = CRC16_OUT(4) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 12 =>
                     if Serial_Data = CRC16_OUT(3) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 13 =>
                     if Serial_Data = CRC16_OUT(2) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
                 when 14 =>
                     if Serial_Data = CRC16_OUT(1) then
                         FCS_STATE <= FCS_STATE + 1;   
                     else                              
                         BUSY <= '0';                     
                         FCS_STATE <= 0;               
                     end if;                           
                 when 15 =>
                     if Serial_Data = CRC16_OUT(0) then
                         FCS_STATE <= 0;
                         LOAD <= '1';    
                     else                              
                         BUSY <= '0';                  
                         FCS_STATE <= 0;               
                     end if;                           
             end case;

             when 5 =>
                Bit_Stuffing_State <= 0;
             end case;
           
           when '1' =>
              if Packet_Counter = 0 then
              Packet_Counter <= Packet_Counter + 1;
              elsif(Packet_Counter < Packet_Length_as_bit - 1 and Packet_Counter > 0) then
                    Packet_Counter <= Packet_Counter + 1;
                    Data_Valid_Out <= '1';
                    Serial_Data_Out <= dout;
              elsif Packet_Counter = Packet_Length_as_bit - 1 then
                   Data_Valid_Out <= '1';
                   Packet_Counter <= Packet_Counter + 1;
                   Serial_Data_Out <= Last_Bit;
              else
                   we <= '0';
                   Serial_Data_Out <= '0';
                   Data_Valid_Out <= '0';
                   LOAD <= '0';
                   BUSY <= '0';
                   FOUND <= '0';
                   CRC_ENABLE <= '0';
                   Beginning_State <= 0;
                   FCS_State <= 0;
                   Bit_Stuffing_State <= 0;
                   Packet_Counter <= 0;
                   CRC16_IN <= x"FFFF";
              end if;
           
           when OTHERS => NULL;
           
           end case;
            
            when OTHERS => NULl;
        end case;
    end if;
end process;

process(CLK, ASYNC_RESET)
begin
if ASYNC_RESET = '1' then
Packet_Length <= (others => '1');
elsif rising_edge(CLK) then
    case(BUSY) is
        when '0' =>
            if ENABLE = '1' then
                case(FOUND) is
                    when '0' =>
                    NULL;
                    when '1' =>
                        case(Packet_Counter) is
                            when 48 => if Bit_Stuffing_State < 5 then Packet_Length(15) <= Serial_Data; end if;
                            when 49 => if Bit_Stuffing_State < 5 then Packet_Length(14) <= Serial_Data; end if;
                            when 50 => if Bit_Stuffing_State < 5 then Packet_Length(13) <= Serial_Data; end if;
                            when 51 => if Bit_Stuffing_State < 5 then Packet_Length(12) <= Serial_Data; end if;
                            when 52 => if Bit_Stuffing_State < 5 then Packet_Length(11) <= Serial_Data; end if;
                            when 53 => if Bit_Stuffing_State < 5 then Packet_Length(10) <= Serial_Data; end if;
                            when 54 => if Bit_Stuffing_State < 5 then Packet_Length(9) <= Serial_Data; end if;
                            when 55 => if Bit_Stuffing_State < 5 then Packet_Length(8) <= Serial_Data; end if;
                            when 56 => if Bit_Stuffing_State < 5 then Packet_Length(7) <= Serial_Data; end if;
                            when 57 => if Bit_Stuffing_State < 5 then Packet_Length(6) <= Serial_Data; end if;
                            when 58 => if Bit_Stuffing_State < 5 then Packet_Length(5) <= Serial_Data; end if;
                            when 59 => if Bit_Stuffing_State < 5 then Packet_Length(4) <= Serial_Data; end if;
                            when 60 => if Bit_Stuffing_State < 5 then Packet_Length(3) <= Serial_Data; end if;
                            when 61 => if Bit_Stuffing_State < 5 then Packet_Length(2) <= Serial_Data; end if;
                            when 62 => if Bit_Stuffing_State < 5 then Packet_Length(1) <= Serial_Data; end if;
                            when 63 => if Bit_Stuffing_State < 5 then Packet_Length(0) <= Serial_Data; end if;
                            when OTHERS => NULL;
                        end case;
                        
                    when OTHERS => NULL;
                end case;
            end if;
        when '1' =>
            NULL;
        when OTHERS => NULL;
    end case;
end if;
end process;

CRC_COMPUTE_001: process(ASYNC_RESET, CLK) 
begin
	if(ASYNC_RESET = '1') then
		CRC16_OUT <= x"FFFF";
	elsif rising_edge(CLK) then
		if(CRC_ENABLE = '1') then
			-- new incoming byte
			if Packet_Counter = 7 then
			     CRC16_OUT(0) <= DATA_IN_BYTE(4) xor Serial_Data xor CRC16_IN(8) xor CRC16_IN(12);
			     CRC16_OUT(1) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_IN(9) xor CRC16_IN(13);
			     CRC16_OUT(2) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_IN(10) xor CRC16_IN(14);
			     CRC16_OUT(3) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_IN(11) xor CRC16_IN(15);
			     CRC16_OUT(4) <= DATA_IN_BYTE(4) xor CRC16_IN(12);
			     CRC16_OUT(5) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(4) xor Serial_Data xor CRC16_IN(8) xor CRC16_IN(12) xor CRC16_IN(13);
			     CRC16_OUT(6) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_IN(9) xor CRC16_IN(13) xor CRC16_IN(14);
			     CRC16_OUT(7) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_IN(10) xor CRC16_IN(14) xor CRC16_IN(15);
			     CRC16_OUT(8) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_IN(0) xor CRC16_IN(11) xor CRC16_IN(15);
			     CRC16_OUT(9) <= DATA_IN_BYTE(4) xor CRC16_IN(1) xor CRC16_IN(12);
			     CRC16_OUT(10) <= DATA_IN_BYTE(5) xor CRC16_IN(2) xor CRC16_IN(13);
			     CRC16_OUT(11) <= DATA_IN_BYTE(6) xor CRC16_IN(3) xor CRC16_IN(14);
			     CRC16_OUT(12) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(4) xor Serial_Data xor CRC16_IN(4) xor CRC16_IN(8) xor CRC16_IN(12) xor 
			                 CRC16_IN(15);
			     CRC16_OUT(13) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_IN(5) xor CRC16_IN(9) xor CRC16_IN(13);
			     CRC16_OUT(14) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_IN(6) xor CRC16_IN(10) xor CRC16_IN(14);
			     CRC16_OUT(15) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_IN(7) xor CRC16_IN(11) xor CRC16_IN(15);
			elsif Packet_Counter > 7 then
			     CRC16_OUT(0) <= DATA_IN_BYTE(3) xor Serial_Data xor CRC16_IN(8) xor CRC16_IN(12);
                 CRC16_OUT(1) <= DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_IN(9) xor CRC16_IN(13);
                 CRC16_OUT(2) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_IN(10) xor CRC16_IN(14);
                 CRC16_OUT(3) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_IN(11) xor CRC16_IN(15);
                 CRC16_OUT(4) <= DATA_IN_BYTE(3) xor CRC16_IN(12);
                 CRC16_OUT(5) <= DATA_IN_BYTE(4) xor DATA_IN_BYTE(3) xor Serial_Data xor CRC16_IN(8) xor CRC16_IN(12) xor CRC16_IN(13);
                 CRC16_OUT(6) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_IN(9) xor CRC16_IN(13) xor CRC16_IN(14);
                 CRC16_OUT(7) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_IN(10) xor CRC16_IN(14) xor CRC16_IN(15);
                 CRC16_OUT(8) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_IN(0) xor CRC16_IN(11) xor CRC16_IN(15);
                 CRC16_OUT(9) <= DATA_IN_BYTE(3) xor CRC16_IN(1) xor CRC16_IN(12);
                 CRC16_OUT(10) <= DATA_IN_BYTE(4) xor CRC16_IN(2) xor CRC16_IN(13);
                 CRC16_OUT(11) <= DATA_IN_BYTE(5) xor CRC16_IN(3) xor CRC16_IN(14);
                 CRC16_OUT(12) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(3) xor Serial_Data xor CRC16_IN(4) xor CRC16_IN(8) xor CRC16_IN(12) xor 
                             CRC16_IN(15);
                 CRC16_OUT(13) <= DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_IN(5) xor CRC16_IN(9) xor CRC16_IN(13);
                 CRC16_OUT(14) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_IN(6) xor CRC16_IN(10) xor CRC16_IN(14);
                 CRC16_OUT(15) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_IN(7) xor CRC16_IN(11) xor CRC16_IN(15);
			--elsif Packet_Counter > 8 then
			--CRC16_OUT(0) <= DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_OUT(8) xor CRC16_OUT(12);
            --CRC16_OUT(1) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_OUT(9) xor CRC16_OUT(13);
            --CRC16_OUT(2) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_OUT(10) xor CRC16_OUT(14);
            --CRC16_OUT(3) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_OUT(11) xor CRC16_OUT(15);
            --CRC16_OUT(4) <= DATA_IN_BYTE(4) xor CRC16_OUT(12);
            --CRC16_OUT(5) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_OUT(8) xor CRC16_OUT(12) xor CRC16_OUT(13);
            --CRC16_OUT(6) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_OUT(9) xor CRC16_OUT(13) xor CRC16_OUT(14);
            --CRC16_OUT(7) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_OUT(10) xor CRC16_OUT(14) xor CRC16_OUT(15);
            --CRC16_OUT(8) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_OUT(0) xor CRC16_OUT(11) xor CRC16_OUT(15);
            --CRC16_OUT(9) <= DATA_IN_BYTE(4) xor CRC16_OUT(1) xor CRC16_OUT(12);
            --CRC16_OUT(10) <= DATA_IN_BYTE(5) xor CRC16_OUT(2) xor CRC16_OUT(13);
            --CRC16_OUT(11) <= DATA_IN_BYTE(6) xor CRC16_OUT(3) xor CRC16_OUT(14);
            --CRC16_OUT(12) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_OUT(4) xor CRC16_OUT(8) xor CRC16_OUT(12) xor 
            --            CRC16_OUT(15);
            --CRC16_OUT(13) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_OUT(5) xor CRC16_OUT(9) xor CRC16_OUT(13);
            --CRC16_OUT(14) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_OUT(6) xor CRC16_OUT(10) xor CRC16_OUT(14);
            --CRC16_OUT(15) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_OUT(7) xor CRC16_OUT(11) xor CRC16_OUT(15);
            --
            --else
            --null;
            end if;
		end if;
	end if;
end process;


end Behavioral;
