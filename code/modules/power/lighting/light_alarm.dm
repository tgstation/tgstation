/obj/machinery/light/alarm
	name = "alarm light"
	icon = 'icons/obj/lighting.dmi'
	desc = "A light signalling if there is a serious situation on the station."
	base_state = "alarmlight"
	icon_state = "alarmlight"
	max_integrity = 180
	brightness = 6
	bulb_emergency_colour = "#f1bc0d"
	bulb_colour = "#e61313"
	nightshift_allowed = FALSE
	no_low_power = TRUE
	light_type = /obj/item/light/bulb
	fitting = "bulb"

/obj/machinery/light/alarm/Initialize(mapload)
	. = ..()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(emergency))

/obj/machinery/light/attackby(obj/item/tool, mob/living/user, params)
	on = (status == LIGHT_OK && SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
	update()

/obj/machinery/light/alarm/set_on(turn_on)
	on = (turn_on && status == LIGHT_OK && SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
	update()

/obj/machinery/light/alarm/power_change()
	var/area/local_area = get_room_area(src)
	set_on(local_area.power_light)

/obj/machinery/light/alarm/proc/emergency()
	SIGNAL_HANDLER
	set_on(TRUE)

