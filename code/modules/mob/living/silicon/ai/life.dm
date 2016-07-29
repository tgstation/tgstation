<<<<<<< HEAD
#define POWER_RESTORATION_OFF 0
#define POWER_RESTORATION_START 1
#define POWER_RESTORATION_SEARCH_APC 2
#define POWER_RESTORATION_APC_FOUND 3

/mob/living/silicon/ai/Life()
	if (src.stat == DEAD)
		return
	else //I'm not removing that shitton of tabs, unneeded as they are. -- Urist
		//Being dead doesn't mean your temperature never changes

		update_gravity(mob_has_gravity())

		if(malfhack && malfhack.aidisabled)
			deltimer(malfhacking)
			// This proc handles cleanup of screen notifications and
			// messenging the client
			malfhacked(malfhack)

		if(!eyeobj || qdeleted(eyeobj) || !eyeobj.loc)
			view_core()

		if(machine)
			machine.check_eye(src)

		// Handle power damage (oxy)
		if(aiRestorePowerRoutine)
=======
/mob/living/silicon/ai/Life()
	if(timestopped) return 0 //under effects of time magick

	if (src.stat == 2)
		return
	else //I'm not removing that shitton of tabs, unneeded as they are. -- Urist
		//Being dead doesn't mean your temperature never changes
		var/turf/T = get_turf(src)

		if (src.stat!=0)
			src.cameraFollow = null
			src.reset_view(null)
			src.unset_machine()

		src.updatehealth()

		if (src.malfhack)
			if (src.malfhack.aidisabled)
				to_chat(src, "<span class='warning'>ERROR: APC access disabled, hack attempt canceled.</span>")
				src.malfhacking = 0
				src.malfhack = null


		if (src.health <= config.health_threshold_dead)
			death()
			return

		if(client)
			if (src.machine)
				if (!( src.machine.check_eye(src) ))
					src.reset_view(null)
			else
				if(!isTeleViewing(client.eye))
					reset_view(null)

		// Handle power damage (oxy)
		if(src:aiRestorePowerRoutine != 0)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			// Lost power
			adjustOxyLoss(1)
		else
			// Gain Power
<<<<<<< HEAD
			if(getOxyLoss())
				adjustOxyLoss(-1)

		if(!lacks_power())
			var/area/home = get_area(src)
			if(home.powered(EQUIP))
				home.use_power(1000, EQUIP)

			if(aiRestorePowerRoutine >= POWER_RESTORATION_SEARCH_APC)
				ai_restore_power()
				return

		else if(!aiRestorePowerRoutine)
			ai_lose_power()

/mob/living/silicon/ai/proc/lacks_power()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	return !T || !A || ((!A.master.power_equip || istype(T, /turf/open/space)) && !is_type_in_list(src.loc, list(/obj/item, /obj/mecha)))

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getBruteLoss() - getFireLoss()
	update_stat()
	diag_hud_set_health()

/mob/living/silicon/ai/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= config.health_threshold_dead)
			death()
			return
		else if(stat == UNCONSCIOUS)
			stat = CONSCIOUS
			adjust_blindness(-1)
	diag_hud_set_status()

/mob/living/silicon/ai/update_sight()
	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	if(aiRestorePowerRoutine)
		sight = sight&~SEE_TURFS
		sight = sight&~SEE_MOBS
		sight = sight&~SEE_OBJS
		see_in_dark = 0

	if(see_override)
		see_invisible = see_override


