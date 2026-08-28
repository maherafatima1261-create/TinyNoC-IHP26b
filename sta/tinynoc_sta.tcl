read_liberty /home/maha/IHP-Open-PDK/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib

read_verilog /home/maha/TinyNoC/synthesis/tinynoc_wrapper_ihp130_mapped.v
link_design tinynoc_wrapper

create_clock -name clk -period 20.0 [get_ports clk]

set_input_delay  2.0 -clock clk [get_ports ui_in*]
set_input_delay  2.0 -clock clk [get_ports uio_in*]
set_input_delay  2.0 -clock clk [get_ports ena]

set_output_delay 2.0 -clock clk [get_ports uo_out*]
set_output_delay 2.0 -clock clk [get_ports uio_out*]

report_checks -path_delay max -digits 4
report_checks -path_delay min -digits 4
report_worst_slack -max
report_worst_slack -min

