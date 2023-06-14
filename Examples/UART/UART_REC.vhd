library ieee;
use ieee.std_logic_1164.all;

-- Define the UART_REC entity with generic parameters for the clock frequency, baudrate, and stop bit
entity UART_REC is
	generic(
	clk_freq : integer :=50000000; -- Clock frequency
	baudrate : integer :=115200;   -- Baudrate
	stopbit  : integer :=1         -- Stop bit
	);
	port(
		clk	: in std_logic;                 -- Clock input
		data_in : in std_logic;              -- Data input
		rx_out : out std_logic;              -- Received signal output
		data_out : out std_logic_vector(7 downto 0) -- Data output
	);
end entity;

-- Define the architecture for the UART_REC entity
architecture rtl of UART_REC is

constant counter_lim : integer := (clk_freq/baudrate); -- Counter limit for the UART

constant c_stopbitlim 	: integer := (clk_freq/baudrate)*stopbit; -- Stop bit limit

-- Define the states for the UART
type states is (S_IDLE, S_START, S_DATA, S_STOP);
signal state : states := S_IDLE;

-- Define signals used in UART
signal counter : integer range 0 to counter_lim;
signal stop_sign : integer range 0 to c_stopbitlim := 0;
signal cnt : integer range 0 to 7 :=0;

begin 

	-- Define the main process for UART
	process(clk)
	begin
		if (rising_edge(clk)) then	
			-- Define the state machine for the UART
			case state is
				-- In idle state, it waits for a start bit to go to the start state
				when S_IDLE =>
					rx_out <= '0';
					if(data_in='0') then
						state <= S_START;
						rx_out <= '1';
					end if;
				-- In the start state, it waits for the stop bit time, then starts to receive data bits
				when S_START =>
					if(stop_sign=c_stopbitlim-1) then
						data_out(cnt) <= data_in;
						cnt <= cnt+1;
						stop_sign <= 0;
						state <= S_DATA;
					else
						stop_sign <= stop_sign+1;	
					end if;
				-- In the data state, it keeps receiving bits until the last one
				when S_DATA =>
					if(counter=counter_lim-1) then
						if(cnt = 7) then
							data_out(cnt) <= data_in;
							rx_out <= '0';
							state <= S_STOP;
							cnt <= 0;
						else
							data_out(cnt) <= data_in;
							cnt <= cnt+1;
						end if;
						counter <= 0;
					else
						counter <= counter +1;
					end if;
				-- In the stop state, it adds the stop bit and goes back to the idle state
				when S_STOP =>
					if(stop_sign=c_stopbitlim-1) then
						stop_sign <= 0;
						state <= S_IDLE;
					else
						stop_sign <= stop_sign+1;	
					end if;
			end case;
		end if;
	end process;

end rtl;