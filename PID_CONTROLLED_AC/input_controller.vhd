library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity input_controller is

port
(
	clk						: in std_logic;
	rst						: in std_logic; --sw9
	rx_pin					: in std_logic; --gpio 5
	ir_pin					: in std_logic; --ir_pin
	sensor_reading_async	: in std_logic; --gpio1
	sensor_writing			: inout std_logic; --gpio3
	pwm_out_pin				: out std_logic;	--led0 PIN_V17 --gpio7 aj19
	ir_received				: out std_logic;	--led9
	uart_received			: out std_logic;	--led8
	sensor_received		: out std_logic;	--led7
	seven_segment1			: out std_logic_vector(6 downto 0);	--hex1
	seven_segment2			: out std_logic_vector(6 downto 0); --hex0
	seven_segment3			: out std_logic_vector(6 downto 0); --hex3
	seven_segment4			: out std_logic_vector(6 downto 0); --hex2
	seven_segment5			: out std_logic_vector(6 downto 0); --hex5
	seven_segment6			: out std_logic_vector(6 downto 0);  --hex4
	
	
	----------------vga outputs-------------------------
	R           : out std_logic;
	G           : out std_logic;
	B           : out std_logic;
	hsync       : out std_logic;
	clk25Mhz    : out std_logic;
	blank       : out std_logic:='1';
	sync        : out std_logic:='1';
	rr          : out std_logic_vector(6 downto 0):=(others =>'0');
	gg          : out std_logic_vector(6 downto 0):=(others =>'0');
	bb          : out std_logic_vector(6 downto 0):=(others =>'0');
	vsync       : out std_logic
);

end entity;

architecture rtl of input_controller is

---------------------components--------------------------------------------
component VGA is 
	port(
	   clk_50Mhz   : in std_logic;
		reset       : in  std_logic;
	   R           : out std_logic;
      G           : out std_logic;
      B           : out std_logic;
      hsync       : out std_logic;
		clk25Mhz    : out std_logic;
		blank       : out std_logic:='1';
		sync        : out std_logic:='1';
		rr          : out std_logic_vector(6 downto 0):=(others =>'0');
		gg          : out std_logic_vector(6 downto 0):=(others =>'0');
		bb          : out std_logic_vector(6 downto 0):=(others =>'0');
      vsync       : out std_logic;
		temp        : in std_logic_vector(7 downto 0);
		mode_temp   : in std_logic_vector(7 downto 0);
		fan         : in std_logic_vector(7 downto 0);
		desired     : in std_logic_vector(7 downto 0)
	
	);
	end component;


component seven_seg is
    port (
        input          : in  std_logic_vector(7 downto 0);   -- 8-bit binary input
        seven_segment1 : out std_logic_vector(6 downto 0);  -- First 7-segment display output
        seven_segment2 : out std_logic_vector(6 downto 0)   -- Second 7-segment display output     
    );
end component;
component receiver is

generic
(
	 number_of_baud   	 : integer:=10;
    system_clock       	 : integer:=50000000;
    baud_rate            : integer:=115200
);
port
(
	Clk 	: in std_logic;
	Rst 	: in std_logic;
	Din 	: in std_logic;
	Dout	: out std_logic_vector(number_of_baud-3 downto 0);
	Ready : out std_logic
);
end component;

component pwm is
generic(
clockfreq 	: integer := 50000000;
pwmfreq  	: integer :=10000
);

port ( 
		  clk 	: in std_logic;
        rst 	: in std_logic;
        duty 	: in std_logic_vector(4 downto 0);
        pwmout	: out std_logic
);
end component;

component pid_controller is
    port (
        clk 	  		: in std_logic;
        reset 	  		: in std_logic;
		  desired  		: in std_logic_vector(7 downto 0);
        measured 		: in std_logic_vector(7 downto 0); 
        output_pwm 	: out std_logic_vector(4 downto 0)
    );
end component;

component ir_receiver is
    port (
        clk     			: in  std_logic;
        ir_in_async		: in  std_logic;
		  rst		 			: in  std_logic;
        data_out			: out std_logic_vector(7 downto 0);
		  IRF					: out std_logic 
			);
end component;

component dht_sensor is
    port (
        clk     					: in  std_logic;
		  rst		 					: in  std_logic;
		  start						: in  std_logic;
		  sensor_reading_async	: in std_logic;
		  sensor_writing  		: inout std_logic:='Z';
		  data_out					: out std_logic_vector(7 downto 0);
		  data_flag					: out std_logic
			);
end component;

component risingedge_detector is

port 
(
	clk		: in std_logic;
	rst		: in std_logic;
	input 	: in std_logic;
	output 	: out std_logic
);
end component;

