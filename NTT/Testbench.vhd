library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--Write data to RAM manually?

entity testbench is

end testbench;

architecture RTL of testbench is

    signal clk_s    : std_logic := '0';

    signal enable_NTT_s : std_logic := '0';
    signal reset_NTT_s  : std_logic := '1';
    signal NTT_INTT_Select_s : std_logic := '0';
    signal ntt_ready_s   : std_logic;

    signal selectTBCmds_s   : std_logic := '1';

    signal ram_in_from_TB_s : RAM_IN    := RAM_IN_INITIALIZE;

    signal ramSelect_s : std_logic_vector (1 downto 0) := "00";

begin

    clk_s <= not clk_s after 10 ns;

    mainControlTB : entity work.mainControl(RTL)
        port map (
            --Control I/O
                --Inputs
                clk => clk_s,
                enable_NTT => enable_NTT_s,
                reset_NTT => reset_NTT_s,
                NTT_INTT_Select => NTT_INTT_Select_s,
                ramSelect => ramSelect_s,
                --Outputs
                ntt_ready => ntt_ready_s,
            --RAM I/O
                --Inputs
                selectTBCmds => selectTBCmds_s,
                ram_in_from_TB => ram_in_from_TB_s
        );

    stimulus: process begin

        wait for 80 ns;

        selectTBCmds_s <= '0';           --Previous Commands if needed
     
        NTT_INTT_Select_s <= '0';        --Select the NTT
        reset_NTT_s <= '0';     
        enable_NTT_s <= '1';             --Start the NTT
     
        wait for 80 ns;     
     
        enable_NTT_s <= '0';             --Show it can handle enable being turned off midway through

        NTT_INTT_Select_s <= '1';        --Select the INTT

        wait until ntt_ready_s = '1';    --Wait until the NTT finishes    

        wait for 80 ns;

        ramSelect_s <= "01";             --Select the second RAM to perform INTT on

        wait for 80 ns;

        enable_NTT_s <= '1';             --Start the INTT
            
        wait for 80 ns;       
    
        enable_NTT_s <= '0';             --Show it can handle enable being turned off midway through

        wait;

    end process stimulus;

end RTL;