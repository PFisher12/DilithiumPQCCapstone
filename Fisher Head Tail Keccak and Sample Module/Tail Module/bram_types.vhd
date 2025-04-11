library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package bram_types is

  constant N : integer := 256;

  -- 32-bit vector array for coeffs, z, t0, t1, w1
  type ram32_array is array (0 to N-1) of std_logic_vector(31 downto 0);

  -- 1-bit array for hint bits
  type hint_array is array (0 to N-1) of std_logic;

end package bram_types;
