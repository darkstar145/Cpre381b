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
		RESET :  IN  STD_LOGIC
--		RESET :  IN  STD_LOGIC;
--		SET_TO_4 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0)
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

COMPONENT if_id
	PORT (CLK : IN STD_LOGIC;
		id_flush, id_stall, ifid_reset : in std_logic;
		if_instruction  : in std_logic_vector(31 DOWNTO 0);
		id_instruction  : OUT STD_logic_vector(31 DOWNTO 0);
		if_pc_plus_4 : in std_logic_vector(31 DOWNTO 0);
		id_pc_plus_4 : OUT STD_logic_vector(31 DOWNTO 0));
END COMPONENT;

COMPONENT ex_mem
	PORT (CLK           : in  std_logic;
		mem_flush, mem_stall, exmem_reset : in std_logic;
		ex_instruction  : in std_logic_vector(31 downto 0); -- pass instruction along (useful for debugging)
        mem_instruction  : OUT STD_logic_vector(31 downto 0);
        ex_pc_plus_4 : in std_logic_vector(31 downto 0);
       	mem_pc_plus_4 : OUT STD_logic_vector(31 downto 0);

  	-- CONTROL signals
        ex_reg_dest   : in std_logic;
  	    ex_mem_to_reg : in std_logic;
  	    ex_mem_write  : in std_logic;
  	    ex_reg_write  : in std_logic;
  	    mem_reg_dest   : OUT STD_logic;
  	    mem_mem_to_reg : OUT STD_logic;
  	    mem_mem_write  : OUT STD_logic;
  	    mem_reg_write  : OUT STD_logic;
  	-- END CONTROL signals

  	-- ALU signals
		ex_ALU_out : in std_logic_vector(31 downto 0);
		mem_ALU_out : OUT STD_logic_vector(31 downto 0);
  	-- END ALU signals

	-- Register signals
		ex_rt_data : in std_logic_vector(31 downto 0);
		mem_rt_data : OUT STD_logic_vector(31 downto 0);
  		ex_write_reg_sel : in std_logic_vector(4 downto 0); -- see the Reg. Dest. mux in the pipeline architecture diagram
  		mem_write_reg_sel : OUT STD_logic_vector(4 downto 0)-- END Register signals
  	    );
END COMPONENT;

COMPONENT mem_wb
	PORT (CLK           : in  std_logic;
		wb_flush, wb_stall, memwb_reset : in std_logic;
		mem_instruction  : in std_logic_vector(31 downto 0); -- pass instruction along (useful for debugging)
        wb_instruction  : OUT STD_logic_vector(31 downto 0);
        mem_pc_plus_4 : in std_logic_vector(31 downto 0);
       	wb_pc_plus_4 : OUT STD_logic_vector(31 downto 0);

  	-- CONTROL signals
        mem_reg_dest   : in std_logic;
  	    mem_mem_to_reg : in std_logic;
  	    mem_reg_write  : in std_logic;
  	    wb_reg_dest   : OUT STD_logic;
  	    wb_mem_to_reg : OUT STD_logic;
  	    wb_reg_write  : OUT STD_logic;
  	-- END CONTROL signals

  	-- ALU signals
		mem_ALU_out : in std_logic_vector(31 downto 0);
		wb_ALU_out : OUT STD_logic_vector(31 downto 0);
  	-- END ALU signals

  	-- Memory signals
		mem_dmem_out : in std_logic_vector(31 downto 0);
		wb_dmem_out : OUT STD_logic_vector(31 downto 0);
  	-- END Memory signals

	-- Register signals
  		mem_write_reg_sel : in std_logic_vector(4 downto 0);
  		wb_write_reg_sel : OUT STD_logic_vector(4 downto 0)
  	-- END Register signals
  	    );
END COMPONENT;


