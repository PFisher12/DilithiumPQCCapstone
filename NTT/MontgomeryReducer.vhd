--MontgomeryReducer.vhd
--Turns 64bit input into the 32 bit montgomery form output
--TODO: See if any of these calculations can be optmized better to reduce DSP usage

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

entity MontgomeryReducer is

  port (
    a : in unsigned (63 downto 0);
    t : out unsigned (31 downto 0)
  );

end MontgomeryReducer;

architecture RTL of MontgomeryReducer is
begin

  process (a)
  --Initialize temporary variables to be used in between calculations
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