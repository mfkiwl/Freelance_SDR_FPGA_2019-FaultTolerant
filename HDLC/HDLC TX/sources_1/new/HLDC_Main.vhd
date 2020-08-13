library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HLDC_Main is
  Port (    
            ASYNC_RESET : in std_logic;
            CLK         : in std_logic;
            DATA_IN     : in std_logic;
            Start_Of_Frame : in std_logic;
            End_Of_Frame : in std_logic;
            Data_Valid_In : in std_logic;
            REQ         : in std_logic;
            
            READY       : out std_logic;
            Data_Valid_Out : out std_logic;
            BUSY_OUT        : out std_logic; 
            DATA_OUT    : out std_logic
        );
end HLDC_Main;

architecture Behavioral of HLDC_Main is

signal REQ_COUNTER : integer range 0 to 2 := 0;
signal DELAY_STATE : integer range 0 to 2 := 2;
signal BUSY : std_logic := '0';
signal ENABLE : std_logic := '0';

signal CRC_ENABLE_FLAG : integer range 0 to 1 := 0;
signal CRC_ENABLE_COUNTER : integer range 0 to 7 := 0;
signal CRC_ENABLE   : std_logic := '0';
signal CRC16_IN     : std_logic_vector(15 downto 0) := x"77F1";
signal CRC16_OUT    : std_logic_vector(15 downto 0) := x"FFFF";
signal DATA_IN_BYTE : std_logic_vector(7 downto 0);

--PACKET LENGTH PROCESS REGISTERS
signal PACKET_LENGTH : unsigned(15 downto 0) := (others => '1');
signal Packet_Length_as_bit : unsigned(31 downto 0) := (others => '1');
signal Packet_Bit_Counter : integer range 0 to 33 := 0;
signal Packet_Length_First_Byte : unsigned(7 downto 0);
signal Packet_Length_Second_Byte : unsigned(7 downto 0);
signal Packet_Length_First_Byte_Counter : integer range 0 to 7 := 7;
signal Packet_Length_Second_Byte_Counter : integer range 0 to 7 := 7;

--FCS PROCESS REGISTERS
signal FCS_STATE : integer range 0 to 1 := 0;
signal FCS_COUNTER : unsigned(31 downto 0) := (others => '0');
signal FCS         : std_logic_vector(15 downto 0);

--BÝT STUFFÝNG REGÝSTERS
signal Bit_Stuffing_State : integer range 0 to 5 := 0;
signal Bit_Stuffing_Counter : integer range 0 to 9031 := 0;

--PACKET TO-BE-SENT REGISTERS
signal Packet_Counter : integer range 0 to 9031 := 0;
signal Last_Counter : integer range 0 to 15 := 0;

signal we : std_logic := '0';
signal addr : std_logic_vector(14-1 downto 0);
signal dp_addr : std_logic_vector(14-1 downto 0);
signal din : std_logic;
signal dp_dout : std_logic;
signal dout : std_logic;

component Dual_Port_RAM is
 port(
   clk: in std_logic;
   we : in std_logic;
   addr : in std_logic_vector(14-1 downto 0);
   dp_addr : in std_logic_vector(14-1 downto 0);
   din : in std_logic;
   dp_dout : out std_logic;
   dout : out std_logic
   );
end component Dual_Port_RAM;

begin

BUSY_OUT <= BUSY;
READY <= BUSY;

