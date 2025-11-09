library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

entity rej is
    port (
        
        clk : in std_logic;
        enable : in std_logic;
        len : in unsigned (31 downto 0);
        buflen : in unsigned (31 downto 0);

        ctr : out unsigned (8 downto 0);
        ready : out std_logic;

    --RAM I/O
        --Inputs
        ram_out_buf : in RAM_OUT;
        --Outputs
        ram_in_a  : out RAM_IN; 
        ram_in_buf  : out RAM_IN
    );

end rej;

architecture RTL of rej is

    signal ctr_s : std_logic_vector(8 downto 0);
    signal data_addrs_s : std_logic_vector(7 downto 0);
    signal pos_s : unsigned(8 downto 0);
    signal buf_addrs_a_s, buf_addrs_b_s : unsigned(7 downto 0);
    signal pos_inner_s : unsigned(2 downto 0);
    signal data_out_a_s, data_out_b_s : std_logic_vector(31 downto 0);
    
    constant ETA : unsigned(2 downto 0) := "111";

    type state is (processing, done);
    signal state_s : state := done;


begin

    process (clk)
    
    variable ctr_v : unsigned(8 downto 0);
    variable t0_v, t1_v : std_logic_vector(2 downto 0);

    begin

        if(clk'event and clk = '1') then
            ctr_v := unsigned(ctr_s);
            if (state_s = processing) then
                --If all addresses have been written to, exit the loop
                if (unsigned(ctr_s) >= len) then
                    state_s <= done;
                else

                    --Take the random buffer values to generate t0/t1
                    case pos_inner_s is
                        when "000" =>
                            t0_v := ram_out_buf.q_a(2 downto 0);
                            t1_v := ram_out_buf.q_a(7 downto 5);
                        when "001" =>
                            t0_v := ram_out_buf.q_a(10 downto 8);
                            t1_v := ram_out_buf.q_a(15 downto 13);
                        when "010" =>
                            t0_v := ram_out_buf.q_a(18 downto 16);
                            t1_v := ram_out_buf.q_a(23 downto 21);
                        when "011" =>
                            t0_v := ram_out_buf.q_a(26 downto 24);
                            t1_v := ram_out_buf.q_a(31 downto 29);
                            buf_addrs_a_s <= buf_addrs_a_s + 2;
                        when "100" =>
                            t0_v := ram_out_buf.q_b(2 downto 0);
                            t1_v := ram_out_buf.q_b(7 downto 5);
                        when "101" =>
                            t0_v := ram_out_buf.q_b(10 downto 8);
                            t1_v := ram_out_buf.q_b(15 downto 13);
                        when "110" =>
                            t0_v := ram_out_buf.q_b(18 downto 16);
                            t1_v := ram_out_buf.q_b(23 downto 21);
                        when "111" =>
                            t0_v := ram_out_buf.q_b(26 downto 24);
                            t1_v := ram_out_buf.q_b(31 downto 29);
                            buf_addrs_b_s <= buf_addrs_b_s + 2;
                        when others =>
                            null;
                    end case;

                    --If t0/t1 are within bounds, add them to the current RAM value
                    if (unsigned(t0_v) <= 2*ETA) then 
                        data_out_a_s <= std_logic_vector(unsigned(Q) + unsigned(ETA) - unsigned(t0_v));
                        ctr_v := ctr_v + 1;
                    end if;

                    if (unsigned(t1_v) <= 2*ETA and unsigned(ctr_s) < unsigned(N)) then 
                        data_out_b_s <= std_logic_vector(unsigned(Q) + unsigned(ETA) - unsigned(t1_v));
                        ctr_v := ctr_v + 1;
                    end if;

                    --Increment the internal counter signals every cycle
                    ctr_s <= std_logic_vector(ctr_v);
                    pos_s <= pos_s + 2;
                    pos_inner_s <= pos_inner_s + 1;

                    --Delay the address incrementing by 1 cycle by registering it
                    data_addrs_s <= ctr_s(7 downto 0);

                    --If the buffer is empty, exit the looop
                    if (pos_s >= buflen) then 
                        state_s <= done;
                    end if;

                end if;
            elsif(state_s = done) then
                ctr_s <= (others => '0');
                buf_addrs_a_s <= x"00";
                buf_addrs_b_s <= x"01";
                data_out_a_s <= (others => '0');
                data_out_b_s <= (others => '0');
                pos_s <= (others => '0');
                pos_inner_s <= "000";
                data_addrs_s <= (others => '0');
                if (enable = '1') then
                    state_s <= processing;
                end if;
            end if;
        end if;
    end process;

    process (state_s)
    begin

        case state_s is
            when done =>
                ready <= '1';
                ram_in_a.wren_a <= '0';
                ram_in_a.wren_b <= '0';
            when processing =>
                ready <= '0';
                ram_in_a.wren_a <= '1';
                ram_in_a.wren_b <= '1';
            when others =>
                ready <= '0';
                ram_in_a.wren_a <= '0';
                ram_in_a.wren_b <= '0';
        end case;

    end process;

    ram_in_a.address_a <= data_addrs_s;
    ram_in_a.address_b <= std_logic_vector(unsigned(data_addrs_s) + 1);
    ram_in_a.data_a <= data_out_a_s;
    ram_in_a.data_b <= data_out_b_s;

    ram_in_buf.address_a <= std_logic_vector(buf_addrs_a_s);
    ram_in_buf.address_b <= std_logic_vector(buf_addrs_b_s);
    ram_in_buf.wren_a <= '0';
    ram_in_buf.wren_b <= '0';
    ram_in_buf.data_a <= (others => '0');
    ram_in_buf.data_b <= (others => '0');

    ctr <= unsigned(ctr_s);

end RTL;
