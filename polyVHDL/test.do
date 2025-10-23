# Create and map work library
vlib work
vmap work work

# ============================================================
# Compile VHDL sources (adjust paths if needed)
# ============================================================
vcom "C:/Users/fishe/OneDrive/Documents/Villanova JR Year/Capstone/polyetauniformVHDL/DilithiumPQCCapstone/polyVHDL/globalVars.vhd"
vcom "C:/Users/fishe/OneDrive/Documents/Villanova JR Year/Capstone/polyetauniformVHDL/DilithiumPQCCapstone/polyVHDL/polyVHDL.vhd"


# ============================================================
# Add waveform signals
# ============================================================

add wave -divider "Clock and Reset"
add wave sim:/rejEta_tb/clk
add wave sim:/rejEta_tb/rst_n

add wave -divider "Input Control"
add wave sim:/rejEta_tb/start
add wave sim:/rejEta_tb/buf_in
add wave sim:/rejEta_tb/buf_valid
add wave sim:/rejEta_tb/len_in

add wave -divider "Output Control"
add wave sim:/rejEta_tb/coeff_out
add wave sim:/rejEta_tb/coeff_valid
add wave sim:/rejEta_tb/done

add wave -divider "Internal DUT Signals"
add wave sim:/rejEta_tb/uut/state
add wave sim:/rejEta_tb/uut/t0
add wave sim:/rejEta_tb/uut/t1
add wave sim:/rejEta_tb/uut/ctr_cnt
add wave sim:/rejEta_tb/uut/pos_cnt

# ============================================================
# Run the simulation
# ============================================================

# Generate clock
force -freeze sim:/rejEta_tb/clk 0 0, 1 {5 ns} -r 10ns

# Reset, start, and feed example bytes
force sim:/rejEta_tb/rst_n 0 0ns, 1 20ns
force sim:/rejEta_tb/start 0 0ns, 1 30ns, 0 60ns
force sim:/rejEta_tb/len_in 0000000000001000 0ns

# Feed sample random bytes (these will drive buf_in)
force -deposit sim:/rejEta_tb/buf_valid 1 40ns, 0 50ns, 1 60ns, 0 70ns, 1 80ns, 0 90ns
force -deposit sim:/rejEta_tb/buf_in x"1A" 40ns
force -deposit sim:/rejEta_tb/buf_in x"5E" 60ns
force -deposit sim:/rejEta_tb/buf_in x"73" 80ns
force -deposit sim:/rejEta_tb/buf_in x"2B" 100ns

# Run the simulation for 1 microsecond
run 1 us


