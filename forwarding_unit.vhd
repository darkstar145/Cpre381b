LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY forwarding_unit IS
	PORT (
		EX_MEM_RegisterRd, ID_EX_RegisterRs, ID_EX_RegisterRt, MEM_WB_RegisterRd, IF_ID_RegisterRs, IF_ID_RegisterRt, EX_MEM_WRITE_REG_SEL, ID_EX_RegisterRd : IN std_logic_vector(4 DOWNTO 0);
		EX_MEM_RegWrite, MEM_WB_RegWrite, EX_MEM_MEM_TO_REG, ID_EX_RegWrite, ID_RegWrite : IN std_logic;
		ForwardA, ForwardB : OUT std_logic_vector(1 DOWNTO 0);
		ForwardC, ForwardD : OUT std_logic
	);
END forwarding_unit;

ARCHITECTURE mixed OF forwarding_unit IS

	SIGNAL conditionIA, conditionIB, conditionIIA, conditionIIB, conditionIIIA, conditionIIIB, conditionIVA, conditionIVB : BOOLEAN;

BEGIN
	conditionIA <= (((EX_MEM_RegWrite = '1') AND (EX_MEM_RegisterRd /= "00000"))
		AND (EX_MEM_RegisterRd = ID_EX_RegisterRs));
	conditionIB <= (((EX_MEM_RegWrite = '1') AND (EX_MEM_RegisterRd /= "00000"))
		AND (EX_MEM_RegisterRd = ID_EX_RegisterRt));
	conditionIIA <= ((MEM_WB_RegWrite = '1') AND (MEM_WB_RegisterRd /= "00000")
		AND NOT ((EX_MEM_RegWrite = '1') AND (EX_MEM_RegisterRd /= "00000")
		AND (EX_MEM_RegisterRd = ID_EX_RegisterRs))
		AND (MEM_WB_RegisterRd = ID_EX_RegisterRs));
	conditionIIB <= ((MEM_WB_RegWrite = '1') AND (MEM_WB_RegisterRd /= "00000")
		AND NOT ((EX_MEM_RegWrite = '1') AND (EX_MEM_RegisterRd /= "00000")
		AND (EX_MEM_RegisterRd = ID_EX_RegisterRt))
		AND (MEM_WB_RegisterRd = ID_EX_RegisterRt));
	conditionIVA <= ((EX_MEM_RegWrite = '1') AND (EX_MEM_RegisterRd /= "00000")
		AND NOT ((ID_EX_RegWrite = '1') AND (ID_EX_RegisterRd /= "00000")
		AND (ID_EX_RegisterRd = IF_ID_RegisterRs))
		AND (EX_MEM_RegisterRd = IF_ID_RegisterRs));
	conditionIVB <= ((EX_MEM_RegWrite = '1') AND (EX_MEM_RegisterRd /= "00000")
		AND NOT ((ID_EX_RegWrite = '1') AND (ID_EX_RegisterRd /= "00000")
		AND (ID_EX_RegisterRd = IF_ID_RegisterRt))
		AND (EX_MEM_RegisterRd = IF_ID_RegisterRt));

	P1 : PROCESS (conditionIA, conditionIB, conditionIIA, conditionIIB, conditionIIIA, conditionIIIB, conditionIVA, conditionIVB)
	BEGIN
		ForwardA <= "00";
		ForwardB <= "00";
		ForwardC <= '0';
		ForwardD <= '0';

		IF (conditionIA) THEN
			ForwardA <= "10";
		END IF;
		IF (conditionIB) THEN
			ForwardB <= "10";
		END IF;
		IF (conditionIIA) THEN
			ForwardA <= "01";
		END IF;
		IF (conditionIIB) THEN
			ForwardB <= "01";
		END IF;
		IF (conditionIVA) THEN
			ForwardC <= '1';
		END IF;
		IF (conditionIVB) THEN
			ForwardD <= '1';
		END IF;
	END PROCESS P1;

END mixed;
