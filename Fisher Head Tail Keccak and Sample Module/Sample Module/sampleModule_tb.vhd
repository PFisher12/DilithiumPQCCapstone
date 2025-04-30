-- sampleModule_tb.vhd (testbench with direct entity instantiation)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.GlobalVars.all;

entity sampleModule_tb is
end sampleModule_tb;

architecture Behavioral of sampleModule_tb is

  signal clk         : std_logic := '0';
  signal reset       : std_logic := '1';
  signal sampleStart : std_logic := '0';
  signal keccakIn    : std_logic_vector(255 downto 0) := (others => '0');
  signal sampleValid : std_logic;
  signal sampleOut   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal indexOut    : std_logic_vector(7 downto 0);

  signal ram_addr    : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal ram_din     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ram_dout    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ram_en      : std_logic;
  signal ram_we      : std_logic;

  -- simple RAM model
  type ram_type is array (0 to RAM_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ram : ram_type := (others => (others => '0'));

begin

  -- Clock generation
  clk_process : process
  begin
    clk <= '0'; wait for 5 ns;
    clk <= '1'; wait for 5 ns;
  end process;

  -- Connect DUT (unit under test)
  uut: entity work.sampleModule
    port map (
      clk         => clk,
      reset       => reset,
      sampleStart => sampleStart,
      keccakIn    => keccakIn,
      sampleValid => sampleValid,
      sampleOut   => sampleOut,
      indexOut    => indexOut,
      ram_addr    => ram_addr,
      ram_din     => ram_din,
      ram_dout    => ram_dout,
      ram_en      => ram_en,
      ram_we      => ram_we
    );

  -- Simple RAM behavior
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
  stim_proc: process
  begin
    reset <= '1'; wait for 20 ns;
    reset <= '0'; wait for 20 ns;
    keccakIn <= x"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
    sampleStart <= '1'; wait for 20 ns;
    sampleStart <= '0';
    wait for 2000 ns;
    wait;
  end process;

end Behavioral;