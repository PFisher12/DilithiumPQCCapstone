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

    rejtest : entity work.rej(RTL)
        port map (
            clk => clk,
            
            enable => enable,
            len => len,
            buflen => buflen,

            ready => ready
        );

    stimulus: process begin

        wait for 80 ns;

        enable <= '1';
        len <= x"0000000F";
        wait for 10 ns;
        enable <= '0';
        wait;

    end process stimulus;

end RTL;