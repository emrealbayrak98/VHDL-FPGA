library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA is 
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
	end entity;
	
	
architecture behavioral of VGA is 

    component mem_text is
        port (
            clk_clk                : in  std_logic                     := 'X';             -- clk
            reset_reset_n          : in  std_logic                     := 'X';             -- reset_n
            mem_text_clk1_clk      : in  std_logic                     := 'X';             -- clk
            mem_text_s1_address    : in  std_logic_vector(11 downto 0) := (others => 'X'); -- address
            mem_text_s1_clken      : in  std_logic                     := '0';             -- clken
            mem_text_s1_chipselect : in  std_logic                     := 'X';             -- chipselect
            mem_text_s1_write      : in  std_logic                     := 'X';             -- write
            mem_text_s1_readdata   : out std_logic_vector(7 downto 0);                     -- readdata
            mem_text_s1_writedata  : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- writedata
            mem_text_reset1_reset  : in  std_logic                     := 'X';             -- reset
            mem_text_s2_address    : in  std_logic_vector(11 downto 0) := (others => 'X'); -- address
            mem_text_s2_chipselect : in  std_logic                     := 'X';             -- chipselect
            mem_text_s2_clken      : in  std_logic                     := 'X';             -- clken
            mem_text_s2_write      : in  std_logic                     := 'X';             -- write
            mem_text_s2_readdata   : out std_logic_vector(7 downto 0);                     -- readdata
            mem_text_s2_writedata  : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- writedata
            mem_text_clk2_clk      : in  std_logic                     := 'X';             -- clk
            mem_text_reset2_reset  : in  std_logic                     := 'X'              -- reset
        );
    end component mem_text;
    component mem_font is
        port (
            mem_font_clk1_clk       : in  std_logic                     := 'X';             -- clk
            mem_font_reset1_reset   : in  std_logic                     := 'X';             -- reset
            mem_font_s1_address     : in  std_logic_vector(11 downto 0) := (others => 'X'); -- address
            mem_font_s1_debugaccess : in  std_logic                     := 'X';             -- debugaccess
            mem_font_s1_clken       : in  std_logic                     := 'X';             -- clken
            mem_font_s1_chipselect  : in  std_logic                     := 'X';             -- chipselect
            mem_font_s1_write       : in  std_logic                     := 'X';             -- write
            mem_font_s1_readdata    : out std_logic_vector(7 downto 0);                     -- readdata
            mem_font_s1_writedata   : in  std_logic_vector(7 downto 0)  := (others => 'X')  -- writedata
        );
    end component mem_font;

component vga80x40 is
  port (
    reset       : in  std_logic;
    clk25MHz    : in  std_logic;
    TEXT_A      : out std_logic_vector(11 downto 0); -- text buffer
    TEXT_D      : in  std_logic_vector(07 downto 0);
	 FONT_A      : out std_logic_vector(11 downto 0); -- font buffer
	 FONT_D      : in  std_logic_vector(07 downto 0);
	 --
	 ocrx        : in  std_logic_vector(07 downto 0); -- OUTPUT regs
    ocry        : in  std_logic_vector(07 downto 0);
    octl        : in  std_logic_vector(07 downto 0);
    --
    R           : out std_logic;
    G           : out std_logic;
    B           : out std_logic;
    hsync       : out std_logic;
    vsync       : out std_logic
    );   
end component;
    component pll is
        port (
            pll_0_outclk0_clk : out std_logic;        -- clk
            pll_0_refclk_clk  : in  std_logic := 'X'; -- clk
            pll_0_reset_reset : in  std_logic := 'X'  -- reset
        );
    end component pll;

  



signal text_address: std_logic_vector(11 downto 0);
signal font_address: std_logic_vector(11 downto 0);

signal text_data : std_logic_vector(7 downto 0);
signal font_data : std_logic_vector(7 downto 0);
signal data : std_logic_vector(7 downto 0);
signal counter   : integer range 0 to 2;
signal clk_25Mhz : std_logic;

constant temp_addr_1 : std_logic_vector(11 downto 0) := "000101001101";  -- Address for X
constant temp_addr_2 : std_logic_vector(11 downto 0) := "000101001110";  -- Address for X
constant mode_addr : std_logic_vector(11 downto 0):="000111101101";  -- Address for mode
constant fan_addr_1 : std_logic_vector(11 downto 0):="001010001110";
constant fan_addr_2 : std_logic_vector(11 downto 0):="001010001111";
constant fan_addr_3 : std_logic_vector(11 downto 0):="001010010000";
constant des_addr_1 : std_logic_vector(11 downto 0) := "000010101101";  -- Address for X
constant des_addr_2 : std_logic_vector(11 downto 0) := "000010101110";  -- Address for X

--signal temp   : std_logic_vector(7 downto 0) :="00011001";  -- Value of temp
signal temp_1 : std_logic_vector(7 downto 0) ;  -- Value of temp
signal temp_2 : std_logic_vector(7 downto 0) ;  -- Value of temp
signal mode   : std_logic_vector(7 downto 0) ;
--signal fan    : std_logic_vector(7 downto 0) :="01010101";  -- Value of mode
signal fan_1  : std_logic_vector(7 downto 0) ;  -- Value of mode
signal fan_1_temp  : std_logic_vector(7 downto 0) ;  -- Value of mode
signal fan_2_temp  : std_logic_vector(7 downto 0) ;  -- Value of mode
signal fan_2  : std_logic_vector(7 downto 0) ;  -- Value of mode
signal fan_3  : std_logic_vector(7 downto 0) ;  -- Value of mode
signal des_1 : std_logic_vector(7 downto 0) ;  -- Value of temp
signal des_2 : std_logic_vector(7 downto 0) ;  -- Value of temp

-- Signals for mem_text component
signal mem_text_s1_address : std_logic_vector(11 downto 0);
signal mem_text_s1_clken : std_logic := '0';
signal mem_text_s1_chipselect : std_logic;
signal mem_text_s1_write : std_logic;
signal mem_text_s1_readdata : std_logic_vector(7 downto 0);
signal mem_text_s1_writedata : std_logic_vector(7 downto 0);

type State_type is (WRITE_des_1, WRITE_des_2,WRITE_temp_1, WRITE_temp_2, WRITE_mode, WRITE_fan_1, WRITE_fan_2, WRITE_fan_3, IDLE);
signal State : State_type := IDLE;


begin
temp_1 <= std_logic_vector((unsigned(temp) / 10 + 48));
temp_2 <= std_logic_vector((unsigned(temp) mod 10 + 48));
des_1 <= std_logic_vector((unsigned(desired) / 10 + 48));
des_2 <= std_logic_vector((unsigned(desired) mod 10 + 48));
fan_1_temp <= std_logic_vector((unsigned(fan) / 100 + 48));
fan_2_temp <= std_logic_vector(((unsigned(fan) mod 100) / 10 + 48));
fan_3 <= std_logic_vector((unsigned(fan) mod 10 + 48));


with fan_1_temp select
        fan_1 <=
            "00100000" when "00110000",  -- 0
            fan_1_temp when others;  -- Default value for all other cases
				
with fan_2_temp select
        fan_2 <=
            "00100000" when "00110000" ,  -- 0
            fan_2_temp when others;  -- Default value for all other cases
				
with mode_temp select
        mode <=
            "00100010" when "10000000",  -- 0
				"00110000" when "00000000",  -- 0
				"00110001" when "00000001",  -- 0
				"00110010" when "00000010",  -- 0
				"00110011" when "00000011",  -- 0
            mode_temp when others;  -- Default value for all other cases

--process(fan_1)
--	begin
--		if(fan_1="00110000") then
--			fan_1_temp <= "00100000";
--		else
--			fan_1_temp <= fan_1;
--		end if;
--end process;

clk25Mhz <=clk_25Mhz;
u0 : component pll
	  port map (
			pll_0_outclk0_clk => clk_25Mhz, -- pll_0_outclk0.clk
			pll_0_refclk_clk  => clk_50Mhz,  --  pll_0_refclk.clk
			pll_0_reset_reset => reset  --   pll_0_reset.reset
	  );

