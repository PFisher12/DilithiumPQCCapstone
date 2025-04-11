library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.globalVars.all;

entity makeHint is
  port (
    r_in     : in  std_logic_vector(31 downto 0);
    z_in     : in  std_logic_vector(31 downto 0);
    hint_out : out std_logic
  );
end makeHint;

architecture Behavioral of makeHint is

  signal r_int, z_int, sum_int        : integer;
  signal r_mod_q, sum_mod_q           : integer;
  signal r0, sum_r0                   : integer;
  signal r1, sum_r1                   : integer;

begin

  r_int    <= to_integer(signed(r_in));
  z_int    <= to_integer(signed(z_in));
  sum_int  <= r_int + z_int;

  r_mod_q   <= (r_int mod Q + Q) mod Q;
  sum_mod_q <= (sum_int mod Q + Q) mod Q;

  r0      <= (r_mod_q + ALPHA / 2) mod ALPHA - ALPHA / 2;
  sum_r0  <= (sum_mod_q + ALPHA / 2) mod ALPHA - ALPHA / 2;

  process(r_mod_q, r0, sum_mod_q, sum_r0)
    variable r1_var     : integer;
    variable sum_r1_var : integer;
  begin
    if (r_mod_q - r0 = Q - 1) then
      r1_var := 0;
    else
      r1_var := (r_mod_q - r0) / ALPHA;
    end if;

    if (sum_mod_q - sum_r0 = Q - 1) then
      sum_r1_var := 0;
    else
      sum_r1_var := (sum_mod_q - sum_r0) / ALPHA;
    end if;

    r1     <= r1_var;
    sum_r1 <= sum_r1_var;
  end process;

  hint_out <= '1' when r1 /= sum_r1 else '0';

end Behavioral;
