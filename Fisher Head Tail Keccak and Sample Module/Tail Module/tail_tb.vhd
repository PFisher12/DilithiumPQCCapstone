-- tail_tb.vhd
-- Testbench for Tail module with RAM

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.GlobalVars.all;

entity tail_tb is
end tail_tb;

architecture Behavioral of tail_tb is

  -- Clock and reset
  signal clk        : std_logic := '0';
  signal reset      : std_logic := '1';
  signal start      : std_logic := '0';
  signal done       : std_logic;

  -- BRAM interface
  signal ram_addr   : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal ram_din    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ram_dout   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ram_we     : std_logic;
  signal ram_en     : std_logic;

  -- RAM memory
  type ram_type is array (0 to RAM_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ram : ram_type := (others => (others => '0'));

begin

  -- Clock process
  clk_process : process
  begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
  end process;

  -- Instantiate Tail Module
  uut: entity work.tail
    port map (
      clk      => clk,
      reset    => reset,
      start    => start,
      done     => done,
      ram_addr => ram_addr,
      ram_din  => ram_din,
      ram_dout => ram_dout,
      ram_en   => ram_en,
      ram_we   => ram_we
    );

  -- RAM read/write emulation
  process(clk)
  begin
    if rising_edge(clk) then
      if ram_en = '1' then
        if ram_we = '1' then
          ram(to_integer(unsigned(ram_addr))) <= ram_din;
        end if;
        ram_dout <= ram(to_integer(unsigned(ram_addr)));
      end if;
    end if;
  end process;

  -- Stimulus
  stimulus: process
  begin
    wait for 20 ns;
    reset <= '0';
    wait for 10 ns;
    start <= '1';
    wait for 10 ns;
    start <= '0';
    wait until done = '1';

    -- Check some RAM contents
    for i in 0 to 3 loop
      assert ram(i) = std_logic_vector(to_unsigned(i, DATA_WIDTH))
        report "RAM mismatch at index " & integer'image(i) severity error;
    end loop;

    wait;
  end process;

end Behavioral;
