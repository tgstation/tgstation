/// Priority is top to bottom.
GLOBAL_LIST_INIT(sm_delam_list, list(
	/datum/sm_delam/cascade = new /datum/sm_delam/cascade,
	/datum/sm_delam/singularity = new /datum/sm_delam/singularity,
	/datum/sm_delam/tesla = new /datum/sm_delam/tesla,
	/datum/sm_delam/explosive = new /datum/sm_delam/explosive,
))

/// Logic holder for supermatter delaminations, goes off the strategy design pattern.
/// Selected by [/obj/machinery/power/supermatter_crystal/proc/set_delam]
/datum/sm_delam

/// Whether we are eligible for this delamination or not. TRUE if valid, FALSE if not.
/// [/obj/machinery/power/supermatter_crystal/proc/set_delam]
/datum/sm_delam/proc/can_select(obj/machinery/power/supermatter_crystal/sm)
	return FALSE

/// Called when the count down has been finished, do the nasty work.
/// [/obj/machinery/power/supermatter_crystal/proc/count_down]
/datum/sm_delam/proc/delaminate(obj/machinery/power/supermatter_crystal/sm)
	if (sm.is_main_engine)
		SSpersistence.rounds_since_engine_exploded = ROUNDCOUNT_ENGINE_JUST_EXPLODED
		for (var/obj/structure/sign/delamination_counter/sign as anything in GLOB.map_delamination_counters)
			sign.update_count(ROUNDCOUNT_ENGINE_JUST_EXPLODED)
	qdel(sm)

/// Whatever we're supposed to do when a delam is currently in progress.
/// Mostly just to tell people how useless engi is, and play some alarm sounds.
/// Returns TRUE if we just told people a delam is going on. FALSE if its healing or we didnt say anything.
/// [/obj/machinery/power/supermatter_crystal/proc/process_atmos]
/datum/sm_delam/proc/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	if(sm.damage <= sm.warning_point) // Damage is too low, lets not
		return FALSE

	if (sm.damage >= sm.emergency_point && sm.damage_archived < sm.emergency_point)
		sm.investigate_log("has entered the emergency point.", INVESTIGATE_ENGINE)
		message_admins("[sm] has entered the emergency point [ADMIN_VERBOSEJMP(sm)].")

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
		sm.radio.talk_into(sm,"Crystalline hyperstructure returning to safe operating parameters. Integrity: [round(sm.get_integrity_percent(), 0.01)]%", sm.damage_archived >= sm.emergency_point ? sm.emergency_channel : sm.warning_channel)
		return FALSE

	if(sm.damage >= sm.emergency_point) // Taking damage, in emergency
		sm.radio.talk_into(sm, "CRYSTAL DELAMINATION IMMINENT Integrity: [round(sm.get_integrity_percent(), 0.01)]%", sm.emergency_channel)
		sm.lastwarning = REALTIMEOFDAY - (SUPERMATTER_WARNING_DELAY / 2) // Cut the time to next announcement in half.
	else // Taking damage, in warning
		sm.radio.talk_into(sm, "Danger! Crystal hyperstructure integrity faltering! Integrity: [round(sm.get_integrity_percent(), 0.01)]%", sm.warning_channel)

	SEND_SIGNAL(sm, COMSIG_SUPERMATTER_DELAM_ALARM)
	return TRUE

/// Called when a supermatter switches it's strategy from another one to us.
/// [/obj/machinery/power/supermatter_crystal/proc/set_delam]
/datum/sm_delam/proc/on_select(obj/machinery/power/supermatter_crystal/sm)
	return

/// Called when a supermatter switches it's strategy from us to something else.
/// [/obj/machinery/power/supermatter_crystal/proc/set_delam]
/datum/sm_delam/proc/on_deselect(obj/machinery/power/supermatter_crystal/sm)
	return

/// Added to an examine return value.
/// [/obj/machinery/power/supermatter_crystal/examine]
/datum/sm_delam/proc/examine(obj/machinery/power/supermatter_crystal/sm)
	return list()

/// Add whatever overlay to the sm.
/// [/obj/machinery/power/supermatter_crystal/update_overlays]
/datum/sm_delam/proc/overlays(obj/machinery/power/supermatter_crystal/sm)
	if(sm.final_countdown)
		return list(mutable_appearance(icon = sm.icon, icon_state = "causality_field", layer = FLOAT_LAYER))
	return list()

/// Applies filters to the SM.
/// [/obj/machinery/power/supermatter_crystal/process_atmos]
/datum/sm_delam/proc/filters(obj/machinery/power/supermatter_crystal/sm)
	var/new_filter = isnull(sm.get_filter("ray"))

	sm.add_filter(name = "ray", priority = 1, params = list(
		type = "rays",
		size = clamp(sm.internal_energy / 50, 1, 100),
		color = (sm.gas_heat_power_generation > 0.8 ? SUPERMATTER_RED : SUPERMATTER_COLOUR),
		factor = clamp(sm.damage / 10, 1, 10),
		density = clamp(sm.damage, 12, 100)
	))

	// Filter animation persists even if the filter itself is changed externally.
	// Probably prone to breaking. Treat with suspicion.
	if(new_filter)
		animate(sm.get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
		animate(offset = 0, time = 10 SECONDS)

// Change how bright the rock is.
/// [/obj/machinery/power/supermatter_crystal/process_atmos]
/datum/sm_delam/proc/lights(obj/machinery/power/supermatter_crystal/sm)
	sm.set_light(
		l_range = ROUND_UP(clamp(sm.internal_energy / 500, 4, 10)),
		l_power = ROUND_UP(clamp(sm.internal_energy / 1000, 1, 5)),
		l_color = sm.gas_heat_power_generation > 0.8 ? SUPERMATTER_RED : SUPERMATTER_COLOUR,
		l_on = !!sm.internal_energy,
	)

/// Returns a set of messages to be spouted during delams
/// First message is start of count down, second message is quitting of count down (if sm healed), third is 5 second intervals
/datum/sm_delam/proc/count_down_messages(obj/machinery/power/supermatter_crystal/sm)
	var/list/messages = list()
	messages += "CRYSTAL DELAMINATION IMMINENT. The supermatter has reached critical integrity failure. Emergency causality destabilization field has been activated."
	messages += "Crystalline hyperstructure returning to safe operating parameters. Failsafe has been disengaged."
	messages += "remain before causality stabilization."
	return messages
