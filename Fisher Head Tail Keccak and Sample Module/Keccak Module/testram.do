# keccak_adapter.do

vlib work
vmap work ./work

# 1) Compile stub (must come first)
vcom -2002 -explicit keccak_bram_stub.vhd

# 2) Compile adapter + TB
vcom -2002 -explicit keccak_adapter.vhd
vcom -2002 -explicit keccak_adapter_tb.vhd

# 3) Run in GUI
vsim work.keccak_adapter_tb

# force the adapter’s internal kb_dout to a constant 64-bit value
force -deposit /keccak_adapter_tb/uut/kb_dout 64'hDEADBEEFCAFEBABE


# 4) Key signals + memory
add wave /keccak_adapter_tb/start
add wave /keccak_adapter_tb/done
add wave /keccak_adapter_tb/uut/ram_addr
add wave /keccak_adapter_tb/uut/ram_din
add wave /keccak_adapter_tb/uut/ram_en
add wave /keccak_adapter_tb/uut/ram_we
add wave /keccak_adapter_tb/uut/state
add wave /keccak_adapter_tb/mem

run -all
