/obj/machinery/computer/atmos_alert
	name = "atmospheric alert console"
	desc = "Used to monitor the station's air alarms."
	circuit = /obj/item/circuitboard/computer/atmos_alert
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	light_color = LIGHT_COLOR_CYAN

	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	/// Determines if the alerts track via z-level, or only show all station areas
	var/station_only

/obj/machinery/computer/atmos_alert/examine(mob/user)
	. = ..()
	. += span_info("The console is set to [station_only ? "track all station and mining alarms" : "track alarms on the same z-level"].")

/obj/machinery/computer/atmos_alert/Initialize(mapload)
	. = ..()
	// Checks the internal circuit to determine if it's in station_only mode
	var/obj/item/circuitboard/computer/atmos_alert/my_circuit = circuit
	station_only = my_circuit.station_only

/obj/machinery/computer/atmos_alert/on_construction(mob/user)
	. = ..()
	// Same code as Initialize to make sure that ones built in-round have this as well
	var/obj/item/circuitboard/computer/atmos_alert/my_circuit = circuit
	station_only = my_circuit.station_only

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

	// An area list used for station_only, so we only send an alarm if we're in one of the station or mining home areas
	var/list/station_alert_areas
	station_alert_areas = GLOB.the_station_areas + typesof(/area/mine)

	for (var/obj/machinery/airalarm/air_alarm as anything in GLOB.air_alarms)
		if(!station_only)
			// By default it only checks if alarms match the console's z-level
			if (air_alarm.z != z)
				continue
		else
			// If station_only, instead checks if alarm areas are in the station list
			if (!(air_alarm.my_area.type in station_alert_areas))
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

// Subtype which only checks station areas and the mining station
/obj/machinery/computer/atmos_alert/station_only
	circuit = /obj/item/circuitboard/computer/atmos_alert/station_only
	station_only = TRUE
