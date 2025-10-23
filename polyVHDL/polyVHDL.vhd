--------------------------------------------------------------------------------------------
-- Name:        rej_eta
--Description: Sample uniformly random coefficients in [-ETA, ETA] by
--              performing rejection sampling using array of random bytes
--Arguments:   - uint32_t *a: pointer to output array (allocated)
--             - unsigned int len: number of coefficients to be sampled
--              - const unsigned char *buf: array of random bytes
--              - unsigned int buflen: length of array of random bytes
--Returns number of sampled coefficients. Can be smaller than len if not enough
--random bytes were given.
-------------------------------------------------------
--static unsigned int rej_eta(uint32_t *a,
--                            unsigned int len,
--                            const unsigned char *buf,
--                            unsigned int buflen)
--{
--#if ETA > 7
--#error "rej_eta() assumes ETA <= 7"
--#endif
--  unsigned int ctr, pos;
--  unsigned char t0, t1;

--  ctr = pos = 0;
--  while(ctr < len) {
--#if ETA <= 3
--    t0 = buf[pos] & 0x07;
--    t1 = buf[pos++] >> 5;
--#else
--    t0 = buf[pos] & 0x0F;
--    t1 = buf[pos++] >> 4;
--#endif

--    if(t0 <= 2*ETA)
--      a[ctr++] = Q + ETA - t0;
--    if(t1 <= 2*ETA && ctr < N)
--      a[ctr++] = Q + ETA - t1;

--    if(pos >= buflen)
--      break;
--  }

--  return ctr;
--}
------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity polyVHDL is
  port (
    clk         : in  std_logic;
    rst_n       : in  std_logic;
    start       : in  std_logic;
    done        : out std_logic;
    buf_in      : in  std_logic_vector(7 downto 0);
    buf_valid   : in  std_logic;
    coeff_out   : out std_logic_vector(31 downto 0);
    coeff_valid : out std_logic
  );
end entity polyVHDL;

architecture Behavioral of polyVHDL is

  -------------------------------------------------------------------
  -- Constants (moved from globalVars)
  -------------------------------------------------------------------
  constant Q   : integer := 8380417;   -- Dilithium modulus
  constant N   : integer := 256;       -- Polynomial degree
  constant ETA : integer := 2;         -- Noise bound (≤7 per Dilithium spec)

  -------------------------------------------------------------------
  -- Types and signals
  -------------------------------------------------------------------
  type state_type is (IDLE, LOAD, COMPUTE, FINISH);
  signal state : state_type := IDLE;

  signal t0, t1           : integer range 0 to 15 := 0;
  signal ctr_cnt           : integer range 0 to N := 0;
  signal pos_cnt           : integer range 0 to 255 := 0;
  signal coeff_reg         : unsigned(31 downto 0) := (others => '0');
  signal coeff_valid_reg   : std_logic := '0';
  signal done_reg          : std_logic := '0';

begin

  -------------------------------------------------------------------
  -- Main FSM implementing rej_eta behavior
  -------------------------------------------------------------------
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      state           <= IDLE;
      ctr_cnt         <= 0;
      pos_cnt         <= 0;
      coeff_reg       <= (others => '0');
      coeff_valid_reg <= '0';
      done_reg        <= '0';

    elsif rising_edge(clk) then
      case state is

        -----------------------------------------------------------------
        when IDLE =>
          done_reg        <= '0';
          coeff_valid_reg <= '0';
          if start = '1' then
            state <= LOAD;
          end if;

        -----------------------------------------------------------------
        when LOAD =>
          if buf_valid = '1' then
            -- Extract two 3-bit or 4-bit values from buf_in
            t0 <= to_integer(unsigned(buf_in(2 downto 0)));  -- low bits
            t1 <= to_integer(unsigned(buf_in(7 downto 5)));  -- high bits
            state <= COMPUTE;
          end if;

        -----------------------------------------------------------------
        when COMPUTE =>
          coeff_valid_reg <= '0';

          -- If t0 within range → accept
          if t0 <= 2*ETA then
            coeff_reg       <= to_unsigned(Q + ETA - t0, 32);
            coeff_valid_reg <= '1';
            ctr_cnt         <= ctr_cnt + 1;
          end if;

          -- If t1 within range → accept second coefficient
          if t1 <= 2*ETA and ctr_cnt < N then
            coeff_reg       <= to_unsigned(Q + ETA - t1, 32);
            coeff_valid_reg <= '1';
            ctr_cnt         <= ctr_cnt + 1;
          end if;

          pos_cnt <= pos_cnt + 1;

          if ctr_cnt >= N-1 then
            done_reg <= '1';
            state    <= FINISH;
          else
            state <= LOAD;
          end if;

        -----------------------------------------------------------------
        when FINISH =>
          done_reg        <= '1';
          coeff_valid_reg <= '0';
          state <= IDLE;

      end case;
    end if;
  end process;

  coeff_out   <= std_logic_vector(coeff_reg);
  coeff_valid <= coeff_valid_reg;
  done        <= done_reg;

end architecture Behavioral;



-----------------------------------------------------------------------------
-- Name:        poly_uniform_eta
--Description: Sample polynomial with uniformly random coefficients
--             in [-ETA,ETA] by performing rejection sampling using the
--              output stream from SHAKE256(seed|nonce)
--Arguments:   - poly *a: pointer to output polynomial
--             - const unsigned char seed[]: byte array with seed of length
--                                            SEEDBYTES
--              - unsigned char nonce: nonce byte
-----------------
--void poly_uniform_eta(poly *a,
--                      const unsigned char seed[SEEDBYTES], 
--                      unsigned char nonce)
--{
--  unsigned int i, ctr;
--  unsigned char inbuf[SEEDBYTES + 1];
--  /* Probability that we need more than 2 blocks: < 2^{-84} */
--  unsigned char outbuf[2*SHAKE256_RATE];
--  uint64_t state[25];
--  for(i= 0; i < SEEDBYTES; ++i)
--    inbuf[i] = seed[i];
--  inbuf[SEEDBYTES] = nonce;
--  shake256_absorb(state, inbuf, SEEDBYTES + 1);
--  shake256_squeezeblocks(outbuf, 2, state);
--  ctr = rej_eta(a->coeffs, N, outbuf, 2*SHAKE256_RATE);
--  if(ctr < N) {
--    shake256_squeezeblocks(outbuf, 1, state);
--    rej_eta(a->coeffs + ctr, N - ctr, outbuf, SHAKE256_RATE);
--  }
--}
------------------------------------------------------------------------------------