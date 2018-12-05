LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY hazard_detection_unit IS
	PORT (
		ID_EX_RegisterRt, IF_ID_RegisterRs, IF_ID_RegisterRt, EX_Write_Reg_Sel : IN std_logic_vector(4 DOWNTO 0);
		ID_Jump, IF_ID_Branch, ID_EX_MemRead, branch_condition_combined : IN std_logic;
		stall, IF_ID_flush, ID_EX_flush : OUT std_logic);
END hazard_detection_unit;

ARCHITECTURE mixed OF hazard_detection_unit IS

	SIGNAL loadUseHazard, ALUtoBranchH : BOOLEAN;

BEGIN

	loadUseHazard <= ((ID_EX_MemRead = '1') AND (((ID_EX_RegisterRt = IF_ID_RegisterRs) AND (IF_ID_RegisterRs /= "00000")) OR ((ID_EX_RegisterRt = IF_ID_RegisterRt) AND (IF_ID_RegisterRt /= "00000")))); --can make code shorter too many ands, sets signals and then sends stall based on results
	ALUtoBranchH <= ((IF_ID_Branch = '1') AND (((EX_Write_Reg_Sel = IF_ID_RegisterRs) AND (IF_ID_RegisterRs /= "00000")) OR ((EX_Write_Reg_Sel = IF_ID_RegisterRt) AND (IF_ID_RegisterRt /= "00000"))));

	P1 : PROCESS (ID_Jump, loadUseHazard, branch_condition_combined, ALUtoBranchH)
	BEGIN

		IF_ID_flush <= '0';
		ID_EX_flush <= '0';
		stall <= '0';

		IF (ID_Jump = '1') THEN
			IF_ID_flush <= '1';
			ID_EX_flush <= '0';
			stall <= '0';
		END IF;
		IF (branch_condition_combined = '1') THEN
			IF_ID_flush <= '1';
			ID_EX_flush <= '0';
			stall <= '0';
		END IF;
		IF (loadUseHazard) THEN
			IF_ID_flush <= '0';
			ID_EX_flush <= '1';
			stall <= '1';
		END IF;
		IF (ALUtoBranchH) THEN
			IF_ID_flush <= '0';
			ID_EX_flush <= '1';
			stall <= '1';
		END IF;
	END PROCESS P1;

END mixed;