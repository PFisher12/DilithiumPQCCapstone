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
    enable          : in std_logic;
    ready           : out std_logic
  );

end mainControl;

architecture RTL of mainControl is

  --RAM SIGNALS
  signal ramEmpty_in, ramS1_in, ramS2_in, ramS1Hat_in, ramT_in, ramT1_in, ramT0_in, ramMat_in : RAM_IN;
  signal ramEmpty_out, ramS1_out, ramS2_out, ramS1Hat_out, ramT_out, ramT1_out, ramT0_out, ramMat_out : RAM_OUT;

  --Module RAM I/O
  signal ram_ntt_in, ram_power2_a_in, ram_power2_b_in, ram_power2_c_in, ram_addmult_a_in, ram_addmult_b_in, ram_addmult_c_in, ram_freeze_in, ram_add2_a_in, ram_add2_b_in : RAM_IN;
  signal ram_ntt_out, ram_power2_a_out, ram_addmult_a_out, ram_addmult_b_out, ram_freeze_out, ram_add2_a_out, ram_add2_b_out : RAM_OUT;
  
  --1 bit registers / wires
  signal wait1cycle_r, ntt_enable_r, ntt_ready, ntt_select_r, freeze_enable_r, freeze_ready, power2round_enable_r, power2round_ready, addmult_enable_r, addmult_select_r, addmult_ready, add2_enable, add2_ready : std_logic;

  --State Machine Vars
  type state is (WAITING, S1HAT, NTT, POINTWISE, INTT, ADD, FREEZE, POWER2ROUND);
  signal state_s : state := waiting;

begin

