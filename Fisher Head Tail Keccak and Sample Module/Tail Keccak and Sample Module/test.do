# Create and map library
vlib work
vmap work work

# Compile all VHDL source files
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Sample Module/GlobalVars.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Tail Module/decompose.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Keccak Module/keccak_globals.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Keccak Module/keccak_round_constants_gen.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Keccak Module/keccak_round.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Keccak Module/keccak_buffer.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Keccak Module/keccak.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Sample Module/rejectionSampler.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Sample Module/sampleInBall.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Sample Module/sampleModule.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Tail Keccak And Sample Module/tailKeccakSampleIntegration.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Tail Keccak And Sample Module/tb_tailKeccakSampleIntegration.vhd"

# Load simulation
vsim work.tb_tailKeccakSampleIntegration

# Add external signals to waveform
add wave -position insertpoint sim:/tb_tailKeccakSampleIntegration/clk
add wave -position insertpoint sim:/tb_tailKeccakSampleIntegration/rst_n
add wave -position insertpoint sim:/tb_tailKeccakSampleIntegration/input_data
add wave -position insertpoint sim:/tb_tailKeccakSampleIntegration/input_valid
add wave -position insertpoint sim:/tb_tailKeccakSampleIntegration/sample_out
add wave -position insertpoint sim:/tb_tailKeccakSampleIntegration/index_out
add wave -position insertpoint sim:/tb_tailKeccakSampleIntegration/sample_valid

# Dive into internal signals inside UUT
add wave -position insertpoint sim:/tb_tailKeccakSampleIntegration/uut/high_bits_out
add wave -position insertpoint sim:/tb_tailKeccakSampleIntegration/uut/keccak_din
add wave -position insertpoint sim:/tb_tailKeccakSampleIntegration/uut/keccak_dout

# Run simulation for 4000 ns
run 4000 ns
