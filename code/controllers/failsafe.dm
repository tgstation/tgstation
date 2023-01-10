/**
 * Failsafe
 *
 * Pretty much pokes the MC to make sure it's still alive.
 **/

GLOBAL_REAL(Failsafe, /datum/controller/failsafe)

/datum/controller/failsafe // This thing pretty much just keeps poking the master controller
	name = "Failsafe"

	// The length of time to check on the MC (in deciseconds).
	// Set to 0 to disable.
	var/processing_interval = 20
	// The alert level. For every failed poke, we drop a DEFCON level. Once we hit DEFCON 1, restart the MC.
	var/defcon = 5
	//the world.time of the last check, so the mc can restart US if we hang.
	// (Real friends look out for *eachother*)
	var/lasttick = 0

	// Track the MC iteration to make sure its still on track.
	var/master_iteration = 0
	var/running = TRUE

/datum/controller/failsafe/New()
	// Highlander-style: there can only be one! Kill off the old and replace it with the new.
	if(Failsafe != src)
		if(istype(Failsafe))
			qdel(Failsafe)
	Failsafe = src
	Initialize()

/datum/controller/failsafe/Initialize()
	set waitfor = FALSE
	Failsafe.Loop()
	if (!Master || defcon == 0) //Master is gone/not responding and Failsafe just exited its loop
		defcon = 3 //Reset defcon level as its used inside the emergency loop
		while (defcon > 0)
			var/recovery_result = emergency_loop()
			if (recovery_result == 1) //Exit emergency loop and delete self if it was able to recover MC
				break
			else if (defcon == 1) //Exit Failsafe if we weren't able to recover the MC in the last stage
				log_game("FailSafe: Failed to recover MC while in emergency state. Failsafe exiting.")
				message_admins(span_boldannounce("Failsafe failed critically while trying to recreate broken MC. Please manually fix the MC or reboot the server. Failsafe exiting now."))
				message_admins(span_boldannounce("You can try manually calling these two procs:."))
				message_admins(span_boldannounce("/proc/recover_all_SS_and_recreate_master: Most stuff should still function but expect instability/runtimes/broken stuff."))
				message_admins(span_boldannounce("/proc/delete_all_SS_and_recreate_master: Most stuff will be broken but basic stuff like movement and chat should still work."))
			else if (recovery_result == -1) //Failed to recreate MC
				defcon--
			sleep(initial(processing_interval)) //Wait a bit until the next try

	if(!QDELETED(src))
		qdel(src) //when Loop() returns, we delete ourselves and let the mc recreate us

/datum/controller/failsafe/Destroy()
	running = FALSE
	..()
	return QDEL_HINT_HARDDEL_NOW

/datum/controller/failsafe/proc/Loop()
	while(running)
		lasttick = world.time
		if(!Master)
			// Break out of the main loop so we go into emergency state
			break
		// Only poke it if overrides are not in effect.
		if(processing_interval > 0)
			if(Master.processing && Master.iteration)
				if (defcon > 1 && (!Master.stack_end_detector || !Master.stack_end_detector.check()))

					to_chat(GLOB.admins, span_boldannounce("ERROR: The Master Controller code stack has exited unexpectedly, Restarting..."))
					defcon = 0
					var/rtn = Recreate_MC()
					if(rtn > 0)
						master_iteration = 0
						to_chat(GLOB.admins, span_adminnotice("MC restarted successfully"))
					else if(rtn < 0)
						log_game("FailSafe: Could not restart MC, runtime encountered. Entering defcon 0")
						to_chat(GLOB.admins, span_boldannounce("ERROR: DEFCON [defcon_pretty()]. Could not restart MC, runtime encountered. I will silently keep retrying."))
				// Check if processing is done yet.
				if(Master.iteration == master_iteration)
					switch(defcon)
						if(4,5)
							--defcon

						if(3)
							message_admins(span_adminnotice("Notice: DEFCON [defcon_pretty()]. The Master Controller has not fired in the last [(5-defcon) * processing_interval] ticks."))
							--defcon

						if(2)
							to_chat(GLOB.admins, span_boldannounce("Warning: DEFCON [defcon_pretty()]. The Master Controller has not fired in the last [(5-defcon) * processing_interval] ticks. Automatic restart in [processing_interval] ticks."))
							--defcon

						if(1)
							to_chat(GLOB.admins, span_boldannounce("Warning: DEFCON [defcon_pretty()]. The Master Controller has still not fired within the last [(5-defcon) * processing_interval] ticks. Killing and restarting..."))
							--defcon
							var/rtn = Recreate_MC()
							if(rtn > 0)
								defcon = 4
								master_iteration = 0
								to_chat(GLOB.admins, span_adminnotice("MC restarted successfully"))
							else if(rtn < 0)
								log_game("FailSafe: Could not restart MC, runtime encountered. Entering defcon 0")
								to_chat(GLOB.admins, span_boldannounce("ERROR: DEFCON [defcon_pretty()]. Could not restart MC, runtime encountered. I will silently keep retrying."))
							//if the return number was 0, it just means the mc was restarted too recently, and it just needs some time before we try again
							//no need to handle that specially when defcon 0 can handle it

						if(0) //DEFCON 0! (mc failed to restart)
							var/rtn = Recreate_MC()
							if(rtn > 0)
								defcon = 4
								master_iteration = 0
								to_chat(GLOB.admins, span_adminnotice("MC restarted successfully"))
				else
					defcon = min(defcon + 1,5)
					master_iteration = Master.iteration
			if (defcon <= 1)
				sleep(processing_interval*2)
			else
				sleep(processing_interval)
		else
			defcon = 5
			sleep(initial(processing_interval))

