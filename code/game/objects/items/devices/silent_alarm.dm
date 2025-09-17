/obj/machinery/button/silent_alarm
	name = "Silent alarm"
	desc = "A small button that silently notifies security when pressed"
	silent = TRUE
	device_type = /obj/item/assembly/silent_alarm

/obj/item/assembly/silent_alarm
	name = "Silent alarm electronics"
	desc = "The internal electronics of a silent alarm button"
	icon_state = "control"
	COOLDOWN_DECLARE(announce_cooldown)
	assembly_flags = ASSEMBLY_SILENCE_BUTTON | ASSEMBLY_NO_DUPLICATES
	var/list/broadcast_channels = list(RADIO_CHANNEL_SECURITY)

/obj/item/assembly/silent_alarm/activate(mob/user)
	if(is_within_radio_jammer_range(src))
		COOLDOWN_START(src, announce_cooldown, 1.5 MINUTES)
		return
	if(!COOLDOWN_FINISHED(src, announce_cooldown))
		return
	aas_config_announce(/datum/aas_config_entry/silent_alarm_trigger, list("LOCATION" = get_area_name(src)), src, broadcast_channels, "Message")
	COOLDOWN_START(src, announce_cooldown, 3 MINUTES)

/datum/aas_config_entry/silent_alarm_trigger
	name = "RC Alert: Emergency"
	announcement_lines_map = list(
		"Message" = "A silent alarm has been triggered in %LOCATION. Respond with caution."
	)
	vars_and_tooltips_map = list(
		"LOCATION" = "will be replaced with the location of the triggered alarm",
	)

/obj/machinery/button/silent_alarm/north
	table_bound = TRUE
	dir = NORTH

/obj/machinery/button/silent_alarm/south
	table_bound = TRUE
	dir = SOUTH

/obj/machinery/button/silent_alarm/east
	table_bound = TRUE
	dir = EAST

/obj/machinery/button/silent_alarm/west
	table_bound = TRUE
	dir = WEST
