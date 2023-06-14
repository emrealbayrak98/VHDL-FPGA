library ieee;
use ieee.std_logic_1164.all;

entity fallingedge_detector is

port 
(
	clk		: in std_logic;
	rst		: in std_logic;
	input 	: in std_logic;
	output 	: out std_logic
);
end entity;

architecture rtl of fallingedge_detector is

signal input_delayed : std_logic;

begin 

process(clk,rst)
begin
	if rst='1' then
		output<='0';
	elsif rising_edge(clk) then
		input_delayed<=input;
		if input_delayed='1' and input='0' then
			output<='1';
		else
			output<='0';
		end if;
	end if;
end process;

end rtl;