//Emergency loop used when Master got deleted or the main loop exited while Defcon == 0
//Loop is driven externally so runtimes only cancel the current recovery attempt
/datum/controller/failsafe/proc/emergency_loop()
	//The code in this proc should be kept as simple as possible, anything complicated like to_chat might rely on master existing and runtime
	//The goal should always be to get a new Master up and running before anything else
	. = -1
	switch (defcon) //The lower defcon goes the harder we try to fix the MC
		if (2 to 3) //Try to normally recreate the MC two times
			. = Recreate_MC()
		if (1) //Delete the old MC first so we don't transfer any info, in case that caused any issues
			del(Master)
			. = Recreate_MC()

	if (. == 1) //We were able to create a new master
		master_iteration = 0
		SSticker.Recover(); //Recover the ticket system so the Masters runlevel gets set
		Master.Initialize(10, FALSE, TRUE) //Need to manually start the MC, normally world.new would do this
		to_chat(GLOB.admins, span_adminnotice("Failsafe recovered MC while in emergency state [defcon_pretty()]"))
	else
		log_game("FailSafe: Failsafe in emergency state and was unable to recreate MC while in defcon state [defcon_pretty()].")
		message_admins(span_boldannounce("Failsafe in emergency state and master down, trying to recreate MC while in defcon level [defcon_pretty()] failed."))

///Recreate all SSs which will still cause data survive due to Recover(), the new Master will then find and take them from global.vars
/proc/recover_all_SS_and_recreate_master()
	del(Master)
	var/list/subsytem_types = subtypesof(/datum/controller/subsystem)
	sortTim(subsytem_types, GLOBAL_PROC_REF(cmp_subsystem_init))
	for(var/I in subsytem_types)
		new I
	. = Recreate_MC()
	if (. == 1) //We were able to create a new master
		SSticker.Recover(); //Recover the ticket system so the Masters runlevel gets set
		Master.Initialize(10, FALSE, TRUE) //Need to manually start the MC, normally world.new would do this
		to_chat(GLOB.admins, span_adminnotice("MC successfully recreated after recovering all subsystems!"))
	else
		message_admins(span_boldannounce("Failed to create new MC!"))

///Delete all existing SS to basically start over
/proc/delete_all_SS_and_recreate_master()
	del(Master)
	for(var/global_var in global.vars)
		if (istype(global.vars[global_var], /datum/controller/subsystem))
			del(global.vars[global_var])
	. = Recreate_MC()
	if (. == 1) //We were able to create a new master
		SSticker.Recover(); //Recover the ticket system so the Masters runlevel gets set
		Master.Initialize(10, FALSE, TRUE) //Need to manually start the MC, normally world.new would do this
		to_chat(GLOB.admins, span_adminnotice("MC successfully recreated after deleting and recreating all subsystems!"))
	else
		message_admins(span_boldannounce("Failed to create new MC!"))

/datum/controller/failsafe/proc/defcon_pretty()
	return defcon

/datum/controller/failsafe/stat_entry(msg)
	msg = "Defcon: [defcon_pretty()] (Interval: [Failsafe.processing_interval] | Iteration: [Failsafe.master_iteration])"
	return msg
