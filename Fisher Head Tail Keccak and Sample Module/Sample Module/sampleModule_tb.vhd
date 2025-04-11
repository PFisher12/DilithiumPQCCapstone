-- Updated sampleModule_tb.vhd with BRAM integration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sampleModule_tb is
end sampleModule_tb;

architecture test of sampleModule_tb is
  component sampleModule
    Port (
      keccakOut   : in  std_logic_vector(31 downto 0);
      sampleOut   : out std_logic_vector(7 downto 0);
      indexOut    : out integer range 0 to 255;
      sampleValid : out std_logic
    );
  end component;

  -- Testbench signals
  signal keccakOut   : std_logic_vector(31 downto 0);
  signal sampleOut   : std_logic_vector(7 downto 0);
  signal indexOut    : integer range 0 to 255;
  signal sampleValid : std_logic;

  -- Simulated BRAM
  type bram_type is array(0 to 255) of std_logic_vector(7 downto 0);
  signal sampleBRAM : bram_type := (others => (others => '0'));

begin
  -- Unit Under Test
  uut: sampleModule
    port map (
      keccakOut   => keccakOut,
      sampleOut   => sampleOut,
      indexOut    => indexOut,
      sampleValid => sampleValid
    );

  -- Stimulus process
  stim_proc: process
  begin
    -- Test 1
    keccakOut <= x"12345678";  -- indexOut = 86
    wait for 10 ns;

    -- Test 2
    keccakOut <= x"87654321";  -- indexOut = 67
    wait for 10 ns;

    -- Test 3
    keccakOut <= x"DEADBEEF";  -- indexOut = 190
    wait for 10 ns;

    -- Test 4
    keccakOut <= x"A5A5A5A5";  -- indexOut = 165
    wait for 10 ns;

    -- Test 5
    keccakOut <= x"0F0F0F0F";  -- indexOut = 15
    wait for 10 ns;

    -- Idle
    keccakOut <= (others => '0');
    wait;
  end process;

  -- BRAM write process
  write_proc: process(sampleValid, indexOut, sampleOut)
  begin
    if sampleValid = '1' then
      sampleBRAM(to_integer(unsigned(to_unsigned(indexOut, 8)))) <= sampleOut;
    end if;
  end process;

end architecture;