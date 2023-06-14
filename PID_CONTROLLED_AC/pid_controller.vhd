library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity pid_controller is
    port (
        clk 	  		: in std_logic;
        reset 	  		: in std_logic;
		  desired  		: in std_logic_vector(7 downto 0);
        measured 		: in std_logic_vector(7 downto 0); 
        output_pwm 	: out std_logic_vector(4 downto 0)
    );
end PID_Controller;

architecture Behavioral of pid_controller is

    -- PID constants
    constant Kp : signed(15 downto 0) := to_signed(700, 16);  -- Proportional gain
    constant Ki : signed(15 downto 0) := to_signed(600, 16);  -- Integral gain
    constant Kd : signed(15 downto 0) := to_signed(300, 16);  -- Derivative gain

    -- Internal signals
    signal integral 		: signed(15 downto 0) 	:= (others => '0'); -- 32 bit signed
    signal derivative 	: signed(15 downto 0) 	:= (others => '0'); -- 32 bit signed
    signal prev_error 	: signed(15 downto 0) 	:= (others => '0'); -- 16 bit signed
    signal pwm 			: signed(31 downto 0) 	:= (others => '0'); -- 16 bit signed
	 signal error_in     : signed(15 downto 0)   := (others => '0'); -- 16 bit signed
	 signal measured_int : signed(15 downto 0)	:= (others => '0');
	 signal desired_int 	: signed(15 downto 0)	:= (others => '0');
	 signal pwm_int 		: integer range -2147483647 to 2147483647:=0;
    signal integral_temp 		: signed(15 downto 0) 	:= (others => '0'); -- 32 bit signed

begin


desired_int<="00000000"& signed(desired);

measured_int<="00000000"& signed(measured);

error_in<=measured_int-desired_int;

process(clk,reset)

 begin
	 if reset = '0' then
		 integral <= (others => '0');
		 derivative <= (others => '0');
		 prev_error <= (others => '0');
		 pwm <= (others => '0');
    elsif rising_edge(clk) then
		
		integral_temp<=integral;
		
		-- Update integral and derivative
		 if integral>32000 then
		 
			if error_in>=0 then
				
				integral<=integral_temp;
				
			else
				integral<=integral + error_in;
			
			end if;
			
		 else
			
			integral <= integral + error_in;
		 
		 end if;
		 
		 derivative <= error_in - prev_error;
		 
		 -- Update PID controller output
		 pwm <= Ki*integral(15 downto 0) + Kp*error_in + Kd*derivative(15 downto 0);
		 
		 pwm_int<= to_integer(signed(pwm));

		 -- Update previous error
		 prev_error <= error_in;
    end if;
 end process;

output_pwm  <= "00000" when pwm_int>=-2147483647 and pwm<-293803 else

					"00001" when pwm_int>=-293803 and pwm_int<-262876 else

					"00010" when pwm_int>=-262876 and pwm_int<-231949 else

					"00011" when pwm_int>=-231949 and pwm_int<-201022 else

					"00100" when pwm_int>=-201022 and pwm_int<-170095 else

					"00101" when pwm_int>=-170095 and pwm_int<-139168 else

					"00110" when pwm_int>=-139168 and pwm_int<-108241 else

					"00111" when pwm_int>=-108241 and pwm_int<-77314 else

					"01000" when pwm_int>=-77314 and pwm_int<-46387 else

					"01001" when pwm_int>=-46387 and pwm_int<-15460 else

					"01010" when pwm_int>=-15460 and pwm_int<15467 else

					"01011" when pwm_int>=15467 and pwm_int<46394 else

					"01100" when pwm_int>=46394 and pwm_int<77321 else

					"01101" when pwm_int>=77321 and pwm_int<108241 else

					"01110" when pwm_int>=108241 and pwm_int<139168 else

					"01111" when pwm_int>=139168 and pwm_int<170095 else

					"10000" when pwm_int>=170095 and pwm_int<201022 else

					"10001" when pwm_int>=201022 and pwm_int<231949 else

					"10010" when pwm_int>=231949 and pwm<262876 else

					"10011" when pwm>=262876 and pwm<293803 else

					"10100" when pwm>=293803 and pwm<324730 else 
					
					"10100";

end Behavioral;
