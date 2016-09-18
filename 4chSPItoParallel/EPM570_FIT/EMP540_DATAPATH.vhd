library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EMP240_DATAPATH is
	port(
		clk      : in    std_logic;
		rst      : in    std_logic;
		input1   : in    std_logic;
		input2   : in    std_logic;
		input3   : in    std_logic;
		input4   : in    std_logic;
		mux_sel  : in    std_logic_vector(1 downto 0);
		n_int1   : in    std_logic;
		n_int2   : in    std_logic;
		n_int3   : in    std_logic;
		n_int4   : in    std_logic;
		n_cs1    : out   std_logic;
		n_cs2    : out   std_logic;
		n_cs3    : out   std_logic;
		n_cs4    : out   std_logic;
		spi_clk1 : out   std_logic;
		spi_clk2 : out   std_logic;
		spi_clk3 : out   std_logic;
		spi_clk4 : out   std_logic;
		spi_out1 : out   std_logic;
		spi_out2 : out   std_logic;
		spi_out3 : out   std_logic;
		spi_out4 : out   std_logic;
		output   : inout std_logic_vector(15 downto 0)
	);
end entity EMP240_DATAPATH;

architecture RTL of EMP240_DATAPATH is
	signal output1      : std_logic_vector(15 downto 0);
	signal output2      : std_logic_vector(15 downto 0);
	signal output3      : std_logic_vector(15 downto 0);
	signal output4      : std_logic_vector(15 downto 0);
	signal n_cs         : std_logic := '1';
	signal n_int        : std_logic := '1';
	signal spi_clk_en   : std_logic := '0';
	signal spi_clk_temp : std_logic;

begin
	process(rst, mux_sel, output1, output2, output3, output4) is
	begin
		if rst = '1' then
			--CPLD SPI output disabled in EMP240_DATA_SHIFT_IN
			n_cs1    <= output(15);     --here we assign processor input to ADC
			n_cs2    <= output(15);
			n_cs3    <= output(15);
			n_cs4    <= output(15);
			spi_clk1 <= output(14);
			spi_clk2 <= output(14);
			spi_clk3 <= output(14);
			spi_clk4 <= output(14);
			spi_out1 <= output(13);
			spi_out2 <= output(13);
			spi_out3 <= output(13);
			spi_out4 <= output(13);
		else
			n_int    <= n_int1 or n_int2 or n_int3 or n_int4;
			spi_clk1 <= spi_clk_temp;
			spi_clk2 <= spi_clk_temp;
			spi_clk3 <= spi_clk_temp;
			spi_clk4 <= spi_clk_temp;
			n_cs1    <= n_cs;
			n_cs2    <= n_cs;
			n_cs3    <= n_cs;
			n_cs4    <= n_cs;
			case mux_sel is
				when "00"   => output <= output1;
				when "01"   => output <= output2;
				when "10"   => output <= output3;
				when "11"   => output <= output4;
				when others => null;
			end case;
		end if;
	end process;

	SPI_CLK_inst : entity work.SPI_CLK
		generic map(
			CLK_DIVISION => 4
		)
		port map(
			clk     => clk,
			en      => spi_clk_en,
			spi_clk => spi_clk_temp
		);

	EPM240_DATA_SHIFT_IN_inst : entity work.EPM240_DATA_SHIFT_IN
		port map(
			spi_clk    => spi_clk_temp,
			rst        => rst,
			input1     => input1,
			input2     => input2,
			input3     => input3,
			input4     => input4,
			n_int      => n_int,
			n_cs       => n_cs,
			spi_clk_en => spi_clk_en,
			output1    => output1,
			output2    => output2,
			output3    => output3,
			output4    => output4
		);
end architecture RTL;
