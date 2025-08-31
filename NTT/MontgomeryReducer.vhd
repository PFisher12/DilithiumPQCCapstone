library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--Turns 64bit input into a montgomery form 32 bit output

entity MontgomeryReducer is

  port (
    a : in unsigned (63 downto 0); --64 bit signed integer
    t : out unsigned (31 downto 0) --32 bit signed integer
  );

end MontgomeryReducer;

architecture RTL of MontgomeryReducer is

  signal a_s     : unsigned (63 downto 0); --64 bit signed integer
  signal t_s     : unsigned (63 downto 0); --64 bit signed integer
  signal temp1_v : unsigned (127 downto 0); --128 bit signed integer
  signal temp2_v : unsigned (63 downto 0); --128 bit signed integer
  signal qinv_s  : unsigned(63 downto 0); --64 bit signed integer

begin
  
  a_s    <= unsigned(a);
  qinv_s <= unsigned(x"00000000" & QINV);

  process (a_s, temp1_v, temp2_v)
  begin
    --Montgomery Reducer Function

    temp1_v <= a_s * qinv_s;

    temp2_v <= temp1_v(31 downto 0) * unsigned(Q);

    t_s <= temp2_v + a_s;

  end process;

  t <= t_s(63 downto 32);

end RTL;