vlib work
vmap work work

vcom -2008 globalVars.vhd
vcom -2008 ram.vhd
vcom -2008 sampleRamModule.vhd
vcom -2008 sampleModule_tb.vhd

vsim work.sampleModule_tb

add wave -divider "Control"
add wave sim:/sampleModule_tb/clk
add wave sim:/sampleModule_tb/reset
add wave sim:/sampleModule_tb/sampleStart

add wave -divider "BRAM Interface"
add wave sim:/sampleModule_tb/ram_en
add wave sim:/sampleModule_tb/ram_we
add wave sim:/sampleModule_tb/ram_addr
add wave sim:/sampleModule_tb/ram_din
add wave sim:/sampleModule_tb/ram_dout

add wave -divider "Sample Output"
add wave sim:/sampleModule_tb/sampleOut
add wave sim:/sampleModule_tb/sampleValid
add wave sim:/sampleModule_tb/indexOut

run 5000 ns
