/obj/machinery/computer/atmos_alert
	name = "atmospheric alert console"
	desc = "Used to monitor the station's air alarms."
	circuit = /obj/item/circuitboard/computer/atmos_alert
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	light_color = LIGHT_COLOR_CYAN

	var/list/priority_alarms = list()
	var/list/minor_alarms = list()

/obj/machinery/computer/atmos_alert/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosAlertConsole", name)
		ui.open()

/obj/machinery/computer/atmos_alert/ui_data(mob/user)
	var/list/data = list()

	data["priority"] = list()
	for(var/zone in priority_alarms)
		data["priority"] += zone
	data["minor"] = list()
	for(var/zone in minor_alarms)
		data["minor"] += zone

	return data

/obj/machinery/computer/atmos_alert/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("clear")
			var/zone = params["zone"]
			if(zone in priority_alarms)
				to_chat(usr, span_notice("Priority alarm for [zone] cleared."))
				priority_alarms -= zone
				. = TRUE
			if(zone in minor_alarms)
				to_chat(usr, span_notice("Minor alarm for [zone] cleared."))
				minor_alarms -= zone
				. = TRUE
	update_appearance()

/obj/machinery/computer/atmos_alert/process()
	. = ..()
	if (!.)
		return FALSE

	var/alarm_count = priority_alarms.len + minor_alarms.len

	priority_alarms.Cut()
	minor_alarms.Cut()

	for (var/obj/machinery/airalarm/air_alarm as anything in GLOB.air_alarms)
		if (air_alarm.z != z)
			continue

		switch (air_alarm.danger_level)
			if (AIR_ALARM_ALERT_NONE)
				continue
			if (AIR_ALARM_ALERT_WARNING)
				minor_alarms += get_area_name(air_alarm, format_text = TRUE)
			if (AIR_ALARM_ALERT_HAZARD)
				priority_alarms += get_area_name(air_alarm, format_text = TRUE)

	// Either we got new alarms, or we have no alarms anymore
	if ((alarm_count == 0) != (minor_alarms.len + priority_alarms.len == 0))
		update_appearance(UPDATE_ICON)

	return TRUE

/obj/machinery/computer/atmos_alert/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(priority_alarms.len)
		. += "alert:2"
		return
	if(minor_alarms.len)
		. += "alert:1"
