library ieee;
use ieee.std_logic_1164.all;

entity receiver is

generic
(
	 number_of_baud   	 : integer:=10;
    system_clock       	 : integer:=50000000;
    baud_rate            : integer:=115200
);
port
(
	Clk : in std_logic;
	Rst : in std_logic;
	Din : in std_logic;
	Dout: out std_logic_vector(number_of_baud-3 downto 0);
	Ready : out std_logic
);
end entity;

architecture rtl of receiver is
component sync is

port
(
	 Clk     : in std_logic;
    Rst     : in std_logic;
	 
    Async   : in std_logic;
    Synced  : out std_logic
);
end component;
component baudclk_generator is

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

end component;
component shift_register is
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
end component;
component fallingedge_detector is

port 
(
	clk		: in std_logic;
	rst		: in std_logic;
	
	input 	: in std_logic;
	output 	: out std_logic
);
end component;
component risingedge_detector is

port 
(
	clk		: in std_logic;
	rst		: in std_logic;
	input 	: in std_logic;
	output 	: out std_logic
);
end component;
signal Din_synced 				: std_logic;
signal Din_falling_edge			: std_logic;
signal Dout_with_startandstop : std_logic_vector(number_of_baud-1 downto 0);
signal Baud 						: std_logic;
signal StartForBaud				: std_logic;
signal Ready_process 			: std_logic;
signal Ready_process_rising 	: std_logic;

begin

StartForBaud<=Ready_process and Din_falling_edge;

do_sync:sync port map(Clk=>Clk,Rst=>Rst,Async=>Din,Synced=>Din_synced);

edge_det:fallingedge_detector port map(Clk=>Clk,Rst=>Rst,input=>Din_synced,output=>Din_falling_edge);

edge_det2:risingedge_detector port map(Clk=>Clk,Rst=>Rst,input=>Ready_process,output=>Ready_process_rising);

shift:shift_register generic map(number_of_baud=>number_of_baud) 
							port map(Clk=>Clk,Rst=>Rst,ShiftEn=>Baud,Din=>Din,Dout=>Dout_with_startandstop);


baudclk:baudclk_generator generic map(number_of_baud=>number_of_baud,baud_rate=>baud_rate,system_clock=>system_clock)
							  port map(Clk=>Clk,Rst=>Rst,start=>StartForBaud,Ready=>Ready_process,Baud=>Baud);
							  
process(clk,rst)
begin
	if rst='1' then
		Dout<=(others=>'1');
		Ready<='0';
	elsif rising_edge(clk) then
			Ready<='0';
		if Ready_process_rising='1' then
			Dout<=Dout_with_startandstop(number_of_baud-2 downto 1);
			Ready<='1';
		end if;
	end if;
end process;	
end rtl;