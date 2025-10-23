library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package globalVars is

  -- Constants from original
  constant Q : integer := 8380417;
  constant Q_BITS : integer := 23;  -- <== Added to fix the rejectionSampler compile error
  constant QINV : std_logic_vector(31 downto 0) := "00000011100000000010000000000001";
  constant LOGQ : std_logic_vector(31 downto 0) := "00000000000000000000000000010111";
  constant N : integer := 256;
  constant ADDR_WIDTH : integer := 12;
  constant DATA_WIDTH : integer := 32;
  constant L : integer := 4;
  constant RAM_DEPTH : integer := N * L;
  constant LOGN : std_logic_vector(31 downto 0) := "00000000000000000000000000001000";
  constant PHI : std_logic_vector(31 downto 0) := "00000000000000000000011011011001";

  -- Dilithium-specific parameters
  constant GAMMA2     : integer := 3917;
  constant ALPHA      : integer := 256;
  constant HALF_ALPHA : integer := ALPHA / 2;
  constant ALPHA2     : integer := 2 * GAMMA2;
  constant D          : integer := 14;
  constant TWO_D      : integer := 2 ** D;
  constant HALF_TWO_D : integer := TWO_D / 2;

  -- For rejection sampling and SampleInBall
  constant MAX_SHUFFLE_COUNT : integer := 60; -- used in SampleInBall for number of non-zero coeffs
  constant SAMPLE_WIDTH      : integer := 23; -- output width from rejection sampling
  constant SIGN_BIT_INDEX    : integer := 8;  -- sign bit location in keccakOut for SampleInBall

  -- Added for HEAD module & submodules
  constant SEEDBYTES       : integer := 32;
  constant CRHBYTES        : integer := 48;
  constant MSG_WIDTH       : integer := 1024;  -- example message width
  constant KEY_INPUT_WIDTH : integer := 4096;  -- size of packed key input

  constant POLY_WIDTH      : integer := 16;    -- coefficient width
  constant POLY_ADDR_WIDTH : integer := 10;    -- 2^10 = 1024 addresses (safe upper bound)

  constant SHAKE_RATE      : integer := 1088;  -- SHAKE128 rate in bits (136 bytes)
  constant SHAKE_ROUNDS    : integer := 2;

  constant MAX_POLY_COUNT     : integer := 768;  -- s1 + s2 + t0 (3N if N=256)
  constant MAX_T1_POLY_COUNT  : integer := 512;  -- for t1 unpacking

  constant SK_PACKED_WIDTH : integer := 3840; -- Adjust based on your parameter set
  constant PK_PACKED_WIDTH : integer := 1792; -- Adjust for your Dilithium mode

  constant ETA : integer := 2;  


end package globalVars;
