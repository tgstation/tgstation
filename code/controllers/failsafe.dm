<<<<<<< HEAD
 /**
  * Failsafe
  *
  * Pretty much pokes the MC to make sure it's still alive.
 **/

var/datum/controller/failsafe/Failsafe

/datum/controller/failsafe // This thing pretty much just keeps poking the master controller
	name = "Failsafe"

	// The length of time to check on the MC (in deciseconds).
	// Set to 0 to disable.
	var/processing_interval = 20
	// The alert level. For every failed poke, we drop a DEFCON level. Once we hit DEFCON 1, restart the MC.
	var/defcon = 5
	//the world.time of the last check, so the mc can restart US if we hang.
	//	(Real friends look out for *eachother*)
	var/lasttick = 0

	// Track the MC iteration to make sure its still on track.
	var/master_iteration = 0

/datum/controller/failsafe/New()
	// Highlander-style: there can only be one! Kill off the old and replace it with the new.
	if(Failsafe != src)
		if(istype(Failsafe))
			qdel(Failsafe)
	Failsafe = src
	spawn()
		Failsafe.Loop()
		qdel(Failsafe) //when Loop() returns, we delete ourselves and let the mc recreate us

/datum/controller/failsafe/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

/datum/controller/failsafe/proc/Loop()
	while(1)
		lasttick = world.time
		if(!Master)
			// Replace the missing Master! This should never, ever happen.
			new /datum/controller/master()
		// Only poke it if overrides are not in effect.
		if(processing_interval > 0)
			if(Master.processing && Master.iteration)
				// Check if processing is done yet.
				if(Master.iteration == master_iteration)
					switch(defcon)
						if(4,5)
							--defcon
						if(3)
							admins << "<span class='adminnotice'>Notice: DEFCON [defcon_pretty()]. The Master Controller has not fired in the last [(5-defcon) * processing_interval] ticks."
							--defcon
						if(2)
							admins << "<span class='boldannounce'>Warning: DEFCON [defcon_pretty()]. The Master Controller has not fired in the last [(5-defcon) * processing_interval] ticks. Automatic restart in [processing_interval] ticks.</span>"
							--defcon
						if(1)

							admins << "<span class='boldannounce'>Warning: DEFCON [defcon_pretty()]. The Master Controller has still not fired within the last [(5-defcon) * processing_interval] ticks. Killing and restarting...</span>"
							--defcon
							var/rtn = Recreate_MC()
							if(rtn > 0)
								defcon = 4
								master_iteration = 0
								admins << "<span class='adminnotice'>MC restarted successfully</span>"
							else if(rtn < 0)
								log_game("FailSafe: Could not restart MC, runtime encountered. Entering defcon 0")
								admins << "<span class='boldannounce'>ERROR: DEFCON [defcon_pretty()]. Could not restart MC, runtime encountered. I will silently keep retrying.</span>"
							//if the return number was 0, it just means the mc was restarted too recently, and it just needs some time before we try again
							//no need to handle that specially when defcon 0 can handle it
						if(0) //DEFCON 0! (mc failed to restart)
							var/rtn = Recreate_MC()
							if(rtn > 0)
								defcon = 4
								master_iteration = 0
								admins << "<span class='adminnotice'>MC restarted successfully</span>"
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

/datum/controller/failsafe/proc/defcon_pretty()
	return defcon

/datum/controller/failsafe/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug("Initializing...", src)

	stat("Failsafe Controller:", statclick.update("Defcon: [defcon_pretty()] (Interval: [Failsafe.processing_interval] | Iteration: [Failsafe.master_iteration])"))
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
