/obj/item/silent_alarm
	name = "Silent alarm electronics"
	desc = "A small button that silently notifies security when pressed. Can be placed under tables."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "button"

/obj/structure/table/proc/attach_silent_alarm(mob/user, obj/item/silent_alarm/alarm)
	silent_alarm_rigged = TRUE
	silent_alarm_direction = get_dir(user, src)
	user.visible_message(span_notice("[user.name] rigs a silent alarm under \the [src]."),
		span_notice("You rig a silent alarm under \the [src]."))
	qdel(alarm)

/obj/structure/table/proc/trip_silent_alarm(area/alarm_area, mob/living/user)
	user.visible_message(self_message = span_warning("You discreetly reach under \the [src] and activate the silent alarm!"))
	if(COOLDOWN_FINISHED(src,tripped_alarm))
		aas_config_announce(/datum/aas_config_entry/silent_alarm_trigger, list("LOCATION" = alarm_area.name), null, list(RADIO_CHANNEL_SECURITY), "Message")
		COOLDOWN_START(src, tripped_alarm, 1 MINUTES)


/datum/aas_config_entry/silent_alarm_trigger
	name = "RC Alert: Emergency"
	announcement_lines_map = list(
		"Message" = "A silent alarm has been triggered in %LOCATION. Respond with caution."
	)
	vars_and_tooltips_map = list(
		"LOCATION" = "will be replaced with the location of the triggered alarm",
	)

/obj/structure/table/silent_alarm
	silent_alarm_rigged = TRUE

/obj/structure/table/reinforced/silent_alarm
	silent_alarm_rigged = TRUE

/obj/structure/table/reinforced/rglass/silent_alarm
	silent_alarm_rigged = TRUE


/obj/structure/table/silent_alarm/north
	silent_alarm_direction = SOUTH

/obj/structure/table/silent_alarm/south
	silent_alarm_direction = NORTH

/obj/structure/table/silent_alarm/east
	silent_alarm_direction = WEST

/obj/structure/table/silent_alarm/west
	silent_alarm_direction = EAST


/obj/structure/table/reinforced/silent_alarm/north
	silent_alarm_direction = SOUTH

/obj/structure/table/reinforced/silent_alarm/south
	silent_alarm_direction = NORTH

/obj/structure/table/reinforced/silent_alarm/east
	silent_alarm_direction = WEST

/obj/structure/table/reinforced/silent_alarm/west
	silent_alarm_direction = EAST


/obj/structure/table/reinforced/rglass/silent_alarm/north
	silent_alarm_direction = SOUTH

/obj/structure/table/reinforced/rglass/silent_alarm/south
	silent_alarm_direction = NORTH

/obj/structure/table/reinforced/rglass/silent_alarm/east
	silent_alarm_direction = WEST

/obj/structure/table/reinforced/rglass/silent_alarm/west
	silent_alarm_direction = EAST
