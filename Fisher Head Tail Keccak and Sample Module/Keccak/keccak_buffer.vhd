-- The Keccak sponge function, designed by Guido Bertoni, Joan Daemen,
-- Michaël Peeters and Gilles Van Assche. For more information, feedback or
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
  use ieee.numeric_std.all;

entity keccak_buffer is
  port (
    clk                  : in  std_logic;
    rst_n                : in  std_logic;
    din_buffer_in        : in  std_logic_vector(63 downto 0);
    din_buffer_in_valid  : in  std_logic;
    last_block           : in  std_logic;
    shake_mode           : in  std_logic;  -- NEW: 0 = SHAKE128, 1 = SHAKE256
    din_buffer_full      : out std_logic;
    din_buffer_out       : out std_logic_vector(1343 downto 0); -- output buffer
    dout_buffer_in       : in  std_logic_vector(255 downto 0);
    dout_buffer_out      : out std_logic_vector(63 downto 0);
    dout_buffer_out_valid: out std_logic;
    ready                : in  std_logic
  );
end keccak_buffer;

architecture rtl of keccak_buffer is

  signal mode               : std_logic;  -- 0 = input mode, 1 = output mode
  signal buffer_full        : std_logic;
  signal count_in_words     : unsigned(4 downto 0);
  signal buffer_data        : std_logic_vector(1343 downto 0);
  signal rate_words         : integer range 0 to 21;
  signal rate_bits          : integer range 0 to 1344;

begin

  -- Dynamic rate selection (SHAKE128: 1344 bits = 21 words; SHAKE256: 1088 bits = 17 words)
  rate_bits  <= 1344 when shake_mode = '0' else 1088;
  rate_words <= 21   when shake_mode = '0' else 17;

  ----------------------------------------------------------------------------
  -- Main process for both absorbing and squeezing
  ----------------------------------------------------------------------------
  p_main : process (clk, rst_n)
    variable count_out_words: integer range 0 to 4;
  begin
    if rst_n = '0' then
      buffer_data           <= (others => '0');
      count_in_words        <= (others => '0');
      count_out_words       := 0;
      buffer_full           <= '0';
      mode                  <= '0';
      dout_buffer_out_valid <= '0';

    elsif rising_edge(clk) then

      if last_block = '1' and ready = '1' then
        mode <= '1'; -- switch to output mode
      end if;

      -- ================================
      -- Absorbing mode (input side)
      -- ================================
      if mode = '0' then
        dout_buffer_out_valid <= '0';  -- turn off output flag

        if buffer_full = '1' and ready = '1' then
          buffer_full    <= '0';
          count_in_words <= (others => '0');

        elsif din_buffer_in_valid = '1' and buffer_full = '0' then
          -- shift buffer left
          for i in 0 to rate_words - 2 loop
            buffer_data(63 + i*64 downto i*64) <= buffer_data(127 + i*64 downto 64 + i*64);
          end loop;

          -- insert new input word at the top
          buffer_data(rate_bits-1 downto rate_bits-64) <= din_buffer_in;

          -- update word count
          if count_in_words = to_unsigned(rate_words - 1, 5) then
            buffer_full    <= '1';
            count_in_words <= (others => '0');
          else
            count_in_words <= count_in_words + 1;
          end if;
        end if;

      -- ================================
      -- Squeezing mode (output side)
      -- ================================
      else
        dout_buffer_out_valid <= '1';

        if count_out_words = 0 then
          buffer_data(255 downto 0) <= dout_buffer_in;
          count_out_words := 1;

        elsif count_out_words < 4 then
          -- shift buffer left
          for i in 0 to 2 loop
            buffer_data(63 + i*64 downto i*64) <= buffer_data(127 + i*64 downto 64 + i*64);
          end loop;
          count_out_words := count_out_words + 1;

        else
          dout_buffer_out_valid <= '0';
          count_out_words := 0;
          mode <= '0';  -- switch back to input mode
        end if;

      end if;  -- mode

    end if;  -- rising_edge
  end process;

  ----------------------------------------------------------------------------
  -- Output assignments
  ----------------------------------------------------------------------------
  din_buffer_out        <= buffer_data;
  dout_buffer_out       <= buffer_data(63 downto 0);
  din_buffer_full       <= buffer_full;

end rtl;

