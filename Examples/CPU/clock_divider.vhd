library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
    port (
        clock_50MHZ         : in  std_logic;
        reset	         	 : in  std_logic;
        clock_05HZ			 : out std_logic        
    );
end entity;

architecture rtl of clock_divider is
signal counter : natural := 0;
signal temp_05hz : std_logic := '0';

begin
	process(clock_50MHZ,reset)
	begin
			if reset = '0' then
			counter <= 0;
			temp_05hz <= '0';
			elsif rising_edge(clock_50MHZ) then
				if counter = 49999999 then
					counter <= 0;
					temp_05hz <= not temp_05hz; 
				else
					counter <= counter + 1;
				end if;
			end if;
	end process;
	clock_05hz <= temp_05hz;
end rtl;