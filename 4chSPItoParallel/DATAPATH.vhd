library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DATAPATH is
	port(
		clk                  : in  std_logic;
		rst                  : in  std_logic;

		--SPI
		n_int                : in  std_logic;
		input1               : in  std_logic;
		input2               : in  std_logic;
		input3               : in  std_logic;
		input4               : in  std_logic;
		spi_clk              : out std_logic;
		n_cs                 : out std_logic;
		output1              : out std_logic;
		output2              : out std_logic;
		output3              : out std_logic;
		output4              : out std_logic;

		--Parallel to DSP
		parallel_output      : out std_logic_vector(15 downto 0);

		--SRAM
		n_we                 : out std_logic;
		n_ce                 : out std_logic;
		n_bhe                : out std_logic;
		n_ble                : out std_logic;
		n_oe                 : out std_logic;
		sram_address         : out std_logic_vector(17 downto 0);
		sram_out_data        : out std_logic_vector(15 downto 0);

		--DSP CTRL
		ld_parallel          : in  std_logic;
		parallel_data_good   : out std_logic;
		data_received        : in  std_logic;
		pointer_conflict     : out std_logic;
		sonar_input_period   : in  std_logic; --time when cpld stores to sram (from DSP)
		sonar_input_complete : out std_logic --cpld notifies DSP sram storage complete
	);
end entity DATAPATH;

architecture RTL of DATAPATH is
	signal shift_out_start      : std_logic;
	signal shift_in_start       : std_logic;
	signal out_to_spi           : std_logic_vector(15 downto 0);
	signal data_shift_in_out1   : std_logic_vector(15 downto 0);
	signal data_shift_in_out2   : std_logic_vector(15 downto 0);
	signal data_shift_in_out3   : std_logic_vector(15 downto 0);
	signal data_shift_in_out4   : std_logic_vector(15 downto 0);
	signal n_cs_temp1           : std_logic;
	signal n_cs_temp2           : std_logic;
	signal spi_clk_temp1        : std_logic := '0';
	signal spi_clk_temp2        : std_logic := '0';
	signal d_in_shift_complete  : std_logic;
	signal d_out_shift_complete : std_logic;

begin
	n_cs    <= n_cs_temp1 and n_cs_temp2; --prevent chip select conflict
	spi_clk <= spi_clk_temp1 or spi_clk_temp2;

	U_SPI_CTRL : entity work.CONTROLLER_SPI
		port map(
			clk                  => clk,
			rst                  => rst,
			d_out_shift_complete => d_out_shift_complete,
			shift_out_start      => shift_out_start,
			shift_in_start       => shift_in_start,
			out_to_spi           => out_to_spi
		);

	U_DATA_SHIFT_IN : entity work.DATA_SHIFT_IN
		port map(
			input1         => input1,
			input2         => input2,
			input3         => input3,
			input4         => input4,
			sys_clk        => clk,
			rst            => rst,
			n_int          => n_int,
			shift_in_start => shift_in_start,
			spi_clk        => spi_clk_temp1,
			n_cs           => n_cs_temp2,
			output1        => data_shift_in_out1,
			output2        => data_shift_in_out2,
			output3        => data_shift_in_out3,
			output4        => data_shift_in_out4,
			shift_complete => d_in_shift_complete
		);
	U_DATA_SHIFT_OUT : entity work.DATA_SHIFT_OUT
		port map(
			input          => out_to_spi,
			sys_clk        => clk,
			rst            => rst,
			shift_start    => shift_out_start,
			spi_clk        => spi_clk_temp2,
			n_cs           => n_cs_temp1,
			output1        => output1,
			output2        => output2,
			output3        => output3,
			output4        => output4,
			shift_complete => d_out_shift_complete
		);

	U_FIFO : entity work.FIFO
		port map(
			clk              => clk,
			rst              => rst,
			ld_spi_stream    => d_in_shift_complete,
			ld_parallel      => ld_parallel,
			data_received    => data_received,
			input1           => data_shift_in_out1,
			input2           => data_shift_in_out2,
			input3           => data_shift_in_out3,
			input4           => data_shift_in_out4,
			data_good        => parallel_data_good,
			pointer_conflict => pointer_conflict,
			output           => parallel_output
		);

	U_SRAM : entity work.SRAM_INPUT
		port map(
			clk                  => clk,
			rst                  => rst,
			sonar_input_period   => sonar_input_period,
			ld_spi_stream        => d_in_shift_complete,
			input1               => data_shift_in_out1,
			input2               => data_shift_in_out2,
			input3               => data_shift_in_out3,
			input4               => data_shift_in_out4,
			n_we                 => n_we,
			n_ce                 => n_ce,
			n_bhe                => n_bhe,
			n_ble                => n_ble,
			n_oe                 => n_oe,
			sonar_input_complete => sonar_input_complete,
			address              => sram_address,
			data                 => sram_out_data
		);

end architecture RTL;
