library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak_adapter is
  generic
    ( ADDR_WIDTH_64 : integer := 4 );  -- must match your keccak_bram ADDR_WIDTH
  port
    ( clk      : in  std_logic;
      reset    : in  std_logic;
      start    : in  std_logic;
      done     : out std_logic;

      -- 32-bit BRAM port C
      ram_addr : out std_logic_vector(ADDR_WIDTH_64 downto 0);
      ram_din  : out std_logic_vector(31 downto 0);
      ram_dout : in  std_logic_vector(31 downto 0);
      ram_en   : out std_logic;
      ram_we   : out std_logic );
end keccak_adapter;

architecture rtl of keccak_adapter is

  -- your existing 64-bit wrapper
  component keccak_bram
    generic ( ADDR_WIDTH : integer; DATA_WIDTH : integer );
    port
      ( clk      : in  std_logic;
        reset    : in  std_logic;
        start    : in  std_logic;
        done     : out std_logic;
        ram_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        ram_din  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        ram_dout : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        ram_en   : out std_logic;
        ram_we   : out std_logic );
  end component;

  -- interconnect signals
  signal kb_addr  : std_logic_vector(ADDR_WIDTH_64-1 downto 0);
  signal kb_din   : std_logic_vector(63 downto 0);
  signal kb_dout  : std_logic_vector(63 downto 0);
  signal kb_en, kb_we, kb_start, kb_done : std_logic;

  -- FSM states (prefixed to avoid collisions)
  type st_t is (
    S_IDLE,
    S_READ_LOW,
    S_READ_HIGH,
    S_FEED,
    S_WAIT,
    S_WRITE_LOW,
    S_WRITE_HIGH,
    S_FINISH
  );
  signal state    : st_t := S_IDLE;
  signal word_idx : integer range 0 to 15 := 0;
  signal buf64    : std_logic_vector(63 downto 0);

  constant ADDR_WIDTH_32 : integer := ADDR_WIDTH_64 + 1;

begin

  -- instantiate your 64-bit keccak_bram
  keccak_u: keccak_bram
    generic map (ADDR_WIDTH => ADDR_WIDTH_64, DATA_WIDTH => 64)
    port map (
      clk      => clk,
      reset    => reset,
      start    => kb_start,
      done     => kb_done,
      ram_addr => kb_addr,
      ram_din  => kb_din,
      ram_dout => kb_dout,
      ram_en   => kb_en,
      ram_we   => kb_we
    );

  -- signal done only when FINISH state and core done
  done <= '1' when (state = S_FINISH and kb_done = '1') else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state    <= S_IDLE;
        ram_en   <= '0';  ram_we   <= '0';
        kb_start <= '0';
        word_idx <= 0;
      else
        -- default: no BRAM or core start
        ram_en   <= '0';  ram_we   <= '0';
        kb_start <= '0';

        case state is

          when S_IDLE =>
            if start = '1' then
              word_idx <= 0;
              state    <= S_READ_LOW;
            end if;

          when S_READ_LOW =>
            ram_addr <= std_logic_vector(to_unsigned(word_idx*2, ADDR_WIDTH_32));
            ram_en   <= '1';  ram_we <= '0';
            state    <= S_READ_HIGH;

          when S_READ_HIGH =>
            buf64(31 downto 0) <= ram_dout;
            ram_addr <= std_logic_vector(to_unsigned(word_idx*2+1, ADDR_WIDTH_32));
            ram_en   <= '1';  ram_we <= '0';
            state    <= S_FEED;

          when S_FEED =>
            buf64(63 downto 32) <= ram_dout;
            kb_din    <= buf64;
            kb_start  <= '1';
            state     <= S_WAIT;

          when S_WAIT =>
            if kb_done = '1' then
              word_idx <= 0;
              state    <= S_WRITE_LOW;
            end if;

          when S_WRITE_LOW =>
            ram_addr <= std_logic_vector(to_unsigned(word_idx*2, ADDR_WIDTH_32));
            ram_din  <= kb_dout(31 downto 0);
            ram_en   <= '1';  ram_we <= '1';
            state    <= S_WRITE_HIGH;

          when S_WRITE_HIGH =>
            ram_addr <= std_logic_vector(to_unsigned(word_idx*2+1, ADDR_WIDTH_32));
            ram_din  <= kb_dout(63 downto 32);
            ram_en   <= '1';  ram_we <= '1';

            if word_idx < 15 then
              word_idx <= word_idx + 1;
              state    <= S_WRITE_LOW;
            else
              state    <= S_FINISH;
            end if;

          when S_FINISH =>
            if start = '0' then
              state <= S_IDLE;
            end if;

        end case;
      end if;
    end if;
  end process;

end rtl;

