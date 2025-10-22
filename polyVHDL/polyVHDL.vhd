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
use work.globalVars.all;  

entity rejEta is
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    start     : in  std_logic;
    buf_in    : in  std_logic_vector(7 downto 0); -- one random byte input
    buf_valid : in  std_logic;
    len_in    : in  unsigned(15 downto 0);        -- number of coeffs
    done      : out std_logic;
    coeff_out : out unsigned(31 downto 0);
    coeff_valid : out std_logic
  );
end entity rejEta;

architecture rtl of rejEta is
  constant TWO_ETA : integer := 2 * ETA;
  constant ETA_C   : integer := ETA;
  constant Q_C     : integer := Q;
  type state_type is (IDLE, PROCESS, OUTPUT, FINISH);
  signal state      : state_type := IDLE;

  signal pos_cnt    : unsigned(15 downto 0) := (others => '0');  -- buffer byte counter
  signal ctr_cnt    : unsigned(15 downto 0) := (others => '0');  -- coefficient counter
  signal byte_reg   : std_logic_vector(7 downto 0) := (others => '0');
  signal t0, t1     : integer range 0 to 255 := 0;
  signal coeff_temp : unsigned(31 downto 0) := (others => '0');
begin

  process(clk, rst_n)
  begin
    if rst_n = '0' then
      state       <= IDLE;
      pos_cnt     <= (others => '0');
      ctr_cnt     <= (others => '0');
      done        <= '0';
      coeff_valid <= '0';
      coeff_out   <= (others => '0');

    elsif rising_edge(clk) then
      case state is

        when IDLE =>
          done        <= '0';
          coeff_valid <= '0';
          if start = '1' then
            ctr_cnt <= (others => '0');
            pos_cnt <= (others => '0');
            state   <= PROCESS;
          end if;

        when PROCESS =>
          coeff_valid <= '0';
          if buf_valid = '1' then
            byte_reg <= buf_in;
            -- Extract t0/t1
            if ETA <= 3 then
              t0 <= to_integer(unsigned(buf_in(2 downto 0)));     -- buf & 0x07
              t1 <= to_integer(unsigned(buf_in(7 downto 5)));     -- buf >> 5
            else
              t0 <= to_integer(unsigned(buf_in(3 downto 0)));     -- buf & 0x0F
              t1 <= to_integer(unsigned(buf_in(7 downto 4)));     -- buf >> 4
            end if;
            state <= OUTPUT;
          end if;

        when OUTPUT =>
          coeff_valid <= '0';
          -- Emit t0 if valid
          if (t0 <= TWO_ETA) and (ctr_cnt < len_in) then
            coeff_temp  <= to_unsigned(Q_C + ETA_C - t0, 32);
            coeff_out   <= coeff_temp;
            coeff_valid <= '1';
            ctr_cnt     <= ctr_cnt + 1;
          end if;

          -- Emit t1 if valid and space remains
          if (t1 <= TWO_ETA) and (ctr_cnt < len_in) then
            coeff_temp  <= to_unsigned(Q_C + ETA_C - t1, 32);
            coeff_out   <= coeff_temp;
            coeff_valid <= '1';
            ctr_cnt     <= ctr_cnt + 1;
          end if;

          -- If done or end of buffer
          if ctr_cnt >= len_in then
            state <= FINISH;
          else
            state <= PROCESS;
          end if;

        when FINISH =>
          coeff_valid <= '0';
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end architecture rtl;






















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