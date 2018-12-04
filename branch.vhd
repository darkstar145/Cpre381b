library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity branch is
	port (
		i_id_instruction : in std_logic_vector(31 downto 0);
		--i_offset : in std_logic_vector(31 downto 0);
		i_id_pc_plus_4 : in std_logic_vector(31 downto 0);
		i_rs_data, i_rt_data : in std_logic_vector(31 downto 0);
		o_branch_addr : out std_logic_vector(31 downto 0);
		o_branch : out std_logic
	);
end branch;

architecture bdf_type of branch is

	component branch_comparator
		port (
			i_rs_data, i_rt_data : in std_logic_vector(31 downto 0);
			o_equal : out std_logic
		);
	end component;

	component adder_32
		port (
			i_A : in std_logic_vector(31 downto 0);
			i_B : in std_logic_vector(31 downto 0);
			o_F : out std_logic_vector(31 downto 0)
		);
	end component;
	
	COMPONENT sign_extender_16_32
		PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	--signal s_id_instruction : std_logic_vector(31 downto 0);
	signal s_id_instruction_ext : std_logic_vector(31 downto 0);
	--signal offset : std_logic_vector(31 downto 0);
	--signal s_rs_data, s_rt_data : std_logic_vector(31 downto 0);
	signal s_branch_addr : std_logic_vector(31 downto 0);
	signal s_branch : std_logic;

begin
	b2v_branch_comparator : branch_comparator
	port map(
		i_rs_data => i_rs_data, 
		i_rt_data => i_rt_data, 
		o_equal => s_branch
	);

		
	b2v_sign_extender : sign_extender_16_32
	PORT MAP(i_to_extend => i_id_instruction(15 DOWNTO 0),
			o_extended => s_id_instruction_ext);

	b2v_branch_adder : adder_32
	port map(
		i_A => i_id_pc_plus_4, 
		i_B => s_id_instruction_ext, 
		o_F => s_branch_addr
	);
	process (i_id_instruction, i_rs_data, i_rt_data, s_branch_addr, s_branch)
	begin
	o_branch <= s_branch;
	o_branch_addr <= s_branch_addr;
	end process;

end bdf_type;
