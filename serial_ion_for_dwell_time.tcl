# Put the detail here
set sprefix nw_mosse_se-se_d15.8_0.8nm_ions
set dcd nw_mosse_se-se_d15.8_0.8nm_20.0V_1 
set final_frame 5400
set zmax 12.71
set zmin -12.71
set ip ./
set op ./

source dwell_time_calculator.tcl

ion_translocate $sprefix $dcd POT $final_frame $zmax $zmin $ip $op
ion_translocate $sprefix $dcd CLA $final_frame $zmax $zmin $ip $op
