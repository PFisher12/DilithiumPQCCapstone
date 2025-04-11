library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.GlobalVars.all;

entity sampleInBall is
  Port (
    rand32 : in std_logic_vector(31 downto 0);
    sampleOut : out std_logic_vector(7 downto 0);
    valid : out std_logic
  );
end sampleInBall;

architecture Behavioral of sampleInBall is
begin
  process(rand32)
  begin
    -- Dummy logic for now; to be replaced with SampleInBall behavior
    sampleOut <= rand32(7 downto 0);
    valid <= '1';
  end process;
end Behavioral;