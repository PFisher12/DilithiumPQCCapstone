library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;


entity freeze is
  port (
    --Control I/O
        --Inputs
        clk    : in std_logic;
        enable : in std_logic;
        --Outputs
        ready : out std_logic;

    --RAM I/O
        --Inputs
        ram_out_a : in RAM_OUT;
        --Outputs
        ram_in_a  : out RAM_IN
  );

end freeze;

architecture RTL of freeze is

  --State Machine Vars
  signal address_s, address_next_s : std_logic_vector(8 downto 0);  --Current location of calculation

  signal result_1_r, result_2_r : unsigned(31 downto 0);

  --State Machine Vars
  type mode is (waiting, reduce);
  signal mode_s : mode := waiting;


begin
    
  sequential : process (clk)
    variable temp_1_v : unsigned(22 downto 0);
    variable temp_2_v : unsigned(21 downto 0);
    variable temp_3_v : unsigned(31 downto 0);

  begin
    if(clk'event and clk = '1') then
      case mode_s is

          when waiting =>
            address_s <= (others => '0');
            result_1_r <= (others => '0');
            result_2_r <= (others => '0');
            --Select reduce when enabled
            if(enable = '1') then
              mode_s <= reduce;
            else --Module Disabled
              mode_s <= waiting;
            end if;

          when others =>

            temp_1_v := unsigned(ram_out_a.q_a(22 downto 0));
            temp_2_v := unsigned(ram_out_a.q_a(31 downto 23) & "0000000000000");

            result_1_r(31 downto 23) <= (others => '0');
            result_1_r(22 downto 0) <= (temp_2_v - unsigned(ram_out_a.q_a(31 downto 23))) + temp_1_v;

            if(result_1_r >= unsigned(Q)) then
              result_2_r <= result_1_r - unsigned(Q);
            else
              result_2_r <= result_1_r;
            end if;

            --FIX
            if (address_next_s /= "100000011") then
              address_s <= address_next_s;
            else
              mode_s <= waiting;
            end if;

          end case;
    end if;
  end process;

  combinatorial: process(mode_s, address_next_s, address_s) 
  begin
    case mode_s is
      when reduce => 
        ready <= '0';

        if(address_next_s >= ('0' & x"04")) then
          ram_in_a.address_b <= std_logic_vector(unsigned(address_s(7 downto 0)) - 3);
          ram_in_a.wren_b <= '1';
        else
          ram_in_a.address_b <= (others => '0');
          ram_in_a.wren_b <= '0';
        end if;

      when others =>
        ready <= '1';
        ram_in_a.address_b <= (others => '0');
        ram_in_a.wren_b <= '0';
    end case;

  end process;
      
  address_next_s <= std_logic_vector(unsigned(address_s) + 1);

  ram_in_a.data_a <= (others => '0');
  ram_in_a.address_a <= address_s(7 downto 0);
  ram_in_a.wren_a <= '0';

  ram_in_a.data_b <= std_logic_vector(result_2_r);

end RTL;
