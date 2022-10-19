/obj/machinery/computer/station_alert
	name = "station alert console"
	desc = "Used to access the station's automated alert system."
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/stationalert
	light_color = LIGHT_COLOR_CYAN
	/// Station alert datum for showing alerts UI
	var/datum/station_alert/alert_control

/obj/machinery/computer/station_alert/Initialize(mapload)
	alert_control = new(src, list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER), list(z), title = name)
	RegisterSignal(alert_control.listener, list(COMSIG_ALARM_LISTENER_TRIGGERED, COMSIG_ALARM_LISTENER_CLEARED), .proc/update_alarm_display)
	return ..()

/obj/machinery/computer/station_alert/Destroy()
	QDEL_NULL(alert_control)
	return ..()

/obj/machinery/computer/station_alert/ui_interact(mob/user)
	. = ..()
	alert_control.ui_interact(user)

/obj/machinery/computer/station_alert/on_set_machine_stat(old_value)
	if(machine_stat & BROKEN)
		alert_control.listener.prevent_alarm_changes()
	else
		alert_control.listener.allow_alarm_changes()

/obj/machinery/computer/station_alert/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(length(alert_control.listener.alarms))
		. += "alert:2"

/**
 * Signal handler for calling an icon update in case an alarm is added or cleared
 *
 * Arguments:
 * * source The datum source of the signal
 */
/obj/machinery/computer/station_alert/proc/update_alarm_display(datum/source)
	SIGNAL_HANDLER
	update_icon()
