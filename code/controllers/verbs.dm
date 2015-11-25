//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done

/client/proc/restart_controller(controller in list("Master","Failsafe","Supply Shuttle", "Process Scheduler"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!holder)	return
	usr = null
	src = null
	switch(controller)
		if("Supply Shuttle")
			supply_shuttle.process()
			feedback_add_details("admin_verb","RSupply")
		if("Process Scheduler")
			var/datum/controller/processScheduler/psched = new
			psched.processes = processScheduler.processes.Copy()
			psched.idle = processScheduler.idle.Copy()
			psched.idle = processScheduler.idle.Copy()
			psched.last_start = processScheduler.last_start.Copy()
			psched.last_run_time = processScheduler.last_run_time.Copy()
			psched.last_twenty_run_times = processScheduler.last_twenty_run_times.Copy()
			psched.highest_run_time = processScheduler.highest_run_time.Copy()
			psched.nameToProcessMap = processScheduler.nameToProcessMap.Copy()
			psched.last_start = processScheduler.last_start.Copy()
			for(var/datum/controller/process/P in psched.processes)
				P.main = psched
			del(processScheduler)
			processScheduler = psched
			//processScheduler.deferSetupFor(/datum/controller/process/ticker)
			processScheduler.start()
			to_chat(world, "<h1><span class='warning'>Process Scheduler was restarted</span></h1>")
	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")
	return


/client/proc/debug_controller(controller in list("Air", "Cameras", "Configuration", "Emergency Shuttle", "failsafe", "Garbage", "Jobs", "master", "pAI", "Radio", "Scheduler", "Sun", "Supply Shuttle", "Ticker", "Vote"))
	set category = "Debug"
	set name = "debug controller"
	set desc = "debug the various periodic loop controllers for the game (be careful!)."

	if (!holder)
		return

	switch (controller)
		if ("master")
			debug_variables(master_controller)
			feedback_add_details("admin_verb", "dmaster")
		if ("failsafe")
			debug_variables(failsafe)
			feedback_add_details("admin_verb", "dfailsafe")
		if("Ticker")
			debug_variables(ticker)
			feedback_add_details("admin_verb","DTicker")
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
		if("Garbage")
			debug_variables(garbageCollector)
			feedback_add_details("admin_verb","DGarbage")
		if("Scheduler")
			debug_variables(processScheduler)
			feedback_add_details("admin_verb","DprocessScheduler")
		if("Vote")
			debug_variables(vote)
			feedback_add_details("admin_verb","DprocessVote")
	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
	return
