library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dht_sensor is
    port (
        clk     					: in  std_logic;
		  rst		 					: in  std_logic;
		  start						: in  std_logic;
		  sensor_reading_async	: in std_logic;
		  sensor_writing  		: inout std_logic:='Z';
		  data_out					: out std_logic_vector(7 downto 0);
		  data_flag					: out std_logic
			);
end dht_sensor;

architecture rtl of dht_sensor is

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

component risingedge_detector is

port 
(
	clk		: in std_logic;
	rst		: in std_logic;
	input 	: in std_logic;
	output 	: out std_logic
);
end component; 

signal count      		: integer range 0 to 50000000 := 0;
type 	 state_type is (IDLE,S1,S2,S3,S4,S5,S6);
signal state 		 		: state_type:=IDLE;
signal data       		: std_logic_vector(39 downto 0):=(others=>'0');
signal bit_count  		: integer range -1 to 41 := 0;
signal sensor_falling 	: std_logic;
signal sensor_rising 	: std_logic;
signal sensor_reading	: std_logic; 
signal start_rising 	: std_logic;

begin

do_sync:sync port map(Clk=>Clk,Rst=>Rst,Async=>sensor_reading_async,Synced=>sensor_reading);

falling:fallingedge_detector port map(Clk=>clk,Rst=>rst,input=>sensor_reading,output=>sensor_falling);

rising:risingedge_detector port map(Clk=>clk,Rst=>rst,input=>sensor_reading,output=>sensor_rising);

rising_start:risingedge_detector port map(Clk=>clk,Rst=>rst,input=>start,output=>start_rising);


DHT_reading:process(clk,rst)
begin
    if rst='1' then
        sensor_writing<='Z';
		  data_out<=(others=>'0');
		  data<=(others=>'0');
		  data_flag<='0';
		  state<=IDLE;
		  bit_count<=0;
		  count<=0;
    elsif rising_edge(clk) then
        case state is

            when IDLE =>
				sensor_writing<='Z';
				data_flag<='0';
                if start_rising='1' then
						  count<=0;
						  state<=S1;
						  sensor_writing<='0';
                end if;

            when S1 =>
				 count<=count+1;
					if count=950000 then
						sensor_writing<='1';
						count<=0;
						state<=s2;
					end if;
					
            when S2 =>
				 count<=count+1;
					if count=1500 then
						count<=0;
						state<=s3;
						sensor_writing<='Z';
					end if;
           
            when S3 =>
				count<=count+1;
				if count>6000 then
					state<=IDLE;
				end if;
				 if sensor_rising='1' then
					if count>2000 then --normally 4000
						count<=0;
						state<=s4;
					else
						state<=IDLE;
					end if;
				  end if;
				  
				when S4 =>
				count<=count+1;
				if count>6000 then
					state<=IDLE;
				end if;
				 if sensor_reading='0' then 
					if count>2000 then --normally 4000
						count<=0;
						bit_count<=0;
						state<=s5;
					else
						state<=IDLE;
					end if;
				end if;	
								
           when S5 =>
                count<=count+1;
				if count>10000 then
					state<=IDLE;
				end if;
                if sensor_falling = '1' then
                    if count >=5000 and count<7000 then --bit addressing(normally 6000)
                        data(bit_count) <= '1';
                        count<=0;
                    elsif count<5000 and count>1000 then
                        data(bit_count) <= '0';
                        count<=0;
						  elsif count<=1000 then
								state<=s5;
								bit_count<=bit_count-1;
						  else
								state<=IDLE;
                    end if;
                    bit_count <= bit_count + 1;
                    if bit_count > 39 then
                        count<=0;
                        bit_count<=0;
                        state <= S6;
                    end if;
                end if;
					 
				when S6 =>
				if count>8000 then
					state<=IDLE;
				end if;
				if sensor_rising='1' then 
					 data_out(0)<=data(24);
					 data_out(1)<=data(23);
					 data_out(2)<=data(22);
					 data_out(3)<=data(21);
					 data_out(4)<=data(20);
					 data_out(5)<=data(19);
					 data_out(6)<=data(18);
					 data_out(7)<=data(17);
					 bit_count <= 0;
                count<=0;
					 data_flag<='1';
					 state <= IDLE;
				end if;

            -- Default Case
            when others =>
					 data_flag<='0';
					 state <= IDLE;
        end case;
    end if;
end process;

end rtl;

