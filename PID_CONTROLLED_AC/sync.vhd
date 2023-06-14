library ieee;
use ieee.std_logic_1164.all;

entity sync is

port
(
	 Clk     : in std_logic;
    Rst     : in std_logic;
    Async   : in std_logic;
    Synced  : out std_logic
);
end entity;

architecture rtl of sync is
signal Reg : std_logic_vector(1 downto 0):="11";
begin
Synced<=Reg(1);
	process(Rst,Clk)
	begin 
		if Rst='1' then
			Reg<=(others=>'1');
		elsif rising_edge(clk) then
			Reg(0)<=Async;
			Reg(1)<=Reg(0);
		end if;
	end process;

end rtl;