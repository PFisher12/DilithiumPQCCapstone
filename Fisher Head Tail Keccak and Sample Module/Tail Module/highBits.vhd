library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
Use work.globalVars.all;

------------------------------------------------------------------------------
-- HighBits Entity
-- Inputs:
-- 	r1 and r0
-- Outputs:
-- 	r1

--     r_mod := r mod+ Q
--     r0    := centered remainder of r_mod modulo ALPHA (ALPHA = 2*GAMMA2)
--     if (r_mod - r0) = Q - 1 then
--         r1 := 0
--     else
--         r1 := (r_mod - r0) / ALPHA
--
-- The output r1 is returned as a 23-bit unsigned value.
------------------------------------------------------------------------------

entity highBits is
  Port (
    r_in   : in  std_logic_vector(31 downto 0);
    r1_out : out std_logic_vector(31 downto 0)
  );
end highBits;

architecture Behavioral of highBits is

  signal r_int, r_mod_q, r0_int, r1_int : integer;

begin
  process(r_in)
  begin
    r_int <= to_integer(unsigned(r_in));

    -- mod+ Q
    r_mod_q <= r_int mod Q;
    if r_mod_q < 0 then
      r_mod_q <= r_mod_q + Q;
    end if;

    -- mod± ALPHA
    r0_int <= r_mod_q mod ALPHA;
    if r0_int > HALF_ALPHA then
      r0_int <= r0_int - ALPHA;
    end if;

    -- Compute high bits (r1)
    if (r_mod_q - r0_int = Q - 1) then
      r1_int <= 0;
    else
      r1_int <= (r_mod_q - r0_int) / ALPHA;
    end if;

    r1_out <= std_logic_vector(to_unsigned(r1_int, 32));
  end process;

end Behavioral;
