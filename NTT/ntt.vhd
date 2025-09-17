library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--Note: Either switch NTT/INTT mode before the current iteration finishes OR switch it after and manually reset the block

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

  --Butterfly Vars
  signal butterfly_NTT_INTT_Select_s  : std_logic := '0';

  --State Machine Vars
  signal address_s, address_next_s    : std_logic_vector(7 downto 0) := "00000000";  --Current location of NTT, equiv to j variable in C
  signal offset_s, offset_next_s      : std_logic_vector(7 downto 0) := "10000000";  --8 bit offset, equiv to len variable in C
  signal start_s                      : std_logic_vector(7 downto 0) := "00000000";  --Equiv to start var in C
  signal start_next_s                 : std_logic_vector(8 downto 0) := "000000000"; --Extra carry bit is needed for proper incrementation

  --Zeta Vars
  signal zeta_address_s                                     : std_logic_vector(7 downto 0) := "00000001";
  signal zeta_forward_s, zeta_inverse_s, zeta_butterfly_s   : std_logic_vector(31 downto 0) := (others => '0'); --zeta input (size is diff from code);

  --State Machine Vars
  type state is (readRAM, writeRAM);
  signal state_s : state := readRAM;

  type mode is (waiting, NTT, INTT);
  signal mode_s : mode := waiting;


begin

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

  butterfly : entity work.butterfly(RTL)
    port map
    (
      --Control I/O
          --Inputs
          address => address_s,
          offset  => offset_s,
          zeta    => zeta_butterfly_s,
          NTT_INTT_Select => butterfly_NTT_INTT_Select_s,
      --RAM I/O
          --Inputs
          ram_out => ram_out_ntt,
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

        case mode_s is
          when NTT => mode_s <= NTT;
          when INTT => mode_s <= INTT;
          when others => mode_s <= waiting; --error case
        end case;

        --Calculate next butterfly values when the butterfly is done
        if(state_s = writeRAM) then
          state_s <= readRAM;
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
          else
            mode_s <= waiting;
          end if; --j check
        else
          state_s <= writeRAM;
        end if;

      --NTT/INTT Select Block
      else
        state_s <= readRAM;
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

  combinatorial: process(mode_s, state_s, offset_s, address_s, zeta_forward_s, zeta_inverse_s) 
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

    if(state_s = writeRAM) then
      ram_in_ntt.wren_a <= '1';
      ram_in_ntt.wren_b <= '1';
    else 
      ram_in_ntt.wren_a <= '0';
      ram_in_ntt.wren_b <= '0';
    end if;


        
  end process;


end RTL;