COMPONENT branch
	PORT (
		i_id_instruction : IN std_logic_vector(31 DOWNTO 0);
		i_id_pc_plus_4 : IN std_logic_vector(31 DOWNTO 0);
		i_branch : IN std_logic;
		--i_offset : IN std_logic_vector(31 DOWNTO 0);
		i_rs_data, i_rt_data : IN std_logic_vector(31 DOWNTO 0);
		o_branch_addr : OUT std_logic_vector(31 DOWNTO 0);
		o_branch : OUT std_logic
	);
END COMPONENT;

--SIGNAL	alu_iA :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	alu_iB :  STD_LOGIC_VECTOR(31 DOWNTO 0);
--SIGNAL	alu_op :  STD_LOGIC_VECTOR(3 DOWNTO 0);
--SIGNAL	alu_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	alu_shamt :  STD_LOGIC_VECTOR(4 DOWNTO 0);
--SIGNAL	alu_src_sel :  STD_LOGIC;
SIGNAL	alu_zero :  STD_LOGIC;
SIGNAL	branch_addr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	branch_mux_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
--SIGNAL	branch_sel :  STD_LOGIC;
SIGNAL	dmem_byteena :  STD_LOGIC_VECTOR(3 DOWNTO 0);
--SIGNAL	dmem_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
--SIGNAL	dmem_wren :  STD_LOGIC;
SIGNAL	imem_byteena :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	imem_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	imeme_wren :  STD_LOGIC;
--SIGNAL	imm_extended :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	id_imm_shifted :  STD_LOGIC_VECTOR(31 DOWNTO 0);
--SIGNAL	instr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	jump_i_selc :  STD_LOGIC;
SIGNAL	jumpaddr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
--SIGNAL	mem_to_reg :  STD_LOGIC;
SIGNAL	next_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_branch :  STD_LOGIC;
--SIGNAL	o_reg_dest_out :  STD_LOGIC;
SIGNAL	o_shifted :  STD_LOGIC_VECTOR(31 DOWNTO 0);
--SIGNAL	pc4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	pc_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	reg_w_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);
--SIGNAL	reg_w_sel :  STD_LOGIC_VECTOR(4 DOWNTO 0);
--SIGNAL	reg_wrt :  STD_LOGIC;
--SIGNAL	rt_data :  STD_LOGIC_VECTOR(31 DOWNTO 0);

-- IF/ID signals
SIGNAL	id_stall : std_logic;
--id_flush
--id_reset
SIGNAL 	if_instruction  : std_logic_vector(31 DOWNTO 0);
SIGNAL 	if_pc_plus_4 : std_logic_vector(31 DOWNTO 0);
SIGNAL	id_instruction : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	id_pc_plus_4 : STD_LOGIC_VECTOR(31 DOWNTO 0);

-- ID/EX signals
SIGNAL	ex_flush, ex_stall  : std_logic;
--  idex_reset
SIGNAL	ex_instruction  : std_logic_vector(31 DOWNTO 0);
SIGNAL	ex_pc_plus_4 : std_logic_vector(31 DOWNTO 0);
SIGNAL	id_reg_dest   : std_logic;
SIGNAL	id_branch    : std_logic;

SIGNAL	id_mem_to_reg : std_logic;
SIGNAL	id_ALU_op    : std_logic_vector(3 downto 0);
SIGNAL	id_mem_write  : std_logic;
SIGNAL	id_ALU_src   : std_logic;
SIGNAL	id_reg_write  : std_logic;
--SIGNAL	id_dmem_wren :  STD_LOGIC;
--SIGNAL	id_alu_src_sel :  STD_LOGIC;
SIGNAL	ex_reg_dest   : std_logic;
SIGNAL	ex_branch    : std_logic;
SIGNAL	ex_mem_to_reg : std_logic;
SIGNAL	ex_ALU_op    : std_logic_vector(3 downto 0);
SIGNAL	ex_mem_write  : std_logic;
SIGNAL	ex_ALU_src   : std_logic;
SIGNAL	ex_reg_write  : std_logic;
SIGNAL	id_rs_data : std_logic_vector(31 downto 0);
SIGNAL	id_rt_data : std_logic_vector(31 downto 0);
SIGNAL	ex_rs_data : std_logic_vector(31 downto 0);
SIGNAL	ex_rt_data : std_logic_vector(31 downto 0);
--SIGNAL	id_rs_sel : std_logic_vector(4 downto 0);
--SIGNAL	id_rt_sel : std_logic_vector(4 downto 0);
--SIGNAL	id_rd_sel : std_logic_vector(4 downto 0);
SIGNAL	ex_rs_sel : std_logic_vector(4 downto 0);
SIGNAL	ex_rt_sel : std_logic_vector(4 downto 0);
SIGNAL	ex_rd_sel : std_logic_vector(4 downto 0);
SIGNAL	id_extended_immediate : std_logic_vector(31 downto 0);
SIGNAL	ex_extended_immediate : std_logic_vector(31 downto 0);
SIGNAL	ex_write_reg_sel : std_logic_vector(4 downto 0);

