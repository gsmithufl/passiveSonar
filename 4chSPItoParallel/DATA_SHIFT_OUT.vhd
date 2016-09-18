library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DATA_SHIFT_OUT is
	port(
		input          : in  std_logic_vector(15 downto 0);
		sys_clk        : in  std_logic;
		rst            : in  std_logic;
		shift_start    : in  std_logic;
		spi_clk        : out std_logic;
		n_cs           : out std_logic;
		output1        : out std_logic;
		output2        : out std_logic;
		output3        : out std_logic;
		output4        : out std_logic;
		shift_complete : out std_logic
	);
end DATA_SHIFT_OUT;

architecture RTL of DATA_SHIFT_OUT is
begin
	process(sys_clk, rst)
		variable counter    : integer                       := 0;
		variable spi_cntr   : integer                       := 0;
		variable good_input : std_logic_vector(15 downto 0) := x"0000";
	begin
		if rst = '1' then
			output1        <= 'Z';
			output2        <= 'Z';
			output3        <= 'Z';
			output4        <= 'Z';
			counter        := 0;
			n_cs           <= '1';
			shift_complete <= '0';
			good_input     := (others => 'Z');
		elsif rising_edge(sys_clk) then
			if shift_start = '1' then
				spi_cntr := spi_cntr + 1;
				if spi_cntr = 1 then
					spi_clk <= '1';
				elsif spi_cntr = 3 then
					spi_clk <= '0';
				elsif spi_cntr = 4 then
					spi_clk  <= '0';
					spi_cntr := 0;
				end if;

				n_cs <= '0';

				if counter = 0 and spi_cntr = 1 then
					counter    := 1;
					good_input := input;
					output1    <= good_input(15);
					output2    <= good_input(15);
					output3    <= good_input(15);
					output4    <= good_input(15);
				elsif counter <= 15 and counter > 0 and spi_cntr = 1 then
					counter    := counter + 1;
					good_input := std_logic_vector(shift_left(unsigned(good_input), 1));
					output1    <= good_input(15);
					output2    <= good_input(15);
					output3    <= good_input(15);
					output4    <= good_input(15);
				elsif counter = 16 then
					counter        := counter + 1;
					shift_complete <= '1';
				elsif counter = 17 then
					shift_complete <= '0';
					spi_cntr       := 0;
					spi_clk        <= '0';
					counter        := 17;
					n_cs           <= '1';
				end if;
			end if;
		end if;
	end process;
end architecture RTL;