/obj/machinery/computer/station_alert
	name = "station alert console"
	desc = "Used to access the station's automated alert system."
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/stationalert
	///Listens for alarms, provides the alarms list for our ui
	var/datum/alarm_listener/listener

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/station_alert/Initialize()
	listener = new(list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER), list(z))
	return ..()

/obj/machinery/computer/station_alert/Destroy()
	QDEL_NULL(listener)
	return ..()

/obj/machinery/computer/station_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StationAlertConsole", name)
		ui.open()

/obj/machinery/computer/station_alert/ui_data(mob/user)
	var/list/data = list()

	data["alarms"] = list()
	var/list/alarms = listener.alarms
	for(var/alarm_type in alarms)
		data["alarms"][alarm_type] = list()
		for(var/area_name in alarms[alarm_type])
			data["alarms"][alarm_type] += area_name

	return data

/obj/machinery/computer/station_alert/on_set_machine_stat(old_value)
	if(machine_stat & BROKEN)
		listener.prevent_alarm_changes()
	else
		listener.allow_alarm_changes()

/obj/machinery/computer/station_alert/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(length(listener.alarms))
		. += "alert:2"
