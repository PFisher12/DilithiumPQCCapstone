library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tail_tb is
end tail_tb;

architecture Behavioral of tail_tb is

    -- Inputs
    signal coeff_in : std_logic_vector(31 downto 0);
    signal z_in     : std_logic_vector(31 downto 0);

    -- Outputs
    signal t0_out   : std_logic_vector(31 downto 0);
    signal t1_out   : std_logic_vector(31 downto 0);
    signal w1_out   : std_logic_vector(31 downto 0);
    signal hint_out : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    DUT: entity work.tail
        port map (
            coeff_in  => coeff_in,
            z_in      => z_in,
            t0_out    => t0_out,
            t1_out    => t1_out,
            w1_out    => w1_out,
            hint_out  => hint_out
        );

end Behavioral;
