LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY branch IS
	PORT (
		i_id_instruction : IN std_logic_vector(31 DOWNTO 0);
		--i_offset : in std_logic_vector(31 downto 0);
		i_branch : IN std_logic;
		i_id_pc_plus_4 : IN std_logic_vector(31 DOWNTO 0);
		i_rs_data, i_rt_data : IN std_logic_vector(31 DOWNTO 0);
		o_branch_addr : OUT std_logic_vector(31 DOWNTO 0);
		o_branch : OUT std_logic
	);
END branch;

ARCHITECTURE bdf_type OF branch IS

	COMPONENT branch_comparator
		PORT (
			i_rs_data, i_rt_data : IN std_logic_vector(31 DOWNTO 0);
			o_equal : OUT std_logic
		);
	END COMPONENT;

	COMPONENT adder_32
		PORT (
			i_A : IN std_logic_vector(31 DOWNTO 0);
			i_B : IN std_logic_vector(31 DOWNTO 0);
			o_F : OUT std_logic_vector(31 DOWNTO 0)
		);
	END COMPONENT;
 
	COMPONENT sign_extender_16_32
		PORT (
			i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT sll_2
		PORT (
			i_to_shift : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	--signal s_id_instruction : std_logic_vector(31 downto 0);
	SIGNAL s_id_instruction_ext, s_id_imm_shifted : std_logic_vector(31 DOWNTO 0);
	--signal offset : std_logic_vector(31 downto 0);
	--signal s_rs_data, s_rt_data : std_logic_vector(31 downto 0);
	SIGNAL s_branch_addr : std_logic_vector(31 DOWNTO 0);
	SIGNAL s_branch : std_logic;

BEGIN
	b2v_branch_comparator : branch_comparator
	PORT MAP(
		i_rs_data => i_rs_data, 
		i_rt_data => i_rt_data, 
		o_equal => s_branch
	);

 
	b2v_imm_addr_shifter : sll_2
	PORT MAP(
		i_to_shift => i_id_instruction, 
		o_shifted => s_id_imm_shifted
	);
	b2v_sign_extender : sign_extender_16_32
	PORT MAP(
		i_to_extend => s_id_imm_shifted(15 DOWNTO 0), 
		o_extended => s_id_instruction_ext
	);
	b2v_branch_adder : adder_32
	PORT MAP(
		i_A => i_id_pc_plus_4, 
		i_B => s_id_instruction_ext, 
		o_F => s_branch_addr
	);
	PROCESS (i_id_instruction, i_rs_data, i_rt_data, s_branch_addr, s_branch)
	BEGIN
		o_branch <= s_branch AND i_branch;
		o_branch_addr <= s_branch_addr;
	END PROCESS;

END bdf_type;
