library ieee;
use ieee.std_logic_1164.all;

-- Define the UART entity with generic parameters for the clock frequency, baudrate, and stop bit
entity UART is
	generic(
	clk_freq : integer :=50000000; -- Clock frequency
	baudrate : integer :=115200;   -- Baudrate
	stopbit  : integer :=1         -- Stop bit
	);
	port(
		clk	: in std_logic;          -- Clock input
		data_in : in std_logic_vector(7 downto 0); -- Data input
		tx_enable : in std_logic;    -- Transmission enable
		data_out : out std_logic     -- Data output
	);
end entity;

-- Define the architecture for the UART entity
architecture rtl of UART is

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
				when S_IDLE =>
					data_out <= '1';
					if(tx_enable='1') then -- Wait for Tx_enable
						state <= S_START;
						data_out <= '0';
					end if;
				when S_START => 		--Wait one period for transmitting
					if(stop_sign=c_stopbitlim-1) then
						data_out <= data_in(cnt);
						cnt <= cnt+1;
						stop_sign <= 0;
						state <= S_DATA;
					else
						stop_sign <= stop_sign+1;	
					end if;
				when S_DATA =>			-- Transmit bits one by one
					if(counter=counter_lim-1) then
						if(cnt = 7) then
							data_out <= data_in(cnt);
							state <= S_STOP;
							cnt <= 0;
						else
							data_out <= data_in(cnt);
							cnt <= cnt+1;
						end if;
						counter <= 0;
					else
						counter <= counter +1;
					end if;
				when S_STOP =>     -- Wait after transmit complited
					data_out <= '1';
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