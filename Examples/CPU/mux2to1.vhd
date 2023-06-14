library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2to1 is
    port (
        mux_input1         : in  std_logic_vector(3 downto 0);
        mux_input2         : in  std_logic_vector(3 downto 0);
        mux_sel       		: in  std_logic;
        mux_output			: out std_logic_vector(3 downto 0)        
    );
end entity;

architecture rtl of mux2to1 is
begin
	with mux_sel select
		mux_output <= mux_input1 when '1',
					     mux_input2 when '0',
					     (others => '0') when others;
end rtl;