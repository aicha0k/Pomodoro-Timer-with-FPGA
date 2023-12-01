-- Componente com 1 Decodificador 7 Segmentos
--
-- Recebe um dado de 4 bits e apresenta na saída os 
-- os segmentos que devem ser acesos para um display
-- de 7 segmentos de anodo comum.

library ieee;
	use ieee.std_logic_1164.all;

entity display_7seg is
port(

	data_i		:	in std_logic_vector(3 downto 0);
	disp_7seg_o	:	out std_logic_vector(6 downto 0)

);
end display_7seg;

architecture behavior of display_7seg is
begin

	disp_7seg_o <= "1000000" when data_i = x"0" else -- 0
						"1111001" when data_i = x"1" else -- 1
						"0100100" when data_i = x"2" else -- 2
						"0110000" when data_i = x"3" else -- 3
					
						"0011001" when data_i = x"4" else -- 4
						"0010010" when data_i = x"5" else -- 5
						"0000010" when data_i = x"6" else -- 6
						"1111000" when data_i = x"7" else -- 7
						
						"0000000" when data_i = x"8" else -- 8
						"0011000" when data_i = x"9" else -- 9
						--"0001000" when data_i = x"A" else -- A
						"1111100" when data_i = x"B" else -- B
						
						"0111001" when data_i = x"C" else -- C
						"1011110" when data_i = x"D" else -- D
						"1111001" when data_i = x"E" else -- E
						"1110001" when data_i = x"F" else	  -- F
                        "0111111" when data_i = x"A"; -- Hífen '-'
				
end behavior;