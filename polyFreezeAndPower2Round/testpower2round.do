# ==========================================================
# test_power2round.do
# ModelSim automation script for polyveck_power2round.vhd
# ==========================================================

# Create and map the work library
vlib work
vmap work work

# ----------------------------------------------------------
# Compile design files
# ----------------------------------------------------------
vcom -2008 "./polyveck_power2round.vhd"

# ----------------------------------------------------------
# Load simulation
# ----------------------------------------------------------
vsim work.polyveck_power2round

# ----------------------------------------------------------
# Add useful waveform signals
# ----------------------------------------------------------
add wave -divider "Clock and Reset"
add wave sim:/polyveck_power2round/clk
add wave sim:/polyveck_power2round/rst_n

add wave -divider "Control Signals"
add wave sim:/polyveck_power2round/start
add wave sim:/polyveck_power2round/done
add wave sim:/polyveck_power2round/state
add wave sim:/polyveck_power2round/idx

add wave -divider "Data"
add wave sim:/polyveck_power2round/v_in
add wave sim:/polyveck_power2round/v0_out
add wave sim:/polyveck_power2round/v1_out

# ----------------------------------------------------------
# Apply stimulus
# ----------------------------------------------------------

# Generate a 20 ns period clock
force -freeze sim:/polyveck_power2round/clk 0 0ns, 1 10ns -repeat 20ns

# Reset for 40 ns
force -freeze sim:/polyveck_power2round/rst_n 0 0ns, 1 40ns

# Pulse start after reset
force -freeze sim:/polyveck_power2round/start 0 0ns, 1 60ns, 0 100ns

# ----------------------------------------------------------
# Example input vector (4 coefficients × 32 bits = 128 bits total)
# Adjust K and N in the entity generics if you change this width
# ----------------------------------------------------------
force -deposit sim:/polyveck_power2round/v_in 16#0000000A_FFFFFFFF_00000010_FFFFFFF0#

# ----------------------------------------------------------
# Run simulation long enough to reach DONE_STATE
# ----------------------------------------------------------
run 200 us

# ----------------------------------------------------------
# Display final state and completion
# ----------------------------------------------------------
echo "==========================================================="
echo " Simulation finished."
echo " If 'done' = 1 and state = DONE_STATE, module completed OK."
echo "==========================================================="

wave zoom full
