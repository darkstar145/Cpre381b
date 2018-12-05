library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux31_32bit is
  port( i_0, i_1, i_2 : in std_logic_vector(31 downto 0);
  		i_sel : in std_logic_vector(1 downto 0);
  	    o_mux : out std_logic_vector(31 downto 0));
 end mux31_32bit;

architecture mixed of mux31_32bit is 

begin

with i_sel select
	o_mux <= 	i_0 when "00",
			i_1 when "01",
			i_2 when others;

end mixed;