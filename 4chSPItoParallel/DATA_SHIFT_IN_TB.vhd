library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DATA_SHIFT_IN_TB is
end entity DATA_SHIFT_IN_TB;

architecture RTL of DATA_SHIFT_IN_TB is
	signal clk            : std_logic := '0';
	signal rst            : std_logic := '0';
	signal n_int          : std_logic := '1';
	signal n_cs           : std_logic;
	signal input1         : std_logic := '1';
	signal input2         : std_logic := 'Z';
	signal input3         : std_logic := 'Z';
	signal input4         : std_logic := 'Z';
	signal spi_clk        : std_logic;
	signal output1        : std_logic_vector(15 downto 0);
	signal output2        : std_logic_vector(15 downto 0);
	signal output3        : std_logic_vector(15 downto 0);
	signal output4        : std_logic_vector(15 downto 0);
	signal shift_complete : std_logic;

begin
	U_ENTITY : entity work.DATA_SHIFT_IN
		port map(
			input1         => input1,
			input2         => input2,
			input3         => input3,
			input4         => input4,
			sys_clk        => clk,
			rst            => rst,
			n_int          => n_int,
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
		n_int <= '0';
		wait until falling_edge(n_cs);
		wait for 1 ns;
		n_int <= '1';
		for I in 0 to 14 loop
			wait until rising_edge(spi_clk);
			input1 <= not input1;
		end loop;
		wait for 100 ns;
		n_int <= '0';
		wait until falling_edge(n_cs);
		wait for 1 ns;
		n_int <= '1';
		for I in 0 to 14 loop
			wait until rising_edge(spi_clk);
			input1 <= not input1;
		end loop;
		wait for 100 ns;
		assert false report "end of simulation" severity failure;
	end process U_TEST;

end architecture RTL;