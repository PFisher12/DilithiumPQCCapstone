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