library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.globalVars.all;
use work.bram_types.all;

entity tailWrapper_tb is
end tailWrapper_tb;

architecture Behavioral of tailWrapper_tb is

    constant N_val : integer := work.globalVars.N;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    -- Simulated BRAM arrays
    signal inputCoeff  : ram32_array := (others => (others => '0'));
    signal inputZ      : ram32_array := (others => (others => '0'));
    signal outputT0    : ram32_array;
    signal outputT1    : ram32_array;
    signal outputW1    : ram32_array;
    signal outputHint  : hint_array;

begin

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- DUT instance
    DUT: entity work.tailWrapper
        port map (
            clk         => clk,
            rst         => rst,
            inputCoeff  => inputCoeff,
            inputZ      => inputZ,
            outputT0    => outputT0,
            outputT1    => outputT1,
            outputW1    => outputW1,
            outputHint  => outputHint
        );

    -- Stimulus
    stim_proc: process
    begin
        wait for 25 ns;
        rst <= '0';

        -- Inject test data
        inputCoeff(0) <= std_logic_vector(to_signed(100000, 32));
        inputZ(0)     <= std_logic_vector(to_signed(1000000, 32));

        inputCoeff(1) <= std_logic_vector(to_signed(100000, 32));
        inputZ(1)     <= std_logic_vector(to_signed(523792, 32));

        inputCoeff(2) <= std_logic_vector(to_signed(1000000, 32));
        inputZ(2)     <= std_logic_vector(to_signed(200000, 32));

        inputCoeff(3) <= std_logic_vector(to_signed(0, 32));
        inputZ(3)     <= std_logic_vector(to_signed(800000, 32));

        inputCoeff(4) <= std_logic_vector(to_signed(400000, 32));
        inputZ(4)     <= std_logic_vector(to_signed(439843, 32));

        -- Optional: fill rest with zeros
        for i in 5 to N_val - 1 loop
            inputCoeff(i) <= (others => '0');
            inputZ(i)     <= (others => '0');
        end loop;

        -- Let simulation run long enough for full processing
        wait for 6000 ns;
        wait;
    end process;

end Behavioral;
