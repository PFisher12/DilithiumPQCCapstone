--NTT.vhd
--This module acts as the top level module that connects the twiddle factors stored in ROM 
--and butterfly module needed for the actual calculations. 
--If enable is switched high whilst ready is active, the module will work until completion. 
--NTT_INTT_Select selects either the forward NTT or inverse NTT computation. 0 = forward and 1 = inverse
--No reset is used for now, though it may be added later if the design necissates one.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

entity ntt is

  port (
    --Control I/O
        --Inputs
        clk    : in std_logic;
        enable : in std_logic;
        NTT_INTT_Select : in std_logic;
        --Outputs
        ntt_ready : out std_logic := '0';

    --RAM I/O
        --Inputs
        ram_out_ntt : in RAM_OUT;
        --Outputs
        ram_in_ntt  : out RAM_IN  --Mux output
  );

end ntt;

architecture RTL of ntt is

  --Butterfly Signals
  signal butterfly_NTT_INTT_Select_s  : std_logic := '0';
  signal MONT_Mode_s                  : std_logic := '0';
  signal ram_out_ntt_s                : RAM_OUT := RAM_OUT_INITIALIZE;

  --State Machine Signals
  signal address_s, address_next_s    : std_logic_vector(7 downto 0) := "00000000";  --Current location of NTT, equiv to j variable in C
  signal offset_s, offset_next_s      : std_logic_vector(7 downto 0) := "10000000";  --8 bit offset, equiv to len variable in C
  signal start_s                      : std_logic_vector(7 downto 0) := "00000000";  --Equiv to start var in C
  signal start_next_s                 : std_logic_vector(8 downto 0) := "000000000"; --Extra carry bit is needed for proper incrementation

  --Zeta Signals
  signal zeta_address_s                                     : std_logic_vector(7 downto 0) := "00000001";
  signal zeta_forward_s, zeta_inverse_s, zeta_butterfly_s   : std_logic_vector(31 downto 0) := (others => '0'); --zeta input (size is diff from code);

  --State Machine Signals
  type state is (readDualPort, writeDualPort, writeSinglePort);
  signal state_s : state := readDualPort;

  type mode is (waiting, NTT, INTT);
  signal mode_s : mode := waiting;


