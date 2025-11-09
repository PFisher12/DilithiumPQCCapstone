library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--Write data to RAM manually?

entity testbench is

end testbench;

architecture RTL of testbench is
    signal clk, enable, ready : std_logic := '0';
    signal len, buflen : unsigned(31 downto 0) := (others => '0');

begin

    clk <= not clk after 10 ns;

    main : entity work.mainControl(RTL)
        port map (
            clk => clk,
            
            enable => enable,
            len => len,
            buflen => buflen,

            ready => ready
        );

    stimulus: process begin

        len <= x"00000100"; --256
        buflen <= x"00000110"; --272

        wait for 80 ns;

        enable <= '1';

        wait for 80 ns;  

        enable <= '0';

        wait until ready = '1';

        wait for 80 ns;       
        
        report "Sim Done" severity FAILURE;

        wait;

    end process stimulus;

end RTL;