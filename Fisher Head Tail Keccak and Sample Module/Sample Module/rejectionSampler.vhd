library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.GlobalVars.all;

entity rejectionSampler is
  Port (
    inputWord : in std_logic_vector(31 downto 0);
    qValue : out std_logic_vector(Q_BITS-1 downto 0);
    valid : out std_logic
  );
end rejectionSampler;

architecture Behavioral of rejectionSampler is
begin
  process(inputWord)
    variable val : integer;
  begin
    val := to_integer(unsigned(inputWord(22 downto 0)));
    if val < Q then
      qValue <= std_logic_vector(to_unsigned(val, Q_BITS));
      valid <= '1';
    else
      qValue <= (others => '0');
      valid <= '0';
    end if;
  end process;
end Behavioral;