library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.globalVars.all;

entity useHint is
  port(
    r_in        : in  std_logic_vector(31 downto 0);
    hint        : in  std_logic;
    usehint_out : out std_logic_vector(31 downto 0)
  );
end useHint;

architecture Behavioral of useHint is
  signal r_int  : integer;
  signal r_mod  : integer;
begin

  -- Convert and reduce input
  r_int <= to_integer(unsigned(r_in));
  r_mod <= (r_int mod Q + Q) mod Q;

  process(r_mod, hint)
    variable r0     : integer;
    variable r1     : integer;
    variable result : integer;
  begin
    -- Centered mod
    r0 := (r_mod + ALPHA / 2) mod ALPHA - ALPHA / 2;

    -- Decompose logic
    if (r_mod - r0 = Q - 1) then
      r1 := 0;
      r0 := r0 - 1;
    else
      r1 := (r_mod - r0) / ALPHA;
    end if;

    -- Apply hint logic
    if hint = '0' then
      result := r1;
    elsif r0 > 0 then
      result := r1 + 1;
    else
      result := r1 - 1;
    end if;

    usehint_out <= std_logic_vector(to_signed(result, 32));
  end process;

end Behavioral;
