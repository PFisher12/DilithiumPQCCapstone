----------------------------------------------------------------------------------
-- Name: polyveck_power2round
--   For each coefficient a of polynomials in a vector of length K,
--   compute a0 and a1 such that a = a1 * 2^D + a0,
--   with -2^(D/2) < a0 <= 2^(D/2).
--   ram_b is a0, ram_c is a1
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

entity power2round is
  generic (
    D : integer := 14   -- power2round parameter (Dilithium: D=14)
  );
  port (
    clk     : in std_logic;
    enable   : in std_logic;
    ready    : out std_logic;

  --RAM I/O
      --Inputs
      ram_out_a : in RAM_OUT;
      --Outputs
      ram_in_a  : out RAM_IN;
      ram_in_b  : out RAM_IN;
      ram_in_c  : out RAM_IN

  );
end entity;


architecture RTL of power2round is

  --State Machine Vars
  signal address_s, address_next_s : std_logic_vector(8 downto 0);  --Current location of calculation

  signal result_b_a_r, result_b_b_r, result_c_a_r, result_c_b_r : signed(31 downto 0);

  constant zeros : signed(D-1 downto 0) := (others => '0');

  --State Machine Vars
  type mode is (waiting, round);
  signal mode_s : mode := waiting;

begin
    
  sequential : process (clk)
    variable temp_1_v, temp_2_v, temp_3_v, temp_4_v : signed(31 downto 0);
  begin
    if(clk'event and clk = '1') then
      case mode_s is

          when waiting =>
            address_s <= (others => '0');
            result_b_a_r <= (others => '0');
            result_b_b_r <= (others => '0');
            result_c_a_r <= (others => '0');
            result_c_b_r <= (others => '0');
            --Select round when enabled
            if(enable = '1') then
              mode_s <= round;
            else --Module Disabled
              mode_s <= waiting;
            end if;

          when others =>
            
            temp_1_v := signed(ram_out_a.q_a(D - 1 downto 0)) - x"00002001";
            temp_2_v := signed(ram_out_a.q_b(D - 1 downto 0)) - x"00002001";

            if(temp_1_v(31) = '1') then
              temp_1_v := temp_1_v + x"00004000";
            end if;

            if(temp_2_v(31) = '1') then
              temp_2_v := temp_2_v + x"00004000";
            end if;

            temp_1_v := temp_1_v - x"00001FFF";
            temp_2_v := temp_2_v - x"00001FFF";

            result_b_a_r <= temp_1_v + signed(Q);
            result_b_b_r <= temp_2_v + signed(Q);

            temp_3_v := signed(ram_out_a.q_a) - temp_1_v;
            temp_4_v := signed(ram_out_a.q_b) - temp_2_v;

            result_c_a_r <= zeros & temp_3_v(31 downto D);
            result_c_b_r <= zeros & temp_4_v(31 downto D);


            if (address_next_s /= "100000100") then
              address_s <= address_next_s;
            else
              mode_s <= waiting;
            end if;

          end case;
    end if;
  end process;

  combinatorial: process(mode_s, address_s) 
  begin
    case mode_s is
      when round => 
        ready <= '0';
        if(address_s >= ('0' & x"04")) then
          ram_in_b.wren_a <= '1';
          ram_in_b.wren_b <= '1';
          ram_in_c.wren_a <= '1';
          ram_in_c.wren_b <= '1';
          ram_in_b.address_a <= std_logic_vector(unsigned(address_s(7 downto 0)) - 4);
          ram_in_b.address_b <= std_logic_vector(unsigned(address_s(7 downto 0)) - 3);
          ram_in_c.address_a <= std_logic_vector(unsigned(address_s(7 downto 0)) - 4);
          ram_in_c.address_b <= std_logic_vector(unsigned(address_s(7 downto 0)) - 3);
        else
          ram_in_b.wren_a <= '0';
          ram_in_b.wren_b <= '0';
          ram_in_c.wren_a <= '0';
          ram_in_c.wren_b <= '0';
          ram_in_b.address_a <= (others => '0');
          ram_in_b.address_b <= (others => '0');
          ram_in_c.address_a <= (others => '0');
          ram_in_c.address_b <= (others => '0');
        end if;

      when others =>
        ready <= '1';
        ram_in_b.wren_a <= '0';
        ram_in_b.wren_b <= '0';
        ram_in_c.wren_a <= '0';
        ram_in_c.wren_b <= '0';
        ram_in_b.address_a <= (others => '0');
        ram_in_b.address_b <= (others => '0');
        ram_in_c.address_a <= (others => '0');
        ram_in_c.address_b <= (others => '0');
    end case;

  end process;
      
  address_next_s <= std_logic_vector(unsigned(address_s) + 2);

  ram_in_a.data_a <= (others => '0');
  ram_in_a.data_b <= (others => '0');
  ram_in_a.address_a <= address_s(7 downto 0);
  ram_in_a.address_b <= std_logic_vector(unsigned(address_s(7 downto 0)) + 1);
  ram_in_a.wren_a <= '0';
  ram_in_a.wren_b <= '0';


  ram_in_b.data_a <= std_logic_vector(result_b_a_r);
  ram_in_b.data_b <= std_logic_vector(result_b_b_r);

  ram_in_c.data_a <= std_logic_vector(result_c_a_r);
  ram_in_c.data_b <= std_logic_vector(result_c_b_r);


end RTL;
