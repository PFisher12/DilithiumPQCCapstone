# Create and map work library
vlib work
vmap work work

# Compile VHDL sources
vcom ./keccak_globals.vhd
vcom ./keccak_round_constants_gen.vhd
vcom ./keccak_round.vhd
vcom ./keccak_buffer.vhd
vcom ./keccak.vhd
vcom ./tb_keccak.vhd

# Load the correct testbench entity
vsim work.keccak_tb

# Add waveform signals
add wave -divider "Clock and Reset"
add wave sim:/keccak_tb/clk
add wave sim:/keccak_tb/rst_n

add wave -divider "Input Control"
add wave sim:/keccak_tb/start
add wave sim:/keccak_tb/din
add wave sim:/keccak_tb/din_val
add wave sim:/keccak_tb/last_block

add wave -divider "Output Control"
add wave sim:/keccak_tb/ready
add wave sim:/keccak_tb/dout
add wave sim:/keccak_tb/dout_valid
add wave sim:/keccak_tb/buffer_full

add wave -divider "FSM State"
add wave sim:/keccak_tb/st

# Run the simulation
run 1 ms

