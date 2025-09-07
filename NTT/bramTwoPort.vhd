library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use work.GlobalVars.all;

entity bramTwoPort is
  generic (
    width   : integer := 32;
    depth   : integer := 8
  );

  	PORT
	(
    clk		      : IN STD_LOGIC;
		address_a		: IN STD_LOGIC_VECTOR (depth - 1 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (depth - 1 DOWNTO 0);
		data_a		  : IN STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
		data_b		  : IN STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
		wren_a		  : IN STD_LOGIC  := '0';
		wren_b		  : IN STD_LOGIC  := '0';
		q_a		      : OUT STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
		q_b		      : OUT STD_LOGIC_VECTOR (width - 1 DOWNTO 0)
	);

  attribute RAM_STYLE         : string;
  attribute RAM_STYLE of bramTwoPort : entity is "block";
end entity;

architecture RTL of bramTwoPort is
  subtype word_t is std_logic_vector(width - 1 downto 0);
  type memory_t is array(0 to 2**depth-1) of word_t;

  signal ram : memory_t := (others => (others => '0'));

begin
  sequential : process(clk)
  begin
    if (rising_edge(clk)) then

      --Write Logic
      if(wren_a = '1') then
        ram(to_integer(unsigned(address_a))) <= data_a;
      end if;

      if(wren_b = '1') then
        ram(to_integer(unsigned(address_b))) <= data_b;
      end if;

      --Read Logic
      q_a <= ram(to_integer(unsigned(address_a)));
      q_b <= ram(to_integer(unsigned(address_b)));

    end if;
  end process;

end RTL;