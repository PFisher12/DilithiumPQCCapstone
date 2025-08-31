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
    clk     : in std_logic;

    ram_in  : in RAM_IN;
    ram_out : out RAM_OUT;

    ramSelect : in std_logic_vector (1 downto 0)
  );

end ramControl;
architecture RTL of ramControl is
  --RAM 0 temp
  signal wren_a_s_0   : std_logic := '0';
  signal wren_b_s_0   : std_logic := '0';
  signal output_a_s_0 : std_logic_vector(31 downto 0);
  signal output_b_s_0 : std_logic_vector(31 downto 0);

  --RAM 1 temp
  signal wren_a_s_1   : std_logic := '0';
  signal wren_b_s_1   : std_logic := '0';
  signal output_a_s_1 : std_logic_vector(31 downto 0);
  signal output_b_s_1 : std_logic_vector(31 downto 0);

begin

  ram0 : entity work.ram(SYN) --butterfly RAM
    port map
    (
      clock     => clk,
      address_a => ram_in.address_a,
      address_b => ram_in.address_b,
      data_a    => ram_in.data_a,
      data_b    => ram_in.data_b,
      wren_a    => wren_a_s_0,
      wren_b    => wren_b_s_0,
      q_a       => output_a_s_0,
      q_b       => output_b_s_0
    );

  ram1 : entity work.ram(SYN) --unused RAM
    port map
    (
      clock     => clk,
      address_a => ram_in.address_a,
      address_b => ram_in.address_b,
      data_a    => ram_in.data_a,
      data_b    => ram_in.data_b,
      wren_a    => wren_a_s_1,
      wren_b    => wren_b_s_1,
      q_a       => output_a_s_1,
      q_b       => output_b_s_1
    );
  ramsSelect : process (ramSelect, ram_in.wren_a, ram_in.wren_b, output_a_s_0, output_b_s_0, output_a_s_1, output_b_s_1)
  begin
    case ramSelect is
      when "00" => --butterfly RAM
        ram_out.q_a <= output_a_s_0;
        ram_out.q_b <= output_b_s_0;
      when "01" => --unused RAM
        ram_out.q_a <= output_a_s_1;
        ram_out.q_b <= output_b_s_1;
      when others    =>
        ram_out.q_a <= (others => '0');
        ram_out.q_b <= (others => '0');
    end case;

    --Set write enable to high if that RAM's write enable is high and it is selected and enabled
    wren_a_s_0 <= (ram_in.wren_a and (not (ramSelect(1))) and (not (ramSelect(0))));
    wren_b_s_0 <= (ram_in.wren_b and (not (ramSelect(1))) and (not (ramSelect(0))));
    wren_a_s_1 <= (ram_in.wren_a and (not (ramSelect(1))) and (ramSelect(0)));
    wren_b_s_1 <= (ram_in.wren_b and (not (ramSelect(1))) and (ramSelect(0)));

  end process;

end RTL;
