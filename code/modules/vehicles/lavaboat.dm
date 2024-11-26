
//Boat

/obj/vehicle/ridden/lavaboat
	name = "lava boat"
	desc = "A boat used for traversing lava."
	icon = 'icons/obj/mining_zones/dragonboat.dmi'
	icon_state = "goliath_boat"
	icon_preview = 'icons/obj/fluff/previews.dmi'
	icon_state_preview = "boat"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	can_buckle = TRUE
	key_type = /obj/item/oar
	var/allowed_turf = /turf/open/lava

/obj/vehicle/ridden/lavaboat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lavaboat)

/obj/item/oar
	name = "oar"
	desc = "Not to be confused with the kind Research hassles you for."
	icon = 'icons/mob/rideables/vehicles.dmi'
	icon_state = "oar"
	inhand_icon_state = "oar"
	lefthand_file = 'icons/mob/inhands/items/lavaland_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/lavaland_righthand.dmi'
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = LAVA_PROOF | FIRE_PROOF

/datum/crafting_recipe/oar
	name = "Goliath Bone Oar"
	result = /obj/item/oar
	reqs = list(/obj/item/stack/sheet/bone = 2)
	time = 15
	category = CAT_TOOLS

/datum/crafting_recipe/boat
	name = "Goliath Hide Boat"
	result = /obj/vehicle/ridden/lavaboat
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	time = 50
	category = CAT_TOOLS

/obj/vehicle/ridden/lavaboat/plasma
	name = "plasma boat"
	desc = "A boat used for traversing the streams of plasma without turning into an icecube."
	icon = 'icons/obj/mining_zones/dragonboat.dmi'
	icon_state = "goliath_boat"
	resistance_flags = FREEZE_PROOF
	can_buckle = TRUE

/datum/crafting_recipe/boat/plasma
	name = "Polar Bear Hide Boat"
	result = /obj/vehicle/ridden/lavaboat/plasma
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide = 3)

//Dragon Boat


/obj/item/ship_in_a_bottle
	name = "ship in a bottle"
	desc = "A tiny ship inside a bottle."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "ship_bottle"

/obj/item/ship_in_a_bottle/attack_self(mob/user)
	to_chat(user, span_notice("You're not sure how they get the ships in these things, but you're pretty sure you know how to get it out."))
	playsound(user.loc, 'sound/effects/glass/glassbr1.ogg', 100, TRUE)
	new /obj/vehicle/ridden/lavaboat/dragon(get_turf(src))
	qdel(src)

/obj/vehicle/ridden/lavaboat/dragon
	name = "mysterious boat"
	desc = "This boat moves where you will it, without the need for an oar."
	icon_state = "dragon_boat"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF

/obj/vehicle/ridden/lavaboat/dragon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lavaboat/dragonboat)
