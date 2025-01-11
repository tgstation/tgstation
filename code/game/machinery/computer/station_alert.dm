/obj/machinery/computer/station_alert
	name = "station alert console"
	desc = "Used to access the station's automated alert system."
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/station_alert
	light_color = LIGHT_COLOR_CYAN
	/// Station alert datum for showing alerts UI
	var/datum/station_alert/alert_control

/obj/machinery/computer/station_alert/examine(mob/user)
	. = ..()
	var/obj/item/circuitboard/computer/station_alert/my_circuit = circuit
	. += span_info("The console is set to [my_circuit.station_only ? "track all station and mining alarms" : "track alarms on the same z-level"].")

/obj/machinery/computer/station_alert/Initialize(mapload)
	// If the console's circuit is station_only, set up the alert_control to only listen to station areas
	var/obj/item/circuitboard/computer/station_alert/my_circuit = circuit
	if(my_circuit.station_only)
		name = "station alert console"
		var/list/alert_areas
		alert_areas = (GLOB.the_station_areas + typesof(/area/mine))
		alert_control = new(src, list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER), listener_areas = alert_areas, title = name)
	else // If not station_only, just check the z-level
		name = "local alert console"
		alert_control = new(src, list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER), list(z), title = name)
	RegisterSignals(alert_control.listener, list(COMSIG_ALARM_LISTENER_TRIGGERED, COMSIG_ALARM_LISTENER_CLEARED), PROC_REF(update_alarm_display))
	return ..()

/obj/machinery/computer/station_alert/on_construction(mob/user)
	. = ..()
	var/obj/item/circuitboard/computer/station_alert/my_circuit = circuit
	// The circuitboard isn't "added" to the machine until this proc, meaning the station_only check
	// in init isn't valid for consoles built mid-round...
	// this code checks the board and clears+replaces the alert_control for crew to build them in-round
	if(my_circuit.station_only)
		UnregisterSignal(alert_control.listener, list(COMSIG_ALARM_LISTENER_TRIGGERED, COMSIG_ALARM_LISTENER_CLEARED), PROC_REF(update_alarm_display))
		QDEL_NULL(alert_control)
		name = "station alert console"
		var/list/alert_areas
		alert_areas = (GLOB.the_station_areas + typesof(/area/mine))
		alert_control = new(src, list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER), listener_areas = alert_areas, title = name)
		RegisterSignals(alert_control.listener, list(COMSIG_ALARM_LISTENER_TRIGGERED, COMSIG_ALARM_LISTENER_CLEARED), PROC_REF(update_alarm_display))

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

// Subtype which only checks station areas and the mining station
/obj/machinery/computer/station_alert/station_only
	circuit = /obj/item/circuitboard/computer/station_alert/station_only
