-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.0.0 Build 614 04/24/2018 SJ Standard Edition"
-- CREATED		"Fri Nov 02 14:59:01 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY mipssimulator IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		PC_RESET :  IN  STD_LOGIC;
		REG_RESET :  IN  STD_LOGIC;
		SET_TO_4 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END mipssimulator;

ARCHITECTURE bdf_type OF mipssimulator IS 

COMPONENT alu
	PORT(ALU_OP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_32bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT adder_32
	PORT(i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT concat
	PORT(i_A : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dmem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT and_2
	PORT(i_A : IN STD_LOGIC;
		 i_B : IN STD_LOGIC;
		 o_F : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT imem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sll_2
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sign_extender_16_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT main_control
	PORT(i_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_reg_dest : OUT STD_LOGIC;
		 o_jump : OUT STD_LOGIC;
		 o_branch : OUT STD_LOGIC;
		 o_mem_to_reg : OUT STD_LOGIC;
		 o_mem_write : OUT STD_LOGIC;
		 o_ALU_src : OUT STD_LOGIC;
		 o_reg_write : OUT STD_LOGIC;
		 o_ALU_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc_reg
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 i_next_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_5bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT register_file
	PORT(CLK : IN STD_LOGIC;
		 w_en : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 w_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 w_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rs_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT id_ex
	PORT
	(
		CLK		:	 IN STD_LOGIC;
		ex_flush		:	 IN STD_LOGIC;
		ex_stall		:	 IN STD_LOGIC;
		idex_reset		:	 IN STD_LOGIC;
		id_instruction		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		ex_instruction		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		id_pc_plus_4		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		ex_pc_plus_4		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		id_reg_dest		:	 IN STD_LOGIC;
		id_branch		:	 IN STD_LOGIC;
		id_mem_to_reg		:	 IN STD_LOGIC;
		id_ALU_op		:	 IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		id_mem_write		:	 IN STD_LOGIC;
		id_ALU_src		:	 IN STD_LOGIC;
		id_reg_write		:	 IN STD_LOGIC;
		ex_reg_dest		:	 OUT STD_LOGIC;
		ex_branch		:	 OUT STD_LOGIC;
		ex_mem_to_reg		:	 OUT STD_LOGIC;
		ex_ALU_op		:	 OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		ex_mem_write		:	 OUT STD_LOGIC;
		ex_ALU_src		:	 OUT STD_LOGIC;
		ex_reg_write		:	 OUT STD_LOGIC;
		id_rs_data		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		id_rt_data		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		ex_rs_data		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		ex_rt_data		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		id_rs_sel		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		id_rt_sel		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		id_rd_sel		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		ex_rs_sel		:	 OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		ex_rt_sel		:	 OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		ex_rd_sel		:	 OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		id_extended_immediate		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		ex_extended_immediate		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;


SIGNAL	alu_iA :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	alu_iB :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	alu_op :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	alu_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	alu_shamt :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	alu_src_sel :  STD_LOGIC;
SIGNAL	alu_zero :  STD_LOGIC;
SIGNAL	branch_addr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	branch_mux_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	branch_sel :  STD_LOGIC;
SIGNAL	dmem_byteena :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	dmem_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	dmem_wren :  STD_LOGIC;
SIGNAL	imem_byteena :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	imem_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	imeme_wren :  STD_LOGIC;
SIGNAL	imm_extended :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	imm_shifted :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	instr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	jump_i_selc :  STD_LOGIC;
SIGNAL	jumpaddr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	mem_to_reg :  STD_LOGIC;
SIGNAL	next_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_branch :  STD_LOGIC;
SIGNAL	o_reg_dest_out :  STD_LOGIC;
SIGNAL	o_shifted :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	pc4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	pc_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	reg_w_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	reg_w_sel :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	reg_wrt :  STD_LOGIC;
SIGNAL	rt_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN 



b2v_ALU : alu
PORT MAP(ALU_OP => alu_op,
		 i_A => alu_iA,
		 i_B => alu_iB,
		 shamt => alu_shamt,
		 zero => alu_zero,
		 ALU_out => alu_out);


b2v_alu_in_mux : mux21_32bit
PORT MAP(i_sel => alu_src_sel,
		 i_0 => rt_data,
		 i_1 => imm_extended,
		 o_mux => alu_iB);


b2v_branch_adder : adder_32
PORT MAP(i_A => pc4,
		 i_B => imm_shifted,
		 o_F => branch_addr);


b2v_branch_mux : mux21_32bit
PORT MAP(i_sel => branch_sel,
		 i_0 => pc4,
		 i_1 => branch_addr,
		 o_mux => branch_mux_out);


b2v_concat : concat
PORT MAP(i_A => o_shifted(27 DOWNTO 0),
		 i_B => pc4(31 DOWNTO 28),
		 o_F => jumpaddr);


b2v_dmem : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => CLK,
		 wren => dmem_wren,
		 address => alu_out(11 DOWNTO 2),
		 byteena => dmem_byteena,
		 data => rt_data,
		 q => dmem_out);


b2v_eq_and : and_2
PORT MAP(i_A => o_branch,
		 i_B => alu_zero,
		 o_F => branch_sel);


b2v_imem_reg : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => CLK,
		 wren => imeme_wren,
		 address => pc_out(11 DOWNTO 2),
		 byteena => imem_byteena,
		 data => imem_data,
		 q => instr);


b2v_imm_addr_shifter : sll_2
PORT MAP(i_to_shift => imm_extended,
		 o_shifted => imm_shifted);


b2v_imm_sign_extender : sign_extender_16_32
PORT MAP(i_to_extend => instr(15 DOWNTO 0),
		 o_extended => imm_extended);







b2v_jump_mux : mux21_32bit
PORT MAP(i_sel => jump_i_selc,
		 i_0 => branch_mux_out,
		 i_1 => jumpaddr,
		 o_mux => next_PC);


b2v_jump_shifter : sll_2
PORT MAP(i_to_shift => instr,
		 o_shifted => o_shifted);


b2v_main_control : main_control
PORT MAP(i_instruction => instr,
		 o_reg_dest => o_reg_dest_out,
		 o_jump => jump_i_selc,
		 o_branch => o_branch,
		 o_mem_to_reg => mem_to_reg,
		 o_mem_write => dmem_wren,
		 o_ALU_src => alu_src_sel,
		 o_reg_write => reg_wrt,
		 o_ALU_op => alu_op);


b2v_pc_adder : adder_32
PORT MAP(i_A => pc_out,
		 i_B => SET_TO_4,
		 o_F => pc4);


b2v_PC_reg : pc_reg
PORT MAP(CLK => CLK,
		 reset => PC_RESET,
		 i_next_PC => next_PC,
		 o_PC => pc_out);


b2v_reg_in_mux : mux21_5bit
PORT MAP(i_sel => o_reg_dest_out,
		 i_0 => instr(20 DOWNTO 16),
		 i_1 => instr(15 DOWNTO 11),
		 o_mux => reg_w_sel);


b2v_reg_w_data_mux : mux21_32bit
PORT MAP(i_sel => mem_to_reg,
		 i_0 => alu_out,
		 i_1 => dmem_out,
		 o_mux => reg_w_data);


b2v_register_file : register_file
PORT MAP(CLK => CLK,
		 w_en => reg_wrt,
		 reset => REG_RESET,
		 rs_sel => instr(25 DOWNTO 21),
		 rt_sel => instr(20 DOWNTO 16),
		 w_data => reg_w_data,
		 w_sel => reg_w_sel,
		 rs_data => alu_iA,
		 rt_data => rt_data);
		 
PORT MAP(CLK => CLK,
		ex_flush => ,			
		ex_stall => ,	
		idex_reset => reset,	
		id_instruction => instr,	
		ex_instruction => ,	
		id_pc_plus_4 => pc4,	
		ex_pc_plus_4 => ,	
		id_reg_dest	 => o_reg_dest_out,	
		id_branch => branch_sel,	
		id_mem_to_reg => mem_to_reg,	
		id_ALU_op => alu_op ,	
		id_mem_write => dmem_wren,	
		id_ALU_src => alu_src_sel,	
		id_reg_write => reg_wrt,	
		ex_reg_dest => ,	
		ex_branch => ,	
		ex_mem_to_reg => ,	
		ex_ALU_op => ,	
		ex_mem_write => ,	
		ex_ALU_src => ,	
		ex_reg_write => ,	
		id_rs_data => rs_data,		
		id_rt_data => rt_data,		
		ex_rs_data => ,		
		ex_rt_data => ,		
		id_rs_sel => rs_sel,		
		id_rt_sel => rt_sel,		
		id_rd_sel => w_data,		
		ex_rs_sel => ,		
		ex_rt_sel => ,		
		ex_rd_sel => ,		
		id_extended_immediate,
		ex_extended_immediate);


alu_shamt <= "00000";
dmem_byteena <= "1111";
imem_byteena <= "1111";
imem_data <= "00000000000000000000000000000000";
imeme_wren <= '0';
END bdf_type;