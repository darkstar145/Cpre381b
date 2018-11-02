library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity concat is
  port( i_A : in std_logic_vector(27 downto 0);
		i_B : in std_logic_vector(3 downto 0);
  	    o_F : out std_logic_vector(31 downto 0));
 end concat;

architecture mixed of concat is 

begin

o_F <= std_logic_vector(unsigned(i_B) & unsigned(i_A));

end mixed;