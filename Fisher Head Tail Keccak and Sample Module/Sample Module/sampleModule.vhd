library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.GlobalVars.all;

entity sampleModule is
  Port (
    keccakOut : in std_logic_vector(31 downto 0);
    sampleOut : out std_logic_vector(7 downto 0);
    indexOut : out integer range 0 to N-1;
    sampleValid : out std_logic
  );
end sampleModule;

architecture Behavioral of sampleModule is
  signal intermed : std_logic_vector(Q_BITS-1 downto 0);
  signal isValid : std_logic;
begin
  sampler: entity work.rejectionSampler
    port map (
      inputWord => keccakOut,
      qValue => intermed,
      valid => isValid
    );

  ballSampler: entity work.sampleInBall
    port map (
      rand32 => keccakOut,
      sampleOut => sampleOut,
      valid => sampleValid
    );

  indexOut <= to_integer(unsigned(keccakOut(15 downto 8)));
end Behavioral;
