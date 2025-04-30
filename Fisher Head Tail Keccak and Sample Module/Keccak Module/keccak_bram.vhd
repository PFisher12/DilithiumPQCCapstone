library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak_bram is
  generic (
    ADDR_WIDTH : integer := 4;   -- 4 bits → 16 words
    DATA_WIDTH : integer := 64   -- 64-bit words
  );
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    start    : in  std_logic;
    done     : out std_logic;

    -- BRAM interface
    ram_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    ram_din  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    ram_dout : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    ram_en   : out std_logic;
    ram_we   : out std_logic
  );
end keccak_bram;

architecture Behavioral of keccak_bram is

  -- FSM states
  type state_t is (IDLE, ABSORB, WAIT_VALID, WRITE, FINISH);
  signal state_reg : state_t := IDLE;

  -- Counters
  signal absorb_count : integer range 0 to 1 := 0;
  signal output_count : integer range 0 to 15 := 0;

  -- Keccak core handshake signals
  signal keccak_start       : std_logic := '0';
  signal keccak_din         : std_logic_vector(63 downto 0) := (others => '0');
  signal keccak_din_valid   : std_logic := '0';
  signal keccak_last_block  : std_logic := '0';
  signal keccak_dout        : std_logic_vector(63 downto 0);
  signal keccak_valid       : std_logic;

  -- Invert reset for the core
  signal rst_n_sig : std_logic;
  
  -- Declaration of the Keccak core
  component keccak is
    port (
      clk         : in  std_logic;
      rst_n       : in  std_logic;
      start       : in  std_logic;
      din         : in  std_logic_vector(63 downto 0);
      din_valid   : in  std_logic;
      last_block  : in  std_logic;
      buffer_full : out std_logic;
      ready       : out std_logic;
      dout        : out std_logic_vector(63 downto 0);
      dout_valid  : out std_logic
    );
  end component;

begin
  -- Create an active-low reset for the core
  rst_n_sig <= not reset;

  -- Instantiate the Keccak core
  keccak_u: keccak
    port map (
      clk         => clk,
      rst_n       => rst_n_sig,
      start       => keccak_start,
      din         => keccak_din,
      din_valid   => keccak_din_valid,
      last_block  => keccak_last_block,
      buffer_full => open,
      ready       => open,
      dout        => keccak_dout,
      dout_valid  => keccak_valid
    );

  ----------------------------------------------------------------
  -- Main FSM: ABSORB two 64-bit words, then SQUEEZE 16 words
  ----------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        -- reset all
        state_reg        <= IDLE;
        done             <= '0';
        ram_en           <= '0';
        ram_we           <= '0';
        keccak_start     <= '0';
        keccak_din_valid <= '0';
        keccak_last_block<= '0';
        absorb_count     <= 0;
        output_count     <= 0;

      else
        case state_reg is

          ----------------------------------------------------------------
          when IDLE =>
            done <= '0';
            ram_en <= '0';
            ram_we <= '0';
            keccak_din_valid <= '0';
            keccak_last_block<= '0';
            if start = '1' then
              -- Kick off the absorb
              keccak_start   <= '1';
              absorb_count   <= 0;
              state_reg      <= ABSORB;
            end if;

          ----------------------------------------------------------------
          when ABSORB =>
            -- Only pulse start for one cycle
            keccak_start <= '0';
            -- Drive the absorb handshake
            keccak_din_valid <= '1';
            if absorb_count = 0 then
              keccak_din        <= x"0123456789ABCDEF";  -- example first block
              keccak_last_block <= '0';
            else
              keccak_din        <= x"0000000000000000";  -- example second block
              keccak_last_block <= '1';
            end if;

            if absorb_count < 1 then
              absorb_count <= absorb_count + 1;
            else
              -- finished absorbing two words
              keccak_din_valid   <= '0';
              keccak_last_block  <= '0';
              output_count       <= 0;
              state_reg          <= WAIT_VALID;
            end if;

          ----------------------------------------------------------------
          when WAIT_VALID =>
            -- Wait for each squeezed word
            if keccak_valid = '1' then
              ram_addr <= std_logic_vector(to_unsigned(output_count, ADDR_WIDTH));
              ram_din  <= keccak_dout;
              ram_en   <= '1';
              ram_we   <= '1';
              state_reg<= WRITE;
            end if;

          ----------------------------------------------------------------
          when WRITE =>
            -- One-cycle write pulse
            ram_en <= '0';
            ram_we <= '0';
            if output_count < 15 then
              output_count <= output_count + 1;
              state_reg    <= WAIT_VALID;
            else
              -- done squeezing
              done      <= '1';
              state_reg <= FINISH;
            end if;

          ----------------------------------------------------------------
          when FINISH =>
            -- Wait for start to go low before re-entering IDLE
            if start = '0' then
              state_reg <= IDLE;
            end if;

        end case;
      end if;
    end if;
  end process;

end Behavioral;
