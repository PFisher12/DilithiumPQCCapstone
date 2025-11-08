-- ==========================================================
-- polyveck_freeze.vhd
-- Reduce coefficients of polynomials in a vector (length K)
-- to their canonical representatives mod Q.
-- ==========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity polyveck_freeze is
  generic (
    K : integer := 4;
    N : integer := 256;
    Q : integer := 8380417
  );
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    start   : in  std_logic;
    done    : out std_logic;

    v_in  : in  std_logic_vector(K*N*32 - 1 downto 0);
    v_out : out std_logic_vector(K*N*32 - 1 downto 0)
  );
end entity polyveck_freeze;

architecture rtl of polyveck_freeze is

  type state_type is (IDLE, WORK, DONE_STATE);

  signal state : state_type := IDLE;
  signal idx   : integer range 0 to K*N := 0;

  function freeze_mod_q(a : integer; q : integer) return integer is
    variable r : integer;
  begin
    r := a mod q;
    if r < 0 then
      r := r + q;
    end if;
    return r;
  end function;

begin

  process(clk, rst_n)
    variable a, reduced : integer;
  begin
    if rst_n = '0' then
      state <= IDLE;
      idx   <= 0;
      done  <= '0';
      v_out <= (others => '0');

    elsif rising_edge(clk) then
      case state is

        when IDLE =>
          done <= '0';
          if start = '1' then
            idx   <= 0;
            state <= WORK;
          end if;

        when WORK =>
          -- Extract 32-bit coefficient from vector
          a := to_integer(signed(v_in(32*(idx+1)-1 downto 32*idx)));

          -- reduction
          reduced := freeze_mod_q(a, Q);

          -- Store reduced coefficient
          v_out(32*(idx+1)-1 downto 32*idx) <= std_logic_vector(to_signed(reduced, 32));

          -- Move to next coefficient
          if idx = K*N - 1 then
            state <= DONE_STATE;
          else
            idx <= idx + 1;
          end if;

        when DONE_STATE =>
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end architecture rtl;

