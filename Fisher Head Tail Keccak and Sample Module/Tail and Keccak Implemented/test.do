# Set up library
vlib work
vmap work work

# Compile all files
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Keccak Module/keccak_globals.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Keccak Module/keccak_round_constants_gen.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Keccak Module/keccak_round.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Keccak Module/keccak_buffer.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Keccak Module/keccak.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Tail Module/decompose.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Tail and Keccak Module/tailKeccakIntegration.vhd"
vcom -2002 -explicit -work work "C:/Villanova school work/CAPSTONE/Tail and Keccak Module/tb_tailKeccakIntegration.vhd"

# Load simulation
vsim work.tb_tailKeccakIntegration

# Add waves for full tracing
add wave -position insertpoint sim:/tb_tailKeccakIntegration/clk
add wave -position insertpoint sim:/tb_tailKeccakIntegration/rst_n
add wave -position insertpoint sim:/tb_tailKeccakIntegration/input_data
add wave -position insertpoint sim:/tb_tailKeccakIntegration/input_valid
add wave -position insertpoint sim:/tb_tailKeccakIntegration/output_data
add wave -position insertpoint sim:/tb_tailKeccakIntegration/output_valid

# Internal signals from UUT (tailKeccakIntegration)
add wave -position insertpoint sim:/tb_tailKeccakIntegration/uut/high_bits_out
add wave -position insertpoint sim:/tb_tailKeccakIntegration/uut/keccak_din
add wave -position insertpoint sim:/tb_tailKeccakIntegration/uut/keccak_dout
add wave -position insertpoint sim:/tb_tailKeccakIntegration/uut/keccak_din_valid
add wave -position insertpoint sim:/tb_tailKeccakIntegration/uut/keccak_last_block

# Run simulation for 4000 ns
run 4000 ns


