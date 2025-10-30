library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

entity expandMat is 
  port (
    --Control I/O
      --Inputs
      clk     : in std_logic;
      enable  : in std_logic;
      --Outputs
      expandMat_ready : out std_logic;
    --Ram I/O
      --Inputs
      ram_out_expand_buf  : in RAM_OUT;
      --Outputs
      ram_in_expand_buf   : out RAM_IN;
      ram_in_expand_coeff   : out RAM_IN
  );
end entity;

architecture RTL of expandMat is 

  type mode is (Waiting, Operation);
  signal mode_s : mode := Waiting;
  type RAM_state is (Read_A, Read_B);
  signal RAM_state_s : RAM_state := Read_A;
  signal value_a_s, value_b_s, data_a_s, data_b_s : std_logic_vector(31 downto 0);
  signal ram_r_address_s, ram_w_address_a_s : unsigned(7 downto 0) := (others => '0');
  signal ctr_s : integer := 0;

  begin
    
    combinatorial : process(mode_s, RAM_state_s, ram_out_expand_buf.q_a, ram_out_expand_buf.q_b)
    begin
      case mode_s is  
        when Operation =>
          case RAM_state_s is  
            when Read_A =>
              value_a_s(31 downto 23) <= (others =>'0');
              value_b_s(31 downto 23) <= (others =>'0');
            
              value_a_s(22 downto 0) <= ram_out_expand_buf.q_a(22 downto 0);
              value_b_s(22 downto 0) <= ram_out_expand_buf.q_b(14 downto 0) & ram_out_expand_buf.q_a(31 downto 24);

            when Read_B =>
              value_a_s(31 downto 23) <= (others =>'0');
              value_b_s(31 downto 23) <= (others =>'0');
              
              value_a_s(22 downto 0) <= ram_out_expand_buf.q_b(6 downto 0) & ram_out_expand_buf.q_a(31 downto 16);
              value_b_s(22 downto 0) <= ram_out_expand_buf.q_b(30 downto 8);

            when others =>
              value_a_s(31 downto 0) <= (others =>'0');
              value_b_s(31 downto 0) <= (others =>'0');  
          end case;
          ram_in_expand_coeff.wren_a <= '1';
          ram_in_expand_coeff.wren_a <= '1';

        when others => --This is both the Waiting and error state
          value_a_s(31 downto 0) <= (others =>'0');
          value_b_s(31 downto 0) <= (others =>'0');
          ram_in_expand_coeff.wren_a <= '0';
          ram_in_expand_coeff.wren_a <= '0';
      end case;

    end process;

    ram_in_expand_coeff.address_a <= std_logic_vector(ram_w_address_a_s);
    ram_in_expand_coeff.address_b <= std_logic_vector(ram_w_address_a_s + 1);
    ram_in_expand_coeff.data_a <= data_a_s;
    ram_in_expand_coeff.data_b <= data_b_s;
    ram_in_expand_buf.address_a <= std_logic_vector(ram_r_address_s);
    ram_in_expand_buf.address_b <= std_logic_vector(ram_r_address_s + 1);
    ram_in_expand_buf.wren_a <= '0';
    ram_in_expand_buf.wren_b <= '0';
    ram_in_expand_buf.data_a <= (others => '0');
    ram_in_expand_buf.data_b <= (others => '0');

    sequential : process(clk)
    begin
      if(clk'event and clk = '1') then
        case mode_s is 
          when Operation =>
            case RAM_state_s is  
              when Read_A =>
                ram_r_address_s <= ram_r_address_s + 1;
                RAM_state_s <= Read_B;
              when Read_B =>
                ram_r_address_s <= ram_r_address_s + 2;
                RAM_state_s <= Read_A;
            end case;

            --State machine for write logic
            if(unsigned(value_a_s) < unsigned(Q) and unsigned(value_b_s) < unsigned(Q)) then
              data_a_s <= value_a_s;
              data_b_s <= value_b_s;
              ram_w_address_a_s <= ram_w_address_a_s + 2;
              ctr_s <= ctr_s + 2;
            elsif (unsigned(value_a_s) < unsigned(Q)) then
              data_a_s <= value_a_s;
              ram_w_address_a_s <= ram_w_address_a_s + 1;
              ctr_s <= ctr_s + 1;
            elsif (unsigned(value_b_s) < unsigned(Q)) then
              data_a_s <= value_b_s;
              ram_w_address_a_s <= ram_w_address_a_s + 1;
              ctr_s <= ctr_s + 1;
            end if;
            
            --If address goes above 255, set state to done
            if (ctr_s >= 256) then 
              mode_s <= Waiting;
            else
              mode_s <= Operation;
            end if;

          when Waiting =>
            if (enable = '1') then
              mode_s <= Operation;
              expandMat_ready <= '0';
            else
              ram_r_address_s <= "00000000";
              ram_w_address_a_s <= "00000000";

              data_a_s <= (others => '0');
              data_b_s <= (others => '0');

              value_a_s <= (others => '0');
              value_b_s <= (others => '0');

              expandMat_ready <= '1';
              ctr_s <= 0;
              RAM_state_s <= Read_A;
            end if; 
        end case;

      end if;
    end process;
    
end RTL;