vcom -2008 globalVars.vhd
vcom -2008 rejectionSampler.vhd
vcom -2008 sampleInBall.vhd
vcom -2008 sampleModule.vhd
vcom -2008 sampleModule_tb.vhd

vsim work.sampleModule_tb

add wave -divider "Testbench Signals"
add wave sim:/sampleModule_tb/keccakOut
add wave sim:/sampleModule_tb/sampleOut
add wave sim:/sampleModule_tb/indexOut
add wave sim:/sampleModule_tb/sampleValid

add wave -divider "Internal Signals"
add wave sim:/sampleModule_tb/uut/intermed
add wave sim:/sampleModule_tb/uut/isValid

add wave -radix unsigned sim:/sampleModule_tb/sampleBRAM


run 200 ns

