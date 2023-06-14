library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity alu is
    generic (W : integer := 2);
    port (
        A         : in  std_logic_vector(W downto 0);
        B         : in  std_logic_vector(W downto 0);
        sel       : in  std_logic_vector(3 downto 0);
		  cin			: in 	std_logic;
		  Y			: out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of alu is

signal A_extended, B_extended: std_logic_vector(3 downto 0);
begin
	 A_extended <= '0' & A when W = 2 else A;
    B_extended <= '0' & B when W = 2 else B;
	 
    process(A_extended, B_extended, cin, sel)
	 variable temp: std_logic_vector(7 downto 0);
    begin
        case sel is
            when "0000" => Y <= A_extended;
            when "0001" => Y <= A_extended + 1;
            when "0010" => Y <= A_extended - 1;
            when "0011" => Y <= B_extended;
            when "0100" => Y <= A_extended + B_extended + cin;
            when "0101" => Y <= A_extended - B_extended - cin;
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
end rtl;