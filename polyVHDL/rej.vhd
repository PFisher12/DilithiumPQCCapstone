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
        ctr : out unsigned (7 downto 0);

        ready : out std_logic := '0';

    --RAM I/O
        --Inputs
        ram_out_buf : in RAM_OUT;
        --Outputs
        ram_in_a  : out RAM_IN; 
        ram_in_buf  : out RAM_IN
    );

end rej;

architecture RTL of rej is

    signal ctr_s : std_logic_vector(7 downto 0) := (others => '0');
    signal pos_s : std_logic_vector(8 downto 0) := (others => '0');
    signal t0_s, t1_s : std_logic_vector(7 downto 0) := (others => '0');
    constant ETA : unsigned(2 downto 0) := "111";

    type state is (processing, done);
    signal state_s : state := done;

begin

    process (clk)
    
    variable ctr_v : unsigned(7 downto 0) := (others => '0');

    begin

        if(clk'event and clk = '1') then
            ctr_v := unsigned(ctr_s);
            if (state_s = processing) then
                if (unsigned(ctr_s) >= len) then
                    state_s <= done;
                else
                    --t0_s <= placeholder
                    --t1_s <= placeholder
                    if (unsigned(t0_s) <= 2*ETA) then 
                        ram_in_a.data_a <= std_logic_vector(unsigned(Q) + unsigned(ETA) - unsigned(t0_s));
                        ctr_v := ctr_v + 1;
                    end if;
                    if (unsigned(t1_s) <= 2*ETA and unsigned(ctr_s) < unsigned(N)) then 
                        ram_in_a.data_b<= std_logic_vector(unsigned(Q) + unsigned(ETA) - unsigned(t1_s));
                        ctr_v := ctr_v + 1;
                    end if;
                    ctr_s <= std_logic_vector(ctr_v);
                    if (unsigned(pos_s) >= buflen) then 
                        state_s <= done;
                    end if;
                end if;
            elsif(state_s = done) then
                ctr <= unsigned(ctr_s);
                ctr_s <= (others => '0');
                pos_s <= (others => '0');
                if (enable = '1') then
                    state_s <= processing;
                end if;
            end if;
        end if;
    end process;

    process (state_s, ctr_s)
    
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
        
        ram_in_a.address_a <= ctr_s;
        ram_in_a.address_b <= std_logic_vector(unsigned(ctr_s) + 1);

    end process;

end RTL;