/mob/living/silicon/ai/proc/start_RestorePowerRoutine()
	src << "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection."
	sleep(50)
	var/turf/T = get_turf(src)
	var/area/AIarea = get_area(src)
	if(AIarea && AIarea.master.power_equip)
		if(!istype(T, /turf/open/space))
			ai_restore_power()
			return
	src << "Fault confirmed: missing external power. Shutting down main control system to save power."
	sleep(20)
	src << "Emergency control system online. Verifying connection to power network."
	sleep(50)
	T = get_turf(src)
	if (istype(T, /turf/open/space))
		src << "Unable to verify! No power connection detected!"
		aiRestorePowerRoutine = POWER_RESTORATION_SEARCH_APC
		return
	src << "Connection verified. Searching for APC in power network."
	sleep(50)
	var/obj/machinery/power/apc/theAPC = null

	var/PRP //like ERP with the code, at least this stuff is no more 4x sametext
	for (PRP=1, PRP<=4, PRP++)
		T = get_turf(src)
		AIarea = get_area(src)
		if(AIarea)
			for(var/area/A in AIarea.master.related)
				for (var/obj/machinery/power/apc/APC in A)
					if (!(APC.stat & BROKEN))
						theAPC = APC
						break
		if (!theAPC)
			switch(PRP)
				if(1)
					src << "Unable to locate APC!"
				else
					src << "Lost connection with the APC!"
			aiRestorePowerRoutine = POWER_RESTORATION_SEARCH_APC
			return
		if(AIarea.master.power_equip)
			if (!istype(T, /turf/open/space))
				ai_restore_power()
				return
		switch(PRP)
			if (1) src << "APC located. Optimizing route to APC to avoid needless power waste."
			if (2) src << "Best route identified. Hacking offline APC power port."
			if (3) src << "Power port upload access confirmed. Loading control program into APC power port software."
			if (4)
				src << "Transfer complete. Forcing APC to execute program."
				sleep(50)
				src << "Receiving control information from APC."
				sleep(2)
				apc_override = 1
				theAPC.ui_interact(src, state = conscious_state)
				apc_override = 0
				aiRestorePowerRoutine = POWER_RESTORATION_APC_FOUND
				src << "Here are your current laws:"
				show_laws()
		sleep(50)
		theAPC = null

/mob/living/silicon/ai/proc/ai_restore_power()
	if(aiRestorePowerRoutine)
		if(aiRestorePowerRoutine == POWER_RESTORATION_APC_FOUND)
			src << "Alert cancelled. Power has been restored."
		else
			src << "Alert cancelled. Power has been restored without our assistance."
		aiRestorePowerRoutine = POWER_RESTORATION_OFF
		set_blindness(0)
		update_sight()

/mob/living/silicon/ai/proc/ai_lose_power()
	aiRestorePowerRoutine = POWER_RESTORATION_START
	blind_eyes(1)
	update_sight()
	src << "You've lost power!"
	addtimer(src, "start_RestorePowerRoutine", 20)

#undef POWER_RESTORATION_OFF
#undef POWER_RESTORATION_START
#undef POWER_RESTORATION_SEARCH_APC
#undef POWER_RESTORATION_APC_FOUND
=======
			adjustOxyLoss(-1)

		//stage = 1
		//if (istype(src, /mob/living/silicon/ai)) // Are we not sure what we are?
		var/blind = 0
		//stage = 2
		var/area/loc = null
		if (istype(T, /turf))
			//stage = 3
			loc = T.loc
			if (istype(loc, /area))
				//stage = 4
				if (!loc.power_equip && !istype(src.loc,/obj/item))
					//stage = 5
					blind = 1
		if (!blind)	//lol? if(!blind)	#if(src.blind.layer)    <--something here is clearly wrong :P
					//I'll get back to this when I find out  how this is -supposed- to work ~Carn //removed this shit since it was confusing as all hell --39kk9t
			//stage = 4.5
			if(client && client.eye == eyeobj) // We are viewing the world through our "eye" mob.
				src.sight |= SEE_TURFS
				src.sight |= SEE_MOBS
				src.sight |= SEE_OBJS
				src.see_in_dark = 8
				src.see_invisible = SEE_INVISIBLE_LEVEL_TWO

			var/area/home = get_area(src)
			//if(!home)	return//something to do with malf fucking things up I guess. <-- aisat is gone. is this still necessary? ~Carn
			if(home && home.powered(EQUIP))
				home.use_power(1000, EQUIP)

			if (src:aiRestorePowerRoutine==2)
				to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
				src:aiRestorePowerRoutine = 0
				if(src.blind)
					src.blind.layer = 0
				return
			else if (src:aiRestorePowerRoutine==3)
				to_chat(src, "Alert cancelled. Power has been restored.")
				src:aiRestorePowerRoutine = 0
				if(src.blind)
					src.blind.layer = 0
				return
			else if (src.aiRestorePowerRoutine == -1)
				to_chat(src, "Alert cancelled. External power source detected.")
				src:aiRestorePowerRoutine = 0
				if(src.blind)
					src.blind.layer = 0
				return

		else

			//stage = 6
			if(client)
				if(src.blind)
					src.blind.screen_loc = "1,1 to 15,15"
					if (src.blind.layer!=18)
						src.blind.layer = 18
				src.sight = src.sight&~SEE_TURFS
				src.sight = src.sight&~SEE_MOBS
				src.sight = src.sight&~SEE_OBJS
				src.see_in_dark = 0
			src.see_invisible = SEE_INVISIBLE_LIVING

			if (((!loc.power_equip) || istype(T, /turf/space)) && !istype(src.loc,/obj/item))
				if (src:aiRestorePowerRoutine==0)
					src:aiRestorePowerRoutine = 1

					to_chat(src, "You've lost power!")
