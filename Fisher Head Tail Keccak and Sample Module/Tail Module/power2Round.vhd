library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.globalVars.all;

-----------------------------------------------------------------------------
-- Combinational Power2Round
-- a = a1 * 2^D + a0, with -2^{D-1} < a0 <= 2^{D-1}
-----------------------------------------------------------------------------

entity power2round is
  port(
    a_in : in  std_logic_vector(31 downto 0);
    a0   : out std_logic_vector(31 downto 0);
    a1   : out std_logic_vector(31 downto 0)
  );
end power2round;

architecture Behavioral of power2round is
  signal a_int    : integer;
  signal highbits : integer;
  signal lowbits  : integer;
begin

  a_int    <= to_integer(signed(a_in));
  highbits <= (a_int + 2**(D - 1)) / (2**D);
  lowbits  <= a_int - highbits * (2**D);

  a0 <= std_logic_vector(to_signed(lowbits, 32));
  a1 <= std_logic_vector(to_signed(highbits, 32));

end Behavioral;
