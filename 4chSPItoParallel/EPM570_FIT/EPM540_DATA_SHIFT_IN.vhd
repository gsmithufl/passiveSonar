library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EPM240_DATA_SHIFT_IN is
	port(
		spi_clk    : in  std_logic;
		rst        : in  std_logic;
		input1     : in  std_logic;
		input2     : in  std_logic;
		input3     : in  std_logic;
		input4     : in  std_logic;
		n_int      : in  std_logic;
		n_cs       : out std_logic;
		spi_clk_en : out std_logic;
		output1    : out std_logic_vector(15 downto 0);
		output2    : out std_logic_vector(15 downto 0);
		output3    : out std_logic_vector(15 downto 0);
		output4    : out std_logic_vector(15 downto 0)
	);
end EPM240_DATA_SHIFT_IN;

architecture RTL of EPM240_DATA_SHIFT_IN is
	signal combined_edge_detect : std_logic := '1';
begin
	combined_edge_detect <= not spi_clk or not n_int;

	process(combined_edge_detect, rst)
		variable counter   : integer := 0;
		variable temp_out1 : std_logic_vector(15 downto 0);
		variable temp_out2 : std_logic_vector(15 downto 0);
		variable temp_out3 : std_logic_vector(15 downto 0);
		variable temp_out4 : std_logic_vector(15 downto 0);
	begin
		if rst = '1' then
			output1    <= (others => 'Z');
			output2    <= (others => 'Z');
			output3    <= (others => 'Z');
			output4    <= (others => 'Z');
			n_cs       <= 'Z';
			spi_clk_en <= '0';

		elsif rising_edge(combined_edge_detect) then
			if n_int = '0' then
				spi_clk_en <= '1';
				n_cs       <= '0';

			elsif spi_clk = '0' then
				temp_out1    := std_logic_vector(shift_left(unsigned(temp_out1), 1));
				temp_out1(0) := input1;
				temp_out2    := std_logic_vector(shift_left(unsigned(temp_out2), 1));
				temp_out2(0) := input2;
				temp_out3    := std_logic_vector(shift_left(unsigned(temp_out3), 1));
				temp_out3(0) := input3;
				temp_out4    := std_logic_vector(shift_left(unsigned(temp_out4), 1));
				temp_out4(0) := input4;
				if counter = 15 then
					counter := 0;
					n_cs    <= '1';
					spi_clk_en <= '0';
					output1 <= temp_out1;
					output2 <= temp_out2;
					output3 <= temp_out3;
					output4 <= temp_out4;
				else
					counter := counter + 1;
				end if;
			end if;
		end if;
	end process;
end architecture RTL;