begin

  --Instantiate the two ROMS with the precalculated twiddle factors
  zetaForwardRom : entity work.romForwardZetas(RTL)
    port map
    (
      --RAM I/O
          --Inputs
          clk     => clk,
          address => zeta_address_s,
          --Outputs
          q       => zeta_forward_s
    );

    zetaInverseRom : entity work.romInverseZetas(RTL)
    port map
    (
      --RAM I/O
          --Inputs
          clk     => clk,
          address => zeta_address_s,
          --Outputs
          q       => zeta_inverse_s
    );

  --Instantate the butterfly module and feed it all values needed for computation
  butterfly : entity work.butterfly(RTL)
    port map
    (
      --Control I/O
          --Inputs
          address => address_s,
          offset  => offset_s,
          zeta    => zeta_butterfly_s,
          NTT_INTT_Select => butterfly_NTT_INTT_Select_s,
          MONT_Mode => MONT_Mode_s,
      --RAM I/O
          --Inputs
          ram_out => ram_out_ntt_s,
          --Outputs
          address_a => ram_in_ntt.address_a,
          address_b => ram_in_ntt.address_b,
          data_a    => ram_in_ntt.data_a,
          data_b    => ram_in_ntt.data_b
    );


  sequential : process (clk)
  begin
    if(clk'event and clk = '1') then
      --NTT/INTT on
      if(mode_s /= waiting) then
        --Calculate next butterfly values when the butterfly is done
        if(state_s = writeDualPort) then
          state_s <= readDualPort;
          if (address_next_s /= std_logic_vector(unsigned(start_s) + unsigned(offset_s))) then
            address_s  <= address_next_s;
          --start check
          elsif(start_next_s(8) /= '1') then
            start_s <= start_next_s(7 downto 0);
            address_s  <= start_next_s(7 downto 0);
            zeta_address_s <= std_logic_vector(unsigned(zeta_address_s) + 1);
          --len check
          elsif(offset_next_s /= x"00") then
            offset_s <= offset_next_s;
            start_s  <= x"00";
            address_s  <= x"00";
            zeta_address_s <= std_logic_vector(unsigned(zeta_address_s) + 1);
          --INTT Done but still needs montgomery run through
          elsif(mode_s = INTT) then
            --state_s <= writeSinglePort;
            state_s <= readDualPort;
            MONT_Mode_s <= '1';
            address_s  <= x"00";
            start_s  <= x"00";
            offset_s <= x"00";
            zeta_address_s <= x"00";
          else
            mode_s <= waiting;
          end if; --j check
        --Montgomery Runthrough
        elsif(state_s = writeSinglePort) then
          --Increment montgomery addressing
          address_s  <= address_next_s;

          --Check for finish conditions
          if(address_next_s = x"00") then
            mode_s <= waiting;
            state_s <= readDualPort;
            MONT_Mode_s <= '0';
          end if;

        else
          case MONT_Mode_s is
            when '0' =>
              state_s <= writeDualPort;
            when '1' =>
              offset_s <= x"01";
              state_s <= writeSinglePort;
            when others => --error case
              state_s <= readDualPort;
          end case;
        end if;

      --NTT/INTT Select Block
      else
        state_s <= readDualPort;
        case NTT_INTT_Select is
          when '0' =>     --NTT
            offset_s        <= x"80";
            zeta_address_s  <= x"01";
          when '1' =>     --INTT
            offset_s        <= x"01";
            zeta_address_s  <= x"00";
          when others =>  --Error Case
            offset_s        <= x"80";
            zeta_address_s  <= x"01";
        end case;
        start_s         <= x"00";
        address_s       <= x"00";
        MONT_Mode_s     <= '0';
        --Select NTT/INTT if the module is enabled
        if(enable = '1') then
          case NTT_INTT_Select is
            when '0' => 
              mode_s <= NTT;
            when '1' => 
              mode_s <= INTT;
            when others =>  --Error case
              mode_s <= waiting;
          end case;
        else --NTT disabled
          mode_s <= waiting;
        end if; --Enable if
      end if; --mode check if
    end if; --clk event if
  end process;

  combinatorial: process(mode_s, state_s, offset_s, address_s, zeta_forward_s, zeta_inverse_s, ram_out_ntt) 
  begin
    --Precalculate next values to preemt state changes
    case mode_s is
      when NTT =>
        offset_next_s <= std_logic_vector(shift_right(unsigned(offset_s), 1));
        zeta_butterfly_s <= zeta_forward_s;
        ntt_ready <= '0';
        butterfly_NTT_INTT_Select_s <= '0';
      when INTT =>
        offset_next_s <= std_logic_vector(shift_left(unsigned(offset_s), 1));
        zeta_butterfly_s <= zeta_inverse_s;
        ntt_ready <= '0';
        butterfly_NTT_INTT_Select_s <= '1';
      when others =>
        offset_next_s <= std_logic_vector(shift_right(unsigned(offset_s), 1));
        zeta_butterfly_s <= zeta_forward_s;
        ntt_ready <= '1';
        butterfly_NTT_INTT_Select_s <= '0';
    end case;
    start_next_s <= std_logic_vector(('0' & unsigned(address_s) + unsigned(offset_s)) + 1);
    address_next_s <= std_logic_vector(unsigned(address_s) + 1);

    --Set the proper write enables based on the current state
    case state_s is
      when writeDualPort => 
        ram_in_ntt.wren_a <= '1';
        ram_in_ntt.wren_b <= '1';
        ram_out_ntt_s <= ram_out_ntt;
      when writeSinglePort =>
        ram_in_ntt.wren_a <= '1';
        ram_in_ntt.wren_b <= '0';
        ram_out_ntt_s.q_a <= ram_out_ntt.q_b;
        ram_out_ntt_s.q_b <= (others => '0');
      when others =>
        ram_in_ntt.wren_a <= '0';
        ram_in_ntt.wren_b <= '0';
        ram_out_ntt_s <= ram_out_ntt;
     end case;
        
  end process;


end RTL;