--Testbench.vhd
--The purpose of this module is to stimulate the NTT by directly feeding it enable and select signals.
--Currently, it enables the NTT mode, waits for it to finish, then enables the INTT mode, and waits for it to finish
--Notes: The RAM values within mainControl have preallocated values within them, so they do not need to be written to beforehand
--This means the NTT is performed on RAM0 and the INTT is performed on RAM1. Both of which have the same starting values so the same input
--is fed to both in the C code for verification

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

entity testbench is
end testbench;

architecture RTL of testbench is

    --Signals to interact with mainControl
    signal clk_s    : std_logic := '0';
    signal enable_expand_s : std_logic := '0';
    signal expandMat_ready_s   : std_logic;
    
begin
    --Set the clock frequency
    clk_s <= not clk_s after 10 ns;

    --Port map the signals to main
    mainControlTB : entity work.mainControl(RTL)
        port map (
            --Control I/O
                --Inputs
                clk => clk_s,
                enable_expand => enable_expand_s,
                
                --Outputs
                expandMat_ready => expandMat_ready_s
        );

    --Testbench signals
    stimulus: process begin

        wait for 80 ns;
     
        enable_expand_s <= '1';             --Start expandMat
     
        wait for 80 ns;     
     
        enable_expand_s <= '0';             --Show it can handle enable being turned off midway through

        wait until expandMat_ready_s = '1';    --Wait until the expandMat finishes    

        wait for 80 ns;

        report "Sim Done" severity FAILURE;

        wait;

    end process stimulus;

end RTL;