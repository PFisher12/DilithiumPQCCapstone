library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--TODO: Depending on which entity calls the RAM, select correct ramSelect and ramEnable values (use mux?)

entity mainControl is
  port (
    clk : in std_logic
  );

end mainControl;
architecture behavior of mainControl is

  --TEST SIGNALS
  signal address_s : std_logic_vector(7 downto 0);
  signal offset_s  : std_logic_vector(6 downto 0);
  signal zeta_s    : unsigned(31 downto 0);
  signal enable_s  : std_logic;

  --RAM SIGNALS
  signal address_a_s : std_logic_vector (7 downto 0);
  signal address_b_s : std_logic_vector (7 downto 0);
  signal data_a_s    : std_logic_vector (31 downto 0);
  signal data_b_s    : std_logic_vector (31 downto 0);
  signal wren_a_s    : std_logic;
  signal wren_b_s    : std_logic;
  signal q_a_s       : std_logic_vector (31 downto 0);
  signal q_b_s       : std_logic_vector (31 downto 0);

  signal ramSelect_s : std_logic_vector (1 downto 0);
begin

  mainRamControl : entity work.ramControl(behav)
    port map
    (
      address_a => address_a_s,
      address_b => address_b_s,
      clock     => clk,
      data_a    => data_a_s,
      data_b    => data_b_s,
      wren_a    => wren_a_s,
      wren_b    => wren_b_s,
      q_a       => q_a_s,
      q_b       => q_b_s,

      ramSelect => ramSelect_s
    );

  mainNTTForward : entity work.nttForward(behav)
    port map
    (
      clk     => clk,
      address => address_s,
      offset  => offset_s,
      zeta    => zeta_s,
      enable  => enable_s,
      --RAM I/O
      address_a => address_a_s, --CHANGE LATER
      address_b => address_b_s,
      data_a    => data_a_s,
      data_b    => data_b_s,
      wren_a    => wren_a_s,
      wren_b    => wren_b_s,
      q_a       => q_a_s,
      q_b       => q_b_s
    );
end behavior;