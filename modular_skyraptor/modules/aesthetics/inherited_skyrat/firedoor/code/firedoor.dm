/obj/machinery/door/firedoor
	name = "emergency shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas. This one has a glass panel. It has a mechanism to open it with just your hands."
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/firedoor/icons/firedoor_glass.dmi'
	var/door_open_sound = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/firedoor/sound/firedoor_open.ogg'
	var/door_close_sound = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/firedoor/sound/firedoor_open.ogg'

/obj/machinery/door/firedoor/update_overlays()
	. = ..()
	if(istype(src, /obj/machinery/door/firedoor/border_only))
		return
	if(density) // if the door is closed, add the bottom blinking overlay -- and only if it's closed
		. += "firelock_alarm_type_bottom"

/obj/machinery/door/firedoor/open()
	playsound(loc, door_open_sound, 100, TRUE)
	return ..()

/obj/machinery/door/firedoor/close()
	playsound(loc, door_close_sound, 100, TRUE)
	return ..()

/obj/machinery/door/firedoor/heavy
	name = "heavy emergency shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas. It has a mechanism to open it with just your hands."
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/firedoor/icons/firedoor.dmi'

/obj/effect/spawner/structure/window/reinforced/no_firelock
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/fulltile)

/obj/machinery/door/firedoor/closed
	alarm_type = FIRELOCK_ALARM_TYPE_GENERIC
