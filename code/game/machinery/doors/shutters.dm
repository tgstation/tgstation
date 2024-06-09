/obj/machinery/door/poddoor/shutters
	gender = PLURAL
	name = "shutters"
	desc = "Heavy duty mechanical shutters with an atmospheric seal that keeps them airtight once closed."
	icon = 'icons/obj/doors/shutters.dmi'
	layer = SHUTTER_LAYER
	closingLayer = SHUTTER_LAYER
	damage_deflection = 20
	armor_type = /datum/armor/poddoor_shutters
	max_integrity = 100
	recipe_type = /datum/crafting_recipe/shutters
	animation_sound = 'sound/machines/shutter.ogg'

/obj/machinery/door/poddoor/shutters/proc/get_working_state()
	if(animation)
		return "[animation]"
	return density ? "closed" : "open"

/obj/machinery/door/poddoor/shutters/update_icon_state()
	. = ..()
	icon_state = "[get_working_state()]_top"

/obj/machinery/door/poddoor/shutters/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "emissives", src, alpha = 100)

/obj/machinery/door/poddoor/shutters/get_lower_overlay()
	return mutable_appearance(icon, "[get_working_state()]_bottom", ABOVE_MOB_LAYER, appearance_flags = KEEP_APART)

/obj/machinery/door/poddoor/shutters/animation_delay(animation)
	switch(animation)
		if("opening")
			return 0.8 SECONDS
		if("closing")
			return 0.7 SECONDS

/obj/machinery/door/poddoor/shutters/animation_effects(animation)
	switch(animation)
		if("opening")
			playsound(src, animation_sound, 50, TRUE)
		if("closing")
			playsound(src, animation_sound, 50, TRUE)

/obj/machinery/door/poddoor/shutters/preopen
	icon_state = "open_map"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/shutters/preopen/deconstructed
	deconstruction = BLASTDOOR_NEEDS_WIRES

/obj/machinery/door/poddoor/shutters/indestructible
	name = "hardened shutters"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/door/poddoor/shutters/indestructible/preopen
	icon_state = "open_map"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/shutters/radiation
	name = "radiation shutters"
	desc = "Lead-lined shutters with a radiation hazard symbol. Whilst this won't stop you getting irradiated, especially by a supermatter crystal, it will stop radiation travelling as far."
	icon = 'icons/obj/doors/shutters_radiation.dmi'
	icon_state = "closed"
	rad_insulation = RAD_EXTREME_INSULATION

/obj/machinery/door/poddoor/shutters/radiation/animation_delay(animation)
	switch(animation)
		if("opening")
			return 0.91 SECONDS
		if("closing")
			return 0.66 SECONDS

/obj/machinery/door/poddoor/shutters/radiation/preopen
	icon_state = "open_map"
	density = FALSE
	opacity = FALSE
	rad_insulation = RAD_NO_INSULATION

/datum/armor/poddoor_shutters
	melee = 20
	bullet = 20
	laser = 20
	energy = 75
	bomb = 25
	fire = 100
	acid = 70

/obj/machinery/door/poddoor/shutters/radiation/open()
	. = ..()
	rad_insulation = RAD_NO_INSULATION

/obj/machinery/door/poddoor/shutters/radiation/close()
	. = ..()
	rad_insulation = RAD_EXTREME_INSULATION

/obj/machinery/door/poddoor/shutters/window
	name = "windowed shutters"
	desc = "A shutter with a thick see-through polycarbonate window."
	icon = 'icons/obj/doors/shutters_window.dmi'
	icon_state = "closed"
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/poddoor/shutters/window/animation_delay(animation)
	switch(animation)
		if("opening")
			return 0.91 SECONDS
		if("closing")
			return 0.91 SECONDS

/obj/machinery/door/poddoor/shutters/window/preopen
	icon_state = "open_map"
	density = FALSE

/obj/machinery/door/poddoor/shutters/window/indestructible
	name = "hardened windowed shutters"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/door/poddoor/shutters/window/indestructible/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE
