library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SRAM_INPUT is
	port(
		clk                  : in  std_logic;
		rst                  : in  std_logic;
		sonar_input_period   : in  std_logic;
		ld_spi_stream        : in  std_logic;
		input1               : in  std_logic_vector(15 downto 0);
		input2               : in  std_logic_vector(15 downto 0);
		input3               : in  std_logic_vector(15 downto 0);
		input4               : in  std_logic_vector(15 downto 0);
		n_we                 : out std_logic;
		n_ce                 : out std_logic;
		n_bhe                : out std_logic;
		n_ble                : out std_logic;
		n_oe                 : out std_logic;
		sonar_input_complete : out std_logic;
		address              : out std_logic_vector(17 downto 0);
		data                 : out std_logic_vector(15 downto 0)
	);
end entity SRAM_INPUT;

architecture RTL of SRAM_INPUT is
	constant MAX_COUNT : integer := 147; --one more than # of 1 waves datapoints
begin
	process(clk, rst) is
		variable counter            : integer := 0;
		variable data_hold_cntr     : integer := 0;
		variable data_array_pointer : integer := 0;
		type data_vect is array (0 to 3) of std_logic_vector(15 downto 0);
		variable data_array : data_vect;
	begin
		if rst = '1' then
			counter              := 0;
			n_we                 <= 'Z';
			n_ce                 <= 'Z';
			n_bhe                <= 'Z';
			n_ble                <= 'Z';
			n_oe                 <= 'Z';
			sonar_input_complete <= '0';
			address              <= (others => 'Z');
			data                 <= (others => 'Z');
		elsif rising_edge(clk) then
			sonar_input_complete <= '0';
			if sonar_input_period = '1' then
				if ld_spi_stream = '1' then
					data_array(0) := input1;
					data_array(1) := input2;
					data_array(2) := input3;
					data_array(3) := input4;
				end if;

				data_hold_cntr := data_hold_cntr + 1;

				if counter < MAX_COUNT then
					address <= (others => '0');
					n_ce    <= '0';
					n_we    <= '0';
					n_ble   <= '0';
					n_bhe   <= '0';
					if data_hold_cntr = 3 then --this is a delay to hold for sram
						data <= data_array(data_array_pointer); --keeps track of which input to output
						if data_array_pointer = 3 then
							data_array_pointer := 0;
						else
							data_array_pointer := data_array_pointer + 1;
						end if;
						data_hold_cntr := 0;
						counter        := counter + 1;
					end if;
				elsif counter = MAX_COUNT then
					counter              := 0;
					sonar_input_complete <= '1';
					n_we                 <= 'Z';
					n_ce                 <= 'Z';
					n_bhe                <= 'Z';
					n_ble                <= 'Z';
					n_oe                 <= 'Z';
					address              <= (others => 'Z');
					data                 <= (others => 'Z');
				end if;
			end if;
		end if;
	end process;
end architecture RTL;
