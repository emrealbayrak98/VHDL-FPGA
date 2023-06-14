library ieee;
use ieee.std_logic_1164.all;

entity baudclk_generator is

generic
(
	number_of_baud : integer:=10;
	baud_rate      : integer:=115200;
	system_clock	: integer:=50000000
);

port
(
	clk 	: in std_logic;
	rst 	: in std_logic;
	start : in std_logic;
	Ready : out std_logic;
	Baud  : out std_logic
);

end entity;

architecture rtl of baudclk_generator is
constant period 		: integer:=system_clock/baud_rate;

signal How_Much_Left : integer range 0 to number_of_baud;
signal counter 		: integer range 0 to period;

begin 

process(clk,rst)
begin
	if rst='1' then
		Baud<='0';
		counter<=0;
	elsif rising_edge(clk) then
		if How_Much_Left>0 then
			if counter=period then
				Baud<='1';
				counter<=0;
			elsif counter=(period/2) and How_Much_Left=number_of_baud then
				counter<=0;
				Baud<='1';
			else
				counter<=counter+1;
				Baud<='0';
			end if;
		else 
			Baud<='0';
			counter<=0;
		end if;
	end if;	
end process;


process(clk,rst)
begin
	if rst='1' then
		How_Much_Left<=0;
	elsif rising_edge(clk) then
		if start='1'  then
			How_Much_Left<=number_of_baud;
		elsif Baud='1' then
			How_much_Left<=How_much_Left-1;
		end if;
	end if;
end process;

process(clk,rst)
begin
	if rst='1' then
		Ready<='1';
	elsif rising_edge(clk) then
		if start='1' then
			Ready<='0';
		elsif How_much_Left=0 then
			Ready<='1';
		end if;
	end if;
end process;

end rtl;