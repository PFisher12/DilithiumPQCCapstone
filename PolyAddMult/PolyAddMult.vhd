library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;


entity PolyAddMult is
  port (
    --Control I/O
        --Inputs
        clk    : in std_logic;
        enable : in std_logic;
        Add_Mult_Select : in std_logic;
        --Outputs
        ready : out std_logic := '1';

    --RAM I/O
        --Inputs
        ram_out_a : in RAM_OUT;
        ram_out_b : in RAM_OUT;
        --Outputs
        ram_in_a  : out RAM_IN;
        ram_in_b  : out RAM_IN;
        ram_in_c  : out RAM_IN
  );

end PolyAddMult;

architecture RTL of PolyAddMult is

  --State Machine Vars
  signal address_s, address_next_s    : std_logic_vector(7 downto 0) := "00000000";  --Current location of calculation

  signal MontInput_a, MontInput_b : unsigned(63 downto 0) := (others => '0');
  signal MontOutput_a, MontOutput_b : unsigned (31 downto 0) := (others => '0');

  signal finish_s : std_logic := '0';

  --State Machine Vars
  type mode is (waiting, add, mult);
  signal mode_s : mode := waiting;


begin

    MontReducer_a : entity work.MontgomeryReducer(RTL)
    port map
    (
      a => MontInput_a,
      t => MontOutput_a
    );

    MontReducer_b : entity work.MontgomeryReducer(RTL)
    port map
    (
      a => MontInput_b,
      t => MontOutput_b
    );

    --add one cycle warmup / cooldown?
    
  sequential : process (clk)
  begin
    if(clk'event and clk = '1') then
      case mode_s is

          when waiting =>
            finish_s <= '0';
            address_s <= x"00";
            --Select add or multiply when enabled
            if(enable = '1') then
              case Add_Mult_Select is
                when '0' => 
                  mode_s <= add;
                when '1' => 
                  mode_s <= mult;
                when others =>  --Error case
                  mode_s <= waiting;
              end case;
            else --Module Disabled
              mode_s <= waiting;
            end if;

          when others =>

            if (address_next_s /= x"00") then
              address_s  <= address_next_s;
            elsif(finish_s = '1') then
              mode_s <= waiting;
              address_s <= x"00";
              finish_s <= '0';
            else
              finish_s <= '1';
            end if;

          end case;
    end if;
  end process;

  combinatorial: process(mode_s, ram_out_a, ram_out_b, MontOutput_a, MontOutput_b, address_s, finish_s) 
  begin
    case mode_s is
      when add => 
        MontInput_a <= (others => '0');
        MontInput_b <= (others => '0');
        ram_in_c.data_a <= std_logic_vector(unsigned(ram_out_a.q_a) + unsigned(ram_out_b.q_a));
        ram_in_c.data_b <= std_logic_vector(unsigned(ram_out_a.q_b) + unsigned(ram_out_b.q_b));
        ram_in_c.wren_a <= '1';
        ram_in_c.wren_b <= '1';
        ready <= '0';
      when mult =>
        MontInput_a <= unsigned(ram_out_a.q_a) * unsigned(ram_out_b.q_a);
        MontInput_b <= unsigned(ram_out_a.q_b) * unsigned(ram_out_b.q_b);
        ram_in_c.data_a <= std_logic_vector(MontOutput_a);
        ram_in_c.data_b <= std_logic_vector(MontOutput_b);
        ram_in_c.wren_a <= '1';
        ram_in_c.wren_b <= '1';
        ready <= '0';
      when others =>
        MontInput_a <= (others => '0');
        MontInput_b <= (others => '0');
        ram_in_c.data_a <= (others => '0');
        ram_in_c.data_b <= (others => '0');
        ram_in_c.wren_a <= '0';
        ram_in_c.wren_b <= '0';
        ready <= '1';
    end case;

    if(finish_s = '1') then
      ram_in_c.address_a <= x"FE";
      ram_in_c.address_b <= x"FF";
    elsif(unsigned(address_s) > 2) then
      ram_in_c.address_a <= std_logic_vector(unsigned(address_s) - 2);
      ram_in_c.address_b <= std_logic_vector(unsigned(address_s) - 1);
    else
      ram_in_c.address_a <= x"00";
      ram_in_c.address_b <= x"01";
    end if;
  end process;

  address_next_s <= std_logic_vector(unsigned(address_s) + 2);

  ram_in_a.wren_a <= '0';
  ram_in_a.wren_b <= '0';
  ram_in_b.wren_a <= '0';
  ram_in_b.wren_b <= '0';

  ram_in_a.address_a <= address_s;
  ram_in_a.address_b <= std_logic_vector(unsigned(address_s) + 1);
  ram_in_b.address_a <= address_s;
  ram_in_b.address_b <= std_logic_vector(unsigned(address_s) + 1);

  ram_in_a.data_a <= (others => '0');
  ram_in_a.data_b <= (others => '0');
  ram_in_b.data_a <= (others => '0');
  ram_in_b.data_b <= (others => '0');

end RTL;
