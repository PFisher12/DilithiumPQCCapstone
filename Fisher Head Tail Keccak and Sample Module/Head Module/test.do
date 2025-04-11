vlib work
vmap work work

# Compile all VHDL modules
vcom -2008 head.vhd
vcom -2008 testbench.vhd

# Run the simulation
vsim work.testbench

# Waveform setup
add wave -divider "Global Signals"
add wave -hex sim:/testbench/*

add wave -divider "HEAD Module"
add wave -hex sim:/testbench/uut_head/*

# Uncomment these when the corresponding testbench instances exist
# add wave -divider "Poly Loader"
# add wave -hex sim:/testbench/uut_polyLoader/*

# add wave -divider "Seed Expander"
# add wave -hex sim:/testbench/uut_seedExpander/*

# add wave -divider "Unpack Public Key"
# add wave -hex sim:/testbench/uut_unpackPublicKey/*

# add wave -divider "Unpack Secret Key"
# add wave -hex sim:/testbench/uut_unpackSecretKey/*

# Simulate for enough time to observe output
run 500 ns
