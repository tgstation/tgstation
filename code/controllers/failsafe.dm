var/global/datum/controller/failsafe/failsafe

/datum/controller/failsafe // This thing pretty much just keeps poking the controllers.
	processing_interval = 100 // Poke the controllers every 10 seconds.

	/*
	 * Controller alert level.
	 * For every poke that fails this is raised by 1.
	 * When it reaches 5 the MC is replaced with a new one
	 * (effectively killing any controller process() and starting a new one).
	 */

	// master
	var/masterControllerIteration = 0
	var/masterControllerAlertLevel = 0

	// lighting
	var/lightingControllerIteration = 0
	var/lightingControllerAlertLevel = 0

/datum/controller/failsafe/New()
	. = ..()

	// There can be only one failsafe. Out with the old in with the new (that way we can restart the Failsafe by spawning a new one).
	if (failsafe != src)
		if (istype(failsafe))
			recover()
			qdel(failsafe)

		failsafe = src

	failsafe.process()

/datum/controller/failsafe/proc/process()
	processing = 1

	spawn(0)
		set background = BACKGROUND_ENABLED

		while(1) // More efficient than recursivly calling ourself over and over. background = 1 ensures we do not trigger an infinite loop.
			iteration++

			if(processing)
				if(master_controller.processing) // Only poke if these overrides aren't in effect
					if(masterControllerIteration == master_controller.iteration) // Master controller hasn't finished processing in the defined interval.
						switch(masterControllerAlertLevel)
							if(0 to 3)
								masterControllerAlertLevel++
							if(4)
								to_chat(admins, "<font color='red' size='2'><b>Warning. The master Controller has not fired in the last [masterControllerAlertLevel * processing_interval] ticks. Automatic restart in [processing_interval] ticks.</b></font>")
								masterControllerAlertLevel = 5
							if(5)
								to_chat(admins, "<font color='red' size='2'><b>Warning. The master Controller has still not fired within the last [masterControllerAlertLevel * processing_interval] ticks. Killing and restarting...</b></font>")
								new /datum/controller/game_controller() // Replace the old master controller (hence killing the old one's process).
								master_controller.process() // Start it rolling again.
								masterControllerAlertLevel = 0
					else
						masterControllerAlertLevel = 0
						masterControllerIteration = master_controller.iteration

			sleep(processing_interval)
