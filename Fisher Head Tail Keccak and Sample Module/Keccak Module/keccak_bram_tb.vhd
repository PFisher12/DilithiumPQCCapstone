library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keccak_bram_tb is
end keccak_bram_tb;

architecture Behavioral of keccak_bram_tb is

  constant ADDR_WIDTH : integer := 4;
  constant DATA_WIDTH : integer := 64;
  constant RAM_DEPTH  : integer := 2**ADDR_WIDTH;

  signal clk     : std_logic := '0';
  signal reset   : std_logic := '1';
  signal start   : std_logic := '0';
  signal done    : std_logic;

  -- RAM interface signals
  signal ram_addr  : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal ram_din   : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal ram_dout  : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal ram_en    : std_logic;
  signal ram_we    : std_logic;

  -- Simple behavioral RAM model
  type ram_array_type is array (0 to RAM_DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal mem : ram_array_type := (others => (others => '0'));

begin
  ----------------------------------------------------------------
  -- Instantiate Unit Under Test (UUT)
  ----------------------------------------------------------------
  uut: entity work.keccak_bram
    generic map (
      ADDR_WIDTH => ADDR_WIDTH,
      DATA_WIDTH => DATA_WIDTH
    )
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
  -- RAM write/read process
  ----------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if ram_en = '1' then
        if ram_we = '1' then
          mem(to_integer(unsigned(ram_addr))) <= ram_din;
        end if;
        -- always drive ram_dout from the addressed location
        ram_dout <= mem(to_integer(unsigned(ram_addr)));
      end if;
    end if;
  end process;

  ----------------------------------------------------------------
  -- Clock generation: 100 MHz (10 ns period)
  ----------------------------------------------------------------
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
    end loop;
  end process;

  ----------------------------------------------------------------
  -- Stimulus process
  ----------------------------------------------------------------
  stim: process
  begin
    -- Apply reset
    reset <= '1';
    wait for 20 ns;
    reset <= '0';

    -- Start the absorb/squeeze
    wait for 20 ns;
    start <= '1';
    wait for 10 ns;
    start <= '0';

    -- Wait for done
    wait until done = '1';
    wait for 50 ns;

    -- End simulation
    wait;
  end process;

end Behavioral;
