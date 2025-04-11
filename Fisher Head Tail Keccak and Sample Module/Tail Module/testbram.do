vlib work
vmap work work

vcom -2008 globalVars.vhd
vcom -2008 bram_types.vhd
vcom -2008 decompose.vhd
vcom -2008 power2round.vhd
vcom -2008 makeHint.vhd
vcom -2008 useHint.vhd
vcom -2008 tail.vhd
vcom -2008 tailWrapper.vhd
vcom -2008 tailWrapper_tb.vhd

vsim work.tailWrapper_tb

add wave -divider "Clock and Control"
add wave sim:/tailWrapper_tb/clk
add wave sim:/tailWrapper_tb/rst

add wave -divider "Inputs"
add wave -radix signed sim:/tailWrapper_tb/inputCoeff(0)
add wave -radix signed sim:/tailWrapper_tb/inputZ(0)

add wave -divider "Outputs"
add wave -radix signed sim:/tailWrapper_tb/outputT0(0)
add wave -radix signed sim:/tailWrapper_tb/outputT1(0)
add wave -radix signed sim:/tailWrapper_tb/outputW1(0)
add wave sim:/tailWrapper_tb/outputHint(0)

run 6000 ns
