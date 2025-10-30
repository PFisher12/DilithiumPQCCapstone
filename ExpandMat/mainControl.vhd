--mainControl.vhd
--This module acts as the top level system that connects the NTT module and the Ram controller. Eventually,
--this component will hold all finished modules and have a control module within it to allow different
--modules to interact with the same RAMs. Right now they are directly connected for ease of testing.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

entity mainControl is
  port (
    --temp IO for testbench testing
    clk             : in std_logic;
    enable_expand   : in std_logic;
    expandMat_ready : out std_logic
  );

end mainControl;

architecture RTL of mainControl is

  --RAM SIGNALS
  signal ram_in_from_expand_buf_s, ram_in_from_expand_coeff_s, ram_in_unused_s    : RAM_IN  := RAM_IN_INITIALIZE;
  signal ram_out_from_expand_buf_s, ram_out_unused  : RAM_OUT := RAM_OUT_INITIALIZE;
  signal unused_ram_select_s  : std_logic_vector (2 downto 0) := "000";

begin

  mainRamControl : entity work.ramControl(RTL)
    port map (
      --Control I/O
          --Inputs
          clk       => clk,
          ramSelect_in_a => "000",
          ramSelect_in_b => "001",
          ramSelect_in_c => unused_ram_select_s,
      --RAM I/O
          --Inputs
          ram_in_a  => ram_in_from_expand_buf_s,
          ram_in_b  => ram_in_from_expand_coeff_s,
          ram_in_c  => ram_in_unused_s,
          --Outputs
          ram_out_a => ram_out_from_expand_buf_s,
          ram_out_b => ram_out_unused,
          ram_out_c => ram_out_unused
    );

  expandMat : entity work.expandMat(RTL)
    port map (
      --Control I/O
          --Inputs
          clk     => clk,
          enable  => enable_expand,
          --Outputs
          expandMat_ready => expandMat_ready,

      --RAM I/O
          --Inputs
          ram_out_expand_buf   => ram_out_from_expand_buf_s,
          --Outputs
          ram_in_expand_buf    => ram_in_from_expand_buf_s,
          ram_in_expand_coeff  => ram_in_from_expand_coeff_s
    );
  
end RTL;