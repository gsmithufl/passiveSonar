library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DATA_SHIFT_OUT_TB is
end entity DATA_SHIFT_OUT_TB;

architecture RTL of DATA_SHIFT_OUT_TB is
	signal clk            : std_logic := '0';
	signal rst            : std_logic := '0';
	signal n_cs           : std_logic;
	signal input          : std_logic_vector(15 downto 0);
	signal spi_clk        : std_logic;
	signal output1        : std_logic;
	signal output2        : std_logic;
	signal output3        : std_logic;
	signal output4        : std_logic;
	signal shift_start : std_logic;
	signal shift_complete : std_logic;

begin
	U_ENTITY : entity work.DATA_SHIFT_OUT
		port map(
			input          => input,
			sys_clk        => clk,
			rst            => rst,
			shift_start    => shift_start,
			spi_clk        => spi_clk,
			n_cs           => n_cs,
			output1        => output1,
			output2        => output2,
			output3        => output3,
			output4        => output4,
			shift_complete => shift_complete
		);

	clk <= not clk after 5 ns;

	U_TEST : process is
	begin
		wait for 10 ns;
		rst <= '1';
		wait for 20 ns;
		rst <= '0';
		wait for 15 ns;
		shift_start <= '1';
		input <= "1110110110111101";
		wait until rising_edge(shift_complete);
		wait until rising_edge(clk);
		shift_start <= '0';
		wait for 50 ns;
		assert false report "end of simulation" severity failure;
	end process U_TEST;

end architecture RTL;