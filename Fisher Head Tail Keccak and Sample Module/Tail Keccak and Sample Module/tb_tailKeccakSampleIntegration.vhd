library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_tailKeccakSampleIntegration is
end entity;

architecture behavior of tb_tailKeccakSampleIntegration is

    signal clk            : std_logic := '0';
    signal rst_n          : std_logic := '0';
    signal input_data     : std_logic_vector(31 downto 0) := (others => '0');
    signal input_valid    : std_logic := '0';
    signal sample_out     : std_logic_vector(7 downto 0); -- 8 bits now
    signal index_out      : integer range 0 to 255;       -- Integer output
    signal sample_valid   : std_logic;

begin

    -- Instantiate Unit Under Test (UUT)
    uut: entity work.tailKeccakSampleIntegration
        port map (
            clk          => clk,
            rst_n        => rst_n,
            input_data   => input_data,
            input_valid  => input_valid,
            sample_out   => sample_out,
            index_out    => index_out,
            sample_valid => sample_valid
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

        -- Wait for processing
        wait for 3000 ns;

        wait;
    end process;

end architecture;