addr <= std_logic_vector(to_unsigned(8208 - Packet_Counter, addr'length));
dp_addr <= std_logic_vector(to_unsigned(8247 - Bit_Stuffing_Counter, dp_addr'length));

process(CLK,ASYNC_RESET)
begin
if ASYNC_RESET = '1' then
    ENABLE <= '0';
elsif rising_edge(CLK) then
    if Start_Of_Frame = '1' then
        ENABLE <= '1';
    elsif End_Of_Frame = '1' then
        ENABLE <= '0';
    end if;
end if;
end process;

PACKET_LENGTH_PROCESS : process(CLK,ASYNC_RESET)
begin
if ASYNC_RESET = '1' then
    Packet_Bit_Counter <= 0;
    PACKET_LENGTH <= (others => '1');
elsif rising_edge(CLK) then
    if BUSY = '0' then
        if ENABLE = '1' or Start_Of_Frame = '1' or End_Of_Frame = '1' then
            if Data_Valid_In = '1' then
            Packet_Bit_Counter <= Packet_Bit_Counter + 1;
                if(Packet_Bit_Counter > 15 and Packet_Bit_Counter < 24) then
                    Packet_Length_First_Byte(Packet_Length_First_Byte_Counter) <= DATA_IN;
                    Packet_Length_First_Byte_Counter <= Packet_Length_First_Byte_Counter - 1;
                elsif(Packet_Bit_Counter > 23 and Packet_Bit_Counter < 32) then
                    Packet_Length_Second_Byte(Packet_Length_Second_Byte_Counter) <= DATA_IN;
                    Packet_Length_Second_Byte_Counter <= Packet_Length_Second_Byte_Counter - 1;
                elsif(Packet_Bit_Counter = 32) then
                    PACKET_LENGTH <= Packet_Length_First_Byte & Packet_Length_Second_Byte;
                elsif(Packet_Bit_Counter = 33) then
                    Packet_Length_as_Bit <= 8 * PACKET_LENGTH;
                    Packet_Length_First_Byte_Counter <= 7;
                    Packet_Length_Second_Byte_Counter <= 7;
                end if;
            end if;
        else
        Packet_Length_First_Byte_Counter <= 7;
        Packet_Length_Second_Byte_Counter <= 7;
        Packet_Bit_Counter <= 0;
        end if;
    else
    null;
    end if;
end if;
end process;

FCS_PROCESS : process(CLK,ASYNC_RESET)
begin
if ASYNC_RESET = '1' then
CRC_ENABLE <= '0';
FCS_STATE <= 0;
CRC16_IN <= x"77F1";
FCS_COUNTER <= (others => '0');
CRC_ENABLE_COUNTER <= 0;
CRC_ENABLE_FLAG <= 0;
elsif rising_edge(CLK) then
    if BUSY = '0' then
        if ENABLE = '1' or Start_Of_Frame = '1' or End_Of_Frame = '1' then
        
            if Data_Valid_In = '1' then
              case(FCS_STATE) is
              
              when 0 =>
                DATA_IN_BYTE <= "1001100" & DATA_IN;
                CRC_ENABLE <= '0';
                CRC16_IN <= x"77F1";
                FCS_COUNTER <= FCS_COUNTER + 1;
                FCS_STATE <= FCS_STATE + 1;
                CRC_ENABLE_COUNTER <= 1;
                CRC_ENABLE_FLAG <= 0;
              
              when 1 =>
              if(FCS_COUNTER < Packet_Length_as_Bit - 1) then
                FCS_COUNTER <= FCS_COUNTER + 1;
                DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & DATA_IN;
                if(CRC_ENABLE_COUNTER < 7) then
                    CRC_ENABLE_COUNTER <= CRC_ENABLE_COUNTER + 1;
                    CRC_ENABLE <= '0';
                    if CRC_ENABLE_FLAG = 1 then
                    CRC16_IN <= CRC16_OUT;
                    else
                    CRC16_IN <= x"77F1";
                    end if;
                else
                CRC_ENABLE_FLAG <= 1;
                CRC_ENABLE <= '1';
                CRC_ENABLE_COUNTER <= 0;
                end if;
                
              elsif FCS_Counter = Packet_Length_as_Bit - 1 then
              DATA_IN_BYTE(7 downto 0) <= DATA_IN_BYTE(6 downto 0) & DATA_IN;
                FCS <= CRC16_OUT;
                CRC_ENABLE <= '1';
                FCS_COUNTER <= FCS_COUNTER + 1;
              else
                FCS_COUNTER <= (others => '0');
                CRC_ENABLE <= '0';
                CRC16_IN <= x"77F1";
              end if;
              end case;
            else
                CRC_ENABLE <= '0';
            end if;  
        else
            FCS_STATE <= 0;
        end if;
      else
      FCS_STATE <= 0;
      CRC_ENABLE <= '0';               
      CRC16_IN <= x"77F1";
      FCS_COUNTER <= (others => '0');
      CRC_ENABLE_COUNTER <= 0;
      CRC_ENABLE_FLAG <= 0;
    end if;
end if;
end process;

SENDING : process(CLK,ASYNC_RESET)
begin
if ASYNC_RESET = '1' then
    Bit_Stuffing_Counter <= 0;
    Bit_Stuffing_State <= 0;
    DATA_OUT <= '0';
    Data_Valid_Out <= '0';
    Last_Counter <= 0;
    DELAY_STATE <= 2;
elsif rising_edge(CLK) then
    case(BUSY) is
        when '0' =>
                    DATA_OUT <= '0';
                    Bit_Stuffing_State <= 0;
                    Bit_Stuffing_Counter <= 0;
                    Data_Valid_Out <= '0';
                    DELAY_STATE <= 2;
                    REQ_COUNTER <= 0;
            
        when '1' =>
        if REQ = '1' then--------------------------------------------------------------------------------------------
            case(DELAY_STATE) is
            when 0 =>
            if REQ_COUNTER = 2 then
                DELAY_STATE <= 0;
            elsif REQ_COUNTER = 1 then
                DELAY_STATE <= 1;
            end if;
            if Bit_Stuffing_Counter < Packet_Length_as_Bit + 40 then
                if Bit_Stuffing_Counter < 16 then
                  Data_Valid_Out <= '1';
                  DATA_OUT <= dp_dout;
                  Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                else
                  Data_Valid_Out <= '1';
                  Last_Counter <= 0;
                  case(Bit_Stuffing_State) is
                  when 0 =>
                    Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                      if dp_dout = '1' then                            
                          DATA_OUT <= dp_dout;                         
                          Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                      else                                             
                          DATA_OUT <= dp_dout;                         
                          Bit_Stuffing_State <= 0;                     
                      end if;                                          
                      
                  when 1 =>
                    Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                      if dp_dout = '1' then                            
                          DATA_OUT <= dp_dout;                         
                          Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                      else                                             
                          DATA_OUT <= dp_dout;                         
                          Bit_Stuffing_State <= 0;                     
                      end if;                                          
             
                  when 2 =>
                    Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                      if dp_dout = '1' then                            
                          DATA_OUT <= dp_dout;                         
                          Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                      else                                             
                          DATA_OUT <= dp_dout;                         
                          Bit_Stuffing_State <= 0;                     
                      end if;                                          
             
                  when 3 =>
                    Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                      if dp_dout = '1' then                            
                          DATA_OUT <= dp_dout;                         
                          Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                      else                                             
                          DATA_OUT <= dp_dout;                         
                          Bit_Stuffing_State <= 0;                     
                      end if;                                          
                      
                  when 4 =>
                    Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                      if dp_dout = '1' then                            
                          DATA_OUT <= dp_dout;                         
                          Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                      else                                             
                          DATA_OUT <= dp_dout;                         
                          Bit_Stuffing_State <= 0;                     
                      end if;                                          
                  
                  when 5 =>
                    DATA_OUT <= '0';
                    Bit_Stuffing_State <= 0;
                      
                  end case;
              end if;
            elsif Bit_Stuffing_Counter < Packet_Length_as_Bit + 56 then
              Data_Valid_Out <= '1';
              case(Bit_Stuffing_State) is
              
              when 0 =>
                Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                Last_Counter <= Last_Counter + 1;
                  if CRC16_OUT(15 - Last_Counter) = '1' then                            
                      DATA_OUT <= CRC16_OUT(15 - Last_Counter);                         
                      Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                  else                                             
                      DATA_OUT <= CRC16_OUT(15 - Last_Counter);                         
                      Bit_Stuffing_State <= 0;                     
                  end if;                                          
                  
              when 1 =>
                Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                Last_Counter <= Last_Counter + 1;
                  if CRC16_OUT(15 - Last_Counter) = '1' then       
                      DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                      Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                  else                                             
                      DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                      Bit_Stuffing_State <= 0;                     
                  end if;                                          
     
              when 2 =>
                Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                Last_Counter <= Last_Counter + 1;
                  if CRC16_OUT(15 - Last_Counter) = '1' then       
                      DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                      Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                  else                                             
                      DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                      Bit_Stuffing_State <= 0;                     
                  end if;                                          
     
              when 3 =>
                Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                Last_Counter <= Last_Counter + 1;
                  if CRC16_OUT(15 - Last_Counter) = '1' then       
                      DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                      Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                  else                                             
                      DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                      Bit_Stuffing_State <= 0;                     
                  end if;                                          
                  
              when 4 =>
                Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                Last_Counter <= Last_Counter + 1;
                  if CRC16_OUT(15 - Last_Counter) = '1' then       
                      DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                      Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                  else                                             
                      DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                      Bit_Stuffing_State <= 0;                     
                  end if;                                          
              
              when 5 =>
                DATA_OUT <= '0';
                Bit_Stuffing_State <= 0;
                  
              end case;
            else
                  Data_Valid_Out <= '0';
                  DATA_OUT <= '0';
                  Bit_Stuffing_State <= 0;
                  Bit_Stuffing_Counter <= 0;
            end if;
            
            when 1 =>
                DELAY_STATE <= DELAY_STATE - 1;
                REQ_COUNTER <= REQ_COUNTER + 1;
                DATA_OUT <= '0';
                Data_Valid_Out <= '0';
                
            when 2 =>
                REQ_COUNTER <= 1;
                DELAY_STATE <= DELAY_STATE - 1;
                DATA_OUT <= '0';
                Data_Valid_Out <= '0';

        end case;
        
        else
        
        case(DELAY_STATE) is
        when 0 =>
        if REQ_COUNTER = 1 then
            DELAY_STATE <= 2;
            REQ_COUNTER <= 0;
        elsif REQ_COUNTER = 2 then
            DELAY_STATE <= 0;
            REQ_COUNTER <= 1;
        end if;
        if Bit_Stuffing_Counter < Packet_Length_as_Bit + 40 then
            if Bit_Stuffing_Counter < 16 then
              Data_Valid_Out <= '1';
              DATA_OUT <= dp_dout;
              Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
            else
              Data_Valid_Out <= '1';
              Last_Counter <= 0;
              case(Bit_Stuffing_State) is
              when 0 =>
                Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                  if dp_dout = '1' then                            
                      DATA_OUT <= dp_dout;                         
                      Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                  else                                             
                      DATA_OUT <= dp_dout;                         
                      Bit_Stuffing_State <= 0;                     
                  end if;                                          
                  
              when 1 =>
                Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                  if dp_dout = '1' then                            
                      DATA_OUT <= dp_dout;                         
                      Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                  else                                             
                      DATA_OUT <= dp_dout;                         
                      Bit_Stuffing_State <= 0;                     
                  end if;                                          
         
              when 2 =>
                Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                  if dp_dout = '1' then                            
                      DATA_OUT <= dp_dout;                         
                      Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                  else                                             
                      DATA_OUT <= dp_dout;                         
                      Bit_Stuffing_State <= 0;                     
                  end if;                                          
         
              when 3 =>
                Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                  if dp_dout = '1' then                            
                      DATA_OUT <= dp_dout;                         
                      Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                  else                                             
                      DATA_OUT <= dp_dout;                         
                      Bit_Stuffing_State <= 0;                     
                  end if;                                          
                  
              when 4 =>
                Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
                  if dp_dout = '1' then                            
                      DATA_OUT <= dp_dout;                         
                      Bit_Stuffing_State <= Bit_Stuffing_State + 1;
                  else                                             
                      DATA_OUT <= dp_dout;                         
                      Bit_Stuffing_State <= 0;                     
                  end if;                                          
              
              when 5 =>
                DATA_OUT <= '0';
                Bit_Stuffing_State <= 0;
                  
              end case;
          end if;
        elsif Bit_Stuffing_Counter < Packet_Length_as_Bit + 56 then
          Data_Valid_Out <= '1';
          case(Bit_Stuffing_State) is
          
          when 0 =>
            Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
            Last_Counter <= Last_Counter + 1;
              if CRC16_OUT(15 - Last_Counter) = '1' then                            
                  DATA_OUT <= CRC16_OUT(15 - Last_Counter);                         
                  Bit_Stuffing_State <= Bit_Stuffing_State + 1;
              else                                             
                  DATA_OUT <= CRC16_OUT(15 - Last_Counter);                         
                  Bit_Stuffing_State <= 0;                     
              end if;                                          
              
          when 1 =>
            Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
            Last_Counter <= Last_Counter + 1;
              if CRC16_OUT(15 - Last_Counter) = '1' then       
                  DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                  Bit_Stuffing_State <= Bit_Stuffing_State + 1;
              else                                             
                  DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                  Bit_Stuffing_State <= 0;                     
              end if;                                          
 
          when 2 =>
            Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
            Last_Counter <= Last_Counter + 1;
              if CRC16_OUT(15 - Last_Counter) = '1' then       
                  DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                  Bit_Stuffing_State <= Bit_Stuffing_State + 1;
              else                                             
                  DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                  Bit_Stuffing_State <= 0;                     
              end if;                                          
 
          when 3 =>
            Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
            Last_Counter <= Last_Counter + 1;
              if CRC16_OUT(15 - Last_Counter) = '1' then       
                  DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                  Bit_Stuffing_State <= Bit_Stuffing_State + 1;
              else                                             
                  DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                  Bit_Stuffing_State <= 0;                     
              end if;                                          
              
          when 4 =>
            Bit_Stuffing_Counter <= Bit_Stuffing_Counter + 1;
            Last_Counter <= Last_Counter + 1;
              if CRC16_OUT(15 - Last_Counter) = '1' then       
                  DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                  Bit_Stuffing_State <= Bit_Stuffing_State + 1;
              else                                             
                  DATA_OUT <= CRC16_OUT(15 - Last_Counter);    
                  Bit_Stuffing_State <= 0;                     
              end if;                                          
          
          when 5 =>
            DATA_OUT <= '0';
            Bit_Stuffing_State <= 0;
              
          end case;
        else
              Data_Valid_Out <= '0';
              DATA_OUT <= '0';
              Bit_Stuffing_State <= 0;
              Bit_Stuffing_Counter <= 0;
        end if;
        
        when 1 =>
            DELAY_STATE <= DELAY_STATE - 1;
            DATA_OUT <= '0';
            Data_Valid_Out <= '0';
            
        when 2 =>
            REQ_COUNTER <= 0;
            DATA_OUT <= '0';
            Data_Valid_Out <= '0';

    end case;

        end if;
    when OTHERS => NULL;
    end case;
end if;
end process;

LOADING : process(CLK, ASYNC_RESET)
begin
if ASYNC_RESET = '1' then
    BUSY <= '0';
    we <= '0';
    Packet_Counter <= 0;
elsif rising_edge(CLK) then
    if ENABLE = '1' or Start_Of_Frame = '1' or End_Of_Frame = '1' then
      if Data_Valid_In = '1' then
        if Packet_Length_as_Bit < 8193 or Packet_Length_as_Bit = x"FFFFFFFF" then
          if Packet_Counter < Packet_Length_as_Bit - 1 then
            Packet_Counter <= Packet_Counter + 1;
            we <= '1';
            din <= DATA_IN;
            BUSY <= '0';
          else
            we <= '1';
            din <= DATA_IN;
            Packet_Counter <= Packet_Counter + 1;
            BUSY <= '1';
          end if;
        else
        null;
        end if;
      else
        we <= '0';
      end if;
    else
        we <= '0';
        if Bit_Stuffing_Counter < Packet_Length_as_Bit + 56 then
            Packet_Counter <= 0;
        else
            BUSY <= '0';
        end if;
    end if;
end if;
end process;

CRC_COMPUTE_001: process(ASYNC_RESET, CLK) 
begin
	if(ASYNC_RESET = '1') then
		CRC16_OUT <= x"FFFF";
	elsif rising_edge(CLK) then
		if(CRC_ENABLE = '1') then
			-- new incoming byte
			if FCS_Counter >= 1 then
			     CRC16_OUT(0) <= DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_IN(8) xor CRC16_IN(12);
			     CRC16_OUT(1) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_IN(9) xor CRC16_IN(13);
			     CRC16_OUT(2) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_IN(10) xor CRC16_IN(14);
			     CRC16_OUT(3) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_IN(11) xor CRC16_IN(15);
			     CRC16_OUT(4) <= DATA_IN_BYTE(4) xor CRC16_IN(12);
			     CRC16_OUT(5) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_IN(8) xor CRC16_IN(12) xor CRC16_IN(13);
			     CRC16_OUT(6) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_IN(9) xor CRC16_IN(13) xor CRC16_IN(14);
			     CRC16_OUT(7) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_IN(10) xor CRC16_IN(14) xor CRC16_IN(15);
			     CRC16_OUT(8) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_IN(0) xor CRC16_IN(11) xor CRC16_IN(15);
			     CRC16_OUT(9) <= DATA_IN_BYTE(4) xor CRC16_IN(1) xor CRC16_IN(12);
			     CRC16_OUT(10) <= DATA_IN_BYTE(5) xor CRC16_IN(2) xor CRC16_IN(13);
			     CRC16_OUT(11) <= DATA_IN_BYTE(6) xor CRC16_IN(3) xor CRC16_IN(14);
			     CRC16_OUT(12) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_IN(4) xor CRC16_IN(8) xor CRC16_IN(12) xor 
			                 CRC16_IN(15);
			     CRC16_OUT(13) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_IN(5) xor CRC16_IN(9) xor CRC16_IN(13);
			     CRC16_OUT(14) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_IN(6) xor CRC16_IN(10) xor CRC16_IN(14);
			     CRC16_OUT(15) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_IN(7) xor CRC16_IN(11) xor CRC16_IN(15);
			--elsif FCS_Counter > 1 then
			--     CRC16_OUT(0) <= DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_OUT(8) xor CRC16_OUT(12);
            --     CRC16_OUT(1) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_OUT(9) xor CRC16_OUT(13);
            --     CRC16_OUT(2) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_OUT(10) xor CRC16_OUT(14);
            --     CRC16_OUT(3) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_OUT(11) xor CRC16_OUT(15);
            --     CRC16_OUT(4) <= DATA_IN_BYTE(4) xor CRC16_OUT(12);
            --     CRC16_OUT(5) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_OUT(8) xor CRC16_OUT(12) xor CRC16_OUT(13);
            --     CRC16_OUT(6) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_OUT(9) xor CRC16_OUT(13) xor CRC16_OUT(14);
            --     CRC16_OUT(7) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_OUT(10) xor CRC16_OUT(14) xor CRC16_OUT(15);
            --     CRC16_OUT(8) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_OUT(0) xor CRC16_OUT(11) xor CRC16_OUT(15);
            --     CRC16_OUT(9) <= DATA_IN_BYTE(4) xor CRC16_OUT(1) xor CRC16_OUT(12);
            --     CRC16_OUT(10) <= DATA_IN_BYTE(5) xor CRC16_OUT(2) xor CRC16_OUT(13);
            --     CRC16_OUT(11) <= DATA_IN_BYTE(6) xor CRC16_OUT(3) xor CRC16_OUT(14);
            --     CRC16_OUT(12) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(4) xor DATA_IN_BYTE(0) xor CRC16_OUT(4) xor CRC16_OUT(8) xor CRC16_OUT(12) xor 
            --                 CRC16_OUT(15);
            --     CRC16_OUT(13) <= DATA_IN_BYTE(5) xor DATA_IN_BYTE(1) xor CRC16_OUT(5) xor CRC16_OUT(9) xor CRC16_OUT(13);
            --     CRC16_OUT(14) <= DATA_IN_BYTE(6) xor DATA_IN_BYTE(2) xor CRC16_OUT(6) xor CRC16_OUT(10) xor CRC16_OUT(14);
            --     CRC16_OUT(15) <= DATA_IN_BYTE(7) xor DATA_IN_BYTE(3) xor CRC16_OUT(7) xor CRC16_OUT(11) xor CRC16_OUT(15);
            end if;
		end if;
	end if;
end process;

Dual_Port_RAM_INST : Dual_Port_RAM
port map(
    clk => clk,
    we => we,
    din => din,
    dout => dout,
    addr => addr,
    dp_addr => dp_addr,
    dp_dout => dp_dout
);

end Behavioral;