var/datum/controller/failsafe/Failsafe

/datum/controller/failsafe // This thing pretty much just keeps poking the master controller
	var/processing = 0
	var/processing_interval = 100	//poke the MC every 10 seconds

	var/MC_iteration = 0
	var/MC_defcon = 0			//alert level. For every poke that fails this is raised by 1. When it reaches 5 the MC is replaced with a new one. (effectively killing any master_controller.process() and starting a new one)

	var/lighting_iteration = 0
	var/lighting_defcon = 0		//alert level for lighting controller.

/datum/controller/failsafe/New()
	//There can be only one failsafe. Out with the old in with the new (that way we can restart the Failsafe by spawning a new one)
	if(Failsafe != src)
		if(istype(Failsafe))
			del(Failsafe)
	Failsafe = src
	Failsafe.process()


/datum/controller/failsafe/proc/process()
	processing = 1
	spawn(0)
		set background = 1
		while(1)	//more efficient than recursivly calling ourself over and over. background = 1 ensures we do not trigger an infinite loop
			if(!master_controller)		new /datum/controller/game_controller()	//replace the missing master_controller! This should never happen.
			if(!lighting_controller)	new /datum/controller/lighting()		//replace the missing lighting_controller

			if(processing)
				if(master_controller.processing)	//only poke if these overrides aren't in effect
					if(MC_iteration == controller_iteration)	//master_controller hasn't finished processing in the defined interval
						switch(MC_defcon)
							if(0 to 3)
								MC_defcon++
							if(4)
								for(var/client/C in admin_list)
									C << "<font color='red' size='2'><b>Warning. The Master Controller has not fired in the last [MC_defcon*processing_interval] ticks. Automatic restart in [processing_interval] ticks.</b></font>"
								MC_defcon = 5
							if(5)
								for(var/client/C in admin_list)
									C << "<font color='red' size='2'><b>Warning. The Master Controller has still not fired within the last [MC_defcon*processing_interval] ticks. Killing and restarting...</b></font>"
								new /datum/controller/game_controller()	//replace the old master_controller (hence killing the old one's process)
								master_controller.process()				//Start it rolling again
								MC_defcon = 0
					else
						MC_defcon = 0
						MC_iteration = controller_iteration

				if(lighting_controller.processing)
					if(lighting_iteration == lighting_controller.iteration)	//master_controller hasn't finished processing in the defined interval
						switch(lighting_defcon)
							if(0 to 3)
								lighting_defcon++
							if(4)
								for(var/client/C in admin_list)
									C << "<font color='red' size='2'><b>Warning. The Lighting Controller has not fired in the last [lighting_defcon*processing_interval] ticks. Automatic restart in [processing_interval] ticks.</b></font>"
								lighting_defcon = 5
							if(5)
								for(var/client/C in admin_list)
									C << "<font color='red' size='2'><b>Warning. The Lighting Controller has still not fired within the last [lighting_defcon*processing_interval] ticks. Killing and restarting...</b></font>"
								new /datum/controller/lighting()	//replace the old lighting_controller (hence killing the old one's process)
								lighting_controller.process()		//Start it rolling again
								lighting_defcon = 0
					else
						lighting_defcon = 0
						lighting_iteration = lighting_controller.iteration
			else
				MC_defcon = 0
				lighting_defcon = 0

			sleep(processing_interval)