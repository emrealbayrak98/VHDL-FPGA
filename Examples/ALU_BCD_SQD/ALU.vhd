library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu is
    generic (W : natural := 2);
    port (
        A         : in  std_logic_vector(W downto 0);
        B         : in  std_logic_vector(W downto 0);
        sel       : in  std_logic_vector(3 downto 0);
        seven_segment : out std_logic_vector(6 downto 0)        
    );
end entity;

architecture rtl of alu is

signal A_extended, B_extended: std_logic_vector(3 downto 0);
signal Y: std_logic_vector(3 downto 0);
begin
	 A_extended <= '0' & A when W = 2 else A;
    B_extended <= '0' & B when W = 2 else B;
	 
    process(A_extended, B_extended, sel)
	 variable temp: std_logic_vector(7 downto 0);
    begin
        case sel is
            when "0000" => Y <= A_extended;
            when "0001" => Y <= A_extended + 1;
            when "0010" => Y <= A_extended - 1;
            when "0011" => Y <= B_extended;
            when "0100" => Y <= A_extended + B_extended ;
            when "0101" => Y <= A_extended - B_extended ;
            when "0110" => temp := (A_extended) * (B_extended);
			               Y <= temp(3 downto 0);
            when "0111" => Y <= (others => '0');
            when "1000" =>
									if W > 2 Then
									Y <= (not A_extended);
									else
									Y <= ("0111" and (not A_extended));
									end if;
            when "1001" =>
									if W > 2 Then
									Y <= (not B_extended);
									else
									Y <= ("0111" and (not B_extended));
									end if;
            when "1010" => Y <= (A_extended) and (B_extended);
            when "1011" => Y <= (A_extended) or (B_extended);
            when "1100" => Y <= (A_extended) xnor (B_extended);
            when "1101" => Y <= (A_extended) xor (B_extended);
            when "1110" => Y <= (A_extended) nor (B_extended);
            when "1111" => Y <= (A_extended) nand (B_extended);
            when others => null;
        end case;
    end process;	
	process(Y)
	begin
	   case Y is
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