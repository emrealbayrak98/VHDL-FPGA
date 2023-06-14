library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity bcd_counter is
	port
	(
		cnt		  : in std_logic;
		reset	  	  : in std_logic;
		seven_segment : out STD_LOGIC_VECTOR (6 downto 0)
	);

end entity;

architecture rtl of bcd_counter is
signal count : std_logic_vector (3 downto 0):="0000";
begin
	process (cnt,reset)
	begin
			if reset = '0' then
				count <= "0000";
			elsif rising_edge(cnt) then
				if count = "1001" then
					count <= "0000";
				else
					count <= count+1;
				end if;
			end if;
	end process;
	process(count)
	begin
	   case count is
		   when "0000" => seven_segment <="1000000" ;
			when "0001" => seven_segment <="1001111" ;
			when "0010" => seven_segment <="0100100" ;
			when "0011" => seven_segment <="0110000" ;
			when "0100" => seven_segment <="0011001" ;
			when "0101" => seven_segment <="0010010" ;
			when "0110" => seven_segment <="0000010" ;
			when "0111" => seven_segment <="1111000" ;
			when "1000" => seven_segment <="0000000" ;
			when "1001" => seven_segment <="0010000" ;
			when "1010" => seven_segment <="0001000" ;
			when "1011" => seven_segment <="0000011" ;
			when "1100" => seven_segment <="1000110" ;
			when "1101" => seven_segment <="0100001" ;
			when "1110" => seven_segment <="0000110" ;
			when "1111" => seven_segment <="0001110" ;
			when others => seven_segment <="0001110" ; 
		end case;
	end process;
end rtl;