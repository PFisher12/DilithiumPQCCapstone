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
    signal pos_s : unsigned(8 downto 0);
    signal buf_addrs_a, buf_addrs_b : unsigned(7 downto 0);
    signal pos_inner_s : unsigned(2 downto 0);
    signal data_out_a_s, data_out_b_s : std_logic_vector(31 downto 0);
    
    constant ETA : unsigned(2 downto 0) := "111";

    type state is (startup, processing, done);
    signal state_s : state := done;


begin

    process (clk)
    
    variable ctr_v : unsigned(8 downto 0);
    variable t0_v, t1_v : std_logic_vector(2 downto 0);

    begin

        if(clk'event and clk = '1') then
            ctr_v := unsigned(ctr_s);
            if (state_s = processing or state_s = startup) then
                if (unsigned(ctr_s) >= len) then
                    state_s <= done;
                else

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
                            buf_addrs_a <= buf_addrs_a + 2;
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
                            buf_addrs_b <= buf_addrs_b + 2;
                        when others =>
                            null;
                    end case;

                    if (unsigned(t0_v) <= 2*ETA) then 
                        data_out_a_s <= std_logic_vector(unsigned(Q) + unsigned(ETA) - unsigned(t0_v));
                        ctr_v := ctr_v + 1;
                    end if;

                    if (unsigned(t1_v) <= 2*ETA and unsigned(ctr_s) < unsigned(N)) then 
                        data_out_b_s <= std_logic_vector(unsigned(Q) + unsigned(ETA) - unsigned(t1_v));
                        ctr_v := ctr_v + 1;
                    end if;

                    ctr_s <= std_logic_vector(ctr_v);
                    pos_s <= pos_s + 2;
                    pos_inner_s <= pos_inner_s + 1;

                    if (pos_s >= buflen) then 
                        state_s <= done;
                    end if;

                    state_s <= processing;

                end if;
            elsif(state_s = done) then
                ctr_s <= (others => '0');
                buf_addrs_a <= x"00";
                buf_addrs_b <= x"01";
                data_out_a_s <= (others => '0');
                data_out_b_s <= (others => '0');
                pos_s <= (others => '0');
                pos_inner_s <= "000";
                if (enable = '1') then
                    state_s <= startup;
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

    ram_in_a.address_a <= ctr_s(7 downto 0);
    ram_in_a.address_b <= std_logic_vector(unsigned(ctr_s(7 downto 0)) + 1);
    ram_in_a.data_a <= data_out_a_s;
    ram_in_a.data_b <= data_out_b_s;

    ram_in_buf.address_a <= std_logic_vector(buf_addrs_a);
    ram_in_buf.address_b <= std_logic_vector(buf_addrs_b);
    ram_in_buf.wren_a <= '0';
    ram_in_buf.wren_b <= '0';
    ram_in_buf.data_a <= (others => '0');
    ram_in_buf.data_b <= (others => '0');

    ctr <= unsigned(ctr_s);

end RTL;
