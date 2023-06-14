library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ir_receiver is
    port (
        clk     			: in  std_logic;
        ir_in_async		: in  std_logic;
		  rst		 			: in  std_logic;
        data_out			: out std_logic_vector(7 downto 0);
		  IRF					: out std_logic 
			);
end ir_receiver;

architecture Behavioral of ir_receiver is
	
	component sync is

	port
	(
		 Clk     : in std_logic;
		 Rst     : in std_logic;
		 Async   : in std_logic;
		 Synced  : out std_logic
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

signal count      	: integer range 0 to 50000000 := 0;
type 	 state_type is (IDLE, S1, S2, S3, S4);
signal state 		 	: state_type:=IDLE;
signal data       	: std_logic_vector(31 downto 0):=(others=>'0');
signal bit_count  	: integer range 0 to 33 := 0;
signal ir_in		 	: std_logic;
signal ir_in_falling	: std_logic;


begin

synch:sync port map(Clk=>clk,Rst=>rst,Async=>ir_in_async,Synced=>ir_in);

detect:fallingedge_detector port map(clk=>clk,rst=>rst,input=>ir_in,output=>ir_in_falling);

--In this state machine NEC protocol used to understand and decode received infrared data

NEC_decoding:process(clk,rst)
begin
    if rst='1' then
        state <= IDLE;
        bit_count <= 0;
        data <= (others => '0');
        count <= 0;
        data_out <= (others => '0');
		  IRF<='0';
    elsif rising_edge(clk) then
        case state is
            -- IDLE State
            when IDLE =>
                IRF<='0';
                if ir_in = '0' then
                    count<=0;
                    state <=S1;	
                else 
                    state<=IDLE;
                end if;

            -- S1 State(counting 9ms '0' input, if it is not 9ms, go back idle)
            when S1 =>
                count<=count+1;
					if count>600000 then
						state<=IDLE;
					end if;
                if ir_in = '1' then
                    if count >= 400000 and count<500000 then --9ms '0' detected
                        count <= 0;
                        state <= S2;    
                    else
                        state <= IDLE; 
                    end if;
                end if;

            -- S2 State(counting 4.5ms 1 input, if it is not 4.5ms, go back idle)
            when S2 =>
					if count>600000 then
						state<=IDLE;
					end if;	
                count<=count+1;
                if ir_in = '0' then
                    if count >= 175000 and count<250000 then  --4.5ms '1' detected
                        count <= 0;
                        bit_count <= 0;
                        data <= (others => '0');
                        state <= S3;
                    else
                        state <= IDLE; 
                    end if;
                end if;

            -- S3 State(if bit period is 2.25ms then bit is '1', if 1.25ms then '0', else go to idle)
            when S3 => 
                count<=count+1;
					if count>600000 then
						state<=IDLE;
					end if;					 
                if ir_in_falling = '1' then
                    if count >= 90000 and count<200000 then --bit addressing
                        data(bit_count) <= '1';
                        count<=0;
                    elsif count < 90000 then
                        data(bit_count) <= '0';
                        count<=0;
                    else
                        count<=0;
                        bit_count<=0;
								state<=IDLE;
                    end if;
                    bit_count <= bit_count + 1;
                    if bit_count >= 32 then
                        count<=0;
                        bit_count<=0;
                        state <= S4;
                    end if;
                end if;

            -- S4 State(counting 563.5us '0' input to understand operation is valid)
            when S4 =>
					if count>600000 then
						state<=IDLE;
					end if;	
                count<=count+1;
                if ir_in = '1' then
                    if count >= 25000 then  --563.5us '0' detected
                        data_out <= data(23 downto 16);
								IRF<='1';
								bit_count<=0;
                        count<=0;
                        state <= IDLE;
                    else
								bit_count<=0;
                        count<=0;
								IRF<='0';
								state <= IDLE;
                    end if;
                end if;

            -- Default Case
            when others =>
                bit_count <= 0;
                count<=0;
					 IRF<='0';
					 state <= IDLE;
        end case;
    end if;
end process;

end Behavioral;
