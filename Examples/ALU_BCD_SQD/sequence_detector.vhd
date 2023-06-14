library ieee;
use ieee.std_logic_1164.all;

entity sequence_detector is
    port 
    (
        clock       : in  std_logic;
        reset       : in  std_logic;
        zero        : in  std_logic;
        one         : in  std_logic;
        output      : out std_logic
    );
end entity;

architecture rtl of sequence_detector is
    type step is (S0, S1, S2, S3);
    signal state, next_state: step;
begin
    process(clock, reset)
    begin
        if reset = '0' then
            state <= S0;
        elsif rising_edge(clock) then
            state <= next_state;
        end if;
    end process;
   
    process(state, zero, one)
    begin
        output <= '0';
        next_state <= state;
      
        case state is
            when S0 =>
                if one = '0' then next_state <= S1; end if;
            when S1 =>
                if zero = '0' then next_state <= S2; end if;
            when S2 =>
                if one = '0' then
                    next_state <= S3;
                elsif zero = '0' then
                    next_state <= S0;
                end if;
            when S3 =>
                if zero = '0' then
                    next_state <= S2;
                elsif one = '0' then
                    next_state <= S1;
                end if;
                output <= '1';
        end case;
    end process;
end rtl;