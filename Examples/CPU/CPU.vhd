library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity CPU is
    generic (N : integer := 3);
    port (
        A        		 : in  std_logic_vector(N downto 0);
        B         	 : in  std_logic_vector(N downto 0);
		  clock			 : in 	std_logic;
		  reset			 : in 	std_logic;
		  cin				 : in 	std_logic;
		  load_A			 : in 	std_logic;
		  load_B			 : in 	std_logic;
		  opcode			 : in  std_logic_vector(3 downto 0);
        sel       	 : in  std_logic;
		  A_out_ss      : out  std_logic_vector(6 downto 0);
		  B_out_ss      : out  std_logic_vector(6 downto 0);
		  ALU_out_ss    : out  std_logic_vector(6 downto 0)
    );
end entity;
architecture rtl of cpu is
component alu is
    generic (W : integer);
    port (
        A         : in  std_logic_vector(W downto 0);
        B         : in  std_logic_vector(W downto 0);
        sel       : in  std_logic_vector(3 downto 0);
		  cin			: in 	std_logic;
		  Y			: out std_logic_vector(3 downto 0)
    );
end component;
component mux2to1 is
    port (
        mux_input1         : in  std_logic_vector(3 downto 0);
        mux_input2         : in  std_logic_vector(3 downto 0);
        mux_sel       		: in  std_logic;
        mux_output			: out std_logic_vector(3 downto 0)        
    );
end component;
component seven_seg is
    port (
        input         : in  std_logic_vector(3 downto 0);
        seven_segment : out std_logic_vector(6 downto 0)        
    );
end component;
component clock_divider is
    port (
        clock_50MHZ         : in  std_logic;
        reset	         	 : in  std_logic;
        clock_05HZ			 : out std_logic        
    );
end component;
component reg is
    port (
        input         	: in  std_logic_vector(3 downto 0);
        reset	         : in  std_logic;
		  clock         	: in  std_logic;
		  enable         	: in  std_logic;
        output			 	: out std_logic_vector(3 downto 0)        
    );
end component;
signal A_out : std_logic_vector(3 downto 0);
signal B_out : std_logic_vector(3 downto 0);
signal ALU_out : std_logic_vector(3 downto 0);
signal MuxA_out : std_logic_vector(3 downto 0);
signal MuxB_out : std_logic_vector(3 downto 0);
signal clock_05HZ : std_logic;
signal regA_out : std_logic_vector(3 downto 0);
signal regB_out : std_logic_vector(3 downto 0);
begin
mux1:mux2to1 port map(mux_input1=>ALU_out,mux_input2=>A,mux_sel=>sel,mux_output=>MuxA_out);
mux2:mux2to1 port map(mux_input1=>ALU_out,mux_input2=>B,mux_sel=>sel,mux_output=>MuxB_out);
clkdiv:clock_divider port map(clock_50MHZ=>clock,reset=>reset,clock_05HZ=>clock_05HZ);
reg1:reg	port map(input=>MuxA_out,reset=>reset,clock=>clock_05HZ,enable=>load_A,output=>regA_out);
reg2:reg	port map(input=>MuxB_out,reset=>reset,clock=>clock_05HZ,enable=>load_B,output=>regB_out);
alu1:alu generic map(W=>N) port map(A=>regA_out,B=>regB_out,sel=>opcode,cin=>cin,Y=>ALU_out);
ledA:seven_seg port map(input=>A_out,seven_segment=>A_out_ss);
ledB:seven_seg port map(input=>B_out,seven_segment=>B_out_ss);
ledALU:seven_seg port map(input=>ALU_out,seven_segment=>ALU_out_ss);
A_out<=regA_out;
B_out<=regB_out;
end rtl;