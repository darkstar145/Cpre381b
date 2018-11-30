library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity branch is
	port (
		i_id_instruction : in std_logic_vector(31 downto 0);
		i_offset : in std_logic_vector(31 downto 0);
		i_rs_data, i_rt_data : in std_logic_vector(31 downto 0);
		o_branch_addr : in std_logic_vector(31 downto 0);
		o_branch : in std_logic
	);
end branch;

architecture bdf_type of branch is

	component branch_comparator
		port (
			i_rs_data, i_rt_data : in std_logic_vector(31 downto 0);
			o_equal : out std_logic -- '1' if A==B, '0' otherwise
		);
	end component;

	component adder_32
		port (
			i_A : in std_logic_vector(31 downto 0);
			i_B : in std_logic_vector(31 downto 0);
			o_F : out std_logic_vector(31 downto 0)
		);
	end component;

	signal id_instruction : std_logic_vector(31 downto 0);
	signal offset : std_logic_vector(31 downto 0);
	signal rs_data, rt_data : std_logic_vector(31 downto 0);
	signal branch_addr : std_logic_vector(31 downto 0);
	signal branch : std_logic;

begin
	b2v_branch_comparator : branch_comparator
	port map(
		i_rs_data => rs_data, 
		i_rt_data => rt_data, 
		o_equal => branch
	);

	b2v_branch_adder : adder_32
	port map(
		i_A => id_instruction, 
		i_B => offset, 
		o_F => branch_addr
	);

end bdf_type;
