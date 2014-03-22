//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done

/client/proc/restart_controller(controller in list("Master","Failsafe","Lighting","Supply Shuttle"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	usr = null
	src = null
	switch(controller)
		if("Master")
			new /datum/controller/game_controller()
			master_controller.process()
			feedback_add_details("admin_verb","RMC")
		if("Failsafe")
			new /datum/controller/failsafe()
			feedback_add_details("admin_verb","RFailsafe")
		if("Lighting")
			new /datum/controller/lighting()
			lighting_controller.process()
			feedback_add_details("admin_verb","RLighting")
		if("Supply Shuttle")
			supply_shuttle.process()
			feedback_add_details("admin_verb","RSupply")
	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")
	return


/client/proc/debug_controller(controller in list("Master","Failsafe","Ticker","Lighting","Garbage","Air","Jobs","Sun","Radio","Supply Shuttle","Emergency Shuttle","Configuration","pAI", "Cameras", "Events"))
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	switch(controller)
		if("Master")
			debug_variables(master_controller)
			feedback_add_details("admin_verb","DMC")
		if("Failsafe")
			debug_variables(Failsafe)
			feedback_add_details("admin_verb","DFailsafe")
		if("Ticker")
			debug_variables(ticker)
			feedback_add_details("admin_verb","DTicker")
		if("Lighting")
			debug_variables(lighting_controller)
			feedback_add_details("admin_verb","DLighting")
		if("Garbage")
			debug_variables(garbage)
			feedback_add_details("admin_verb","DGarbage")
		if("Air")
			debug_variables(air_master)
			feedback_add_details("admin_verb","DAir")
		if("Jobs")
			debug_variables(job_master)
			feedback_add_details("admin_verb","DJobs")
		if("Sun")
			debug_variables(sun)
			feedback_add_details("admin_verb","DSun")
		if("Radio")
			debug_variables(radio_controller)
			feedback_add_details("admin_verb","DRadio")
		if("Supply Shuttle")
			debug_variables(supply_shuttle)
			feedback_add_details("admin_verb","DSupply")
		if("Emergency Shuttle")
			debug_variables(emergency_shuttle)
			feedback_add_details("admin_verb","DEmergency")
		if("Configuration")
			debug_variables(config)
			feedback_add_details("admin_verb","DConf")
		if("pAI")
			debug_variables(paiController)
			feedback_add_details("admin_verb","DpAI")
		if("Cameras")
			debug_variables(cameranet)
			feedback_add_details("admin_verb","DCameras")
		if("Events")
			debug_variables(events)
			feedback_add_details("admin_verb","DEvents")
	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return
