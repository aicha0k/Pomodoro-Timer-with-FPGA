--
-- Curso de FPGA WR Kits Channel
--
--
-- Utilizando o Display de 7 Segmentos
--
--  Truth Table:
--
--                 Entradas    | Saída (segmentos)                                                          
--               D3 D2 D1 D0   |  h g f e d c b a                                                       
--                0  0  0  0   |  0 0 1 1 1 1 1 1                                              
--                0  0  0  1   |  0 0 0 0 0 1 1 0                                                            
--                0  0  1  0   |  0 1 0 1 1 0 1 1                                                             
--                0  0  1  1   |  0 1 0 0 1 1 1 1                                                                   
--                0  1  0  0   |  0 1 1 0 0 1 1 0                                                                           
--                0  1  0  1   |  0 1 1 0 1 1 0 1                                                                              
--                0  1  1  0   |  0 1 1 1 1 1 0 1                                                                             
--                0  1  1  1   |  0 0 0 0 0 1 1 1                                                                                  
--                1  0  0  0   |  0 1 1 1 1 1 1 1                                                       
--                1  0  0  1   |  0 1 1 0 1 1 1 1                                                             
--                                                                                                                        
--


	library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;
	
	
	entity disp7seg is
	port(
	     Data_In          :   in  std_logic_vector(3 downto 0);
        a,b,c,d,e,f,g,h  :  out  std_logic;
		  dig_uni          :  out  std_logic;
		  dig_dez          :  out  std_logic;
		  dig_cen          :  out  std_logic;
		  dig_mil          :  out  std_logic);
		  
   end disp7seg;
	
	
	architecture hardware of disp7seg is
	begin
		process(Data_In)
		begin
		  case Data_In is
		   when "0000"   => a <= '1'; b <= '1'; c <= '1'; d <= '1'; e <= '1'; f <= '1'; g <= '0'; h <= '0';
	      when "0001"   => a <= '0'; b <= '1'; c <= '1'; d <= '0'; e <= '0'; f <= '0'; g <= '0'; h <= '0';
	      when "0010"   => a <= '1'; b <= '1'; c <= '0'; d <= '1'; e <= '1'; f <= '0'; g <= '1'; h <= '0';	
	      when "0011"   => a <= '1'; b <= '1'; c <= '1'; d <= '1'; e <= '0'; f <= '0'; g <= '1'; h <= '0'; 
	      when "0100"   => a <= '0'; b <= '1'; c <= '1'; d <= '0'; e <= '0'; f <= '1'; g <= '1'; h <= '0';	
	      when "0101"   => a <= '1'; b <= '0'; c <= '1'; d <= '1'; e <= '0'; f <= '1'; g <= '1'; h <= '0';	
	      when "0110"   => a <= '1'; b <= '0'; c <= '1'; d <= '1'; e <= '1'; f <= '1'; g <= '1'; h <= '0';	
	      when "0111"   => a <= '1'; b <= '1'; c <= '1'; d <= '0'; e <= '0'; f <= '0'; g <= '0'; h <= '0';	
	      when "1000"   => a <= '1'; b <= '1'; c <= '1'; d <= '1'; e <= '1'; f <= '1'; g <= '1'; h <= '0';
	      when "1001"   => a <= '1'; b <= '1'; c <= '1'; d <= '1'; e <= '0'; f <= '1'; g <= '1'; h <= '0';			
	      when others   => a <= '0'; b <= '0'; c <= '0'; d <= '0'; e <= '0'; f <= '0'; g <= '0'; h <= '0';	
	     end case;
		end process;
		
		dig_mil <= '1';
		dig_cen <= '1';
		dig_dez <= '1';
		dig_uni <= '1';
		
		
   end hardware;
	