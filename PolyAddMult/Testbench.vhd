library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--Write data to RAM manually?

entity testbench is

end testbench;

architecture RTL of testbench is

    signal clk_s    : std_logic := '0';
    signal enable_Module_s : std_logic := '0';
    signal Add_Mult_Select_s : std_logic := '0';
    signal Module_ready_s   : std_logic;
    signal RamCSelect_s   : std_logic_vector(2 downto 0) := "010";

begin

    clk_s <= not clk_s after 10 ns;

    mainControlTB : entity work.mainControl(RTL)
        port map (
            --Control I/O
                --Inputs
                clk             => clk_s,
                enable          => enable_Module_s,
                AddMultSelect   => Add_Mult_Select_s,
                RamCSelect      => RamCSelect_s,
                --Outputs
                ready           => Module_ready_s
        );

    stimulus: process begin

        wait for 80 ns;
     
        Add_Mult_Select_s <= '0';
        enable_Module_s <= '1';
     
        wait for 80 ns;     
     
        enable_Module_s <= '0';

        Add_Mult_Select_s <= '1';

        wait until Module_ready_s = '1';

        RamCSelect_s <= "011";

        wait for 80 ns;

        enable_Module_s <= '1';
            
        wait for 80 ns;       
    
        enable_Module_s <= '0';

        wait until Module_ready_s = '1';

        wait for 80 ns;       
        
        report "Sim Done" severity FAILURE;

        wait;

    end process stimulus;

end RTL;