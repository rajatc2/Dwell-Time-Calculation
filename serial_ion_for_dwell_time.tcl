# Put the detail here
set sprefix #put the name of the psf file here (without .psf)
set dcd #put the name of the psf file here (without .dcd)
set final_frame 5400
set zmax 7.9
set zmin -7.9
set ip ./		#input folder directory
set op ./		#input folder directory

source dwell_time_calculator.tcl

ion_translocate $sprefix $dcd POT $final_frame $zmax $zmin $ip $op
ion_translocate $sprefix $dcd CLA $final_frame $zmax $zmin $ip $op
