library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity forwarding_unit is
  port( EX_MEM_RegisterRd, ID_EX_RegisterRs, ID_EX_RegisterRt, MEM_WB_RegisterRd, IF_ID_RegisterRs, IF_ID_RegisterRt, EX_MEM_WRITE_REG_SEL, ID_EX_RegisterRd : in std_logic_vector(4 downto 0);
		EX_MEM_RegWrite, MEM_WB_RegWrite, EX_MEM_MEM_TO_REG, ID_EX_RegWrite, ID_RegWrite: std_logic;
  	    ForwardA, ForwardB : out std_logic_vector(1 downto 0);
		ForwardC, ForwardD : out std_logic);
 end forwarding_unit;

architecture mixed of forwarding_unit is 

	signal conditionIA, conditionIB, conditionIIA, conditionIIB, conditionIIIA, conditionIIIB, conditionIVA, conditionIVB: boolean;

begin
	
	conditionIA <= (((EX_MEM_RegWrite = '1') and (EX_MEM_RegisterRd /= "00000"))
				and (EX_MEM_RegisterRd = ID_EX_RegisterRs));
	conditionIB <= (((EX_MEM_RegWrite = '1') and (EX_MEM_RegisterRd /= "00000"))
				and (EX_MEM_RegisterRd = ID_EX_RegisterRt));
	conditionIIA <= ((MEM_WB_RegWrite = '1') and (MEM_WB_RegisterRd /= "00000")
					and not ((EX_MEM_RegWrite = '1') and (EX_MEM_RegisterRd /= "00000")
					and (EX_MEM_RegisterRd = ID_EX_RegisterRs))
					and (MEM_WB_RegisterRd = ID_EX_RegisterRs));
	conditionIIB <= ((MEM_WB_RegWrite = '1') and (MEM_WB_RegisterRd /= "00000")
					and not ((EX_MEM_RegWrite = '1') and (EX_MEM_RegisterRd /= "00000")
					and (EX_MEM_RegisterRd = ID_EX_RegisterRt))
					and (MEM_WB_RegisterRd = ID_EX_RegisterRt));
	conditionIVA <= ((EX_MEM_RegWrite = '1') and (EX_MEM_RegisterRd /= "00000")
					and not ((ID_EX_RegWrite = '1') and (ID_EX_RegisterRd /= "00000")
					and (ID_EX_RegisterRd = IF_ID_RegisterRs))
					and (EX_MEM_RegisterRd = IF_ID_RegisterRs));
	conditionIVB <= ((EX_MEM_RegWrite = '1') and (EX_MEM_RegisterRd /= "00000")
					and not ((ID_EX_RegWrite = '1') and (ID_EX_RegisterRd /= "00000")
					and (ID_EX_RegisterRd = IF_ID_RegisterRt))
					and (EX_MEM_RegisterRd = IF_ID_RegisterRt));
				
	P1: process (conditionIA, conditionIB, conditionIIA, conditionIIB, conditionIIIA, conditionIIIB, conditionIVA, conditionIVB)
	begin
		ForwardA <= "00";
		ForwardB <= "00";
		ForwardC <= '0';
		ForwardD <= '0';
		
		if (conditionIA) then
			ForwardA <= "10";
		end if;
		if (conditionIB) then
			ForwardB <= "10";
		end if;
		if (conditionIIA) then
			ForwardA <= "01";
		end if;
		if (conditionIIB) then
			ForwardB <= "01";
		end if;
		if (conditionIVA) then
			ForwardC <= '1';
		end if;
		if (conditionIVB) then
			ForwardD <= '1';
		end if;
	end process P1;
		
end mixed;