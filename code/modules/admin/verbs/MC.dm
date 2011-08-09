/client/proc/restartcontroller()
	set category = "Debug"
	set name = "Restart Master Controller"
	switch(alert("Are you sure?  If the control is still running it will now be running twice.",,"Yes","No"))
		if("Yes")
			spawn(0)
				master_controller.process()
		if("No")
			return 0
	return