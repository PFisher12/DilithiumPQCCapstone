# -----------------------------
# Dilithium Tail Module Test
# -----------------------------

vlib work
vmap work work

# Compile all modules
vcom -2008 globalVars.vhd
vcom -2008 decompose.vhd
vcom -2008 power2round.vhd
vcom -2008 makeHint.vhd
vcom -2008 useHint.vhd
vcom -2008 tail.vhd
vcom -2008 tail_tb.vhd

# Load simulation
vsim work.tail_tb

# Waveform setup
add wave -divider "Inputs"
add wave sim:/tail_tb/coeff_in
add wave sim:/tail_tb/z_in

add wave -divider "Outputs"
add wave sim:/tail_tb/t0_out
add wave sim:/tail_tb/t1_out
add wave sim:/tail_tb/w1_out
add wave sim:/tail_tb/hint_out

# Force test vectors

# Test 1: hint = 0
force sim:/tail_tb/coeff_in x"000186A0" 0 ns    ;# 100000
force sim:/tail_tb/z_in     x"000F4240" 0 ns    ;# 1000000

# Test 2: hint = 1
force sim:/tail_tb/coeff_in x"000186A0" 40 ns   ;# 100000
force sim:/tail_tb/z_in     x"0007FE10" 40 ns   ;# 523600

# Test 3: hint = 1
force sim:/tail_tb/coeff_in x"000F4240" 80 ns   ;# 1000000
force sim:/tail_tb/z_in     x"00030D40" 80 ns   ;# 200000

# Test 4: hint = 0
force sim:/tail_tb/coeff_in x"00000000" 120 ns  ;# 0
force sim:/tail_tb/z_in     x"000C3500" 120 ns  ;# 800000

# Test 5: hint = 1 (wraparound edge)
force sim:/tail_tb/coeff_in x"00061A80" 160 ns  ;# 400000
force sim:/tail_tb/z_in     x"0006B628" 160 ns  ;# 439000


# Run long enough to see all transitions
run 300 ns