--------------------components-----------------------------------------------



-------------------signal definitions------------------------------------------
signal count_for_ir		: integer range 0 to 50000001:=0;
signal count_for_uart	: integer range 0 to 50000001:=0;
signal count_for_sensor	: integer range 0 to 15000001:=0;
signal count				: integer range 0 to 75000001:=0;
signal temp_temp			: integer range 0 to 60:=0;
signal temp_temp_2		: integer range 0 to 60:=0;
signal command 			: std_logic_vector(7 downto 0);
signal actual_measured_temp 		: std_logic_vector(7 downto 0); --vga temp
signal pid_selector 	: std_logic;
signal mod2_selector : std_logic;
signal mod3_selector : std_logic;
signal mod_kapat 		: std_logic;
signal pid_out			: std_logic_vector(4 downto 0);
signal desired_temp 	: integer range 17 to 31:=20;
signal fan				: integer range 0 to 22:=11;
signal mod_select_hex: std_logic_vector(7 downto 0);
signal ir_command 	: std_logic_vector(7 downto 0);
signal uart_command 	: std_logic_vector(7 downto 0);
signal command_start : std_logic;
signal ir_interrupt 	: std_logic;
signal uart_interrupt: std_logic;
signal measured_temp : std_logic_vector(7 downto 0);
signal dht_start		: std_logic;
signal pwm_in			: std_logic_vector(4 downto 0);
signal dht_interrupt	: std_logic;
signal pid_desired  	: std_logic_vector(7 downto 0);
signal command_start_rising : std_logic;
signal mod_vga	: std_logic_vector(7 downto 0);		--vga mod
signal pwm_info : std_logic_vector(7 downto 0); -- vga fan
signal temp_pwm : integer range 0 to 101:=0;
signal pwm_info_int : integer range 0 to 23:=0;

-----------------signal definitions-------------------------------------------------

begin


command_start<=ir_interrupt or uart_interrupt;

uart:receiver generic map(number_of_baud=>10,system_clock=>50000000,baud_rate=>115200) port map(clk=>clk,rst=>rst,din=>rx_pin,dout=>uart_command,ready=>uart_interrupt);

wireless:ir_receiver port map(clk=>clk,ir_in_async=>ir_pin,rst=>rst,data_out=>ir_command,IRF=>ir_interrupt);

sensor:dht_sensor port map(clk=>clk,rst=>rst,start=>dht_start,sensor_reading_async=>sensor_reading_async,sensor_writing=>sensor_writing,data_out=>measured_temp,data_flag=>dht_interrupt);

fan_control:pwm generic map(clockfreq=>50000000, pwmfreq=>10000) port map(clk=>clk,rst=>rst,duty=>pwm_in,pwmout=>pwm_out_pin);

pid_control:pid_controller port map(clk=>dht_interrupt,reset=>pid_selector,desired=>pid_desired,measured=>actual_measured_temp,output_pwm=>pid_out);

rising_edge_detect:risingedge_detector port map(clk=>clk,rst=>rst,input=>command_start,output=>command_start_rising);

pid_desired<=std_logic_vector(to_unsigned(desired_temp, 8));

temp_temp <=to_integer(unsigned(measured_temp));

temp_temp_2<=temp_temp-3;

actual_measured_temp<=std_logic_vector(to_unsigned(temp_temp_2, 8));

pwm_info_int<=to_integer(unsigned(pwm_in));

temp_pwm<=pwm_info_int*5;

pwm_info<=std_logic_vector(to_unsigned(temp_pwm, 8));

pwm_info_hex:seven_seg port map(input=>pwm_info,seven_segment1=>seven_segment1,seven_segment2=>seven_segment2);

--desired_temp_hex:seven_seg port map(input=>pid_desired,seven_segment1=>seven_segment1,seven_segment2=>seven_segment2);

measured_temp_hex:seven_seg port map(input=>actual_measured_temp,seven_segment1=>seven_segment3,seven_segment2=>seven_segment4);

mod_hex:seven_seg	port map(input=>mod_select_hex,seven_segment1=>seven_segment5,seven_segment2=>seven_segment6);

mod_select_hex<="0000"&mod_kapat&mod3_selector&mod2_selector&pid_selector;

take_input:process(clk,rst)

begin
	if rst='1' then
			
			command<="11111111";
			
	elsif rising_edge(clk) then

		if ir_interrupt='1' then
			
			command<=ir_command;
		
		end if;
		
		if uart_interrupt='1' then
		
			command<=uart_command;
		
		end if;
	end if;
end process;


generate_output:process(clk,rst)

