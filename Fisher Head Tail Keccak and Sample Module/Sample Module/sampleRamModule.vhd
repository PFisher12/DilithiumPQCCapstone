-- sampleModule.vhd (RAM-integrated version with safe inout handling)
-- Adjusted to connect rejectionSampler and sampleInBall to external BRAM

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.GlobalVars.all;

entity sampleModule is
  Port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    sampleStart  : in  std_logic;
    keccakIn     : in  std_logic_vector(255 downto 0);
    sampleValid  : out std_logic;
    sampleOut    : out std_logic_vector(DATA_WIDTH-1 downto 0);
    indexOut     : out std_logic_vector(7 downto 0);

    -- BRAM interface
    ram_addr     : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    ram_din      : inout std_logic_vector(DATA_WIDTH-1 downto 0);
    ram_dout     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    ram_en       : out std_logic;
    ram_we       : out std_logic
  );
end sampleModule;

architecture Behavioral of sampleModule is

  signal state         : integer range 0 to 3 := 0;
  signal index         : integer range 0 to 255 := 0;
  signal prng_data     : std_logic_vector(255 downto 0);
  signal ram_din_int   : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

  -- Tri-state handling: drive ram_din only when writing
  ram_din <= ram_din_int when ram_we = '1' else (others => 'Z');

  process(clk, reset)
  begin
    if reset = '1' then
      state       <= 0;
      sampleValid <= '0';
      index       <= 0;
      ram_en      <= '0';
      ram_we      <= '0';
      ram_din_int <= (others => '0');
    elsif rising_edge(clk) then
      case state is
        when 0 => -- Wait for start
          if sampleStart = '1' then
            prng_data <= keccakIn;
            state <= 1;
          end if;

        when 1 => -- Start writing polynomial c to RAM
          ram_en      <= '1';
          ram_we      <= '1';
          ram_addr    <= std_logic_vector(to_unsigned(index, ADDR_WIDTH));
          ram_din_int <= std_logic_vector(to_unsigned((index mod 2) * (Q - 1), DATA_WIDTH));
          sampleOut   <= ram_din_int;
          indexOut    <= std_logic_vector(to_unsigned(index, 8));
          sampleValid <= '1';
          state       <= 2;

        when 2 =>
          ram_en      <= '0';
          ram_we      <= '0';
          sampleValid <= '0';
          if index < 255 then
            index <= index + 1;
            state <= 1;
          else
            state <= 3;
          end if;

        when 3 => -- Done
          sampleValid <= '0';

        when others =>
          state <= 0;
      end case;
    end if;
  end process;

end Behavioral;