//							to_chat(world, "DEBUG CODE TIME! [loc] is the area the AI is sucking power from")
					if (!is_special_character(src))
						src.set_zeroth_law("")
					//src.clear_supplied_laws() // Don't reset our laws.
					//var/time = time2text(world.realtime,"hh:mm:ss")
					//lawchanges.Add("[time] <b>:</b> [src.name]'s noncore laws have been reset due to power failure")
					spawn(20)
						if(!src.aiRestorePowerRoutine)
							blind = 0
							return // Checking for premature changes.
						to_chat(src, "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection.")
						sleep(50)
						if(!src.aiRestorePowerRoutine)
							blind = 0
							return // Checking for premature changes.
						if (loc.power_equip)
							if (!istype(T, /turf/space))
								to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
								src:aiRestorePowerRoutine = 0
								if(src.blind)
									src.blind.layer = 0
								return
						to_chat(src, "Fault confirmed: missing external power. Shutting down main control system to save power.")
						sleep(20)
						if(!src.aiRestorePowerRoutine)
							blind = 0
							return // Checking for premature changes.
						to_chat(src, "Emergency control system online. Verifying connection to power network.")
						sleep(50)
						if(!src.aiRestorePowerRoutine)
							blind = 0
							return // Checking for premature changes.
						if (istype(T, /turf/space))
							to_chat(src, "Unable to verify! No power connection detected!")
							src:aiRestorePowerRoutine = 2
							return
						to_chat(src, "Connection verified. Searching for APC in power network.")
						sleep(50)
						if(!src.aiRestorePowerRoutine)
							blind = 0
							return // Checking for premature changes.
						var/obj/machinery/power/apc/theAPC = null
/*
						for (var/something in loc)
							if (istype(something, /obj/machinery/power/apc))
								if (!(something:stat & BROKEN))
									theAPC = something
									break
*/
						var/PRP //like ERP with the code, at least this stuff is no more 4x sametext
						for (PRP=1, PRP<=4, PRP++)
							if(!src.aiRestorePowerRoutine)
								blind = 0
								return // Checking for premature changes.
							var/area/AIarea = get_area(src)
							for (var/obj/machinery/power/apc/APC in AIarea)
								if (!(APC.stat & BROKEN))
									theAPC = APC
									break
							if (!theAPC)
								switch(PRP)
									if (1) to_chat(src, "Unable to locate APC!")
									else to_chat(src, "Lost connection with the APC!")
								src:aiRestorePowerRoutine = 2
								return
							if (loc.power_equip)
								if (!istype(T, /turf/space))
									to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
									src:aiRestorePowerRoutine = 0
									if(src.blind)
										src.blind.layer = 0 //This, too, is a fix to issue 603
									return
							switch(PRP)
								if (1) to_chat(src, "APC located. Optimizing route to APC to avoid needless power waste.")
								if (2) to_chat(src, "Best route identified. Hacking offline APC power port.")
								if (3) to_chat(src, "Power port upload access confirmed. Loading control program into APC power port software.")
								if (4)
									to_chat(src, "Transfer complete. Forcing APC to execute program.")
									sleep(50)
									if(!src.aiRestorePowerRoutine)
										theAPC = null
										blind = 0
										return // Checking for premature changes.
									to_chat(src, "Receiving control information from APC.")
									sleep(2)
									if(!src.aiRestorePowerRoutine)
										theAPC = null
										blind = 0
										return // Checking for premature changes.
									//bring up APC dialog
									theAPC.attack_ai(src)
									src:aiRestorePowerRoutine = 3
									to_chat(src, "Here are your current laws:")
									src.show_laws()
							sleep(50)
							theAPC = null

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		if(ai_flags & COREFIRERESIST)
			health = maxHealth - getOxyLoss() - getToxLoss() - getBruteLoss()
		else
			health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
