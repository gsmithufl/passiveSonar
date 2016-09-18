library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CONTROLLER_SPI is
	port(
		clk                  : in  std_logic;
		rst                  : in  std_logic;
		d_out_shift_complete : in  std_logic;
		shift_out_start      : out std_logic;
		shift_in_start       : out std_logic;
		out_to_spi           : out std_logic_vector(15 downto 0)
	);
end entity CONTROLLER_SPI;

architecture RTL of CONTROLLER_SPI is
	type ASM_state is (INIT, START_CONFIG_ADC, WAIT_CONFIG_ADC, ADC_SPI_TRANSFER);
	signal state : ASM_state;
begin
	process(clk, rst) is
	begin
		if rst = '1' then
			shift_out_start <= '0';
			shift_in_start  <= '0';
			state           <= INIT;
		elsif rising_edge(clk) then
			case state is
				when INIT =>
					state <= START_CONFIG_ADC;
				when START_CONFIG_ADC =>
					shift_out_start <= '1';
					out_to_spi      <= "1110110110111101"; -- see p31 ADS8327
					state           <= WAIT_CONFIG_ADC;
				when WAIT_CONFIG_ADC =>
					if d_out_shift_complete = '1' then
						shift_out_start <= '0';
						state           <= ADC_SPI_TRANSFER;
					else
						state <= WAIT_CONFIG_ADC;
					end if;
				when ADC_SPI_TRANSFER =>
					shift_in_start <= '1';
					state          <= ADC_SPI_TRANSFER;
			end case;
		end if;
	end process;
end architecture RTL;
