/obj/machinery/door/poddoor/shutters
	gender = PLURAL
	name = "shutters"
	desc = "Heavy duty mechanical shutters with an atmospheric seal that keeps them airtight once closed."
	icon = 'icons/obj/doors/shutters.dmi'
	layer = SHUTTER_LAYER
	closingLayer = SHUTTER_LAYER
	damage_deflection = 20
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 75, "bomb" = 25, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 70)
	max_integrity = 100

/obj/machinery/door/poddoor/shutters/preopen
	icon_state = "open"
	density = FALSE
	opacity = FALSE

/obj/machinery/door/poddoor/shutters/indestructible
	name = "hardened shutters"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/door/poddoor/shutters/radiation
	name = "radiation shutters"
	desc = "Lead-lined shutters with a raddiation hazard symbol on it. Once closed, this blocks some radiation."
	icon = 'icons/obj/doors/shutters_radiation.dmi'
	icon_state = "closed"
	rad_insulation = 0.2

/obj/machinery/door/poddoor/shutters/radiation/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0
	rad_insulation = 1

/obj/machinery/door/poddoor/shutters/radiation/do_animate(animation)
	. = ..()
	switch(animation)
		if("opening")
			rad_insulation = 1
		if("closing")
			rad_insulation = -0.5	//Rad insulation 0 to 1 doesn't really do anything to radiation, above 1 starts multiplying it, you need to go into negative numbers to start blocking radiation.

/obj/machinery/door/poddoor/shutters/window
	name = "windowed shutters"
	desc = "A shutter with a thick see-through polycarbonate window."
	icon = 'icons/obj/doors/shutters_window.dmi'
	icon_state = "closed"
	opacity = FALSE
	glass = TRUE

/obj/machinery/door/poddoor/shutters/window/preopen
	icon_state = "open"
	density = FALSE
