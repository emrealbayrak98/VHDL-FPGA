library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pwm is
generic(
clockfreq : integer := 50000000;
pwmfreq  : integer :=10000
);

port ( 
      clk : in std_logic;
        rst : in std_logic;
        duty : in std_logic_vector(4 downto 0);
        pwmout: out std_logic
);
end pwm;

architecture rtl of pwm is

constant limit : integer := clockfreq/pwmfreq - 2000;
signal counter : integer range 0 to limit := 0;
signal poweroffan : integer range 0 to limit+2000 := 0;
signal initial : integer range 0 to 31 :=0;

begin

process(clk,rst) 

variable check : integer := 0;

begin

    if rst='1' then
        pwmout <= '0'; 
        poweroffan<=0;
    elsif (rising_edge(clk)) then

        check := initial;
        initial <= CONV_INTEGER(duty);

             if(initial=0) then
				    poweroffan <= 0;
				 
				 elsif(initial > 20) then
                poweroffan <= limit-1 + 2000; 
             else
                poweroffan <= initial*limit/20 + 2000; 
             end if;

             if(initial /= check) then
                counter <= 0;
             end if;

             if(counter = limit-1 + 2000) then
                pwmout <= '0';
                counter <= 0;
             elsif(counter < poweroffan) then
                pwmout <= '1';
                counter <= counter+1;
             else
                pwmout <= '0'; 
                counter <= counter+1;
             end if;
  end if;

end process;

end rtl;