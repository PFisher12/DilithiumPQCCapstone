--Butterfly.vhd
--Acts as the calculation component of the NTT. Uses a montgomery reducer module to deal with the modulus.
--2 clock cycle process
--Reads and writes to the same RAM

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;


entity butterfly is
  port (
    --Control I/O
        --Inputs
        address         : in std_logic_vector(7 downto 0); --Current location of NTT, equiv to j variable in C
        offset          : in std_logic_vector(7 downto 0); --8 bit offset, equiv to len variable in C
        zeta            : in std_logic_vector(31 downto 0); --zeta input (size is diff from code)
        NTT_INTT_Select : in std_logic; --Selects either the NTT or INTT calculations
        MONT_Mode       : in std_logic; --Set high on the last loop of the INTT

    --RAM I/O
        --Inputs
        ram_out         : in RAM_OUT;
        --Outputs
        address_a       : out std_logic_vector(7 downto 0);
        address_b       : out std_logic_vector(7 downto 0);
        data_a          : out std_logic_vector(31 downto 0);
        data_b          : out std_logic_vector(31 downto 0)

  );

end butterfly;

architecture RTL of butterfly is

  --Montgom Signals
  signal montgomeryReducerIn_s  : unsigned(63 downto 0); --Input to montgomery reducer
  signal montgomeryReducerOut_s : unsigned(31 downto 0); --Output of montgomery reduction

begin

  --Instantiate the montgomery reducer with the signals above
  butterflyMontgomeryReducer : entity work.MontgomeryReducer(RTL)
    port map
    (
      --Data I/O
          --Inputs
          a => montgomeryReducerIn_s,
          --Outputs
          t => montgomeryReducerOut_s
    );

  
  combinatorial : process (ram_out.q_a, ram_out.q_b, offset, address, zeta, NTT_INTT_Select, montgomeryReducerOut_s, MONT_Mode)
  
  --TODO: is it better to have these constants within the process or outside as signals?
  --2*Q
  constant Q2_v : unsigned(31 downto 0) := x"00FFC002";

  --256*Q
  constant Q256_v : unsigned(31 downto 0) := x"7FE00100";

  --(MONT*MONT % Q) * (Q-1) % Q) * ((Q-1) >> 8) % Q;
  constant f_v : unsigned(31 downto 0) := x"0000A3FA";

  begin

    --Declare incremented address values
    address_a <= address;                                                --a = p[j]
    address_b <= std_logic_vector(unsigned(address) + unsigned(offset)); --b = p[j+len]

    case NTT_INTT_Select is  
      when '0' => --NTT

        --Calculate Montgomery as soon as memory is ready
        montgomeryReducerIn_s <= unsigned(zeta) * unsigned(ram_out.q_b);
        --Calculate p[j] and p[j+len]
        data_a <= std_logic_vector(unsigned(ram_out.q_a) + montgomeryReducerOut_s);         --p[j]
        data_b <= std_logic_vector(unsigned(ram_out.q_a) + Q2_v - montgomeryReducerOut_s);  --p[j+len]

      when '1' => --INTT

        case MONT_Mode is
          when '0' => --Standard INTT calculation

            --Calculate Montgomery as soon as memory is ready
            montgomeryReducerIn_s <= (unsigned(zeta) * (unsigned(ram_out.q_a) + Q256_v - unsigned(ram_out.q_b)));
            --Otherwise operate as normal and calculate p[j] and p[j+len]
            data_a <= std_logic_vector(unsigned(ram_out.q_a) + unsigned(ram_out.q_b));
            data_b <= std_logic_vector(montgomeryReducerOut_s);

          when '1' => --Unique to the last loop of the INTT

            montgomeryReducerIn_s <= unsigned(ram_out.q_a) * f_v;
            data_a <= std_logic_vector(montgomeryReducerOut_s);
            data_b <= (others => '0');

          when others =>     --error case, used to prevent latches
            montgomeryReducerIn_s <= (others => '0');
            data_a <= (others => '0');
            data_b <= (others => '0');
        end case;
      when others =>     --error case, used to prevent latches
        montgomeryReducerIn_s <= (others => '0');
        data_a <= (others => '0');
        data_b <= (others => '0');
    end case;     
  end process;

end RTL;
