library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hazard_detection_unit is
  port( ID_EX_RegisterRt, IF_ID_RegisterRs, IF_ID_RegisterRt, EX_Write_Reg_Sel : in std_logic_vector(4 downto 0);
		ID_Jump, IF_ID_Branch, ID_EX_MemRead, branch_condition_combined : in std_logic;
		stall, IF_ID_flush, ID_EX_flush : out std_logic);
 end hazard_detection_unit;

architecture mixed of hazard_detection_unit is 

	signal loadUseHazard, ALUtoBranchH : boolean;

begin
	
	loadUseHazard <= ((ID_EX_MemRead = '1') and (((ID_EX_RegisterRt = IF_ID_RegisterRs) and (IF_ID_RegisterRs /= "00000")) or ((ID_EX_RegisterRt = IF_ID_RegisterRt) and (IF_ID_RegisterRt /= "00000")))); --can make code shorter too many ands, sets signals and then sends stall based on results
	ALUtoBranchH <= ((IF_ID_Branch = '1') and (((EX_Write_Reg_Sel = IF_ID_RegisterRs) and (IF_ID_RegisterRs /= "00000")) or ((EX_Write_Reg_Sel = IF_ID_RegisterRt) and (IF_ID_RegisterRt /= "00000"))));
	
	P1: process (ID_Jump, loadUseHazard, branch_condition_combined, ALUtoBranchH)
	begin
	
		IF_ID_flush <= '0';
		ID_EX_flush <= '0';
		stall <= '0';
	
		if (ID_Jump = '1') then
			IF_ID_flush <= '1';
			ID_EX_flush <= '0';
			stall <= '0';
		end if;
		if (branch_condition_combined = '1') then
			IF_ID_flush <= '1';
			ID_EX_flush <= '0';
			stall <= '0';
		end if;
		if (loadUseHazard) then
			IF_ID_flush <= '0';
			ID_EX_flush <= '1';
			stall <= '1';
		end if;
		if (ALUtoBranchH) then
			IF_ID_flush <= '0';
			ID_EX_flush <= '1';
			stall <= '1';
		end if;
	end process P1;

end mixed;