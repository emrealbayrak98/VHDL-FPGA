library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
    port (
        input         	: in  std_logic_vector(3 downto 0);
        reset	         : in  std_logic;
		  clock         	: in  std_logic;
		  enable         	: in  std_logic;
        output			 	: out std_logic_vector(3 downto 0)        
    );
end entity;

architecture rtl of reg is
begin
	process(clock,reset)
	begin
			if reset = '0' then
				output <= "0000";
			elsif rising_edge(clock) then
				if enable = '0' then
				output <= input;
				end if;
			end if;
	end process;
end rtl;