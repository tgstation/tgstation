/obj/machinery/bluespace_beacon
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	name = "bluespace gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	level = 1		// underfloor
	layer = LOW_OBJ_LAYER
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	var/obj/item/device/beacon/beacon

/obj/machinery/bluespace_beacon/Initialize()
	. = ..()
	beacon = new(src)
	beacon.invisibility = INVISIBILITY_MAXIMUM
	var/turf/T = loc
	hide(T.intact)

/obj/machinery/bluespace_beacon/Destroy()
	QDEL_NULL(beacon)
	return ..()

// update the invisibility and icon
/obj/machinery/bluespace_beacon/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_icon()

// update the icon_state
/obj/machinery/bluespace_beacon/update_icon()
	icon_state = "floor_beacon[invisibility ? "f" : null]"