v : vga80x40 port map (
    reset      => '0',
    clk25MHz   => clk_25Mhz,
    TEXT_A     => text_address,
    TEXT_D     => text_data,
	 FONT_A     => font_address,
	 FONT_D     => font_data,
	 --
	 ocrx       => "00000101",
    ocry       => "00000101",
    octl       => "10000111",
    --
    R          => R ,
    G          => G,
    B          => B,
    hsync      => hsync,
    vsync      => vsync
    );   

		 txt : component mem_text
        port map (
            clk_clk                => clk_50Mhz,                --             clk.clk
            reset_reset_n          => reset,          --           reset.reset_n
            mem_text_clk1_clk      => clk_50Mhz,      --   mem_text_clk1.clk
            mem_text_s1_address    => mem_text_s1_address,    --     mem_text_s1.address
            mem_text_s1_clken      => mem_text_s1_clken,      --                .clken
            mem_text_s1_chipselect => mem_text_s1_chipselect, --                .chipselect
            mem_text_s1_write      => mem_text_s1_write,      --                .write
            mem_text_s1_readdata   => mem_text_s1_readdata,   --                .readdata
            mem_text_s1_writedata  => mem_text_s1_writedata,  --                .writedata
            mem_text_reset1_reset  => reset,  -- mem_text_reset1.reset
            mem_text_s2_address    => text_address,    --     mem_text_s2.address
            mem_text_s2_chipselect => '1', --                .chipselect
            mem_text_s2_clken      => '1',      --                .clken
            mem_text_s2_write      => '0',      --                .write
            mem_text_s2_readdata   => text_data,   --                .readdata
            mem_text_s2_writedata  => (others =>'0'),  --                .writedata
            mem_text_clk2_clk      => clk_50Mhz,      --   mem_text_clk2.clk
            mem_text_reset2_reset  => reset   -- mem_text_reset2.reset
        );







    fnt : component mem_font
        port map (
            mem_font_clk1_clk       => clk_50Mhz,       --   mem_font_clk1.clk
            mem_font_reset1_reset   => '0',   -- mem_font_reset1.reset
            mem_font_s1_address     => font_address,     --     mem_font_s1.address
            mem_font_s1_debugaccess => '0', --                .debugaccess
            mem_font_s1_clken       => '1',       --                .clken
            mem_font_s1_chipselect  => '1',  --                .chipselect
            mem_font_s1_write       => '0',       --                .write
            mem_font_s1_readdata    => font_data,    --                .readdata
            mem_font_s1_writedata   => (others =>'0')    --                .writedata
        );


process (clk_50Mhz)
begin
    

    if rising_edge(clk_50Mhz) then
        case State is
		  
            when WRITE_des_1 =>
					 mem_text_s1_clken <= '1';
					 mem_text_s1_address <= des_addr_1;
					 mem_text_s1_writedata <= des_1;
                mem_text_s1_write <= '1';
                mem_text_s1_chipselect <= '1';

                State <= WRITE_des_2;
					 
            when WRITE_des_2 =>
					 mem_text_s1_clken <= '1';
					 mem_text_s1_address <= des_addr_2;
					 mem_text_s1_writedata <= des_2;
                mem_text_s1_write <= '1';
                mem_text_s1_chipselect <= '1';

                State <= WRITE_temp_1;
					 
            when WRITE_temp_1 =>
					 mem_text_s1_clken <= '1';
					 mem_text_s1_address <= temp_addr_1;
					 mem_text_s1_writedata <= temp_1;
                mem_text_s1_write <= '1';
                mem_text_s1_chipselect <= '1';

                State <= WRITE_temp_2;
					 
            when WRITE_temp_2 =>
					 mem_text_s1_clken <= '1';
					 mem_text_s1_address <= temp_addr_2;
					 mem_text_s1_writedata <= temp_2;
                mem_text_s1_write <= '1';
                mem_text_s1_chipselect <= '1';

                State <= WRITE_mode;					 

            when WRITE_mode =>
					 mem_text_s1_address <= mode_addr;
                mem_text_s1_writedata <= mode;
                mem_text_s1_write <= '1';
                mem_text_s1_chipselect <= '1';

                State <= WRITE_fan_1;
					 
            when WRITE_fan_1 =>
					 mem_text_s1_address <= fan_addr_1;
                mem_text_s1_writedata <= fan_1;
                mem_text_s1_write <= '1';
                mem_text_s1_chipselect <= '1';

                State <= WRITE_fan_2;
					 
            when WRITE_fan_2 =>
					 mem_text_s1_address <= fan_addr_2;
					 if fan_1="00110001" then
					 mem_text_s1_writedata <= "00110000";
					 else
                mem_text_s1_writedata <= fan_2;
					 end if;
                mem_text_s1_write <= '1';
                mem_text_s1_chipselect <= '1';

                State <= WRITE_fan_3;

            when WRITE_fan_3 =>
					 mem_text_s1_address <= fan_addr_3;
                mem_text_s1_writedata <= fan_3;
                mem_text_s1_write <= '1';
                mem_text_s1_chipselect <= '1';

                State <= IDLE;

					 
            when IDLE =>
					 mem_text_s1_write <= '0';
                mem_text_s1_chipselect <= '0';
					 mem_text_s1_clken <= '0';
					 
                State <= WRITE_des_1;

        end case;
    end if;
end process;

end behavioral;
