/mob/living/silicon/ai/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if (stat == DEAD)
		return
	//Being dead doesn't mean your temperature never changes

	if(malfhack?.aidisabled)
		deltimer(malfhacking)
		// This proc handles cleanup of screen notifications and
		// messenging the client
		malfhacked(malfhack)

	if(isturf(loc) && (QDELETED(eyeobj) || !eyeobj.loc))
		view_core()

	// Handle power damage (oxy)
	if(aiRestorePowerRoutine)
		// Lost power
		if (!battery)
			to_chat(src, span_warning("Your backup battery's output drops below usable levels. It takes only a moment longer for your systems to fail, corrupted and unusable."))
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
			home.apc?.terminal?.use_energy(500 WATTS * seconds_per_tick, channel = AREA_USAGE_EQUIP)

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

	var/old_health = health
	set_health(maxHealth - getOxyLoss() - getToxLoss() - getBruteLoss() - getFireLoss())

	var/old_stat = stat
	update_stat()

	diag_hud_set_health()

	if(old_health > health || old_stat != stat) // only disconnect if we lose health or change stat
		disconnect_shell()
	SEND_SIGNAL(src, COMSIG_LIVING_HEALTH_UPDATE)

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
	set_invis_see(initial(see_invisible))
	set_sight(initial(sight))
	if(aiRestorePowerRoutine)
		clear_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)

	return ..()


/mob/living/silicon/ai/proc/start_RestorePowerRoutine()
	to_chat(src, span_notice("Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection."))
	end_multicam()
	sleep(5 SECONDS)
	var/turf/T = get_turf(src)
	var/area/AIarea = get_area(src)
	if(AIarea?.power_equip)
		if(!isspaceturf(T))
			ai_restore_power()
			return
	to_chat(src, span_notice("Fault confirmed: missing external power. Shutting down main control system to save power."))
	sleep(2 SECONDS)
	to_chat(src, span_notice("Emergency control system online. Verifying connection to power network."))
	sleep(5 SECONDS)
	T = get_turf(src)
	if(isspaceturf(T))
		to_chat(src, span_alert("Unable to verify! No power connection detected!"))
		setAiRestorePowerRoutine(POWER_RESTORATION_SEARCH_APC)
		return
	to_chat(src, span_notice("Connection verified. Searching for APC in power network."))
	sleep(5 SECONDS)
	var/obj/machinery/power/apc/theAPC = null

	var/PRP //like ERP with the code, at least this stuff is no more 4x sametext
	for (PRP=1, PRP <= 4, PRP++)
		T = get_turf(src)
		AIarea = get_area(src)
		if(AIarea)
			theAPC = AIarea.apc
		if (!theAPC)
			switch(PRP)
				if(1)
					to_chat(src, span_alert("Unable to locate APC!"))
				else
					to_chat(src, span_alert("Lost connection with the APC!"))
			setAiRestorePowerRoutine(POWER_RESTORATION_SEARCH_APC)
			return
		if(AIarea.power_equip)
			if(!isspaceturf(T))
				ai_restore_power()
				return
		switch(PRP)
			if (1)
				to_chat(src, span_notice("APC located. Optimizing route to APC to avoid needless power waste."))
			if (2)
				to_chat(src, span_notice("Best route identified. Hacking offline APC power port."))
			if (3)
				to_chat(src, span_notice("Power port upload access confirmed. Loading control program into APC power port software."))
			if (4)
				to_chat(src, span_notice("Transfer complete. Forcing APC to execute program."))
				sleep(5 SECONDS)
				to_chat(src, span_notice("Receiving control information from APC."))
				sleep(0.2 SECONDS)
				to_chat(src, "<A HREF=?src=[REF(src)];emergencyAPC=[TRUE]>APC ready for connection.</A>")
				apc_override = theAPC
				apc_override.ui_interact(src)
				setAiRestorePowerRoutine(POWER_RESTORATION_APC_FOUND)
		sleep(5 SECONDS)
		theAPC = null

/mob/living/silicon/ai/proc/ai_restore_power()
	if(aiRestorePowerRoutine)
		if(aiRestorePowerRoutine == POWER_RESTORATION_APC_FOUND)
			to_chat(src, span_notice("Alert cancelled. Power has been restored."))
			if(apc_override)
				to_chat(src, span_notice("APC backdoor has been closed.")) //Fluff for why we have to hack every time.
		else
			to_chat(src, span_notice("Alert cancelled. Power has been restored without our assistance."))
		setAiRestorePowerRoutine(POWER_RESTORATION_OFF)
		remove_status_effect(/datum/status_effect/temporary_blindness)
		apc_override = null
		update_sight()

/mob/living/silicon/ai/proc/ai_lose_power()
	disconnect_shell()
	setAiRestorePowerRoutine(POWER_RESTORATION_START)
	adjust_temp_blindness(2 SECONDS)
	update_sight()
	to_chat(src, span_alert("You've lost power!"))
	addtimer(CALLBACK(src, PROC_REF(start_RestorePowerRoutine)), 2 SECONDS)
