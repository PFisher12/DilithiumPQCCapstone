library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_tailKeccakIntegration is
end entity;

architecture behavior of tb_tailKeccakIntegration is

    signal clk          : std_logic := '0';
    signal rst_n        : std_logic := '0';
    signal input_data   : std_logic_vector(31 downto 0) := (others => '0');
    signal input_valid  : std_logic := '0';
    signal output_data  : std_logic_vector(63 downto 0);
    signal output_valid : std_logic;

begin

    uut: entity work.tailKeccakIntegration
        port map (
            clk          => clk,
            rst_n        => rst_n,
            input_data   => input_data,
            input_valid  => input_valid,
            output_data  => output_data,
            output_valid => output_valid
        );

    -- Clock generation
    clk <= not clk after 5 ns;

    -- Stimulus process
    process
    begin
        -- Reset
        rst_n <= '0';
        wait for 20 ns;
        rst_n <= '1';
        wait for 20 ns;

        -- Send one coefficient into Tail
        input_data <= X"00123456"; -- Example input
        input_valid <= '1';
        wait for 10 ns; -- one clock pulse
        input_valid <= '0';

        -- Wait for everything to finish
        wait for 3000 ns;

        wait;
    end process;

end architecture;
