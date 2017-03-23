var/datum/events/keycard_events = new()

/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	anchored = 1
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	req_access = list(access_keycard_auth)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/callback/ev
	var/event = ""
	var/obj/machinery/keycard_auth/event_source
	var/mob/triggerer = null
	var/waiting = 0

/obj/machinery/keycard_auth/New()
	. = ..()
	ev = keycard_events.addEvent("triggerEvent", CALLBACK(src, .proc/triggerEvent))

/obj/machinery/keycard_auth/Destroy()
	keycard_events.clearEvent("triggerEvent", ev)
	qdel(ev)
	. = ..()

/obj/machinery/keycard_auth/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
					datum/tgui/master_ui = null, datum/ui_state/state = physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "keycard_auth", name, 375, 125, master_ui, state)
		ui.open()

/obj/machinery/keycard_auth/ui_data()
	var/list/data = list()
	data["waiting"] = waiting
	data["auth_required"] = event_source ? event_source.event : 0
	data["red_alert"] = (seclevel2num(get_security_level()) >= SEC_LEVEL_RED) ? 1 : 0
	data["emergency_maint"] = emergency_access
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

/obj/machinery/keycard_auth/proc/sendEvent(event_type)
	triggerer = usr
	event = event_type
	waiting = 1
	keycard_events.fireEvent("triggerEvent", src)
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
			feedback_inc("alert_keycard_auth_red",1)
		if("Emergency Maintenance Access")
			make_maint_all_access()
			feedback_inc("alert_keycard_auth_maint",1)


/var/emergency_access = 0
/proc/make_maint_all_access()
	for(var/area/maintenance/A in world)
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = 1
			D.update_icon(0)
	minor_announce("Access restrictions on maintenance and external airlocks have been lifted.", "Attention! Station-wide emergency declared!",1)
	emergency_access = 1

/proc/revoke_maint_all_access()
	for(var/area/maintenance/A in world)
		for(var/obj/machinery/door/airlock/D in A)
			D.emergency = 0
			D.update_icon(0)
	minor_announce("Access restrictions in maintenance areas have been restored.", "Attention! Station-wide emergency rescinded:")
	emergency_access = 0
