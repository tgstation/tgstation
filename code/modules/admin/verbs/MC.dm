/client/proc/restartcontroller()
	set category = "Debug"
	set name = "Restart Master Controller"
	switch(alert("Are you sure?  If the control is still running it will now be running twice.",,"Yes","No"))
		if("Yes")
			spawn(0)
				master_controller.process()
		if("No")
			return 0
	//feedback_add_details("admin_verb","RMC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/debug_master_controller()
	set category = "Debug"
	set name = "Debug Master Controller"
	switch(alert("Debug Master Controller or Failsafe?" ,, "Master Controller" , "Failsafe"))
		if("Master Controller")
			debug_variables(master_controller)
		if("Failsafe")
			debug_variables(Failsafe)
	//feedback_add_details("admin_verb","DMC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return