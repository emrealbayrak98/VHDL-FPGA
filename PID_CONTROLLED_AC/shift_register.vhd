library ieee;
use ieee.std_logic_1164.all;

entity shift_register is
generic
(
	 number_of_baud   	 : integer:=10
);

port
(
	 Clk         : in std_logic;
    Rst         : in std_logic;
    
    ShiftEn     : in std_logic;
    Din         : in std_logic;
    Dout        : out std_logic_vector(number_of_baud - 1 downto 0)
);
end entity;

architecture rtl of shift_register is

component risingedge_detector is

port 
(
	clk		: in std_logic;
	rst		: in std_logic;
	input 	: in std_logic;
	output 	: out std_logic
);
end component;

signal Parallel_data : std_logic_vector(number_of_baud-1 downto 0):=(others=>'1');
begin 

Dout<=Parallel_data;
	Shifting:process(Clk,Rst)
	begin
		if Rst='1' then
			Parallel_data<=(others=>'1');
		elsif rising_edge(Clk) then 
			if ShiftEn='1' then
				Parallel_data<=Din&Parallel_data(number_of_baud-1 downto 1);
			end if;
		end if;
	end process;
end rtl;