-- EX/MEM signals
SIGNAL	ex_ALU_out: std_logic_vector(31 downto 0);
SIGNAL	mem_flush, mem_stall : std_logic;
-- exmem_reset 
SIGNAL	mem_instruction  : std_logic_vector(31 downto 0);
SIGNAL	mem_pc_plus_4 : std_logic_vector(31 downto 0);

-- CONTROL signals
SIGNAL	mem_reg_dest   : std_logic;
SIGNAL	mem_mem_to_reg : std_logic;
SIGNAL	mem_mem_write  : std_logic;
SIGNAL	mem_reg_write  : std_logic;
-- END CONTROL signals

-- ALU signals
SIGNAL	mem_ALU_out: std_logic_vector(31 downto 0);
-- END ALU signals

-- Register signals
SIGNAL	mem_rt_data : std_logic_vector(31 downto 0);
SIGNAL	mem_write_reg_sel : std_logic_vector(4 downto 0);

-- MEM/WB signals
SIGNAL	wb_flush, wb_stall : std_logic;
-- memwb_reset
SIGNAL	wb_instruction  : std_logic_vector(31 downto 0);
SIGNAL	wb_pc_plus_4 : std_logic_vector(31 downto 0);

-- CONTROL signalsreset
SIGNAL	wb_reg_dest   : std_logic;
SIGNAL	wb_mem_to_reg : std_logic;
SIGNAL	wb_reg_write  : std_logic;
-- END CONTROL signals

-- ALU signals
SIGNAL	wb_ALU_out: std_logic_vector(31 downto 0);
-- END ALU signals

-- Memory signals
SIGNAL	mem_dmem_out: std_logic_vector(31 downto 0);
SIGNAL	wb_dmem_out: std_logic_vector(31 downto 0);
-- END Memory signals

-- Register signals
SIGNAL	wb_write_reg_sel : std_logic_vector(4 downto 0);
-- END Register signals

BEGIN 

b2v_ALU : alu
PORT MAP(ALU_OP => ex_ALU_op,
		 i_A => ex_rs_data,
		 i_B => alu_iB,
		 shamt => alu_shamt,
		 zero => alu_zero,
		 ALU_out => ex_ALU_out);


b2v_alu_in_mux : mux21_32bit
PORT MAP(i_sel => ex_ALU_src,
		 i_0 => ex_rt_data,
		 i_1 => ex_extended_immediate,
		 o_mux => alu_iB);


-- add branch resolution in id stage
b2v_id_branch : branch
	PORT MAP(
		i_id_instruction => id_instruction,
		i_id_pc_plus_4 => id_pc_plus_4,
		i_branch => o_branch,
		i_rs_data => id_rs_data,
		i_rt_data => id_rt_data,
		o_branch_addr => branch_addr,
		o_branch => id_branch);
	
	
-- b2v_branch_adder : adder_32
-- PORT MAP(i_A => id_pc_plus_4,
		 -- i_B => id_imm_shifted,
		 -- o_F => branch_addr);


b2v_branch_mux : mux21_32bit
PORT MAP(i_sel => id_branch,
		 i_0 => if_pc_plus_4,
		 i_1 => branch_addr,
		 o_mux => branch_mux_out);


