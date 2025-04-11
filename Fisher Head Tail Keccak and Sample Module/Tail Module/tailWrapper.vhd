library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.globalVars.all;
use work.bram_types.all;

entity tailWrapper is
    Port (
        clk     : in  std_logic;
        rst     : in  std_logic;

        -- Input BRAM-style arrays
        inputCoeff : in  ram32_array;
        inputZ     : in  ram32_array;

        -- Output BRAM-style arrays
        outputT0   : out ram32_array;
        outputT1   : out ram32_array;
        outputW1   : out ram32_array;
        outputHint : out hint_array
    );
end tailWrapper;

architecture Behavioral of tailWrapper is

    -- Use correct N explicitly
    constant N_val : integer := work.globalVars.N;

    signal index       : integer range 0 to N_val;
    signal workingT0   : ram32_array := (others => (others => '0'));
    signal workingT1   : ram32_array := (others => (others => '0'));
    signal workingW1   : ram32_array := (others => (others => '0'));
    signal workingHint : hint_array := (others => '0');

    signal coeff_reg, z_reg : std_logic_vector(31 downto 0);
    signal done : boolean := false;

    -- Tail module outputs
    signal t0_sig   : std_logic_vector(31 downto 0);
    signal t1_sig   : std_logic_vector(31 downto 0);
    signal w1_sig   : std_logic_vector(31 downto 0);
    signal hint_sig : std_logic;

begin

    -- Register input values from BRAM arrays
    coeff_reg <= inputCoeff(index);
    z_reg     <= inputZ(index);

    tail_inst: entity work.tail
        port map (
            coeff_in => coeff_reg,
            z_in     => z_reg,
            t0_out   => t0_sig,
            t1_out   => t1_sig,
            w1_out   => w1_sig,
            hint_out => hint_sig
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                index <= 0;
                workingT0 <= (others => (others => '0'));
                workingT1 <= (others => (others => '0'));
                workingW1 <= (others => (others => '0'));
                workingHint <= (others => '0');
                done <= false;
            elsif not done then
                workingT0(index)   <= t0_sig;
                workingT1(index)   <= t1_sig;
                workingW1(index)   <= w1_sig;
                workingHint(index) <= hint_sig;

                if index = N_val - 1 then
                    done <= true;
                else
                    index <= index + 1;
                end if;
            end if;
        end if;
    end process;

    -- Drive outputs
    outputT0   <= workingT0;
    outputT1   <= workingT1;
    outputW1   <= workingW1;
    outputHint <= workingHint;

end Behavioral;
