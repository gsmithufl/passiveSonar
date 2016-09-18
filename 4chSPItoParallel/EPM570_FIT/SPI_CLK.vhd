library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI_CLK is
	generic(CLK_DIVISION : integer := 4);
	port(
		clk     : in  std_logic;
		en      : in  std_logic;
		spi_clk : out std_logic
	);
end entity SPI_CLK;

architecture RTL of SPI_CLK is
begin
	process(clk, en) is
		variable counter : integer := 0;
	begin
		if en = '0' then
			spi_clk <= 'Z';
			counter := 0;
		elsif rising_edge(clk) then
			counter := counter + 1;
			if counter = 1 then
				spi_clk <= '1';
			elsif counter = (CLK_DIVISION / 2 + 1) then
				spi_clk <= '0';
			elsif counter = CLK_DIVISION then
				counter := 0;
			end if;

		end if;
	end process;

end architecture RTL;
