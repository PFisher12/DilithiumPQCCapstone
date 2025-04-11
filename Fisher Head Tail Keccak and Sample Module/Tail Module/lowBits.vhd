library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
Use work.globalVars.all;

------------------------------------------------------------------------------
-- LowBits Entity
-- Inputs:
-- 	r1 and r0
-- Outputs:
-- 	r0

--     r_mod := r mod+ Q
--     r0    := centered remainder of r_mod modulo ALPHA (ALPHA = 2*GAMMA2)
--     if (r_mod - r0) = Q - 1 then
--         r0 := r0 - 1  -- adjust in the border case
--     else
--         r0 remains as computed
--
-- The output r0 is returned as a 23-bit unsigned value.
------------------------------------------------------------------------------

entity lowBits is
  Port (
    r_in   : in  std_logic_vector(31 downto 0);
    r0_out : out std_logic_vector(31 downto 0)
  );
end lowBits;

architecture Behavioral of lowBits is
  signal r_int, r_mod_q, r0_int : integer;

begin
  process(r_in)
  begin
    r_int <= to_integer(unsigned(r_in));

    -- Step 1: mod+ Q
    r_mod_q <= r_int mod Q;
    if r_mod_q < 0 then
      r_mod_q <= r_mod_q + Q;
    end if;

    -- Step 2: mod± ALPHA (centered mod)
    r0_int <= r_mod_q mod ALPHA;
    if r0_int > HALF_ALPHA then
      r0_int <= r0_int - ALPHA;
    end if;

    -- Step 3: border case correction
    if (r_mod_q - r0_int = Q - 1) then
      r0_int <= r0_int - 1;
    end if;

    -- Output result
    r0_out <= std_logic_vector(to_unsigned(r0_int, 32));
  end process;

end Behavioral;