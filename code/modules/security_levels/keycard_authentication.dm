GLOBAL_DATUM_INIT(keycard_events, /datum/events, new)

#define KEYCARD_RED_ALERT "Red Alert"
#define KEYCARD_EMERGENCY_MAINTENANCE_ACCESS "Emergency Maintenance Access"
#define KEYCARD_BSA_UNLOCK "Bluespace Artillery Unlock"

/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	power_channel = AREA_USAGE_ENVIRON
	req_access = list(ACCESS_KEYCARD_AUTH)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/datum/callback/ev
	var/event = ""
	var/obj/machinery/keycard_auth/event_source
	var/mob/triggerer = null
	var/waiting = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/keycard_auth, 26)

/obj/machinery/keycard_auth/Initialize(mapload)
	. = ..()
	ev = GLOB.keycard_events.addEvent("triggerEvent", CALLBACK(src, PROC_REF(triggerEvent)))

/obj/machinery/keycard_auth/Destroy()
	GLOB.keycard_events.clearEvent("triggerEvent", ev)
	QDEL_NULL(ev)
	return ..()

/obj/machinery/keycard_auth/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/keycard_auth/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KeycardAuth", name)
		ui.open()

/obj/machinery/keycard_auth/ui_data()
	var/list/data = list()
	data["waiting"] = waiting
	data["auth_required"] = event_source ? event_source.event : 0
	data["red_alert"] = (SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED) ? 1 : 0
	data["emergency_maint"] = GLOB.emergency_access
	data["bsa_unlock"] = GLOB.bsa_unlock
	return data

/obj/machinery/keycard_auth/ui_status(mob/user)
	if(isdrone(user))
		return UI_CLOSE
	if(!isanimal(user))
		return ..()
	var/mob/living/simple_animal/A = user
	if(!A.dextrous)
		to_chat(user, span_warning("You are too primitive to use this device!"))
		return UI_CLOSE
	return ..()

/obj/machinery/keycard_auth/ui_act(action, params)
	. = ..()

	if(. || waiting || !allowed(usr))
		return
	switch(action)
		if("red_alert")
			if(!event_source)
				sendEvent(KEYCARD_RED_ALERT)
				. = TRUE
		if("emergency_maint")
			if(!event_source)
				sendEvent(KEYCARD_EMERGENCY_MAINTENANCE_ACCESS)
				. = TRUE
		if("auth_swipe")
			if(event_source)
				event_source.trigger_event(usr)
				event_source = null
				update_appearance()
				. = TRUE
		if("bsa_unlock")
			if(!event_source)
				sendEvent(KEYCARD_BSA_UNLOCK)
				. = TRUE

/obj/machinery/keycard_auth/update_appearance(updates)
	. = ..()

	if(event_source && !(machine_stat & (NOPOWER|BROKEN)))
		set_light(2, 1, "#5668E1")
	else
		set_light(0)

/obj/machinery/keycard_auth/update_overlays()
	. = ..()

	if(event_source && !(machine_stat & (NOPOWER|BROKEN)))
		. += mutable_appearance(icon, "auth_on")
		. += emissive_appearance(icon, "auth_on", src, alpha = src.alpha)

/obj/machinery/keycard_auth/proc/sendEvent(event_type)
	triggerer = usr
	event = event_type
	waiting = TRUE
	GLOB.keycard_events.fireEvent("triggerEvent", src)
	addtimer(CALLBACK(src, PROC_REF(eventSent)), 20)

/obj/machinery/keycard_auth/proc/eventSent()
	triggerer = null
	event = ""
	waiting = FALSE

/obj/machinery/keycard_auth/proc/triggerEvent(source)
	event_source = source
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(eventTriggered)), 20)

/obj/machinery/keycard_auth/proc/eventTriggered()
	event_source = null
	update_appearance()

/obj/machinery/keycard_auth/proc/trigger_event(confirmer)
	triggerer.log_message("triggered and [key_name(confirmer)] confirmed event [event].", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(triggerer)] triggered and [ADMIN_LOOKUPFLW(confirmer)] confirmed event [event]")

	var/area/A1 = get_area(triggerer)
	deadchat_broadcast(" triggered [event] at [span_name("[A1.name]")].", span_name("[triggerer]"), triggerer, message_type=DEADCHAT_ANNOUNCEMENT)

	var/area/A2 = get_area(confirmer)
	deadchat_broadcast(" confirmed [event] at [span_name("[A2.name]")].", span_name("[confirmer]"), confirmer, message_type=DEADCHAT_ANNOUNCEMENT)
	switch(event)
		if(KEYCARD_RED_ALERT)
			SSsecurity_level.set_level(SEC_LEVEL_RED)
		if(KEYCARD_EMERGENCY_MAINTENANCE_ACCESS)
			make_maint_all_access()
		if(KEYCARD_BSA_UNLOCK)
			toggle_bluespace_artillery()

GLOBAL_VAR_INIT(emergency_access, FALSE)
/proc/make_maint_all_access()
	for(var/area/station/maintenance/A in GLOB.areas)
		for(var/turf/in_area as anything in A.get_contained_turfs())
			for(var/obj/machinery/door/airlock/D in in_area)
				D.emergency = TRUE
				D.update_icon(ALL, 0)
	minor_announce("Access restrictions on maintenance and external airlocks have been lifted.", "Attention! Station-wide emergency declared!",1)
	GLOB.emergency_access = TRUE
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency maintenance access", "enabled"))

/proc/revoke_maint_all_access()
	for(var/area/station/maintenance/A in GLOB.areas)
		for(var/turf/in_area as anything in A.get_contained_turfs())
			for(var/obj/machinery/door/airlock/D in in_area)
				D.emergency = FALSE
				D.update_icon(ALL, 0)
	minor_announce("Access restrictions in maintenance areas have been restored.", "Attention! Station-wide emergency rescinded:")
	GLOB.emergency_access = FALSE
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("emergency maintenance access", "disabled"))

/proc/toggle_bluespace_artillery()
	GLOB.bsa_unlock = !GLOB.bsa_unlock
	minor_announce("Bluespace Artillery firing protocols have been [GLOB.bsa_unlock? "unlocked" : "locked"]", "Weapons Systems Update:")
	SSblackbox.record_feedback("nested tally", "keycard_auths", 1, list("bluespace artillery", GLOB.bsa_unlock? "unlocked" : "locked"))

#undef KEYCARD_RED_ALERT
#undef KEYCARD_EMERGENCY_MAINTENANCE_ACCESS
#undef KEYCARD_BSA_UNLOCK
