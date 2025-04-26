-- tailKeccakIntegration.vhd (now self-running Tail → Keccak integration)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tailKeccakIntegration is
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;

        input_data      : in  std_logic_vector(31 downto 0);
        input_valid     : in  std_logic;

        output_data     : out std_logic_vector(63 downto 0);
        output_valid    : out std_logic
    );
end entity;

architecture rtl of tailKeccakIntegration is

    -- Tail outputs
    signal high_bits_out  : std_logic_vector(31 downto 0);
    signal low_bits_dummy : std_logic_vector(31 downto 0);

    -- Keccak control and data
    signal keccak_din        : std_logic_vector(1087 downto 0) := (others => '0');
    signal keccak_dout       : std_logic_vector(63 downto 0);
    signal keccak_start      : std_logic := '0';
    signal keccak_din_valid  : std_logic := '0';
    signal keccak_last_block : std_logic := '0';

    -- FSM control
    type state_type is (IDLE, LOAD, STREAM, WAIT_DONE);
    signal state : state_type := IDLE;

    signal word_counter : integer range 0 to 16 := 0;

begin

    -- Tail: Decompose
    decompose_inst : entity work.decompose
        port map (
            r  => input_data,
            a0 => low_bits_dummy,
            a1 => high_bits_out
        );

    -- Keccak
    keccak_inst : entity work.keccak
        port map (
            clk         => clk,
            rst_n       => rst_n,
            start       => keccak_start,
            din         => keccak_din(63 downto 0),
            din_valid   => keccak_din_valid,
            last_block  => keccak_last_block,
            dout        => keccak_dout
        );

    -- FSM to run Tail → Keccak once per input trigger
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state               <= IDLE;
            keccak_din_valid    <= '0';
            keccak_last_block   <= '0';
            keccak_start        <= '0';
            word_counter        <= 0;
            output_valid        <= '0';
            output_data         <= (others => '0');

        elsif rising_edge(clk) then
            -- Default control
            keccak_start      <= '0';
            keccak_din_valid  <= '0';
            keccak_last_block <= '0';
            output_valid      <= '0';

            case state is
                when IDLE =>
                    if input_valid = '1' then
                        keccak_din <= (others => '0');
                        keccak_din(31 downto 0) <= high_bits_out;
                        word_counter <= 0;
                        keccak_start <= '1';
                        state <= STREAM;
                    end if;

                when STREAM =>
                    keccak_din_valid <= '1';
                    if word_counter = 16 then
                        keccak_last_block <= '1';
                        state <= WAIT_DONE;
                    end if;
                    if word_counter < 16 then
                        word_counter <= word_counter + 1;
                    end if;

                when WAIT_DONE =>
                    output_data <= keccak_dout;
                    output_valid <= '1';
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end architecture;
