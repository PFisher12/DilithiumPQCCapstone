# ----------------------------------------
# testram.do   (fixed quoting – Works in ModelSim-Intel 2020.1)
# ----------------------------------------

vlib work
vmap work work

# ------- Compile everything (VHDL-2008) -------
vcom -2008 keccak_globals.vhd
vcom -2008 keccak_round_constants_gen.vhd
vcom -2008 keccak_round.vhd
vcom -2008 keccak_buffer.vhd
vcom -2008 keccak.vhd
vcom -2008 keccak_bram.vhd
vcom -2008 keccak_bram_tb.vhd

# ------- Load the test-bench -------
vsim work.keccak_bram_tb   

# ------- Waveform setup -------
wave delete *

add wave -divider "Clock & Control"
add wave  sim:/keccak_bram_tb/clk
add wave  sim:/keccak_bram_tb/reset
add wave  sim:/keccak_bram_tb/start
add wave  sim:/keccak_bram_tb/done

add wave -divider "BRAM Interface"
add wave  sim:/keccak_bram_tb/ram_en
add wave  sim:/keccak_bram_tb/ram_we
add wave  sim:/keccak_bram_tb/ram_addr
add wave  sim:/keccak_bram_tb/ram_din
add wave  sim:/keccak_bram_tb/ram_dout

add wave -divider "Internal DUT (recursive)"
add wave -recursive -radix hex  sim:/keccak_bram_tb/uut

add wave -divider "RAM Array"
add wave -radix hex -internal   sim:/keccak_bram_tb/mem

# ------- Run until TB stops itself -------
run -all
