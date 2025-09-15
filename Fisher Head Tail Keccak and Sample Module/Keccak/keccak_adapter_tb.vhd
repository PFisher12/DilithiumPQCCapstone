library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak_adapter_tb is
end keccak_adapter_tb;

architecture tb of keccak_adapter_tb is

  constant ADDR_WIDTH_64 : integer := 4;
  constant ADDR_WIDTH_32 : integer := ADDR_WIDTH_64 + 1;
  constant RAM_DEPTH     : integer := 2**ADDR_WIDTH_32;

  signal clk      : std_logic := '0';
  signal reset    : std_logic := '1';
  signal start    : std_logic := '0';
  signal done     : std_logic;

  signal ram_addr : std_logic_vector(ADDR_WIDTH_32-1 downto 0);
  signal ram_din  : std_logic_vector(31 downto 0);
  signal ram_dout : std_logic_vector(31 downto 0);
  signal ram_en   : std_logic := '0';
  signal ram_we   : std_logic := '0';

  -- 32-bit behavioral RAM, init to all-1 so writes stand out
  type mem_t is array(0 to RAM_DEPTH-1) of std_logic_vector(31 downto 0);
  signal mem : mem_t := (others => x"FFFFFFFF");

begin

  ----------------------------------------------------------------
  -- Instantiate the adapter under test
  ----------------------------------------------------------------
  uut: entity work.keccak_adapter
    generic map (ADDR_WIDTH_64 => ADDR_WIDTH_64)
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

  ----------------------------------------------------------------
  -- Simple 32-bit RAM model
  ----------------------------------------------------------------
  ram_proc: process(clk)
  begin
    if rising_edge(clk) then
      if ram_en = '1' then
        if ram_we = '1' then
          mem(to_integer(unsigned(ram_addr))) <= ram_din;
        end if;
        ram_dout <= mem(to_integer(unsigned(ram_addr)));
      end if;
    end if;
  end process;

  ----------------------------------------------------------------
  -- 100 MHz clock
  ----------------------------------------------------------------
  clkgen: process
  begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
  end process;

  ----------------------------------------------------------------
  -- Stimulus: reset ? start ? wait for done ? dump RAM
  ----------------------------------------------------------------
  stim: process
    variable dec_val : integer;
  begin
    -- apply reset
    reset <= '1'; wait for 20 ns;
    reset <= '0'; wait for 20 ns;

    -- kick off absorb/squeeze
    start <= '1'; wait for 10 ns;
    start <= '0';

    -- wait for adapter to finish
    wait until done = '1';
    wait for 50 ns;

    -- dump memory contents (printed in decimal)
    for i in 0 to RAM_DEPTH-1 loop
      dec_val := to_integer(unsigned(mem(i)));
      report "RAM(" & integer'image(i) & ") = " & integer'image(dec_val);
    end loop;

    wait;
  end process;

end tb;

