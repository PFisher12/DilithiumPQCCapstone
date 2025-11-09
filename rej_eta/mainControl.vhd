library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

entity mainControl is
  port (
    clk     : in std_logic;
    enable  : in std_logic;
    len     : in unsigned (31 downto 0);
    buflen  : in unsigned (31 downto 0);
    ready   : out std_logic
  );

end mainControl;

architecture RTL of mainControl is

  --RAM SIGNALS
  signal ram_in_a, ram_in_b, ram_in_c : RAM_IN  := RAM_IN_INITIALIZE;
  signal ram_out_a, ram_out_b, ram_out_c  : RAM_OUT := RAM_OUT_INITIALIZE;

  signal ctr_s : unsigned (8 downto 0);
  
begin

  mainRamControl : entity work.ramControl(RTL)
    port map (
      --Control I/O
          --Inputs
          clk       => clk,
          ramSelect_in_a => "000",
          ramSelect_in_b => "001",
          ramSelect_in_c => "010",
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

    rej : entity work.rej(RTL)
      port map(
    --Control I/O
        --Inputs
        clk             => clk,
        enable          => enable,
        len             => len,
        buflen          => buflen,
        ctr             => ctr_s,
        --Outputs
        ready           => ready,

    --RAM I/O
        --Inputs
        ram_out_buf       => ram_out_a,
        --Outputs
        ram_in_buf        => ram_in_a,
        ram_in_a        => ram_in_b
    );

end RTL;