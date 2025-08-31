library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--VHDL code for the pipelined butterfly module. Reads and writes to the same RAM
--t = montgomery_reduce((uint64_t)zeta * p[j + len]);
--p[j + len] = p[j] + 2*Q - t;
--p[j] = p[j] + t;
--2 clock cycle process

entity butterflyForward is
  port (
    --Control I/O
        --Inputs
        clk             : in std_logic;
        enable          : in std_logic;
        address         : in std_logic_vector(7 downto 0); --Current location of NTT, equiv to j variable in C
        offset          : in std_logic_vector(7 downto 0); --8 bit offset, equiv to len variable in C
        zeta            : in std_logic_vector(31 downto 0); --zeta input (size is diff from code)
        --Outputs
        butterfly_done  : out std_logic;

    --RAM I/O
        --Inputs
        ram_out         : in RAM_OUT;
        --Outputs
        ram_in          : out RAM_IN
  );

end butterflyForward;
architecture RTL of butterflyForward is

  --Montgom Signals
  signal montgomeryReducerIn_s  : unsigned(63 downto 0); --Input to montgomery reducer
  signal montgomeryReducerOut_s : unsigned(31 downto 0); --Output of montgomery reduction fn, equiv to variable t in C-

  --State Machine Signals
  type state is (set, writeback);
  signal state_s  : state     := set;

  --2*Q
  signal Q_s : unsigned(31 downto 0) := x"00FFC002";

begin

  --Assign the montgomeryReduced variables to the I/O of the montgomeryReduced function
  butterflyMontgomeryReducer : entity work.MontgomeryReducer(RTL)
    port map
    (
      --Data I/O
          --Inputs
          a => montgomeryReducerIn_s,
          --Outputs
          t => montgomeryReducerOut_s
    );

  --Calcuate Butterfly
  sequential : process (clk)
  begin
    if (clk'event and clk = '1') then
      case state_s is
        when set =>
          --Change state if enable is high
          butterfly_done <= '0';
          if (enable = '1') then
            state_s <= writeback;
          else
            state_s <= set;
          end if;

        when writeback =>
          --Write p[j] and p[j+len] into memory (RAM write enable is turned on in this state)
          butterfly_done <= '1';
          state_s <= set;

        when others =>
          state_s <= set;

      end case;
    end if;
  end process;

  
  combinatorial : process (ram_out.q_a, ram_out.q_b, offset, montgomeryReducerOut_s, address, state_s, zeta)
  begin
    --Declare correct address values
    ram_in.address_a <= address; --a = p[j]
    ram_in.address_b <= std_logic_vector(unsigned(address) + unsigned(offset)); --b = p[j+len]

    --Calculate Montgomery as soon as memory is ready
    montgomeryReducerIn_s <= unsigned(zeta) * unsigned(ram_out.q_b);

    --Calculate p[j] and p[j+len]
    ram_in.data_b <= std_logic_vector(unsigned(ram_out.q_a) + Q_s - montgomeryReducerOut_s);
    ram_in.data_a <= std_logic_vector(unsigned(ram_out.q_a) + montgomeryReducerOut_s);

    --Set write enable to high in writeback
    if (state_s = writeback) then
      ram_in.wren_a <= '1';
      ram_in.wren_b <= '1';
    else
    	ram_in.wren_a <= '0';
    	ram_in.wren_b <= '0';
    end if;

  end process;

end RTL;
