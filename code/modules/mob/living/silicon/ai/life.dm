/mob/living/silicon/ai/Life()
	if (src.stat == DEAD)
		return
	else //I'm not removing that shitton of tabs, unneeded as they are. -- Urist
		//Being dead doesn't mean your temperature never changes

		update_gravity(mob_has_gravity())

		update_action_buttons()

		if(malfhack)
			if(malfhack.aidisabled)
				src << "<span class='danger'>ERROR: APC access disabled, hack attempt canceled.</span>"
				malfhacking = 0
				malfhack = null

		if(machine)
			machine.check_eye(src)

		// Handle power damage (oxy)
		if(aiRestorePowerRoutine)
			// Lost power
			adjustOxyLoss(1)
		else
			// Gain Power
			if(getOxyLoss())
				adjustOxyLoss(-1)

		if(!lacks_power())
			var/area/home = get_area(src)
			if(home.powered(EQUIP))
				home.use_power(1000, EQUIP)

			if(aiRestorePowerRoutine==2)
				src << "Alert cancelled. Power has been restored without our assistance."
				aiRestorePowerRoutine = 0
				set_blindness(0)
				update_sight()
				return
			else if (aiRestorePowerRoutine==3)
				src << "Alert cancelled. Power has been restored."
				aiRestorePowerRoutine = 0
				set_blindness(0)
				update_sight()
				return

		else if(!aiRestorePowerRoutine)
			aiRestorePowerRoutine = 1
			blind_eyes(1)
			update_sight()
			src << "You've lost power!"
			spawn(20)
				start_RestorePowerRoutine()

/mob/living/silicon/ai/proc/lacks_power()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	return !T || !A || ((!A.master.power_equip || istype(T, /turf/space)) && !is_type_in_list(src.loc, list(/obj/item, /obj/mecha)))

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getBruteLoss()
	if(!fire_res_on_core)
		health -= getFireLoss()
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
		if(!istype(T, /turf/space))
			src << "Alert cancelled. Power has been restored without our assistance."
			aiRestorePowerRoutine = 0
			set_blindness(0)
			update_sight()
			return
	src << "Fault confirmed: missing external power. Shutting down main control system to save power."
	sleep(20)
	src << "Emergency control system online. Verifying connection to power network."
	sleep(50)
	T = get_turf(src)
	if (istype(T, /turf/space))
		src << "Unable to verify! No power connection detected!"
		aiRestorePowerRoutine = 2
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
			aiRestorePowerRoutine = 2
			return
		if(AIarea.master.power_equip)
			if (!istype(T, /turf/space))
				src << "Alert cancelled. Power has been restored without our assistance."
				aiRestorePowerRoutine = 0
				set_blindness(0)
				update_sight()
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
				aiRestorePowerRoutine = 3
				src << "Here are your current laws:"
				show_laws()
		sleep(50)
		theAPC = null
