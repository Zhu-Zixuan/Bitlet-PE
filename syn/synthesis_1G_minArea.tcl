# dc_shell tcl script to synthesis Bitlet-PE
# Author:   LI Cheng-Long (UESTC), 2021.03

define_design_lib WORK -path "work"

set_app_var target_library {../lib/tcbn28hpcplusbwp30p140ulvtssg0p72v0c_ccs.db}
set_app_var link_library "* $target_library"

analyze -library WORK -format verilog {
    ../rtl/Bitlet_Accumulator.v
    ../rtl/Bitlet_AlignerArray.v
    ../rtl/Bitlet_Calculator.v
    ../rtl/Bitlet_CE.v
    ../rtl/Bitlet_CheckWindow.v
    ../rtl/Bitlet_CmpTree.v
    ../rtl/Bitlet_FindMax.v
    ../rtl/Bitlet_FindMSB.v
    ../rtl/Bitlet_MaxTree.v
    ../rtl/Bitlet_PackFixed.v
    ../rtl/Bitlet_PackFloat.v
    ../rtl/Bitlet_PE.v
    ../rtl/Bitlet_Postprocessor.v
    ../rtl/Bitlet_Preprocessor.v
    ../rtl/Bitlet_Prim_BufferArray.v
    ../rtl/Bitlet_Prim_Compactor.v
    ../rtl/Bitlet_Prim_Decoder.v
    ../rtl/Bitlet_Reassembler.v
    ../rtl/Bitlet_Defs.vh}

elaborate Bitlet_PE -architecture verilog -library DEFAULT

check_design

create_clock -period 1.0 -name clk -waveform {0.5 1.0} [get_ports clk]

set_input_delay 0.2 [remove_from_collection [all_inputs] clk] -clock clk

set_output_delay 0.2 [all_outputs] -clock clk

set_max_area 0

compile_ultra

report_area -hier                   >   ./rpt/synth_area.rpt
report_cell                         >   ./rpt/synth_cells.rpt
report_qor                          >   ./rpt/synth_qor.rpt
report_resources                    >   ./rpt/synth_resoutces.rpt
report_timing -max_paths 10         >   ./rpt/synth_timing.rpt
report_power -hier                  >   ./rpt/synth_power.rpt
report_power                        >   ./rpt/synth_power_summary.rpt
report_constraint -all_violators    >   ./rpt/synth_timing_constraint.rpt

# write_sdc Bitlet_PE.sdc
# write -f ddc -hierarchy -output Bitlet_PE.ddc
# write -hierarchy -format verilog -output Bitlet_PE.v