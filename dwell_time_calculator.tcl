# This script identifies water molecules that permeate through the
# nanotube layer

proc ion_translocate {structPrefix dcd ion_res final_frame zmax zmin ip_folder op_folder} {
	
	mol load psf ${ip_folder}${structPrefix}.psf dcd ${ip_folder}${dcd}.dcd
	# Specify the upper and lower boundaries of the nanotube layer
	set upperEnd ${zmax}
	set lowerEnd ${zmin}
	
	# Opening file
	set outfile [open "${op_folder}/dwell_time_info_${ion_res}_${upperEnd}.dat" w]

	# Start counting permeation events after this number of frames
	set skipFrame 0

	# Rename ion_res for specific ion calc
	puts "Computing permeation events... (please wait)"

	set wat [atomselect top "resname ${ion_res}"]
	set segList [$wat get segname]
	set ridList [$wat get resid]
	set labelList {}
	foreach foo $segList {
  	lappend labelList 0
	}
	#puts "$labelList"

	set num1 0
	set num2 0
	#set numFrame [molinfo top get numframes]
	set numFrame $final_frame
	
	set permeated_ion_list {}
	set exit_frame {}
	
	set entering_ion_list {}
	set enter_frame {}


	# Each water molecule has a label, which has 5 possible values
	#  2: Above the nanotube layer
	# -2: Below the nanotube layer
	#  1: Inside the nanotube layer, entering from upper surface
	# -1: Inside the nanotube layer, entering from lower surface
	#  0: Inside the nanotube layer from the beginning

	# For every frame, the label of each water molecule is
	# determined, and compared with its label in the previous frame.
	# If the new label is +2 (or -2), while the old label is -1 (or +1),
	# it means the water molecule has traversed the nanotube, thus a
	# permeation event is reported and counted. If a water molecule
	# is inside the nanotube layer in the current frame, its label
	# will be determined by its old label.

	for {set fr 0} {$fr < $numFrame} {incr fr} {
	  molinfo top set frame $fr
	  set oldList $labelList
	  set labelList {}
	  foreach z [$wat get z] oldLab $oldList segname $segList resid $ridList {
	    if {$z > $upperEnd} {				# Abover upper in the current frame
	      set newLab 2
	      
	      if {$oldLab == -1} {				### This is to see if it has gone above z from inside the region : -lower < last position < +upper
	        puts $outfile "$segname:$resid permeated through the nanotubes along +z direction at frame $fr"
	        #puts "$resid"
	        lappend permeated_ion_list "$resid"
	        lappend exit_frame "$fr"
	        if {$fr >= $skipFrame} {
	          incr num1
	        }
	      } 
	    } elseif {$z < $lowerEnd} {				# Below lower in the current frame
	      set newLab -2
	      if {$oldLab == 1} {
	        puts $outfile "$segname:$resid permeated through the nanotubes along -z direction at frame $fr"
	        lappend permeated_ion_list "$resid"
	        lappend exit_frame "$fr"
	        if {$fr >= $skipFrame} {
	          incr num2
	        }
	      }
	    } elseif {abs($oldLab) > 1} {			# Inside the tube in the current frame
	      set newLab [expr $oldLab / 2]
	      #puts "ResID: $resid, Segname: $segname"
	      #puts "Changing from $oldLab to $newLab in frame: $fr"
	      
	      set lastElement [lindex $entering_ion_list end]
	      
	      # Check if the last element is equal to the specified value to avoid repitotion 
	      if {$lastElement != $resid} {			# New ion
    		lappend entering_ion_list "$resid"
    		lappend enter_frame "$fr"
	      } else {
    		  #Match found : Replacing last entry frame with the current one
    		  set enter_frame [lreplace $enter_frame end end "$fr"]
		}
	      
	      #lappend entering_ion_list "$resid"
	      #lappend enter_frame "$fr"
	    } else {
	      set newLab $oldLab
	    }
	    lappend labelList $newLab
	  }
	}
	
	puts $outfile ""
	set nf [expr $numFrame-$skipFrame]
	if {$nf >= 0} {
	  puts $outfile "The total number of permeation events during $nf frames in +z direction is: $num1"
	  puts $outfile "The total number of permeation events during $nf frames in -z direction is: $num2"
	} else {
	  puts "The specified first frame ($skipFrame) is larger than the total number of frames ($numFrame)"
	}
	
	mol delete all
	puts $outfile ""
	puts $outfile "ResIDs of permeated ions $permeated_ion_list"
	puts $outfile "Exit frames of ions $exit_frame"
	puts $outfile ""
	puts $outfile "ResIDs of entering ions $entering_ion_list"
	puts $outfile "Enter frames of ions $enter_frame"
	#close $outfile
	
	
	# Dictionary to store the time spent in the region for each ion
	set time_in_region {}
	set ion_with_time {}
	
	set copied_entry_list $entering_ion_list
	set copied_entry_frame $enter_frame
	set copied_exit_list $permeated_ion_list
	set copied_exit_frame $exit_frame
	

	# Loop through each ion in the entering list
	foreach ion_id $entering_ion_list entry_time $enter_frame {
    	# Find the index of the ion in permeated_ion_list to get the exit time
    		set exit_index [lsearch -exact $permeated_ion_list $ion_id]

    		if {$exit_index != -1} {
        		# Ion has an exit record; get the corresponding exit time
        		#---->old line
        		#set exit_time [lindex $exit_frame $exit_index]   
        		
        		###new code starts
        		
        		set copied_index_entry [lsearch -exact $copied_entry_list $ion_id]
        		set new_entry_time [lindex $copied_entry_frame $copied_index_entry]
        		set copied_index_exit [lsearch -exact $copied_exit_list $ion_id]
        		
        		# Ion might not exist in the exit_frame when one ion enters twice but exits once: skip this loop in such case
        		if {$copied_index_exit == -1} {
        			# Skip this iteration
        			continue
        		}
        		
        		set new_exit_time [lindex $copied_exit_frame $copied_index_exit]
        		
        		### Deletes the entry so that duplicates of resid can be included later in calculation
        		set copied_entry_list [lreplace $copied_entry_list $copied_index_entry $copied_index_entry]
        		set copied_entry_frame [lreplace $copied_entry_frame $copied_index_entry $copied_index_entry]
        		set copied_exit_list [lreplace $copied_exit_list $copied_index_exit $copied_index_exit]
        		set copied_exit_frame [lreplace $copied_exit_frame $copied_index_exit $copied_index_exit]
        		
        		###new code ends
        		
        		
        		
        
        		# Calculate the time spent in the region and store it
        		if {$new_exit_time>=$new_entry_time} {
        			set time_spent [expr {($new_exit_time - $new_entry_time)*5}]
        			#puts "Ion $ion_id spent $time_spent time units in the region."
        
        			# Save the result to the dictionary
        			lappend ion_with_time $ion_id
        			lappend time_in_region $time_spent
        		}
    		} else {
        		# No exit record found for this ion
        		puts "Ion $ion_id did not exit the region."
    		}
	}
	
	puts "copied_entry: $copied_entry_list$"
	puts "$copied_entry_frame"
	puts "copied_exit: copied_exit_list"
	puts "$copied_exit_frame"
	
	puts $outfile ""
	puts $outfile "Dwell times of $ion_with_time ::: "
	puts $outfile "$time_in_region"
	
	puts $outfile ""
	puts $outfile "Summary:"
	puts $outfile "Ion Type: ${ion_res}"
	
	if {$num1 != 0} {
    		if {$num2 != 0} {
        		puts $outfile "Direction: Both"
    		} else {
        		puts $outfile "Direction: +ve z"
    		}
	} else {
    		puts $outfile "Direction: +ve z"
	}
	
	set total [expr {$num1 + $num2}]
	puts $outfile "Total number of translocated ions: $total"
	puts $outfile "Dwell times obtained for ions with resid:  $ion_with_time"
	puts $outfile "Dwell times:  $time_in_region"
		
	close $outfile
}
