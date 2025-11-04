# ==========================================================
# test_freeze_full.do
# Simulates the full FSM of polyveck_freeze until DONE_STATE
# ==========================================================

# Create and map the work library
vlib work
vmap work work

# Compile the VHDL source
vcom -2008 "./polyveck_freeze.vhd"

# Load the design
vsim work.polyveck_freeze

# ==========================================================
# Add waveform signals
# ==========================================================
add wave -divider "Clock and Reset"
add wave sim:/polyveck_freeze/clk
add wave sim:/polyveck_freeze/rst_n

add wave -divider "Control Signals"
add wave sim:/polyveck_freeze/start
add wave sim:/polyveck_freeze/done

add wave -divider "Data Signals"
add wave sim:/polyveck_freeze/v_in
add wave sim:/polyveck_freeze/v_out
add wave sim:/polyveck_freeze/state
add wave sim:/polyveck_freeze/idx

# ==========================================================
# Stimulus
# ==========================================================

# Generate clock (20 ns period)
force clk 0 0ns, 1 10ns -repeat 20ns

# Reset low for 40 ns
force rst_n 0 0ns, 1 40ns

# Pulse start after reset
force start 0 0ns, 1 60ns, 0 100ns

# Example input coefficients (dummy data)
force -deposit v_in 16#0000000AFFFFFFFF00000010FFFFFFF0#

# ==========================================================
# Simulation control
# ==========================================================

# Run long enough to reach DONE_STATE (for small K/N)
# If your K*N is large, increase the time (each cycle = 1 coefficient)
run 200 us

# Print completion message once simulation is done
echo "----------------------------------------------------------"
echo "Simulation finished. If 'done' asserted and state = DONE_STATE,"
echo "the polyveck_freeze module completed successfully!"
echo "----------------------------------------------------------"

# Zoom and display entire waveform
wave zoom full
