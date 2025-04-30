-- tail_ram.vhd
-- Tail module integrated with RAM interface
-- Note: This assumes external BRAM is dual-port and standard RAM control signals exist

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.GlobalVars.all;

entity tail is
  Port (
    clk         : in  std_logic;
    reset       : in  std_logic;
    start       : in  std_logic;
    done        : out std_logic;

    -- BRAM interface
    ram_addr    : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    ram_din     : out std_logic_vector(DATA_WIDTH-1 downto 0);
    ram_dout    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    ram_en      : out std_logic;
    ram_we      : out std_logic
  );
end tail;

architecture Behavioral of tail is

  signal state       : integer range 0 to 5 := 0;
  signal poly_index  : integer range 0 to L-1 := 0;
  signal coeff_index : integer range 0 to N-1 := 0;
  signal temp_poly   : std_logic_vector(DATA_WIDTH-1 downto 0);
  
  -- result signals
  signal z           : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal r0          : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal h           : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

  process(clk, reset)
  begin
    if reset = '1' then
      state        <= 0;
      poly_index   <= 0;
      coeff_index  <= 0;
      done         <= '0';
      ram_we       <= '0';
      ram_en       <= '0';
      ram_addr     <= (others => '0');
    elsif rising_edge(clk) then
      case state is

        when 0 => -- Idle
          done <= '0';
          if start = '1' then
            state <= 1;
          end if;

        when 1 => -- Example computation (could be decomposing or power2round)
          -- For demo, we just pass counter value as dummy data
          z <= std_logic_vector(to_unsigned(coeff_index, DATA_WIDTH));
          state <= 2;

        when 2 => -- Write z to RAM
          ram_en   <= '1';
          ram_we   <= '1';
          ram_din  <= z;
          ram_addr <= std_logic_vector(to_unsigned(poly_index * N + coeff_index, ADDR_WIDTH));
          state    <= 3;

        when 3 => -- Advance index
          ram_en <= '0';
          ram_we <= '0';
          if coeff_index = N-1 then
            coeff_index <= 0;
            if poly_index = L-1 then
              poly_index <= 0;
              state <= 4;
            else
              poly_index <= poly_index + 1;
              state <= 1;
            end if;
          else
            coeff_index <= coeff_index + 1;
            state <= 1;
          end if;

        when 4 => -- Done
          done <= '1';
          if start = '0' then
            state <= 0;
          end if;

        when others =>
          state <= 0;

      end case;
    end if;
  end process;

end Behavioral;
