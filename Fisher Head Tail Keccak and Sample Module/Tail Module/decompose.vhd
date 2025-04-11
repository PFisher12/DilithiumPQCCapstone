library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.globalVars.all;

------------------------------------------------------------------------------
-- Decompose(r) : Returns (r1, r0) such that:
-- r1 = (r - r0) / ALPHA, where r0 is centered mod of r mod Q
-- Special case: if (r - r0) = Q - 1 then r1 := 0 and r0 := r0 - 1
------------------------------------------------------------------------------

entity decompose is
  port (
    r   : in  std_logic_vector(31 downto 0);
    a0  : out std_logic_vector(31 downto 0); -- low
    a1  : out std_logic_vector(31 downto 0)  -- high
  );
end decompose;

architecture Behavioral of decompose is

  signal r_int     : integer;
  signal r_mod_q   : integer;
  signal r0, r1    : integer;

begin

  -- Convert input and reduce modulo Q
  r_int    <= to_integer(signed(r));
  r_mod_q  <= (r_int mod Q + Q) mod Q;

  -- Centered low bits
  r0 <= (r_mod_q + ALPHA / 2) mod ALPHA - ALPHA / 2;

  -- Compute high bits (with special case)
  process(r_mod_q, r0)
    variable r1_var : integer;
    variable r0_adj : integer := r0;
  begin
    if (r_mod_q - r0 = Q - 1) then
      r1_var := 0;
      r0_adj := r0 - 1;
    else
      r1_var := (r_mod_q - r0) / ALPHA;
    end if;

    a0 <= std_logic_vector(to_signed(r0_adj, 32));
    a1 <= std_logic_vector(to_signed(r1_var, 32));
  end process;

end Behavioral;