--------------------------------------------------------
------------------ Main State Machine ------------------
--------------------------------------------------------

  process(clk)
  begin
    if(clk'event and clk = '1') then
      case state_s is
        when WAITING =>
          --Set defaults
          wait1cycle_r <= '0';
          ntt_enable_r <=  '0';
          ntt_select_r <=  '0';
          freeze_enable_r <=  '0';
          power2round_enable_r <=  '0';
          addmult_enable_r <= '0';
          addmult_select_r <= '0';
          add2_enable <= '0';
          --Enable the Generation State Machine
          if(enable = '1') then 
            state_s <= S1HAT;
            add2_enable <= '1';
            wait1cycle_r <= '1';
          end if;
        when S1HAT =>
          add2_enable <= '0';
          if(add2_ready = '1' and wait1cycle_r = '0') then
            state_s <= NTT;
            ntt_enable_r <= '1';
            ntt_select_r <= '0';
            wait1cycle_r <= '1';
          end if;
        when NTT =>
          ntt_enable_r <= '0';
          if(ntt_ready = '1' and wait1cycle_r = '0') then 
            state_s <= POINTWISE;
            addmult_enable_r <= '1';
            addmult_select_r <= '1';
            wait1cycle_r <= '1';
          end if;
        when POINTWISE =>
          addmult_enable_r <= '0';
          if(addmult_ready = '1' and wait1cycle_r = '0') then 
            state_s <= INTT;
            ntt_enable_r <= '1';
            ntt_select_r <= '1';
            wait1cycle_r <= '1';
          end if;
        when INTT =>
          ntt_enable_r <= '0';
          if(ntt_ready = '1' and wait1cycle_r = '0') then 
            state_s <= ADD;
            add2_enable <= '1';
            wait1cycle_r <= '1';
          end if;
        when ADD =>
          add2_enable <= '0';
          if(add2_ready = '1' and wait1cycle_r = '0') then 
            state_s <= FREEZE;
            freeze_enable_r <= '1';
            wait1cycle_r <= '1';
          end if;
        when FREEZE =>
          freeze_enable_r <= '0';
          if(freeze_ready = '1' and wait1cycle_r = '0') then 
            state_s <= POWER2ROUND;
            power2round_enable_r <= '1';
            wait1cycle_r <= '1';
          end if;
        when POWER2ROUND =>
          power2round_enable_r <= '0';
          if(power2round_ready = '1' and wait1cycle_r = '0') then 
            state_s <= WAITING;
            wait1cycle_r <= '1';
          end if;
        when others =>
          state_s <= WAITING;
      end case;

      if(wait1cycle_r = '1') then
        wait1cycle_r <= '0';
      end if;

    end if;
  end process;

---------------------------------------------------------------------
------------------ Combinatorial / Assignment Code ------------------
---------------------------------------------------------------------

  process(state_s, ramEmpty_out, ramEmpty_in, ramS1Hat_out, ram_add2_b_in, 
    ram_ntt_in, ramMat_out, ram_addmult_a_in, ram_addmult_b_in, ram_addmult_c_in, 
    ramT_out, ram_ntt_in, ramS2_out, ram_add2_a_in, ram_freeze_in, ram_power2_a_in, 
    ram_power2_b_in, ram_power2_c_in)
  begin
    case state_s is
      when WAITING =>
        ready <= '1';
      when others =>
        ready <= '0';
    end case;

    --Module Ram Inputs
    ram_ntt_out         <= ramEmpty_out;
    ram_freeze_out      <= ramEmpty_out;
    ram_power2_a_out    <= ramEmpty_out;
    ram_addmult_a_out   <= ramEmpty_out;
    ram_addmult_b_out   <= ramEmpty_out;
    ram_add2_a_out      <= ramEmpty_out;
    ram_add2_b_out      <= ramEmpty_out;

    --RAM Inputs
    ramS1_in            <= ramEmpty_in;
    ramS2_in            <= ramEmpty_in;
    ramS1Hat_in         <= ramEmpty_in;
    ramT_in             <= ramEmpty_in;
    ramT1_in            <= ramEmpty_in;
    ramT0_in            <= ramEmpty_in;
    ramMat_in           <= ramEmpty_in;

    --Set Module and Ram inputs based on current state
    case state_s is
      when S1HAT =>
        --ram_add2_a_out <= ramS1_out;
        ram_add2_a_out <= ramEmpty_out; --TEMP
        ram_add2_b_out <= ramS1Hat_out;
        --ramS1_in <= ram_add2_a_in;
        ramS1_in <= ramEmpty_in;
        ramS1Hat_in <= ram_add2_b_in;
      when NTT =>
        ram_ntt_out <= ramS1Hat_out;
        ramS1Hat_in <= ram_ntt_in;
      when POINTWISE =>
        ram_addmult_a_out <= ramS1Hat_out;
        ram_addmult_b_out <= ramMat_out;
        ramS1Hat_in <= ram_addmult_a_in;
        ramMat_in <= ram_addmult_b_in;
        ramT_in <= ram_addmult_c_in;
      when INTT =>
        ram_ntt_out <= ramT_out;
        ramT_in <= ram_ntt_in;
      when ADD =>
        ram_add2_a_out <= ramS2_out;
        ram_add2_b_out <= ramT_out;
        ramS2_in <= ram_add2_a_in;
        ramT_in <= ram_add2_b_in;
      when FREEZE =>
        ram_freeze_out <= ramT_out;
        ramT_in <= ram_freeze_in;
      when POWER2ROUND =>
        ram_power2_a_out <= ramT_out;
        ramT_in <= ram_power2_a_in;
        ramT0_in <= ram_power2_b_in;
        ramT1_in <= ram_power2_c_in;
      when others =>
        null;
    end case;

  end process;

  ramEmpty_in <= RAM_IN_INITIALIZE;
  ramEmpty_out <= RAM_OUT_INITIALIZE;

-----------------------------------------
------------------ NTT ------------------
-----------------------------------------

  nttModule : entity work.ntt(RTL)
    port map (
      --Control I/O
          --Inputs
          clk     => clk,
          enable  => ntt_enable_r,
          NTT_INTT_Select => ntt_select_r,
          ntt_ready => ntt_ready,

      --RAM I/O
          --Inputs
          ram_out_ntt   => ram_ntt_out,
          --Outputs
          ram_in_ntt    => ram_ntt_in
    );

--------------------------------------------
------------------ FREEZE ------------------
--------------------------------------------

    freezeModule : entity work.freeze(RTL)
      port map(
        --Control I/O
            --Inputs
            clk             => clk,
            enable          => freeze_enable_r,
            --Outputs
            ready           => freeze_ready,

        --RAM I/O
            --Inputs
            ram_out_a       => ram_freeze_out,
            --Outputs
            ram_in_a        => ram_freeze_in
        );

-------------------------------------------------
------------------ Power2Round ------------------
-------------------------------------------------

    power2roundModule : entity work.power2round(RTL)
      port map(
        clk     => clk,
        enable   => power2round_enable_r,
        ready    => power2round_ready,
        --RAM I/O
            --Inputs
            ram_out_a => ram_power2_a_out,
            --Outputs
            ram_in_a  => ram_power2_a_in,
            ram_in_b  => ram_power2_b_in,
            ram_in_c  => ram_power2_c_in
        );

-------------------------------------------------
------------------ PolyAddMult ------------------
-------------------------------------------------

    PolyAdderMultiplerModule : entity work.PolyAddMult(RTL)
      port map(
    --Control I/O
        --Inputs
        clk             => clk,
        enable          => addmult_enable_r,
        Add_Mult_Select => addmult_select_r,
        --Outputs
        ready           => addmult_ready,

    --RAM I/O
        --Inputs
        ram_out_a       => ram_addmult_a_out,
        ram_out_b       => ram_addmult_b_out,
        --Outputs
        ram_in_a        => ram_addmult_a_in,
        ram_in_b        => ram_addmult_b_in,
        ram_in_c        => ram_addmult_c_in
        ); 

-------------------------------------------------
------------------ Add2 ------------------
-------------------------------------------------

    Add2 : entity work.Add2(RTL)
      port map(
    --Control I/O
        --Inputs
        clk             => clk,
        enable          => add2_enable,
        --Outputs
        ready           => add2_ready,

    --RAM I/O
        --Inputs
        ram_out_a       => ram_add2_a_out,
        ram_out_b       => ram_add2_b_out,
        --Outputs
        ram_in_a        => ram_add2_a_in,
        ram_in_b        => ram_add2_b_in
        );

--------------------------------------------
------------------ RAM0-5 ------------------
--------------------------------------------
  --S1
  ram0_S1 : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ramS1_in.address_a,
      address_b => ramS1_in.address_b,
      data_a    => ramS1_in.data_a,
      data_b    => ramS1_in.data_b,
      wren_a    => ramS1_in.wren_a,
      wren_b    => ramS1_in.wren_b,
      q_a       => ramS1_out.q_a,
      q_b       => ramS1_out.q_b
    );
  --S2
  ram1_S2 : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ramS2_in.address_a,
      address_b => ramS2_in.address_b,
      data_a    => ramS2_in.data_a,
      data_b    => ramS2_in.data_b,
      wren_a    => ramS2_in.wren_a,
      wren_b    => ramS2_in.wren_b,
      q_a       => ramS2_out.q_a,
      q_b       => ramS2_out.q_b
    );
  --S1hat
  ram2_S1hat : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ramS1Hat_in.address_a,
      address_b => ramS1Hat_in.address_b,
      data_a    => ramS1Hat_in.data_a,
      data_b    => ramS1Hat_in.data_b,
      wren_a    => ramS1Hat_in.wren_a,
      wren_b    => ramS1Hat_in.wren_b,
      q_a       => ramS1Hat_out.q_a,
      q_b       => ramS1Hat_out.q_b
    );
  --T
  ram3_T : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ramT_in.address_a,
      address_b => ramT_in.address_b,
      data_a    => ramT_in.data_a,
      data_b    => ramT_in.data_b,
      wren_a    => ramT_in.wren_a,
      wren_b    => ramT_in.wren_b,
      q_a       => ramT_out.q_a,
      q_b       => ramT_out.q_b
    );
  --T1
  ram4_T1 : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ramT1_in.address_a,
      address_b => ramT1_in.address_b,
      data_a    => ramT1_in.data_a,
      data_b    => ramT1_in.data_b,
      wren_a    => ramT1_in.wren_a,
      wren_b    => ramT1_in.wren_b,
      q_a       => ramT1_out.q_a,
      q_b       => ramT1_out.q_b
    );
  --T0
  ram5_T0 : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ramT0_in.address_a,
      address_b => ramT0_in.address_b,
      data_a    => ramT0_in.data_a,
      data_b    => ramT0_in.data_b,
      wren_a    => ramT0_in.wren_a,
      wren_b    => ramT0_in.wren_b,
      q_a       => ramT0_out.q_a,
      q_b       => ramT0_out.q_b
    );
  --mat
  ram6_MAT : entity work.bramTwoPort(RTL)
    port map
    (
      clk       => clk,
      address_a => ramMat_in.address_a,
      address_b => ramMat_in.address_b,
      data_a    => ramMat_in.data_a,
      data_b    => ramMat_in.data_b,
      wren_a    => ramMat_in.wren_a,
      wren_b    => ramMat_in.wren_b,
      q_a       => ramMat_out.q_a,
      q_b       => ramMat_out.q_b
    );

end RTL;
