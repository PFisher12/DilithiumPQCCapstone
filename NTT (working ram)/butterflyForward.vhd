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
    --Butterfly I/O
    address : in std_logic_vector(7 downto 0); --Current location of NTT, equiv to j variable in C
    offset  : in std_logic_vector(6 downto 0); --7 bit offset, equiv to len variable in C
    zeta    : in unsigned(31 downto 0); --zeta input (size is diff from code)
    enable  : in std_logic;
    clk     : in std_logic; --Clock input
    --RAM I/O
    address_a : out std_logic_vector (7 downto 0);
    address_b : out std_logic_vector (7 downto 0);
    data_a    : out std_logic_vector (31 downto 0);
    data_b    : out std_logic_vector (31 downto 0);
    wren_a    : out std_logic;
    wren_b    : out std_logic;
    q_a       : in std_logic_vector (31 downto 0);
    q_b       : in std_logic_vector (31 downto 0)

  );

end butterflyForward;
architecture behav of butterflyForward is

  --Montgom Signals
  signal montgomeryReducerIn_s  : unsigned(63 downto 0); --Input to montgomery reducer
  signal montgomeryReducerOut_s : unsigned(31 downto 0); --Output of montgomery reduction fn, equiv to variable t in C-

  --State Machine Signals
  type state is (set, writeback);
  signal state_s  : state     := set;
  signal enable_s : std_logic := '0';

  --2*Q
  signal Q_s : unsigned(31 downto 0) := x"00FFC002";

begin

  --Assign the montgomeryReduced variables to the I/O of the montgomeryReduced function
  butterflyMontgomeryReducer : entity work.MontgomeryReducer(behav)
    port map
    (
      a => montgomeryReducerIn_s,
      t => montgomeryReducerOut_s
    );
  --Calcuate Butterfly
  sequential : process (clk)
  begin
    if (clk'event and clk = '1') then
      case state_s is
        when set =>
          --ensures that the first state properly loads on startup
          if (enable_s = '0' and enable = '1') then
            enable_s <= '1';
          end if;

          --Change state if enable is high
          if (enable_s = '1') then
            state_s <= writeback;
          else
            state_s <= set;
          end if;

        when writeback =>
          --Write p[j] and p[j+len] into memory (write enable is turned on in this state)
          state_s <= set;

        when others =>
          state_s <= set;

      end case;
    end if;
  end process;
  combinatorial : process (q_a, q_b, offset, montgomeryReducerOut_s, address, state_s, zeta)
  begin
    --Declare correct address values
    address_a <= address; --a = p[j]
    address_b <= std_logic_vector(unsigned(address) + unsigned(offset)); --b = p[j+len]

    --Calculate Montgomery as soon as memory is ready
    montgomeryReducerIn_s <= zeta * unsigned(q_b);

    --Calculate p[j] and p[j+len]
    data_b <= std_logic_vector(unsigned(q_a) + Q_s - montgomeryReducerOut_s);
    data_a <= std_logic_vector(unsigned(q_a) + montgomeryReducerOut_s);

    --Set write enable to high in writeback
    if (state_s = writeback) then
      wren_a <= '1';
      wren_b <= '1';
    else
    	wren_a <= '0';
    	wren_b <= '0';
    end if;

  end process;

end behav;
