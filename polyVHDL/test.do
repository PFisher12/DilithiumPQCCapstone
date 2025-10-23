# ============================================================
# ModelSim DO file for polyVHDL.vhd (standalone simulation)
# ============================================================
vlib work
vmap work work

# Compile VHDL file
vcom -2008 polyVHDL.vhd

# Load top-level entity
vsim work.polyVHDL

# ============================================================
# Add waveform signals
# ============================================================
add wave -divider "Clock / Reset"
add wave sim:/polyVHDL/clk
add wave sim:/polyVHDL/rst_n

add wave -divider "Control"
add wave sim:/polyVHDL/start
add wave sim:/polyVHDL/done

add wave -divider "Input Buffer"
add wave sim:/polyVHDL/buf_in
add wave sim:/polyVHDL/buf_valid

add wave -divider "Output Coefficients"
add wave sim:/polyVHDL/coeff_out
add wave sim:/polyVHDL/coeff_valid

add wave -divider "Internal State"
add wave -r sim:/polyVHDL/state
add wave sim:/polyVHDL/ctr_cnt
add wave sim:/polyVHDL/pos_cnt

# ============================================================
# Apply test stimuli
# ============================================================
force -freeze sim:/polyVHDL/clk 0 0 ns, 1 10 ns -repeat 20 ns
force sim:/polyVHDL/rst_n 0
run 50 ns
force sim:/polyVHDL/rst_n 1
run 50 ns

# Start FSM
force sim:/polyVHDL/start 1
run 20 ns
force sim:/polyVHDL/start 0

# Feed bytes into buffer
force sim:/polyVHDL/buf_valid 1
force sim:/polyVHDL/buf_in 8'hA5
run 40 ns
force sim:/polyVHDL/buf_in 8'h3C
run 40 ns
force sim:/polyVHDL/buf_in 8'hF0
run 40 ns
force sim:/polyVHDL/buf_valid 0

# Let the FSM run to completion
run 2 us




