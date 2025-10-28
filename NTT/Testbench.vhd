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
    signal enable_NTT_s : std_logic := '0';
    signal NTT_INTT_Select_s : std_logic := '0';
    signal ntt_ready_s   : std_logic;
    signal ramSelect_s : std_logic_vector (2 downto 0) := "000";

begin
    --Set the clock frequency
    clk_s <= not clk_s after 10 ns;

    --Port map the signals to main
    mainControlTB : entity work.mainControl(RTL)
        port map (
            --Control I/O
                --Inputs
                clk => clk_s,
                enable_NTT => enable_NTT_s,
                NTT_INTT_Select => NTT_INTT_Select_s,
                ramSelect => ramSelect_s,
                --Outputs
                ntt_ready => ntt_ready_s
        );

    --Testbench signals
    stimulus: process begin

        wait for 80 ns;
     
        NTT_INTT_Select_s <= '0';        --Select the NTT
        enable_NTT_s <= '1';             --Start the NTT
     
        wait for 80 ns;     
     
        enable_NTT_s <= '0';             --Show it can handle enable being turned off midway through

        NTT_INTT_Select_s <= '1';        --Select the INTT

        wait until ntt_ready_s = '1';    --Wait until the NTT finishes    

        wait for 80 ns;

        ramSelect_s <= "001";             --Select the second RAM to perform INTT on

        wait for 80 ns;

        enable_NTT_s <= '1';             --Start the INTT
            
        wait for 80 ns;       
    
        enable_NTT_s <= '0';             --Let it run to completion

        wait;

    end process stimulus;

end RTL;