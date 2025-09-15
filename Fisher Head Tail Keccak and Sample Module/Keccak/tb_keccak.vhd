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
library std;
  use std.textio.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_misc.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_textio.all;
  use ieee.std_logic_unsigned."+";

entity keccak_tb is
end keccak_tb;

architecture tb of keccak_tb is

  component keccak
    port (
      clk     : in  std_logic;
      rst_n   : in  std_logic;
      start   : in  std_logic;
      din     : in  std_logic_vector(63 downto 0);
      din_valid : in std_logic;
      buffer_full : out std_logic;
      last_block : in std_logic;
      ready : out std_logic;
      dout : out std_logic_vector(63 downto 0);
      dout_valid : out std_logic;
      shake_mode : in std_logic  -- '0' = SHAKE128, '1' = SHAKE256
    );
  end component;

  signal clk, rst_n : std_logic;
  signal dout, din : std_logic_vector(63 downto 0);
  signal start, din_val, buffer_full, last_block, ready, dout_valid : std_logic;
  signal shake_mode : std_logic := '1';  -- Default: SHAKE256

  type st_type is (INIT, read_first_input, st0, st1, END_HASH1, END_HASH2, STOP);
  signal st : st_type;

begin

  keccak_map : keccak port map(
    clk, rst_n, start, din, din_val, buffer_full, last_block, ready,
    dout, dout_valid, shake_mode
  );

  rst_n <= '0', '1' after 19 ns;

  p_main: process (clk, rst_n)
    variable counter, count_hash, num_test: integer;
    variable line_in, line_out : line;
    variable temp: std_logic_vector(63 downto 0);
    file filein : text open read_mode is "../test_vectors/keccak_in.txt";
    file fileout : text open write_mode is "../test_vectors/keccak_out_high_speed_vhdl.txt";
  begin
    if rst_n = '0' then
      st <= INIT;
      counter := 0;
      din <= (others => '0');
      din_val <= '0';
      last_block <= '0';
      count_hash := 0;
    elsif rising_edge(clk) then
      case st is
        when INIT =>
          readline(filein, line_in);
          read(line_in, num_test);
          st <= read_first_input;
          start <= '1';
          din_val <= '0';

        when read_first_input =>
          start <= '0';
          readline(filein, line_in);
          if line_in(1) = '.' then
            FILE_CLOSE(filein);
            FILE_CLOSE(fileout);
            assert false report "Simulation completed" severity failure;
            st <= STOP;
          elsif line_in(1) = '-' then
            st <= END_HASH1;
          else
            din_val <= '1';
            hread(line_in, temp);
            din <= temp;
            st <= st0;
            counter := 0;
          end if;

        when st0 =>
          if counter < 16 then
            if counter < 15 then
              readline(filein, line_in);
              hread(line_in, temp);
              din <= temp;
            end if;
            counter := counter + 1;
            din_val <= '1';
            st <= st0;
          else
            din_val <= '0';
            st <= st1;
          end if;

        when st1 =>
          if buffer_full = '1' then
            st <= st1;
          else
            st <= read_first_input;
          end if;

        when END_HASH1 =>
          if ready = '0' then
            st <= END_HASH1;
          else
            last_block <= '1';
            st <= END_HASH2;
            counter := 0;
          end if;

        when END_HASH2 =>
          last_block <= '0';
          if dout_valid = '1' then
            temp := dout;
            hwrite(line_out, temp);
            writeline(fileout, line_out);
            if counter < 3 then
              counter := counter + 1;
            else
              st <= read_first_input;
              start <= '1';
              write(line_out, string'("-"));
              writeline(fileout, line_out);
            end if;
          end if;

        when STOP =>
          null;
      end case;
    end if;
  end process;

  clkgen : process
  begin
    clk <= '1';
    loop
      wait for 10 ns;
      clk <= not clk;
    end loop;
  end process;

end tb;

