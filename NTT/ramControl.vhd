--ramControl.vhd
--This module declares an arbitrary number of RAM modules that increases as the design necissitates more.
--It has enough ports to allow for up to three of the RAM instances to be selected and operated upon at the same time.
--This is useful for pointwise addition modules that read from two rams and write to a seperate one.

--TODO: Find a way to use loops / generates to clean up the repeated code

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;
use IEEE.math_real.all;


entity ramControl is
  port (
    clk            : in std_logic;

    ramSelect_in_a : in std_logic_vector (2 downto 0);
    ramSelect_in_b : in std_logic_vector (2 downto 0);
    ramSelect_in_c : in std_logic_vector (2 downto 0);

    ram_in_a  : in RAM_IN;
    ram_in_b  : in RAM_IN;
    ram_in_c  : in RAM_IN;

    ram_out_a : out RAM_OUT;
    ram_out_b : out RAM_OUT;
    ram_out_c : out RAM_OUT
  );

end ramControl;

architecture RTL of ramControl is

  signal ramEmpty_in : RAM_IN := RAM_IN_INITIALIZE;
  signal ramEmpty_out : RAM_OUT := RAM_OUT_INITIALIZE;

  signal ram0_in : RAM_IN := RAM_IN_INITIALIZE;
  signal ram0_out : RAM_OUT := RAM_OUT_INITIALIZE;

  signal ram1_in : RAM_IN := RAM_IN_INITIALIZE;
  signal ram1_out : RAM_OUT := RAM_OUT_INITIALIZE;

  signal ram2_in : RAM_IN := RAM_IN_INITIALIZE;
  signal ram2_out : RAM_OUT := RAM_OUT_INITIALIZE;

  signal ram3_in : RAM_IN := RAM_IN_INITIALIZE;
  signal ram3_out : RAM_OUT := RAM_OUT_INITIALIZE;

begin


  ram0 : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ram0_in.address_a,
      address_b => ram0_in.address_b,
      data_a    => ram0_in.data_a,
      data_b    => ram0_in.data_b,
      wren_a    => ram0_in.wren_a,
      wren_b    => ram0_in.wren_b,
      q_a       => ram0_out.q_a,
      q_b       => ram0_out.q_b
    );

  ram1 : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ram1_in.address_a,
      address_b => ram1_in.address_b,
      data_a    => ram1_in.data_a,
      data_b    => ram1_in.data_b,
      wren_a    => ram1_in.wren_a,
      wren_b    => ram1_in.wren_b,
      q_a       => ram1_out.q_a,
      q_b       => ram1_out.q_b
    );

  ram2 : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ram2_in.address_a,
      address_b => ram2_in.address_b,
      data_a    => ram2_in.data_a,
      data_b    => ram2_in.data_b,
      wren_a    => ram2_in.wren_a,
      wren_b    => ram2_in.wren_b,
      q_a       => ram2_out.q_a,
      q_b       => ram2_out.q_b
    );

  ram3 : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ram3_in.address_a,
      address_b => ram3_in.address_b,
      data_a    => ram3_in.data_a,
      data_b    => ram3_in.data_b,
      wren_a    => ram3_in.wren_a,
      wren_b    => ram3_in.wren_b,
      q_a       => ram3_out.q_a,
      q_b       => ram3_out.q_b
    );

  --Priority Selector : Assigns the input signals to a certain RAM, prioritising a > b > c if two inputs select the same module
  ramSelect : process (ramSelect_in_a, ramSelect_in_b, ramSelect_in_c, ram_in_a, ram_in_b, ram_in_c, ramEmpty_in, ramEmpty_out,
    ram0_out, ram1_out, ram2_out, ram3_out)
  begin
    ram0_in <= ramEmpty_in;
    ram1_in <= ramEmpty_in;
    ram2_in <= ramEmpty_in;
    ram3_in <= ramEmpty_in;

    ram_out_a <= ramEmpty_out;
    ram_out_b <= ramEmpty_out;
    ram_out_c <= ramEmpty_out;

    --RAM 0 Select
    if(to_integer(unsigned(ramSelect_in_a)) = 0) then
      ram0_in <= ram_in_a;
      ram_out_a <= ram0_out;
    elsif(to_integer(unsigned(ramSelect_in_b)) = 0) then
      ram0_in <= ram_in_b;
      ram_out_b <= ram0_out;
    elsif(to_integer(unsigned(ramSelect_in_c)) = 0) then
      ram0_in <= ram_in_c;
      ram_out_c <= ram0_out;
    end if;

    --RAM 1 Select
    if(to_integer(unsigned(ramSelect_in_a)) = 1) then
      ram1_in <= ram_in_a;
      ram_out_a <= ram1_out;
    elsif(to_integer(unsigned(ramSelect_in_b)) = 1) then
      ram1_in <= ram_in_b;
      ram_out_b <= ram1_out;
    elsif(to_integer(unsigned(ramSelect_in_c)) = 1) then
      ram1_in <= ram_in_c;
      ram_out_c <= ram1_out;
    end if;

    --RAM 2 Select
    if(to_integer(unsigned(ramSelect_in_a)) = 2) then
      ram2_in <= ram_in_a;
      ram_out_a <= ram2_out;
    elsif(to_integer(unsigned(ramSelect_in_b)) = 2) then
      ram2_in <= ram_in_b;
      ram_out_b <= ram2_out;
    elsif(to_integer(unsigned(ramSelect_in_c)) = 2) then
      ram2_in <= ram_in_c;
      ram_out_c <= ram2_out;
    end if;

    --RAM 3 Select
    if(to_integer(unsigned(ramSelect_in_a)) = 3) then
      ram3_in <= ram_in_a;
      ram_out_a <= ram3_out;
    elsif(to_integer(unsigned(ramSelect_in_b)) = 3) then
      ram3_in <= ram_in_b;
      ram_out_b <= ram3_out;
    elsif(to_integer(unsigned(ramSelect_in_c)) = 3) then
      ram3_in <= ram_in_c;
      ram_out_c <= ram3_out;
    end if;

  end process;

end RTL;