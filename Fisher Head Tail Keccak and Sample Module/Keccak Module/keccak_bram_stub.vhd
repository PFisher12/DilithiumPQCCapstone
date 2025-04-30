-- keccak_bram_stub.vhd
library ieee;
use ieee.std_logic_1164.all;

entity keccak_bram is
  generic (
    ADDR_WIDTH : integer;
    DATA_WIDTH : integer
  );
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    start    : in  std_logic;
    done     : out std_logic;
    ram_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    ram_din  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    ram_dout : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    ram_en   : out std_logic;
    ram_we   : out std_logic
  );
end keccak_bram;

architecture behavior of keccak_bram is
  signal counter : integer range 0 to 10 := 0;
  constant PATTERN : std_logic_vector(63 downto 0) := x"DEADBEEFCAFEBABE";
begin

  -- We?re only interested in pulsing ?done? and providing a fake 64-bit output.
  -- Tie off everything else:
  ram_addr <= (others => '0');
  ram_en   <= '0';
  ram_we   <= '0';
  ram_din  <= (others => '0');

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        counter <= 0;
        done    <= '0';
      elsif start = '1' then
        counter <= 1;      -- kick off the ?permutation?
        done    <= '0';
      elsif counter > 0 and counter < 5 then
        counter <= counter + 1;  -- count a few cycles
      elsif counter = 5 then
        done    <= '1';    -- after 5 cycles, say we?re done
        counter <= 0;      -- and reset for the next start
      else
        done    <= '0';
      end if;
    end if;
  end process;

  -- Our fake ?squeezed? words come from PATTERN,
  -- but the adapter is looking at its internal signal kb_dout,
  -- which is actually wired to this entity?s port ram_dout.
  -- so we _feed_ PATTERN into that port by echoing it back:
  -- note: ram_dout is an input to this stub, so we can?t drive it here.
  -- instead, we?ll tell you below how to map PATTERN into the adapter testbench.

end behavior;
