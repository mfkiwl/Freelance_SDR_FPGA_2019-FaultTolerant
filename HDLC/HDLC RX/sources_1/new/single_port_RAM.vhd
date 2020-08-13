 -- store and retrieve data from single port RAM

-- ports:
    -- we   : write enable
    -- addr : input port for getting address
    -- din : input data to be stored in RAM
    -- data : output data read from RAM
    -- addr_width : total number of elements to store (put exact number)
    -- addr_bits  : bits requires to store elements specified by addr_width
    -- data_width : number of bits in each elements

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_port_RAM is
  port(
    clk: in std_logic;
    we : in std_logic;
    addr : in std_logic_vector(14-1 downto 0);
    din : in std_logic;
    dout : out std_logic
    );
end single_port_RAM;

architecture arch of single_port_RAM is
 type ram_type is array (8240-1 downto 0) of std_logic;
 signal ram_single_port : ram_type;
begin
  process(clk)
  begin 
    if (clk'event and clk='1') then
      if (we='1') then -- write data to address 'addr'
        --convert 'addr' type to integer from std_logic_vector
        ram_single_port(to_integer(unsigned(addr))) <= din;
      end if;
  end if;
  end process;

  -- read data from address 'addr'
  -- convert 'addr' type to integer from std_logic_vector
  dout<=ram_single_port(to_integer(unsigned(addr)));
end arch;