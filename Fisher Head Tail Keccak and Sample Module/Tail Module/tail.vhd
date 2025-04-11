library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.globalVars.all;

---------------------------------------------------------------------------------------------
-- Combinational Tail Module
-- Connects: power2Round, decompose, and makeHint
-- Inputs: coeff_in, z_in
-- Outputs: t0_out, t1_out, w1_out, hint_out
---------------------------------------------------------------------------------------------

entity tail is
    Port (
        coeff_in  : in  std_logic_vector(31 downto 0);  -- input for power2Round
        z_in      : in  std_logic_vector(31 downto 0);  -- input for decompose

        t0_out    : out std_logic_vector(31 downto 0);  -- low bits of coeff_in (a0)
        t1_out    : out std_logic_vector(31 downto 0);  -- high bits of coeff_in (a1)
        w1_out    : out std_logic_vector(31 downto 0);  -- high bits of z_in
        hint_out  : out std_logic                       -- whether a0 ≠ z0
    );
end tail;

architecture Behavioral of tail is

    signal a0, a1 : std_logic_vector(31 downto 0);  -- from power2Round
    signal z0, z1 : std_logic_vector(31 downto 0);  -- from decompose
    signal hint   : std_logic;

begin

    -- Power2Round: coeff_in → (a0, a1)
    power2round_inst: entity work.power2Round
        port map (
            a_in => coeff_in,
            a0   => a0,
            a1   => a1
        );

    -- Decompose: z_in → (z0, z1)
    decompose_inst: entity work.decompose
        port map (
            r   => z_in,
            a0  => z0,
            a1  => z1
        );

    -- MakeHint: compare z0 vs a0
    makehint_inst: entity work.makeHint
        port map (
            r_in     => z0,
            z_in     => a0,
            hint_out => hint
        );

    -- Output wiring
    t0_out   <= a0;
    t1_out   <= a1;
    w1_out   <= z1;
    hint_out <= hint;

end Behavioral;
