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
        reset  : in std_logic;
        NTT_INTT_Select : in std_logic;

    --RAM I/O
        --Inputs
        ram_out_ntt : in RAM_OUT;
        --Outputs
        ram_in_ntt  : out RAM_IN  --Mux output
  );

end ntt;

architecture RTL of ntt is

  --Butterfly Vars
  signal butterfly_done_s         : std_logic := '0';
  signal butterfly_enable_s       : std_logic := '0';
  signal address_s                : std_logic_vector(7 downto 0) := "00000000";  --Current location of NTT, equiv to j variable in C
  signal address_next_s           : std_logic_vector(7 downto 0) := "00000000";
  signal offset_s                 : std_logic_vector(7 downto 0) := "10000000";  --8 bit offset, equiv to len variable in C
  signal offset_next_s            : std_logic_vector(7 downto 0) := "10000000";
  signal start_s                  : std_logic_vector(7 downto 0) := "00000000";  --Equiv to start var in C
  signal start_next_s             : std_logic_vector(8 downto 0) := "000000000"; --Extra carry bit is needed for proper incrementation

  --Zeta Vars
  signal zeta_address_s           : std_logic_vector(7 downto 0) := "00000001";
  signal zeta_forward_s           : std_logic_vector(31 downto 0); --zeta input (size is diff from code)
  signal zeta_inverse_s           : std_logic_vector(31 downto 0); --zeta input (size is diff from code)

  --State Machine Vars
  type state is (len, start, j);
  signal state_s : state := j;

  type direction is (up, down);
  signal direction_s : direction := down;

  type mode is (waiting, NTT, INTT);
  signal mode_s : mode := waiting;

  signal state_change_s : std_logic := '0';
  signal ntt_done_s     : std_logic := '0';

begin

  zetaForwardRom : entity work.ZetaForwardROM(SYN)
    port map
    (
      --RAM I/O
          --Inputs
          clock   => clk,
          address => zeta_address_s,
          --Outputs
          q       => zeta_forward_s
    );

    zetaInverseRom : entity work.ZetaInverseROM(SYN)
    port map
    (
      --RAM I/O
          --Inputs
          clock   => clk,
          address => zeta_address_s,
          --Outputs
          q       => zeta_inverse_s
    );

  Forwardbutterfly : entity work.butterflyForward(RTL)
    port map
    (
      --Control I/O
          --Inputs
          clk     => clk,
          enable  => butterfly_enable_s,
          address => address_s,
          offset  => offset_s,
          zeta    => zeta_forward_s,
          --Outputs
          butterfly_done    => butterfly_done_s,
      --RAM I/O
          --Inputs
          ram_out => ram_out_ntt,
          --Outputs
          ram_in  => ram_in_ntt
    );


  combinatorial : process (offset_s, offset_next_s, start_s, start_next_s, 
    address_s, address_next_s, mode_s, enable, reset, ntt_done_s, NTT_INTT_Select,
    state_s, direction_s, butterfly_done_s)

  begin

    --NTT / INTT Select Block
    if(mode_s = waiting and enable = '1') then
      case NTT_INTT_Select is
        when '0' => mode_s <= NTT;
        when '1' => mode_s <= INTT;
        when others => mode_s <= waiting;
      end case;
    end if;

    --Reset Block
    if((ntt_done_s = '1') or (reset = '1')) then

      --Control / State machine Variables
      mode_s          <= waiting;
      ntt_done_s      <= '0';
      state_s         <= j;
      direction_s     <= down;
      butterfly_enable_s <= '0';

      --Indexing Variables
      case NTT_INTT_Select is
        when '0' =>     --NTT
          offset_s        <= x"80";
          offset_next_s   <= x"80";
          zeta_address_s  <= x"01";
        when '1' =>     --INTT
          offset_s        <= x"01";
          offset_next_s   <= x"01";
          zeta_address_s  <= x"00";
        when others => --error case
          offset_s        <= x"80";
          offset_next_s   <= x"80";
          zeta_address_s  <= x"01";
      end case;

      start_s         <= x"00";
      start_next_s    <= (others => '0');
      address_s       <= x"00";
      address_next_s  <= x"00";
    end if;

    --Main Block
    if (mode_s /= waiting) then

      butterfly_enable_s <= '1';

      --Precalculate next values to preemt state changes
      case NTT_INTT_Select is
        when '0' => offset_next_s <= std_logic_vector(shift_right(unsigned(offset_s), 1));  --NTT
        when '1' => offset_next_s <= std_logic_vector(shift_left(unsigned(offset_s), 1));   --INTT
        when others => offset_next_s <= (others => '0'); --error case
      end case;
      start_next_s <= std_logic_vector(('0' & unsigned(address_s) + unsigned(offset_s)) + 1);
      address_next_s <= std_logic_vector(unsigned(address_s) + 1);

    --Tri state state machine to properly index to all necessary addresses 
    --needed to perform the butterfly in the correct order with the proper 
    --twiddle factors included
      case state_s is
        --Offset loop
        when len =>
          case direction_s is
            when up =>
              if (offset_next_s /= x"00") then
                --Increment to next len state
                offset_s <= offset_next_s;
                direction_s <= down;
              else
                --NTT Done, update done signal
                ntt_done_s <= '1';
              end if;
            when down =>
              --Goto start loop
              start_s  <= x"00";
              state_s <= start;
          end case;
            
        --start loop
        when start =>
            case direction_s is
              when up =>
                --Check if it has reached its max value
                if (start_next_s(8) /= '1') then
                  start_s <= start_next_s(7 downto 0);
                  direction_s <= down;
                else
                  state_s <= len;
                end if;
              when down =>
                --Make current start value the input address of the butterfly
                address_s <= start_s;
                --increment zeta_s
                zeta_address_s <= std_logic_vector(unsigned(zeta_address_s) + 1);
                --Goto J
                state_s <= j;
            end case;          

        --J loop
        when j =>
          case direction_s is
            when up =>
              --Increment the innermost loops
              --Check if it has reached its max value
              if (address_next_s /= std_logic_vector(unsigned(start_s) + unsigned(offset_s))) then
                --If not, continue the increment
                address_s <= address_next_s;
                direction_s <= down;
              else
                --If so, change states
                state_s <= start;
              end if;
            when down =>
              --After butterfly, set direction to up
                if(butterfly_done_s = '1' and butterfly_done_s'event) then --(((ram_in_internal_s.wren_a or ram_in_internal_s.wren_a) = '0') and (butterfly_done_s = '1'))     (butterfly_done_s = '1' and butterfly_done_s'event)
                  --Select butterfly up or down
                  direction_s <= up;
                end if;
            end case;
        when others =>
          --reset?
      end case;
    end if;
  end process;


end RTL;