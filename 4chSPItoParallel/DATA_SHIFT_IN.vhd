library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DATA_SHIFT_IN is
	port(
		input1         : in  std_logic;
		input2         : in  std_logic;
		input3         : in  std_logic;
		input4         : in  std_logic;
		sys_clk        : in  std_logic;
		rst            : in  std_logic;
		n_int          : in  std_logic;
		shift_in_start : in  std_logic;
		spi_clk        : out std_logic := '0';
		n_cs           : out std_logic;
		output1        : out std_logic_vector(15 downto 0);
		output2        : out std_logic_vector(15 downto 0);
		output3        : out std_logic_vector(15 downto 0);
		output4        : out std_logic_vector(15 downto 0);
		shift_complete : out std_logic
	);
end DATA_SHIFT_IN;

architecture RTL of DATA_SHIFT_IN is
	signal combined_edge_detect : std_logic := '0';
begin
	combined_edge_detect <= sys_clk or not n_int;

	process(combined_edge_detect, rst)
		variable counter          : integer                       := 0;
		variable conversion_start : std_logic                     := '0';
		variable spi_cntr         : integer                       := 0;
		variable temp_output1     : std_logic_vector(15 downto 0) := x"0000";
		variable temp_output2     : std_logic_vector(15 downto 0) := x"0000";
		variable temp_output3     : std_logic_vector(15 downto 0) := x"0000";
		variable temp_output4     : std_logic_vector(15 downto 0) := x"0000";
	begin
		if rst = '1' then
			output1          <= (others => 'Z');
			output2          <= (others => 'Z');
			output3          <= (others => 'Z');
			output4          <= (others => 'Z');
			counter          := 0;
			conversion_start := '0';
			n_cs             <= '1';
			spi_cntr         := 0;
			spi_clk          <= '0';
			shift_complete   <= '0';

		elsif rising_edge(combined_edge_detect) then
			if shift_in_start = '1' then
				if n_int = '0' then
					conversion_start := '1';
					n_cs             <= '0';

				elsif sys_clk = '1' and conversion_start = '1' then
					n_cs     <= '0';
					--divide sys_clk by four
					spi_cntr := spi_cntr + 1;
					if spi_cntr = 1 then
						spi_clk <= '1';
					elsif spi_cntr = 3 then
						spi_clk <= '0';
					elsif spi_cntr = 4 then
						spi_clk  <= '0';
						spi_cntr := 0;
					end if;

					if counter = 0 and spi_cntr = 3 then
						counter         := 1;
						temp_output1(0) := input1;
						output1         <= temp_output1;
						temp_output2(0) := input2;
						output2         <= temp_output2;
						temp_output3(0) := input3;
						output3         <= temp_output3;
						temp_output4(0) := input4;
						output4         <= temp_output4;

					elsif counter <= 15 and counter > 0 and spi_cntr = 3 then
						if counter = 15 then
							shift_complete <= '1';
						end if;

						counter := counter + 1;

						temp_Output1    := std_logic_vector(shift_left(unsigned(temp_output1), 1));
						temp_output1(0) := input1;
						output1         <= temp_output1;
						temp_output2    := std_logic_vector(shift_left(unsigned(temp_output2), 1));
						temp_output2(0) := input2;
						output2         <= temp_output2;
						temp_output3    := std_logic_vector(shift_left(unsigned(temp_output3), 1));
						temp_output3(0) := input3;
						output3         <= temp_output3;
						temp_output4    := std_logic_vector(shift_left(unsigned(temp_output4), 1));
						temp_output4(0) := input4;
						output4         <= temp_output4;

					elsif counter = 16 then
						counter        := counter + 1;
						shift_complete <= '0';

					elsif counter = 17 then
						counter          := 0;
						conversion_start := '0';
						n_cs             <= '1';
						spi_cntr         := 0;
						spi_clk          <= '0';
						temp_output1     := (others => '0');
						temp_output2     := (others => '0');
						temp_output3     := (others => '0');
						temp_output4     := (others => '0');
						output1          <= (others => 'Z');
						output2          <= (others => 'Z');
						output3          <= (others => 'Z');
						output4          <= (others => 'Z');

					end if;

				end if;

			end if;

		end if;

	end process;
end architecture RTL;