open_project standalone.xpr

reset_run synth_1
reset_run impl_1

puts "Run synth_1 ..."
launch_runs synth_1
puts "wait for synth_1 ..."
wait_on_run synth_1
puts "synth_1 finished"

puts "Run impl_1 ..."
launch_runs impl_1
puts "wait for impl_1 ..."
wait_on_run impl_1
puts "impl_1 finished"

puts "Run impl_1 bitstream..."
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
puts "impl_1 bitstream finished"
