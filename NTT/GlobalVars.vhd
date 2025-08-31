library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package globalVars is

  constant Q    : std_logic_vector(31 downto 0) := "00000000011111111110000000000001";
  constant QINV : std_logic_vector(31 downto 0) := "11111100011111111101111111111111";
  constant LOGQ : std_logic_vector(31 downto 0) := "00000000000000000000000000010111";
  constant N    : std_logic_vector(31 downto 0) := "00000000000000000000000100000000";
  constant LOGN : std_logic_vector(31 downto 0) := "00000000000000000000000000001000";
  constant PHI  : std_logic_vector(31 downto 0) := "00000000000000000000011011011001";

  type RAM_IN is record
    --Signals going into the RAM module
    address_a : std_logic_vector (7 downto 0);
    address_b : std_logic_vector (7 downto 0);
    data_a    : std_logic_vector (31 downto 0);
    data_b    : std_logic_vector (31 downto 0);
    wren_a    : std_logic;
    wren_b    : std_logic;
  end record RAM_IN;

  type RAM_OUT is record
    --Signals coming out of the RAM module
    q_a       : std_logic_vector (31 downto 0);
    q_b       : std_logic_vector (31 downto 0);
  end record RAM_OUT;

  constant RAM_IN_INITIALIZE  : RAM_IN  := (
    address_a => (others => '0'),
    address_b => (others => '0'),
    data_a    => (others => '0'),
    data_b    => (others => '0'),
    wren_a    => '0',
    wren_b    => '0'
  );

  constant RAM_OUT_INITIALIZE : RAM_OUT := (
    q_a => (others => '0'),
    q_b => (others => '0')
  );


end package globalVars;