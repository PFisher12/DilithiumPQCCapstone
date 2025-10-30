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
begin

  process (a)

  variable t_v     : unsigned (63 downto 0);
  variable temp1_v : unsigned (95 downto 0);
  variable temp2_v : unsigned (63 downto 0);

  begin
    
    --Montgomery Reducer Function
    temp1_v := a * unsigned(QINV);

    temp2_v := temp1_v(31 downto 0) * unsigned(Q);

    t_v := temp2_v + a;

    t <= t_v(63 downto 32);

  end process;

end RTL;