//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done

/obj/effect/statclick
	var/target

/obj/effect/statclick/New(text, target)
	src.name = text
	src.target = target

/obj/effect/statclick/proc/update(text)
	src.name = text
	return src

/obj/effect/statclick
	var/class

/obj/effect/statclick/debug/Click()
	if(!usr.client.holder)
		return
	if(!class)
		if(istype(target, /datum/subsystem))
			class = "subsystem"
		else if(istype(target, /datum/controller))
			class = "controller"
		else
			class = "unknown"

	usr.client.debug_variables(target)
	message_admins("Admin [key_name_admin(usr)] is debugging the [target] [class].")

/client/proc/restart_controller(controller in list("Master", "Failsafe"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!holder)
		return
	switch(controller)
		if("Master")
			new /datum/controller/game_controller()
			master_controller.process()
			feedback_add_details("admin_verb","RMC")
		if("Failsafe")
			new /datum/controller/failsafe()
			feedback_add_details("admin_verb","RFailsafe")

	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")

/client/proc/debug_controller(controller in list("Master", "Failsafe", "Ticker", "Jobs", "Radio", "Configuration", "Cameras"))
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder)
		return
	switch(controller)
		if("Master")
			debug_variables(master_controller)
		if("Failsafe")
			debug_variables(Failsafe)
		if("Ticker")
			debug_variables(ticker)
		if("Jobs")
			debug_variables(SSjob)
		if("Radio")
			debug_variables(radio_controller)
		if("Configuration")
			debug_variables(config)
		if("Cameras")
			debug_variables(cameranet)

	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
