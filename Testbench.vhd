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

    signal selectTBCmds_s   : std_logic := '1';

    signal ram_in_from_TB_s : RAM_IN    := RAM_IN_INITIALIZE;

begin

    clk_s <= not clk_s after 10 ns;

    mainControlTB : entity work.mainControl(RTL)
        port map (
            --Control I/O
                --Inputs
                clk => clk_s,
                enable_NTT => enable_NTT_s,
                reset_NTT => reset_NTT_s,
            --RAM I/O
                --Inputs
                selectTBCmds => selectTBCmds_s,
                ram_in_from_TB => ram_in_from_TB_s
        );

    stimulus: process begin

        --assign ram_in_from_TB_s write commands to fill RAM here
        wait for 40 ns;

        selectTBCmds_s <= '0';

        enable_NTT_s <= '1';
        reset_NTT_s <= '0';

        wait for 40 ns;

        enable_NTT_s <= '0';

        wait;

    end process stimulus;

end RTL;