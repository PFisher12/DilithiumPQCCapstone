library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;
entity nttForward is

  port (
    --TEMP, change when desinging NTT
    address : in std_logic_vector(7 downto 0); --Current location of NTT, equiv to j variable in C
    offset  : in std_logic_vector(6 downto 0); --7 bit offset, equiv to len variable in C
    zeta    : in unsigned(31 downto 0); --zeta input (size is diff from code)
    enable  : in std_logic;
    clk     : in std_logic; --Clock input

    --RAM I/O
    address_a : out std_logic_vector (7 downto 0);
    address_b : out std_logic_vector (7 downto 0);
    data_a    : out std_logic_vector (31 downto 0);
    data_b    : out std_logic_vector (31 downto 0);
    wren_a    : out std_logic;
    wren_b    : out std_logic;
    q_a       : in std_logic_vector (31 downto 0);
    q_b       : in std_logic_vector (31 downto 0)
  );

end nttForward;
architecture behav of nttForward is
begin

  butterfly1 : entity work.butterflyForward(behav)
    port map
    (
      --Butterfly I/O
      address => address,
      offset  => offset,
      zeta    => zeta,
      enable  => enable,
      clk     => clk,
      --RAM I/O
      address_a => address_a,
      address_b => address_b,
      data_a    => data_a,
      data_b    => data_b,
      wren_a    => wren_a,
      wren_b    => wren_b,
      q_a       => q_a,
      q_b       => q_b
    );
end behav;