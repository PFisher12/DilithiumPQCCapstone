library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--VHDL code for the pipelined butterfly module. Reads and writes to the same RAM
--t = montgomery_reduce((uint64_t)zeta * p[j + len]);
--p[j + len] = p[j] + 2*Q - t;
--p[j] = p[j] + t;
--2 clock cycle process

entity butterfly is
  port (
    --Control I/O
        --Inputs
        clk             : in std_logic;
        enable          : in std_logic;
        address         : in std_logic_vector(7 downto 0); --Current location of NTT, equiv to j variable in C
        offset          : in std_logic_vector(7 downto 0); --8 bit offset, equiv to len variable in C
        zeta            : in std_logic_vector(31 downto 0); --zeta input (size is diff from code)
        NTT_INTT_Select : in std_logic;
        --Outputs
        butterfly_done  : out std_logic;

    --RAM I/O
        --Inputs
        ram_out         : in RAM_OUT;
        --Outputs
        ram_in          : out RAM_IN
  );

end butterfly;

architecture RTL of butterfly is

  --Montgom Signals
  signal montgomeryReducerIn_s  : unsigned(63 downto 0); --Input to montgomery reducer
  signal montgomeryReducerOut_s : unsigned(31 downto 0); --Output of montgomery reduction fn, equiv to variable t in C-
  signal montgomeryReducerIn_INTT_a_s   : unsigned (63 downto 0);
  signal montgomeryReducerIn_INTT_b_s   : unsigned (63 downto 0);
  signal montgomeryReducerOut_INTT_a_s  : unsigned (31 downto 0);
  signal montgomeryReducerOut_INTT_b_s  : unsigned (31 downto 0);

  --State Machine Signals
  type state is (set, writeback);
  signal state_s  : state     := set;

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

  --Add two addition Montgomery Reducers for final INTT loop
  INTTMontgomeryReducer_a : entity work.MontgomeryReducer(RTL)
    port map
    (
      --Data I/O
          --Inputs
          a => montgomeryReducerIn_INTT_a_s,
          --Outputs
          t => montgomeryReducerOut_INTT_a_s
    );

  INTTMontgomeryReducer_b : entity work.MontgomeryReducer(RTL)
    port map
    (
      --Data I/O
          --Inputs
          a => montgomeryReducerIn_INTT_b_s,
          --Outputs
          t => montgomeryReducerOut_INTT_b_s
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

  
  combinatorial : process (ram_out.q_a, ram_out.q_b, offset, montgomeryReducerOut_s, address, state_s, zeta, NTT_INTT_Select, montgomeryReducerOut_INTT_a_s, montgomeryReducerOut_INTT_b_s)
  
  --2*Q
  variable Q2_v : unsigned(31 downto 0) := x"00FFC002";

  --256*Q
  variable Q256_v : unsigned(31 downto 0) := x"7FE00100";

  --(MONT*MONT % Q) * (Q-1) % Q) * ((Q-1) >> 8) % Q;
  variable f_v : unsigned(31 downto 0) := x"0000A3FA";

  begin

    --Declare incremented address values
    ram_in.address_a <= address;                                                --a = p[j]
    ram_in.address_b <= std_logic_vector(unsigned(address) + unsigned(offset)); --b = p[j+len]


    case NTT_INTT_Select is  
      when '0' => --NTT
        --Calculate Montgomery as soon as memory is ready
        montgomeryReducerIn_s <= unsigned(zeta) * unsigned(ram_out.q_b);
        montgomeryReducerIn_INTT_a_s <= (others => '0');
        montgomeryReducerIn_INTT_b_s <= (others => '0');

        --Calculate p[j] and p[j+len]
        ram_in.data_a <= std_logic_vector(unsigned(ram_out.q_a) + montgomeryReducerOut_s);         --p[j]
        ram_in.data_b <= std_logic_vector(unsigned(ram_out.q_a) + Q2_v - montgomeryReducerOut_s);  --p[j+len]

      when '1' => --INTT
        --Calculate Montgomery as soon as memory is ready
        montgomeryReducerIn_s <= (unsigned(zeta) * (unsigned(ram_out.q_a) + Q256_v - unsigned(ram_out.q_b)));
        montgomeryReducerIn_INTT_a_s <= (unsigned(ram_out.q_a) + unsigned(ram_out.q_b)) * f_v;
        montgomeryReducerIn_INTT_b_s <= montgomeryReducerOut_s * f_v;

        if(offset = x"80") then
          --Check if the INTT is in its last iteration, if so add additional montgomery factor
          ram_in.data_a <= std_logic_vector(montgomeryReducerOut_INTT_a_s);
          ram_in.data_b <= std_logic_vector(montgomeryReducerOut_INTT_b_s);
        else
          --Otherwise operate as normal and calculate p[j] and p[j+len]
          ram_in.data_a <= std_logic_vector(unsigned(ram_out.q_a) + unsigned(ram_out.q_b));
          ram_in.data_b <= std_logic_vector(montgomeryReducerOut_s);
        end if;
      when others => null;   --error case
    end case;     

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
