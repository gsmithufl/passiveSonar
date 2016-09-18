library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO is
	port(
		clk              : in  std_logic;
		rst              : in  std_logic;
		ld_spi_stream    : in  std_logic;
		ld_parallel      : in  std_logic;
		data_received    : in  std_logic;
		input1           : in  std_logic_vector(15 downto 0);
		input2           : in  std_logic_vector(15 downto 0);
		input3           : in  std_logic_vector(15 downto 0);
		input4           : in  std_logic_vector(15 downto 0);
		data_good        : out std_logic := '0';
		pointer_conflict : out std_logic := '0';
		output           : out std_logic_vector(15 downto 0)
	);
end entity FIFO;

architecture RTL of FIFO is
	type mem is array (0 to 15) of std_logic_vector(15 downto 0);
	signal memory           : mem;
	constant MAX_ARRAY_SIZE : integer   := 15;
	signal input_pointer    : integer   := 0;
	signal output_pointer   : integer   := 0;
	signal data_good_temp   : std_logic := '0';
begin
	output <= (others => 'Z');

	process(clk, input_pointer, output_pointer, rst) is
	begin
		if abs (to_signed(input_pointer, 16) - to_signed(output_pointer, 16)) < 4 then
			pointer_conflict <= '1';
		else
			pointer_conflict <= '0';
		end if;

		if rst = '1' then
			--initialize array to 0
			for I in 0 to MAX_ARRAY_SIZE loop
				memory(I) <= x"0000";
			end loop;
			data_good        <= '0';
			output           <= (others => 'Z');
			input_pointer    <= 0;
			output_pointer   <= 0;
			pointer_conflict <= '0';

		elsif rising_edge(clk) then
			data_good <= '0';

			if ld_spi_stream = '1' then
				memory(input_pointer)     <= input1;
				memory(input_pointer + 1) <= input2;
				memory(input_pointer + 2) <= input3;
				memory(input_pointer + 3) <= input4;
				if input_pointer = MAX_ARRAY_SIZE - 3 then
					input_pointer <= 0;
				else
					input_pointer <= input_pointer + 4;
				end if;
			end if;

			if ld_parallel = '1' and data_good_temp = '0' then
				data_good_temp <= '1';
				data_good      <= '1';
				output         <= memory(output_pointer);
				if output_pointer = MAX_ARRAY_SIZE then
					output_pointer <= 0;
				else
					output_pointer <= output_pointer + 1;
				end if;
			elsif data_good_temp = '1' and data_received = '1' then
				data_good_temp <= '0';
				data_good      <= '0';
			end if;

		end if;
	end process;
end architecture RTL;