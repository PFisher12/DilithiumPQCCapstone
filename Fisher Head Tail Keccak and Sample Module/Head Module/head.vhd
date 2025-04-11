library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity head is
  generic (
    N : integer := 256
  );
  Port (
    -- Inputs
    cIn     : in  std_logic_vector(24*N-1 downto 0);
    s1In    : in  std_logic_vector(24*N-1 downto 0);
    s2In    : in  std_logic_vector(24*N-1 downto 0);
    t0In    : in  std_logic_vector(24*N-1 downto 0);
    yIn     : in  std_logic_vector(24*N-1 downto 0);

    -- Outputs
    zOut    : out std_logic_vector(24*N-1 downto 0);
    wOut    : out std_logic_vector(24*N-1 downto 0);
    ct0Out  : out std_logic_vector(24*N-1 downto 0)
  );
end head;

architecture Behavioral of head is

  subtype coeff is std_logic_vector(23 downto 0);
  type coeff_array is array (0 to 255) of coeff;

  function montgomery_mul(a, b: coeff) return coeff is
    variable a_int : integer := to_integer(unsigned(a));
    variable b_int : integer := to_integer(unsigned(b));
    variable q     : integer := 8380417;
    variable res   : integer;
  begin
    res := (a_int * b_int) mod q;
    return std_logic_vector(to_unsigned(res, 24));
  end;

  function add_mod_q(a, b: coeff) return coeff is
    variable a_int : integer := to_integer(unsigned(a));
    variable b_int : integer := to_integer(unsigned(b));
    variable q     : integer := 8380417;
    variable res   : integer := (a_int + b_int) mod q;
  begin
    return std_logic_vector(to_unsigned(res, 24));
  end;

begin
  process(cIn, s1In, s2In, t0In, yIn)
    variable c_arr, s1_arr, s2_arr, t0_arr, y_arr : coeff_array;
    variable z_arr, w_arr, ct0_arr : coeff_array;
  begin
    -- Unpack inputs
    for i in 0 to N-1 loop
      c_arr(i)   := cIn((i+1)*24-1 downto i*24);
      s1_arr(i)  := s1In((i+1)*24-1 downto i*24);
      s2_arr(i)  := s2In((i+1)*24-1 downto i*24);
      t0_arr(i)  := t0In((i+1)*24-1 downto i*24);
      y_arr(i)   := yIn((i+1)*24-1 downto i*24);
    end loop;

    -- Perform computation
    for i in 0 to N-1 loop
      z_arr(i)   := add_mod_q(y_arr(i), montgomery_mul(c_arr(i), s1_arr(i)));
      w_arr(i)   := montgomery_mul(c_arr(i), s2_arr(i));
      ct0_arr(i) := montgomery_mul(c_arr(i), t0_arr(i));
    end loop;

    -- Pack outputs
    for i in 0 to N-1 loop
      zOut((i+1)*24-1 downto i*24)   <= z_arr(i);
      wOut((i+1)*24-1 downto i*24)   <= w_arr(i);
      ct0Out((i+1)*24-1 downto i*24) <= ct0_arr(i);
    end loop;
  end process;

end Behavioral;