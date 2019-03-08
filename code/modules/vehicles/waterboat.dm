/obj/vehicle/ridden/boat
	name = "boat"
	desc = "A boat used for traversing water."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	can_buckle = TRUE
	resistance_flags = FLAMMABLE

/obj/vehicle/ridden/boat/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.keytype = /obj/item/oar
	D.allowed_turf_typecache = typecacheof(/turf/open/water)

/obj/item/oar/wood
	name = "wooden oar"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "oar"
	item_state = "oar"
	lefthand_file = 'icons/mob/inhands/misc/lavaland_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/lavaland_righthand.dmi'
	desc = "Not to be confused with the kind Peridots hassles you for."
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE