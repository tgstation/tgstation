/obj/machinery/airalarm
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/airalarm/icons/airalarm.dmi'
	var/light_mask = "alarm-light-mask"

/obj/machinery/airalarm/update_appearance(updates)
	. = ..()

	if(panel_open || (machine_stat & (NOPOWER|BROKEN)) || shorted)
		set_light(0)
		return FALSE

	var/color = "#AAFF00"
	if(danger_level == AIR_ALARM_ALERT_HAZARD)
		color = "FF0000"
	else if(danger_level == AIR_ALARM_ALERT_WARNING || my_area.active_alarms[ALARM_ATMOS])
		color = "FF6600"

	set_light(1.5, 1, color)

//why did we do this again?
/*
/obj/item/wallframe/airalarm
	icon = 'icons/obj/monitors.dmi'
*/
