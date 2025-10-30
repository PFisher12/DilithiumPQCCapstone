library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--TODO: Depending on which entity calls the RAM, select correct ramSelect and ramEnable values (use mux?)

entity mainControl is
  port (
    --temp IO for testbench testing
    clk             : in std_logic;
    enable          : in std_logic;
    AddMultSelect   : in std_logic;
    RamCSelect      : in std_logic_vector(2 downto 0);
    ready           : out std_logic
  );

end mainControl;

architecture RTL of mainControl is

  --RAM SIGNALS
  signal ram_in_a, ram_in_b, ram_in_c : RAM_IN  := RAM_IN_INITIALIZE;
  signal ram_out_a, ram_out_b, ram_out_c  : RAM_OUT := RAM_OUT_INITIALIZE;
  

begin

  mainRamControl : entity work.ramControl(RTL)
    port map (
      --Control I/O
          --Inputs
          clk       => clk,
          ramSelect_in_a => "000",
          ramSelect_in_b => "001",
          ramSelect_in_c => RamCSelect,
      --RAM I/O
          --Inputs
          ram_in_a  => ram_in_a,
          ram_in_b  => ram_in_b,
          ram_in_c  => ram_in_c,
          --Outputs
          ram_out_a => ram_out_a,
          ram_out_b => ram_out_b,
          ram_out_c => ram_out_c
    );

    PolyAdderMultipler : entity work.PolyAddMult(RTL)
      port map(
    --Control I/O
        --Inputs
        clk             => clk,
        enable          => enable,
        Add_Mult_Select => AddMultSelect,
        --Outputs
        ready           => ready,

    --RAM I/O
        --Inputs
        ram_out_a       => ram_out_a,
        ram_out_b       => ram_out_b,
        --Outputs
        ram_in_a        => ram_in_a,
        ram_in_b        => ram_in_b,
        ram_in_c        => ram_in_c
        );

end RTL;