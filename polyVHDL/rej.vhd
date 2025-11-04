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

        ready : out std_logic := '0'

    -- --RAM I/O
    --     --Inputs
    --     ram_out_a : in RAM_OUT;
    --     ram_out_buf : in RAM_OUT;
    --     --Outputs
    --     ram_in_a  : out RAM_IN; 
    --     ram_in_buf  : out RAM_IN
    );

end rej;

architecture RTL of rej is

    signal ctr, pos : std_logic_vector(31 downto 0) := (others => '0');
    signal t0, t1 : std_logic_vector(7 downto 0) := (others => '0');

    type state is (processing, done);
    signal state_s : state := done;

begin

    process (clk)

    begin

        if(clk'event and clk = '1') then
            if (state_s = processing) then
                
                if (unsigned(ctr) = (len - 5)) then
                    
                    state_s <= done;
                else
                    --ctr <= std_logic_vector(unsigned(ctr) + 1);
                end if;
            elsif(state_s = done) then
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
            when processing =>
                ready <= '0';
            when others =>
                ready <= '0';
        end case;
    
    end process;

end RTL;