b2v_concat : concat
PORT MAP(i_A => o_shifted(27 DOWNTO 0),
		 i_B => id_pc_plus_4(31 DOWNTO 28),
		 o_F => jumpaddr);


b2v_dmem : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => CLK,
		 wren => mem_mem_write,
		 address => mem_ALU_out(11 DOWNTO 2),
		 byteena => dmem_byteena,
		 data => mem_rt_data,
		 q => mem_dmem_out);


--b2v_eq_and : and_2
--PORT MAP(i_A => o_branch,
--	 i_B => alu_zero,
--	 o_F => id_branch);


b2v_imem_reg : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => CLK,
		 wren => imeme_wren,
		 address => pc_out(11 DOWNTO 2),
		 byteena => imem_byteena,
		 data => imem_data,
		 q => if_instruction);


b2v_imm_addr_shifter : sll_2
PORT MAP(i_to_shift => id_instruction,
		 o_shifted => id_imm_shifted);


b2v_imm_sign_extender : sign_extender_16_32
PORT MAP(i_to_extend => id_instruction(15 DOWNTO 0),
		 o_extended => id_extended_immediate);

b2v_jump_mux : mux21_32bit
PORT MAP(i_sel => jump_i_selc,
		 i_0 => branch_mux_out,
		 i_1 => jumpaddr,
		 o_mux => next_PC);


b2v_jump_shifter : sll_2
PORT MAP(i_to_shift => id_instruction,
		 o_shifted => o_shifted);


b2v_main_control : main_control
PORT MAP(i_instruction => id_instruction,
		 o_reg_dest => id_reg_dest,
		 o_jump => jump_i_selc,
		 o_branch => o_branch,
		 o_mem_to_reg => id_mem_to_reg,
		 o_mem_write => id_mem_write,
		 o_ALU_src => id_ALU_src,
		 o_reg_write => id_reg_write,
		 o_ALU_op => id_alu_op);


b2v_pc_adder : adder_32
PORT MAP(i_A => pc_out,
		 i_B => x"00000004",
		 o_F => if_pc_plus_4);


b2v_PC_reg : pc_reg
PORT MAP(CLK => CLK,
		 reset => RESET,
		 i_next_PC => next_PC,
		 o_PC => pc_out);


b2v_reg_in_mux : mux21_5bit
PORT MAP(i_sel => ex_reg_dest,
		 i_0 => ex_instruction(20 DOWNTO 16),
		 i_1 => ex_instruction(15 DOWNTO 11),
		 o_mux => ex_write_reg_sel); -- changed


b2v_reg_w_data_mux : mux21_32bit
PORT MAP(i_sel => wb_mem_to_reg,
		 i_0 => wb_ALU_out,
		 i_1 => wb_dmem_out,
		 o_mux => reg_w_data);


b2v_register_file : register_file
PORT MAP(CLK => CLK,
		 w_en => wb_reg_write,
		 reset => RESET,
		 rs_sel => id_instruction(25 DOWNTO 21),
		 rt_sel => id_instruction(20 DOWNTO 16),
		 w_data => reg_w_data, --trACK
		 w_sel => wb_write_reg_sel,
		 rs_data => id_rs_data,
		 rt_data => id_rt_data);

b2v_if_id : if_id
PORT MAP(CLK => CLK,
		id_flush => id_branch,
		id_stall => id_stall,
		ifid_reset => RESET,
		if_instruction => if_instruction,
		id_instruction => id_instruction,
		if_pc_plus_4 => if_pc_plus_4,
		id_pc_plus_4 => id_pc_plus_4);

