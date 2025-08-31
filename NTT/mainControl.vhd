library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--TODO: Depending on which entity calls the RAM, select correct ramSelect and ramEnable values (use mux?)

entity mainControl is
  port (
    clk             : in std_logic;
    selectTBCmds    : in std_logic;
    ram_in_from_TB  : in RAM_IN;
    enable_NTT      : in std_logic;
    reset_NTT       : in std_logic
  );

end mainControl;

architecture RTL of mainControl is

  --RAM SIGNALS
  signal ram_in_from_main_s   : RAM_IN  := RAM_IN_INITIALIZE;
  signal ram_in_from_NTT_s    : RAM_IN  := RAM_IN_INITIALIZE;
  signal ram_out_from_main_s  : RAM_OUT := RAM_OUT_INITIALIZE;

  signal ramSelect_s  : std_logic_vector (1 downto 0) := "00";
  signal NTT_INTT_Select : std_logic := '0'; 

begin

  mainRamControl : entity work.ramControl(RTL)
    port map (
      --Control I/O
          --Inputs
          clk       => clk,
          ramSelect => ramSelect_s,

      --RAM I/O
          --Inputs
          ram_in    => ram_in_from_main_s,
          --Outputs
          ram_out   => ram_out_from_main_s
    );

  mainNTT : entity work.ntt(RTL)
    port map (
      --Control I/O
          --Inputs
          clk     => clk,
          enable  => enable_NTT,
          reset   => reset_NTT,
          NTT_INTT_Select => NTT_INTT_Select,

      --RAM I/O
          --Inputs
          ram_out_ntt   => ram_out_from_main_s,
          --Outputs
          ram_in_ntt    => ram_in_from_NTT_s
    );

    RamSelectorMux : process (ram_in_from_TB, ram_in_from_NTT_s, selectTBCmds)
    begin
      if(selectTBCmds = '1') then
        ram_in_from_main_s <= ram_in_from_TB;
      else
        ram_in_from_main_s <= ram_in_from_NTT_s;
      end if;
    end process;

end RTL;