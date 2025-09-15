-- The Keccak sponge function, designed by Guido Bertoni, Joan Daemen,
-- Micha�l Peeters and Gilles Van Assche. For more information, feedback or
-- questions, please refer to our website: http://keccak.noekeon.org/

-- Implementation by the designers,
-- hereby denoted as "the implementer".

-- To the extent possible under law, the implementer has waived all copyright
-- and related or neighboring rights to the source code in this file.
-- http://creativecommons.org/publicdomain/zero/1.0/

library work;
use work.keccak_globals.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity keccak is
  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    start         : in  std_logic;
    din           : in  std_logic_vector(63 downto 0);
    din_valid     : in  std_logic;
    buffer_full   : out std_logic;
    last_block    : in  std_logic;
    shake_mode    : in  std_logic;  -- 0 = SHAKE128, 1 = SHAKE256
    ready         : out std_logic;
    dout          : out std_logic_vector(63 downto 0);
    dout_valid    : out std_logic
  );
end keccak;

architecture rtl of keccak is

  component keccak_round
    port (
      round_in               : in  k_state;
      round_constant_signal  : in  std_logic_vector(63 downto 0);
      round_out              : out k_state
    );
  end component;

  component keccak_round_constants_gen
    port (
      round_number             : in unsigned(4 downto 0);
      round_constant_signal_out: out std_logic_vector(63 downto 0)
    );
  end component;

  component keccak_buffer
    port (
      clk                   : in  std_logic;
      rst_n                 : in  std_logic;
      din_buffer_in         : in  std_logic_vector(63 downto 0);
      din_buffer_in_valid   : in  std_logic;
      last_block            : in  std_logic;
      shake_mode            : in  std_logic;
      din_buffer_full       : out std_logic;
      din_buffer_out        : out std_logic_vector(1343 downto 0);
      dout_buffer_in        : in  std_logic_vector(255 downto 0);
      dout_buffer_out       : out std_logic_vector(63 downto 0);
      dout_buffer_out_valid : out std_logic;
      ready                 : in  std_logic
    );
  end component;

  signal reg_data, round_in, round_out : k_state;
  signal reg_data_vector               : std_logic_vector(255 downto 0);
  signal counter_nr_rounds            : unsigned(4 downto 0);
  signal din_buffer_full              : std_logic;
  signal round_constant_signal        : std_logic_vector(63 downto 0);
  signal din_buffer_out               : std_logic_vector(1343 downto 0);
  signal permutation_computed         : std_logic;
  signal rate_bits                    : integer;

  signal dout_internal                : std_logic_vector(63 downto 0);
  signal dout_valid_internal          : std_logic;

begin

  --------------------------------------------------------------------------
  -- Component Instantiations
  --------------------------------------------------------------------------

  round_map : keccak_round
    port map (
      round_in              => round_in,
      round_constant_signal => round_constant_signal,
      round_out             => round_out
    );

  round_constants_gen : keccak_round_constants_gen
    port map (
      round_number             => counter_nr_rounds,
      round_constant_signal_out => round_constant_signal
    );

  buffer_in : keccak_buffer
    port map (
      clk                   => clk,
      rst_n                 => rst_n,
      din_buffer_in         => din,
      din_buffer_in_valid   => din_valid,
      last_block            => last_block,
      shake_mode            => shake_mode,
      din_buffer_full       => din_buffer_full,
      din_buffer_out        => din_buffer_out,
      dout_buffer_in        => reg_data_vector,
      dout_buffer_out       => dout_internal,
      dout_buffer_out_valid => dout_valid_internal,
      ready                 => permutation_computed
    );

  --------------------------------------------------------------------------
  -- Outputs
  --------------------------------------------------------------------------

  dout         <= dout_internal;
  dout_valid   <= dout_valid_internal;
  ready        <= permutation_computed;
  buffer_full  <= din_buffer_full;

  --------------------------------------------------------------------------
  -- Extract 256 bits from reg_data(0)(0..3) => reg_data_vector
  --------------------------------------------------------------------------

  extract_state: for x in 0 to 3 generate
    extract_bits: for i in 0 to 63 generate
      reg_data_vector(64 * x + i) <= reg_data(0)(x)(i);
    end generate;
  end generate;

  --------------------------------------------------------------------------
  -- FSM: SHAKE Permutation Control
  --------------------------------------------------------------------------

  p_main : process (clk, rst_n)
  begin
    if rst_n = '0' then
      for row in 0 to 4 loop
        for col in 0 to 4 loop
          for i in 0 to 63 loop
            reg_data(row)(col)(i) <= '0';
          end loop;
        end loop;
      end loop;
      counter_nr_rounds      <= (others => '0');
      permutation_computed   <= '1';

    elsif rising_edge(clk) then
      if start = '1' then
        for row in 0 to 4 loop
          for col in 0 to 4 loop
            for i in 0 to 63 loop
              reg_data(row)(col)(i) <= '0';
            end loop;
          end loop;
        end loop;
        counter_nr_rounds    <= (others => '0');
        permutation_computed <= '1';

      elsif din_buffer_full = '1' and permutation_computed = '1' then
        counter_nr_rounds    <= "00001";
        permutation_computed <= '0';
        reg_data             <= round_out;

      elsif counter_nr_rounds < 24 and permutation_computed = '0' then
        counter_nr_rounds    <= counter_nr_rounds + 1;
        reg_data             <= round_out;

        if counter_nr_rounds = 23 then
          permutation_computed <= '1';
          counter_nr_rounds    <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- Dynamic Absorption Rate Selection
  --------------------------------------------------------------------------

  rate_bits <= RATE_SHAKE128 when shake_mode = '0' else RATE_SHAKE256;

  --------------------------------------------------------------------------
  -- Absorption Logic: XOR incoming bits into state
  --------------------------------------------------------------------------

  p_absorb : process(reg_data, din_buffer_out, din_buffer_full, permutation_computed, rate_bits)
    variable bit_index : integer;
  begin
    for row in 0 to 4 loop
      for col in 0 to 4 loop
        for i in 0 to 63 loop
          bit_index := row * 320 + col * 64 + i;
          if bit_index < rate_bits then
            if din_buffer_full = '1' and permutation_computed = '1' then
              round_in(row)(col)(i) <= reg_data(row)(col)(i) xor din_buffer_out(bit_index);
            else
              round_in(row)(col)(i) <= reg_data(row)(col)(i);
            end if;
          else
            round_in(row)(col)(i) <= reg_data(row)(col)(i);
          end if;
        end loop;
      end loop;
    end loop;
  end process;

end rtl;