b2v_id_ex : id_ex
PORT MAP(CLK => CLK,
		ex_flush => ex_flush,
		ex_stall => ex_stall,	
		idex_reset => RESET,	
		id_instruction => id_instruction,	
		ex_instruction => ex_instruction,	
		id_pc_plus_4 => id_pc_plus_4,	
		ex_pc_plus_4 => ex_pc_plus_4,	
		id_reg_dest	 => id_reg_dest,	
		id_branch => id_branch,	
		id_mem_to_reg => id_mem_to_reg,	
		id_ALU_op => id_alu_op ,	
		id_mem_write => id_mem_write,	
		id_ALU_src => id_ALU_src,	
		id_reg_write => id_reg_write,	
		ex_reg_dest => ex_reg_dest,	
		ex_branch => ex_branch,	
		ex_mem_to_reg => ex_mem_to_reg,	
		ex_ALU_op => ex_ALU_op,	
		ex_mem_write => ex_mem_write,	
		ex_ALU_src => ex_ALU_src,	
		ex_reg_write => ex_reg_write,	
		id_rs_data => id_rs_data,		
		id_rt_data => id_rt_data,		
		ex_rs_data => ex_rs_data,		
		ex_rt_data => ex_rt_data,		
		id_rs_sel => id_instruction(25 DOWNTO 21),		
		id_rt_sel => id_instruction(20 DOWNTO 16),		
		id_rd_sel => id_instruction(15 DOWNTO 11),		
		ex_rs_sel => ex_rs_sel,		
		ex_rt_sel => ex_rt_sel,		
		ex_rd_sel => ex_rd_sel,		
		id_extended_immediate => id_extended_immediate,
		ex_extended_immediate => ex_extended_immediate);

b2v_ex_mem : ex_mem
PORT MAP(CLK => CLK,
		mem_flush => mem_flush, 
		mem_stall => mem_stall,
		exmem_reset => RESET,
		ex_instruction  => ex_instruction,
		mem_instruction  => mem_instruction,
		ex_pc_plus_4 => ex_pc_plus_4,
		mem_pc_plus_4 => mem_pc_plus_4,
		ex_reg_dest   => ex_reg_dest,
		ex_mem_to_reg => ex_mem_to_reg,
		ex_mem_write  => ex_mem_write,
		ex_reg_write  => ex_reg_write,
		mem_reg_dest   => mem_reg_dest,
		mem_mem_to_reg => mem_mem_to_reg,
		mem_mem_write  => mem_mem_write,
		mem_reg_write  => mem_reg_write,
		ex_ALU_out => ex_ALU_out,
		mem_ALU_out => mem_ALU_out,
		ex_rt_data => ex_rt_data,
		mem_rt_data => mem_rt_data,
		ex_write_reg_sel =>  ex_write_reg_sel,
		mem_write_reg_sel => mem_write_reg_sel);



b2v_mem_wb : mem_wb
PORT MAP(CLK  => CLK,          
		wb_flush => wb_flush,
		wb_stall => wb_stall,
		memwb_reset => RESET,
		mem_instruction => mem_instruction,  -- pass instruction along (useful for debugging)
        wb_instruction  => wb_instruction,
        mem_pc_plus_4  => mem_pc_plus_4,
       	wb_pc_plus_4  => wb_pc_plus_4,

  	-- CONTROL signals
        mem_reg_dest  => mem_reg_dest, 
  	    mem_mem_to_reg => mem_mem_to_reg, 
  	    mem_reg_write  => mem_reg_write,
  	    wb_reg_dest   => wb_reg_dest,
  	    wb_mem_to_reg => wb_mem_to_reg,
  	    wb_reg_write  => wb_reg_write,
  	-- END CONTROL signals

  	-- ALU signals
		mem_ALU_out => mem_ALU_out, 
		wb_ALU_out => wb_ALU_out,
  	-- END ALU signals

  	-- Memory signals
		mem_dmem_out => mem_dmem_out,
		wb_dmem_out => wb_dmem_out,
  	-- END Memory signals

	-- Register signals
  		mem_write_reg_sel => mem_write_reg_sel,
  		wb_write_reg_sel => wb_write_reg_sel
  	-- END Register signals
  	    );
		
alu_shamt <= "00000";
dmem_byteena <= "1111";
imem_byteena <= "1111";
imem_data <= "00000000000000000000000000000000";
imeme_wren <= '0';
END bdf_type;
