----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.07.2019 02:36:38
-- Design Name: 
-- Module Name: Top_Level - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top_Level is
  Port ( 
         clk                : in std_logic;
         Chip_Enable        : in std_logic;
         Serial_Data       : in std_logic;
         Sync_Word          : in std_logic_vector(31 downto 0);
         Byte_Length_of_Sync_Word     : in std_logic_vector(2 downto 0);
         Packet_Length : in std_logic_vector(15 downto 0);
         Temp_Lock : in std_logic;
         Temp_Data_Valid : in std_logic;
         
         Lock          : out std_logic;
         Data_Valid    : out std_logic;
         Spectrum_inversion : out std_logic;
         Reg_Byte_Length_of_Sync_Word : out std_logic_vector(2 downto 0);
         Reg_Sync_Word : out std_logic_vector(31 downto 0)
         
         
        );
end Top_Level;

architecture Behavioral of Top_Level is

begin

process(clk)
begin
if rising_edge(clk) then

end if;
end process;

end Behavioral;
