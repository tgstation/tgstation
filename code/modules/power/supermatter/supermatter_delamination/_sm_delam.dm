/// Priority is top to bottom.
GLOBAL_LIST_INIT(sm_delam_strat_list, list(
	/datum/sm_delam_strat/cascade = new /datum/sm_delam_strat/cascade,
	/datum/sm_delam_strat/singularity = new /datum/sm_delam_strat/singularity,
	/datum/sm_delam_strat/tesla = new /datum/sm_delam_strat/tesla,
	/datum/sm_delam_strat/explosive = new /datum/sm_delam_strat/explosive,
))

/datum/sm_delam_strat
	var/

/// Whether we are eligible for this delamination or not. TRUE if valid, FALSE if not.
/datum/sm_delam_strat/proc/can_select(obj/machinery/power/supermatter_crystal/sm)
	return FALSE

/// Called when the count down has been finished. 
/// This bad boy is called internally unlike all the rest.
/datum/sm_delam_strat/proc/delaminate(obj/machinery/power/supermatter_crystal/sm)
	qdel(sm)

/// Start counting down, means SM is about to blow. Can still be healed though.
/datum/sm_delam_strat/proc/count_down(obj/machinery/power/supermatter_crystal/sm)
	set waitfor = FALSE

	var/obj/item/radio/radio = sm.radio

	if(sm.final_countdown) // We're already doing it go away
		stack_trace("SM [sm] told to delaminate again while it's already delaminating.")
		return
	sm.final_countdown = TRUE
	sm.update_appearance()

	radio.talk_into(
		sm,
		"CRYSTAL DELAMINATION IMMINENT. The supermatter has reached critical integrity failure. Emergency causality destabilization field has been activated.", 
		sm.emergency_channel
	)

	for(var/i in SUPERMATTER_COUNTDOWN_TIME to 0 step -10)
		var/message
		var/healed = FALSE
		
		if(sm.damage < sm.explosion_point) // Cutting it a bit close there engineers
			message = "Crystalline hyperstructure returning to safe operating parameters. Failsafe has been disengaged."
			healed = TRUE
		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(1 SECONDS)
			continue
		else if(i > 50)
			message = "[DisplayTimeText(i, TRUE)] remain before causality stabilization."
		else
			message = "[i*0.1]..."

		radio.talk_into(sm, message, sm.emergency_channel)
		
		if(healed)
			sm.final_countdown = FALSE
			sm.update_appearance()
			return // delam averted
		sleep(1 SECONDS)

	delaminate(sm)

/// Whatever we're supposed to do when a delam is currently in progress. 
/// Mostly just to tell people how useless engi is, and play some alarm sounds.
/// Returns TRUE if we just told people a delam is going on. FALSE if its healing or we didnt say anything.
/datum/sm_delam_strat/proc/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	if(sm.damage <= sm.warning_point) // Damage is too low, lets not
		return FALSE 

	if (sm.damage >= sm.emergency_point && sm.damage_archived < sm.emergency_point)
		sm.investigate_log("has entered the emergency point.", INVESTIGATE_ENGINE)
		message_admins("[sm] has entered the emergency point [ADMIN_JMP(sm)].")

	if((REALTIMEOFDAY - sm.lastwarning) < SUPERMATTER_WARNING_DELAY)
		return FALSE
	sm.lastwarning = REALTIMEOFDAY

	switch(sm.get_status())
		if(SUPERMATTER_DELAMINATING)
			playsound(sm, 'sound/misc/bloblarm.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
		if(SUPERMATTER_EMERGENCY)
			playsound(sm, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_DANGER)
			playsound(sm, 'sound/machines/engine_alert2.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_WARNING)
			playsound(sm, 'sound/machines/terminal_alert.ogg', 75)

	if(sm.damage < sm.damage_archived) // Healing
		sm.radio.talk_into(sm,"Crystalline hyperstructure returning to safe operating parameters. Integrity: [sm.get_integrity_percent()]%", sm.damage_archived >= sm.emergency_point ? sm.emergency_channel : sm.warning_channel)
		return FALSE

	if(sm.damage >= sm.emergency_point) // Taking damage, in emergency
		sm.radio.talk_into(sm, "CRYSTAL DELAMINATION IMMINENT Integrity: [sm.get_integrity_percent()]%", sm.emergency_channel)
		sm.lastwarning = REALTIMEOFDAY - (SUPERMATTER_WARNING_DELAY / 2) // Cut the time to next announcement in half.
	else // Taking damage, in warning
		sm.radio.talk_into(sm, "Danger! Crystal hyperstructure integrity faltering! Integrity: [sm.get_integrity_percent()]%", sm.warning_channel)
		if(sm.damage_archived < sm.warning_point)
			SEND_SIGNAL(sm, COMSIG_SUPERMATTER_DELAM_START_ALARM)

	SEND_SIGNAL(sm, COMSIG_SUPERMATTER_DELAM_ALARM)
	return TRUE

/// Called when a supermatter switches it's strategy from another one to us.
/datum/sm_delam_strat/proc/on_select(obj/machinery/power/supermatter_crystal/sm)
	return

/// Called when a supermatter switches it's strategy from us to something else.
/datum/sm_delam_strat/proc/on_deselect(obj/machinery/power/supermatter_crystal/sm)
	return
