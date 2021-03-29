/mob/living/silicon/ai/Life(delta_time = SSMOBS_DT, times_fired)
	if (stat == DEAD)
		return
	else //I'm not removing that shitton of tabs, unneeded as they are. -- Urist
		//Being dead doesn't mean your temperature never changes

		update_gravity(mob_has_gravity())

		handle_status_effects(delta_time, times_fired)

		handle_traits()

		if(malfhack?.aidisabled)
			deltimer(malfhacking)
			// This proc handles cleanup of screen notifications and
			// messenging the client
			malfhacked(malfhack)

		if(isturf(loc) && (QDELETED(eyeobj) || !eyeobj.loc))
			view_core()

		if(machine)
			machine.check_eye(src)

		// Handle power damage (oxy)
		if(aiRestorePowerRoutine)
			// Lost power
			if (!battery)
				to_chat(src, "<span class='warning'>Your backup battery's output drops below usable levels. It takes only a moment longer for your systems to fail, corrupted and unusable.</span>")
				adjustOxyLoss(200)
			else
				battery--
		else
			// Gain Power
			if (battery < 200)
				battery++

		if(!lacks_power())
			var/area/home = get_area(src)
			if(home.powered(AREA_USAGE_EQUIP))
				home.use_power(500 * delta_time, AREA_USAGE_EQUIP)

			if(aiRestorePowerRoutine >= POWER_RESTORATION_SEARCH_APC)
				ai_restore_power()
				return

		else if(!aiRestorePowerRoutine)
			ai_lose_power()

/mob/living/silicon/ai/proc/lacks_power()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	switch(requires_power)
		if(NONE)
			return FALSE
		if(POWER_REQ_ALL)
			return !T || !A || ((!A.power_equip || isspaceturf(T)) && !is_type_in_list(loc, list(/obj/item, /obj/vehicle/sealed/mecha)))

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		return
	set_health(maxHealth - getOxyLoss() - getToxLoss() - getBruteLoss() - getFireLoss())
	update_stat()
	diag_hud_set_health()
	disconnect_shell()

/mob/living/silicon/ai/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD)
			death()
			return
		else if(stat >= UNCONSCIOUS)
			set_stat(CONSCIOUS)
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
	sync_lighting_plane_alpha()


/mob/living/silicon/ai/proc/start_RestorePowerRoutine()
	to_chat(src, "<span class='notice'>Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection.</span>")
	end_multicam()
	sleep(50)
	var/turf/T = get_turf(src)
	var/area/AIarea = get_area(src)
	if(AIarea?.power_equip)
		if(!isspaceturf(T))
			ai_restore_power()
			return
	to_chat(src, "<span class='notice'>Fault confirmed: missing external power. Shutting down main control system to save power.</span>")
	sleep(20)
	to_chat(src, "<span class='notice'>Emergency control system online. Verifying connection to power network.</span>")
	sleep(50)
	T = get_turf(src)
	if(isspaceturf(T))
		to_chat(src, "<span class='alert'>Unable to verify! No power connection detected!</span>")
		setAiRestorePowerRoutine(POWER_RESTORATION_SEARCH_APC)
		return
	to_chat(src, "<span class='notice'>Connection verified. Searching for APC in power network.</span>")
	sleep(50)
	var/obj/machinery/power/apc/theAPC = null

	var/PRP //like ERP with the code, at least this stuff is no more 4x sametext
	for (PRP=1, PRP<=4, PRP++)
		T = get_turf(src)
		AIarea = get_area(src)
		if(AIarea)
			for (var/obj/machinery/power/apc/APC in AIarea)
				if (!(APC.machine_stat & BROKEN))
					theAPC = APC
					break
		if (!theAPC)
			switch(PRP)
				if(1)
					to_chat(src, "<span class='alert'>Unable to locate APC!</span>")
				else
					to_chat(src, "<span class='alert'>Lost connection with the APC!</span>")
			setAiRestorePowerRoutine(POWER_RESTORATION_SEARCH_APC)
			return
		if(AIarea.power_equip)
			if(!isspaceturf(T))
				ai_restore_power()
				return
		switch(PRP)
			if (1)
				to_chat(src, "<span class='notice'>APC located. Optimizing route to APC to avoid needless power waste.</span>")
			if (2)
				to_chat(src, "<span class='notice'>Best route identified. Hacking offline APC power port.</span>")
			if (3)
				to_chat(src, "<span class='notice'>Power port upload access confirmed. Loading control program into APC power port software.</span>")
			if (4)
				to_chat(src, "<span class='notice'>Transfer complete. Forcing APC to execute program.</span>")
				sleep(50)
				to_chat(src, "<span class='notice'>Receiving control information from APC.</span>")
				sleep(2)
				to_chat(src, "<A HREF=?src=[REF(src)];emergencyAPC=[TRUE]>APC ready for connection.</A>")
				apc_override = theAPC
				apc_override.ui_interact(src)
				setAiRestorePowerRoutine(POWER_RESTORATION_APC_FOUND)
		sleep(50)
		theAPC = null

/mob/living/silicon/ai/proc/ai_restore_power()
	if(aiRestorePowerRoutine)
		if(aiRestorePowerRoutine == POWER_RESTORATION_APC_FOUND)
			to_chat(src, "<span class='notice'>Alert cancelled. Power has been restored.</span>")
			if(apc_override)
				to_chat(src, "<span class='notice'>APC backdoor has been closed.</span>") //Fluff for why we have to hack every time.
		else
			to_chat(src, "<span class='notice'>Alert cancelled. Power has been restored without our assistance.</span>")
		setAiRestorePowerRoutine(POWER_RESTORATION_OFF)
		set_blindness(0)
		apc_override = null
		update_sight()

/mob/living/silicon/ai/proc/ai_lose_power()
	disconnect_shell()
	setAiRestorePowerRoutine(POWER_RESTORATION_START)
	blind_eyes(1)
	update_sight()
	to_chat(src, "<span class='alert'>You've lost power!</span>")
	addtimer(CALLBACK(src, .proc/start_RestorePowerRoutine), 20)
