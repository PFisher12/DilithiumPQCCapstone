library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;


entity Add2 is
  port (
    --Control I/O
        --Inputs
        clk    : in std_logic;
        enable : in std_logic;
        --Outputs
        ready : out std_logic := '1';

    --RAM I/O
        --Inputs
        ram_out_a : in RAM_OUT;
        ram_out_b : in RAM_OUT;
        --Outputs
        ram_in_a  : out RAM_IN;
        ram_in_b  : out RAM_IN
  );

end Add2;

architecture RTL of Add2 is

  --State Machine Vars
  signal address_s, address_next_s    : std_logic_vector(7 downto 0);  --Current location of calculation

  signal finish_s, rw_r : std_logic;

  --State Machine Vars
  type mode is (waiting, add);
  signal mode_s : mode := waiting;


begin


  sequential : process (clk)
  begin
    if(clk'event and clk = '1') then
      case mode_s is

          when waiting =>
            finish_s <= '0';
            rw_r <= '0';
            address_s <= x"00";
            --Select add or multiply when enabled
            if(enable = '1') then
              mode_s <= add;
            else --Module Disabled
              mode_s <= waiting;
            end if;

          when others =>

            if(address_next_s /= x"00") then
              if(rw_r = '0') then
                rw_r <= '1';
              else
                address_s  <= address_next_s;
                rw_r <= '0';
              end if;
            elsif(finish_s = '1') then
              mode_s <= waiting;
              address_s <= x"00";
              finish_s <= '0';
              rw_r <= '0';
            else
              finish_s <= '1';
              rw_r <= '1';
            end if;

          end case;
    end if;
  end process;

  combinatorial: process(mode_s, rw_r) 
  begin
    case mode_s is
      when add => 
        ready <= '0';
      when others =>
        ready <= '1';
    end case;

    case rw_r is
      when '1' =>
        ram_in_b.wren_a <= '1';
        ram_in_b.wren_b <= '1';
      when others =>
        ram_in_b.wren_a <= '0';
        ram_in_b.wren_b <= '0';
    end case;
  end process;

  address_next_s <= std_logic_vector(unsigned(address_s) + 2);

  ram_in_b.address_a <= address_s;
  ram_in_b.address_b <= std_logic_vector(unsigned(address_s) + 1);

  ram_in_b.data_a <= std_logic_vector(unsigned(ram_out_a.q_a) + unsigned(ram_out_b.q_a));
  ram_in_b.data_b <= std_logic_vector(unsigned(ram_out_a.q_b) + unsigned(ram_out_b.q_b));

  ram_in_a.wren_a <= '0';
  ram_in_a.wren_b <= '0';

  ram_in_a.address_a <= address_s;
  ram_in_a.address_b <= std_logic_vector(unsigned(address_s) + 1);

  ram_in_a.data_a <= (others => '0');
  ram_in_a.data_b <= (others => '0');

end RTL;
