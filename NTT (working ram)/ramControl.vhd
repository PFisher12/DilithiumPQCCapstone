library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.GlobalVars.all;

--Declares all universal RAM instances. Main Control calls this function to select which RAM to read/write to.
--Set ram select to the ram's number to select the correct RAM, set ramselect to an unused slot to "disable" the entity
--Ram 0 is forward butterfly
--Ram 1 is unusued

entity ramControl is
  port (

    address_a : in std_logic_vector (7 downto 0);
    address_b : in std_logic_vector (7 downto 0);
    clock     : in std_logic;
    data_a    : in std_logic_vector (31 downto 0);
    data_b    : in std_logic_vector (31 downto 0);
    wren_a    : in std_logic;
    wren_b    : in std_logic;
    q_a       : out std_logic_vector (31 downto 0);
    q_b       : out std_logic_vector (31 downto 0);

    ramSelect : in std_logic_vector (1 downto 0)
  );

end ramControl;
architecture behav of ramControl is
  --RAM 0 temp
  signal wren_a_s_0   : std_logic;
  signal wren_b_s_0   : std_logic;
  signal output_a_s_0 : std_logic_vector(31 downto 0);
  signal output_b_s_0 : std_logic_vector(31 downto 0);

  --RAM 1 temp
  signal wren_a_s_1   : std_logic;
  signal wren_b_s_1   : std_logic;
  signal output_a_s_1 : std_logic_vector(31 downto 0);
  signal output_b_s_1 : std_logic_vector(31 downto 0);

begin

  ram0 : entity work.ram(SYN) --butterfly RAM
    port map
    (
      address_a => address_a,
      address_b => address_b,
      clock     => clock,
      data_a    => data_a,
      data_b    => data_b,
      wren_a    => wren_a_s_0,
      wren_b    => wren_b_s_0,
      q_a       => output_a_s_0,
      q_b       => output_b_s_0
    );

  ram1 : entity work.ram(SYN) --unused RAM
    port map
    (
      address_a => address_a,
      address_b => address_b,
      clock     => clock,
      data_a    => data_a,
      data_b    => data_b,
      wren_a    => wren_a_s_1,
      wren_b    => wren_b_s_1,
      q_a       => output_a_s_1,
      q_b       => output_b_s_1
    );
  ramsSelect : process (ramSelect, wren_a, wren_b, output_a_s_0, output_b_s_0, output_a_s_1, output_b_s_1)
  begin
    case ramSelect is
      when "00" => --butterfly RAM
        q_a <= output_a_s_0;
        q_b <= output_b_s_0;
      when "01" => --unused RAM
        q_a <= output_a_s_1;
        q_b <= output_b_s_1;
      when others    =>
        q_a <= (others => '0');
        q_b <= (others => '0');
    end case;

    --Set write enable to high if that RAM's write enable is high and it is selected and enabled
    wren_a_s_0 <= (wren_a and (not (ramSelect(1))) and (not (ramSelect(0))));
    wren_b_s_0 <= (wren_b and (not (ramSelect(1))) and (not (ramSelect(0))));
    wren_a_s_1 <= (wren_a and (not (ramSelect(1))) and (ramSelect(0)));
    wren_b_s_1 <= (wren_b and (not (ramSelect(1))) and (ramSelect(0)));

  end process;

end behav;
