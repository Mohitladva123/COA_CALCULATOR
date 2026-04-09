set proj_name "calculator_nexys_a7"
set proj_dir  "./vivado_proj"
set top_name  "calculator_top_nexys_a7"
set part_name "xc7a100tcsg324-1"

create_project $proj_name $proj_dir -part $part_name -force

add_files [glob ./rtl/*.v]
add_files -fileset constrs_1 ./constr/nexys_a7_calculator.xdc

set_property top $top_name [current_fileset]
set_property top $top_name [current_fileset -simset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

open_run impl_1
report_timing_summary -file ./vivado_proj/timing_summary.rpt
report_utilization -file ./vivado_proj/utilization.rpt

puts "Bitstream generated at:"
puts "./vivado_proj/${proj_name}.runs/impl_1/${top_name}.bit"