begin
	if rst='1' then
	
			pwm_in<="00000";
			mod_vga<="10000000";
	
	elsif rising_edge(clk) then
		
		if pid_selector='1' then
			
			pwm_in<=pid_out;
			mod_vga<="00000001";
		
		
		elsif mod2_selector='1' then
		
			pwm_in<="00101"; 
			mod_vga<="00000010";
		
		
		elsif mod3_selector='1' then
		
			pwm_in<="10100"; 
			mod_vga<="00000011";
		
		
		elsif mod_kapat='1' then
			
			pwm_in<=std_logic_vector(to_unsigned(fan, 5));
			mod_vga<="00000000";
		else 
			mod_vga<="10000000";
			pwm_in<="00000";
		
		end if;
	
	end if;
end process;


process_command:process(clk,rst)

begin
	if rst='1' then

			pid_selector<='0';
			mod2_selector<='0';
			mod3_selector<='0';
			mod_kapat<='0';
			desired_temp<=20;
			fan<=10;
		
	elsif rising_edge(clk) then
	
		if command_start_rising='1' then
		
			if command="00101101" then  -- * command close system
				
				pid_selector<='0';
				mod2_selector<='0';
				mod3_selector<='0';
				mod_kapat<='0';
				
			
			elsif command="00110011" then -- 0 command close mods
			
				pid_selector<='0';
				mod2_selector<='0';
				mod3_selector<='0';
				mod_kapat<='1';			
			
			elsif command="10001011" then  --1 command open pid
				
				pid_selector<='1';
				mod2_selector<='0';
				mod3_selector<='0';
				mod_kapat<='0';
			
			elsif command="10001101" then  --2 command open mod2
			
				pid_selector<='0';
				mod2_selector<='1';
				mod3_selector<='0';
				mod_kapat<='0';

			elsif command="10001111" then  --3 command open mod3
				
				pid_selector<='0';
				mod2_selector<='0';
				mod3_selector<='1';
				mod_kapat<='0';
			
			elsif command="00110001" then  --up command 
			
				if pid_selector='1' then
				
					desired_temp<=desired_temp+1;
						if desired_temp>30 then
							desired_temp<=30;
						end if;
				
				elsif mod_kapat='1' then
					
					fan<=fan+1;

					if fan=20 then
							fan<=0;
					end if;
				end if;
			
			elsif command="10100101" then  -- down command
			
				if pid_selector='1' then
				
					desired_temp<=desired_temp-1;
					
						if desired_temp<18 then
							desired_temp<=18;
						end if;
				
				
				elsif mod_kapat='1' then
					
					fan<=fan-1;
						if fan=0 then
							fan<=20;
						end if;
				end if;		
			
			end if;
		end if;
	end if;
end process;

generate_clk_dht:process(rst,clk)
begin
	if rst='1' then
		count<=0;
		dht_start<='0';
	elsif rising_edge(clk) then
		dht_start<='0';
		count<=count+1;
			if count= 75000000 then
				dht_start<='1';
				count<=0;
			end if;
	end if;
end process;


receiving_leds:process(rst,clk)
begin
	if rst='1' then
	
		count_for_ir<=0;
		count_for_uart<=0;
		count_for_sensor<=0;
		ir_received<='0';
		uart_received<='0';
		sensor_received<='0';
		
	elsif rising_edge(clk) then
		
		count_for_ir<=count_for_ir+1;
		count_for_uart<=count_for_uart+1;
		count_for_sensor<=count_for_sensor+1;
		
		if ir_interrupt='1' then
		
			ir_received<='1';
		
			count_for_ir<=0;
		
		end if;
		
		if uart_interrupt='1' then
		
			uart_received<='1';
		
			count_for_uart<=0;
		
		end if;
		
		if dht_interrupt='1' then

			sensor_received<='1';
		
			count_for_sensor<=0;
		
		end if;
		
		if count_for_ir=50000000 then
		
			ir_received<='0';
		
		end if;
		
		if count_for_uart=50000000 then
		
			uart_received<='0';
		
		end if;
		
		if count_for_sensor=15000000 then
		
			sensor_received<='0';
		
		end if;
	end if;
end process;



---------------------------------------------VGA inst----------------------------------


vga_inst:VGA port map(
	   clk_50Mhz   =>clk,
		reset       =>rst,
	   R           =>R,           -----------outputs---------------
      G           =>G,
      B           =>B,
      hsync       =>hsync,
		clk25Mhz    =>clk25Mhz,
		blank       =>blank,
		sync        =>sync,
		rr          =>rr,
		gg          =>gg,
		bb          =>bb,
      vsync       =>vsync,   -----------------outputs--------------
		temp        =>actual_measured_temp,
		mode_temp   =>mod_vga,
		fan        	=>pwm_info,
		desired     =>pid_desired
	
);























end rtl;	