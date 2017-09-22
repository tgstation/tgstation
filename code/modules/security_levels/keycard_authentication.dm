GLOBAL_DATUM_INIT(keycard_events, /datum/events, new)

/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	req_access = list(ACCESS_KEYCARD_AUTH)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/callback/ev
	var/event = ""
	var/obj/machinery/keycard_auth/event_source
	var/mob/triggerer = null
	var/waiting = 0

/obj/machinery/keycard_auth/Initialize()
	. = ..()
	ev = GLOB.keycard_events.addEvent("triggerEvent", CALLBACK(src, .proc/triggerEvent))

/obj/machinery/keycard_auth/Destroy()
	GLOB.keycard_events.clearEvent("triggerEvent", ev)
	QDEL_NULL(ev)
	return ..()

/obj/machinery/keycard_auth/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
					datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "keycard_auth", name, 375, 125, master_ui, state)
		ui.open()

/obj/machinery/keycard_auth/ui_data()
	var/list/data = list()
	data["waiting"] = waiting
	data["auth_required"] = event_source ? event_source.event : 0
	data["red_alert"] = (seclevel2num(get_security_level()) >= SEC_LEVEL_RED) ? 1 : 0
	data["emergency_maint"] = GLOB.emergency_access
	data["bsa_unlock"] = GLOB.bsa_unlock
	return data

/obj/machinery/keycard_auth/ui_status(mob/user)
	if(isanimal(user))
		var/mob/living/simple_animal/A = user
		if(!A.dextrous)
			to_chat(user, "<span class='warning'>You are too primitive to use this device!</span>")
			return UI_CLOSE
	return ..()

/obj/machinery/keycard_auth/ui_act(action, params)
	if(..() || waiting || !allowed(usr))
		return
	switch(action)
		if("red_alert")
			if(!event_source)
				sendEvent("Red Alert")
				. = TRUE
		if("emergency_maint")
			if(!event_source)
				sendEvent("Emergency Maintenance Access")
				. = TRUE
		if("auth_swipe")
			if(event_source)
				event_source.trigger_event(usr)
				event_source = null
				. = TRUE
		if("bsa_unlock")
			if(!event_source)
				sendEvent("Bluespace Artillery Unlock")
				. = TRUE

/obj/machinery/keycard_auth/proc/sendEvent(event_type)
	triggerer = usr
	event = event_type
	waiting = 1
	GLOB.keycard_events.fireEvent("triggerEvent", src)
	addtimer(CALLBACK(src, .proc/eventSent), 20)

/obj/machinery/keycard_auth/proc/eventSent()
	triggerer = null
	event = ""
	waiting = 0

/obj/machinery/keycard_auth/proc/triggerEvent(source)
	icon_state = "auth_on"
	event_source = source
	addtimer(CALLBACK(src, .proc/eventTriggered), 20)

/obj/machinery/keycard_auth/proc/eventTriggered()
	icon_state = "auth_off"
	event_source = null

/obj/machinery/keycard_auth/proc/trigger_event(confirmer)
	log_game("[key_name(triggerer)] triggered and [key_name(confirmer)] confirmed event [event]")
	message_admins("[key_name(triggerer)] triggered and [key_name(confirmer)] confirmed event [event]")
	switch(event)
		if("Red Alert")
			set_security_level(SEC_LEVEL_RED)
			SSblackbox.inc("alert_keycard_auth_red",)
		if("Emergency Maintenance Access")
			make_maint_all_access()
			SSblackbox.inc("alert_keycard_auth_maint")
		if("Bluespace Artillery Unlock")
			toggle_bluespace_artillery()
			SSblackbox.inc("alert_keycard_auth_bsa")

GLOBAL_VAR_INIT(emergency_access, FALSE)
/proc/make_maint_all_access()
	for(var/area/maintenance/A in world)
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = TRUE
			D.update_icon(0)
	minor_announce("Access restrictions on maintenance and external airlocks have been lifted.", "Attention! Station-wide emergency declared!",1)
	GLOB.emergency_access = TRUE

/proc/revoke_maint_all_access()
	for(var/area/maintenance/A in world)
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = FALSE
			D.update_icon(0)
	minor_announce("Access restrictions in maintenance areas have been restored.", "Attention! Station-wide emergency rescinded:")
	GLOB.emergency_access = FALSE

/proc/toggle_bluespace_artillery()
	GLOB.bsa_unlock = !GLOB.bsa_unlock
	minor_announce("Bluespace Artillery firing protocols have been [GLOB.bsa_unlock? "unlocked" : "locked"]", "Weapons Systems Update:")
