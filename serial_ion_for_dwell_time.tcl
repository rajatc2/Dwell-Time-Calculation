# Put the detail here
set sprefix nw_mosse_se-se_d15.8_0.8nm_ions
set dcd nw_mosse_se-se_d15.8_0.8nm_20.0V_1 
set final_frame 5400
set zmax 7.9
set zmin -7.9
set ip ./		#input folder directory
set op ./		#output folder directory
set op_file $zmax	#op_file_name

source dwell_time_calculator.tcl

ion_translocate $sprefix $dcd POT $final_frame $zmax $zmin $ip $op $op_file
ion_translocate $sprefix $dcd CLA $final_frame $zmax $zmin $ip $op $op_file
