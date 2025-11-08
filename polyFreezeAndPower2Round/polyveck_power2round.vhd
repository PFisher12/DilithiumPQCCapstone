----------------------------------------------------------------------------------
-- Name: polyveck_power2round
--   For each coefficient a of polynomials in a vector of length K,
--   compute a0 and a1 such that a = a1 * 2^D + a0,
--   with -2^(D/2) < a0 <= 2^(D/2).
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity polyveck_power2round is
  generic (
    K : integer := 4;   -- number of polynomials
    N : integer := 1;   -- coefficients per polynomial (simplified)
    D : integer := 14   -- power2round parameter (Dilithium: D=14)
  );
  port (
    clk     : in  std_logic;
    rst_n   : in  std_logic;
    start   : in  std_logic;
    done    : out std_logic;
    v_in    : in  unsigned((K*N*32) - 1 downto 0);  
    v0_out  : out unsigned((K*N*32) - 1 downto 0);  
    v1_out  : out unsigned((K*N*32) - 1 downto 0)   
  );
end entity;

architecture rtl of polyveck_power2round is

  type state_type is (IDLE, WORK, DONE_STATE);
  signal state : state_type := IDLE;

  signal idx : integer range 0 to K*N := 0;

  signal temp_a, temp_a0, temp_a1 : unsigned(31 downto 0) := (others => '0');

begin

  process (clk, rst_n)
  begin
    if rst_n = '0' then
      state   <= IDLE;
      idx     <= 0;
      done    <= '0';
      temp_a  <= (others => '0');
      temp_a0 <= (others => '0');
      temp_a1 <= (others => '0');
      v0_out  <= (others => '0');
      v1_out  <= (others => '0');

    elsif rising_edge(clk) then
      case state is

        -- IDLE: Wait for start
        when IDLE =>
          done <= '0';
          if start = '1' then
            idx   <= 0;
            state <= WORK;
          end if;

        -- WORK: Do power2round operation
        when WORK =>

          temp_a <= v_in((idx + 1) * 32 - 1 downto idx * 32);

          temp_a1 <= (others => '0');
          temp_a1(17 downto 0) <= temp_a(31 downto D);  

          temp_a0 <= (others => '0');
          temp_a0(D - 1 downto 0) <= temp_a(D - 1 downto 0);  

          v1_out((idx + 1) * 32 - 1 downto idx * 32) <= temp_a1;
          v0_out((idx + 1) * 32 - 1 downto idx * 32) <= temp_a0;

          if idx = K * N - 1 then
            state <= DONE_STATE;
          else
            idx <= idx + 1;
          end if;

        -- DONE_STATE: Signal completion
        when DONE_STATE =>
          done  <= '1';
          state <= IDLE;

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;

end architecture;
