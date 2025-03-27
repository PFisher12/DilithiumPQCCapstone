library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package globalVars is

	constant Q : std_logic_vector(31 downto 0) := "00000000011111111110000000000001";
	constant QINV : std_logic_vector(31 downto 0) := "00000011100000000010000000000001";
	constant LOGQ : std_logic_vector(31 downto 0) := "00000000000000000000000000010111";
	constant N : std_logic_vector(31 downto 0) := "00000000000000000000000100000000";
	constant LOGN : std_logic_vector(31 downto 0) := "00000000000000000000000000001000";
	constant PHI : std_logic_vector(31 downto 0) := "00000000000000000000011011011001";

end package globalVars;