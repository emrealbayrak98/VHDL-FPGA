library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define the seven_seg entity with a binary input and two 7-segment display outputs
entity seven_seg is
    port (
        input         : in  std_logic_vector(7 downto 0);   -- 8-bit binary input
        seven_segment1 : out std_logic_vector(6 downto 0);  -- First 7-segment display output
        seven_segment2 : out std_logic_vector(6 downto 0)   -- Second 7-segment display output     
    );
end entity;

-- Define the architecture for the seven_seg entity
architecture rtl of seven_seg is

    -- Internal signals to hold the split input
    signal input1 : std_logic_vector(3 downto 0);
    signal input2 : std_logic_vector(3 downto 0);
    
begin
    -- Split the 8-bit input into two 4-bit inputs
    input1 <= input(7 downto 4);
    input2 <= input(3 downto 0);
    
    -- Convert the 4-bit binary input1 to 7-segment display output
    with input1 select
        seven_segment1 <=
            "1000000" when "0000",  -- 0
            "1001111" when "0001",  -- 1
            "0100100" when "0010",  -- 2
            "0110000" when "0011",  -- 3
            "0011001" when "0100",  -- 4
            "0010010" when "0101",  -- 5
            "0000010" when "0110",  -- 6
            "1111000" when "0111",  -- 7
            "0000000" when "1000",  -- 8
            "0010000" when "1001",  -- 9
            "0001000" when "1010",  -- A
            "0000011" when "1011",  -- B
            "1000110" when "1100",  -- C
            "0100001" when "1101",  -- D
            "0000110" when "1110",  -- E
            "0001110" when "1111",  -- F
            "0001110" when others;  -- Default value for all other cases

    -- Convert the 4-bit binary input2 to 7-segment display output
	 
    with input2 select
        seven_segment2 <=
            "1000000" when "0000",
            "1001111" when "0001",
            "0100100" when "0010",
            "0110000" when "0011",
            "0011001" when "0100",
            "0010010" when "0101",
            "0000010" when "0110",
            "1111000" when "0111",
            "0000000" when "1000",
            "0010000" when "1001",
            "0001000" when "1010",
            "0000011" when "1011",
            "1000110" when "1100",
            "0100001" when "1101",
            "0000110" when "1110",
            "0001110" when "1111",
            "0001110" when others;
end rtl;