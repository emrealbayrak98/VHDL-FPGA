library ieee;
use ieee.std_logic_1164.all;

-- Define entity for UART_SYSTEM with input and output ports
entity UART_SYSTEM is
        port(
            clk       : in std_logic;            -- Clock input
            data_in   : in std_logic_vector(7 downto 0); -- Data input
            tx_enable : in std_logic;            -- TX enable signal
            data_out  : out std_logic_vector(7 downto 0); -- Data output
			rx_out	 : out std_logic             -- RX out signal
        );
end entity;


architecture rtl of UART_SYSTEM is

    -- Define component UART for transmission
	component UART is
        generic(
            clk_freq : integer := 50000000; -- Clock frequency
            baudrate : integer := 115200;   -- Baud rate
            stopbit  : integer := 1         -- Stop bit
        );
        port(
            clk       : in std_logic;                       
            data_in   : in std_logic_vector(7 downto 0);    
            tx_enable : in std_logic;                       
            data_out  : out std_logic                       
        );
	end component;

    -- Define component UART_REC for reception
   component UART_REC is
        generic(
            clk_freq : integer := 50000000; 
            baudrate : integer := 115200;   
            stopbit  : integer := 1         
        );
        port(
            clk      : in std_logic;                    
            data_in  : in std_logic;                       
            rx_out   : out std_logic;                      
            data_out : out std_logic_vector(7 downto 0)     
        );
   end component;
	
	-- Define component seven_seg for seven segment display
   component seven_seg is
        port (
            input         : in  std_logic_vector(7 downto 0);        -- Input data
            seven_segment1 : out std_logic_vector(6 downto 0);       -- Seven segment output for the first digit
            seven_segment2 : out std_logic_vector(6 downto 0)        -- Seven segment output for the second digit
        );
	end component;

    -- Define signals used in architecture
   signal tx_data, rx_data : std_logic := '0';
	signal ss_input1, ss_input2, ss_output1, ss_output2: std_logic_vector(6 downto 0);
	signal sig_rx_data : std_logic_vector(7 downto 0);
	signal led_receive : std_logic;

-- Begin body of architecture
begin
    -- Instantiate UART component for transmission
   tx:UART port map (clk => clk,data_in => data_in,tx_enable => tx_enable,data_out => tx_data);
	
    -- Instantiate UART_REC component for reception
   rx:UART_REC port map (clk => clk,data_in => tx_data,rx_out => rx_data,data_out => sig_rx_data);
	
	-- Assign data output
	data_out <= sig_rx_data;
	
	-- Assign RX out signal
	rx_out <= rx_data;
	
	-- Instantiate seven_seg component for displaying input data
	displayInput:seven_seg port map (input=>data_in , seven_segment1=>ss_input1, seven_segment2=>ss_input2);
	
	-- Instantiate seven_seg component for displaying received data
   displayOutput:seven_seg port map (input=>sig_rx_data , seven_segment1=>ss_output1, seven_segment2=>ss_output2);
    
end rtl; -- End of architecture definition