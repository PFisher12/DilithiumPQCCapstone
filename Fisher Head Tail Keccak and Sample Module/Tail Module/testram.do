vlib work
vmap work work

# Compile in correct order
vcom -2008 GlobalVars.vhd
vcom -2008 tailRam.vhd
vcom -2008 tail_tb.vhd

# Load the simulation
vsim work.tail_tb

# Add waveform signals
add wave -divider "Clock & Control"
add wave sim:/tail_tb/clk
add wave sim:/tail_tb/reset
add wave sim:/tail_tb/start
add wave sim:/tail_tb/done

add wave -divider "Tail BRAM Interface"
add wave sim:/tail_tb/ram_en
add wave sim:/tail_tb/ram_we
add wave sim:/tail_tb/ram_addr
add wave sim:/tail_tb/ram_din
add wave sim:/tail_tb/ram_dout

add wave -divider "Tail FSM Debug"
add wave sim:/tail_tb/uut/state
add wave sim:/tail_tb/uut/coeff_index
add wave sim:/tail_tb/uut/poly_index

# Safe access to internal RAM as a full array
add wave -divider "RAM Array (Full)"
add wave -radix unsigned -internal sim:/tail_tb/ram

# Run simulation
run -all
