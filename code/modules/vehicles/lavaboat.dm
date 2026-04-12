// Boat
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

/obj/vehicle/ridden/lavaboat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lavaboat)

/obj/vehicle/ridden/lavaboat/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!key_type || is_key(inserted_key) || !is_key(tool))
		return NONE
	if(!user.transferItemToLoc(tool, src))
		to_chat(user, span_warning("[tool] seems to be stuck to your hand!"))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You attach \the [tool] to \the [src]."))
	if(inserted_key) //just in case there's an invalid key
		inserted_key.forceMove(drop_location())
	inserted_key = tool
	return ITEM_INTERACT_SUCCESS

/obj/vehicle/ridden/lavaboat/examine_key_message()
	if(!key_type)
		return
	if(!inserted_key)
		return span_notice("You can attach an oar to it by clicking \the [src] with one.")
	else
		return span_notice("Alt-click [src] to detach \the [inserted_key].")

/obj/item/oar
	name = "oar"
	desc = "Not to be confused with the kind Research hassles you for."
	icon = 'icons/mob/rideables/vehicles.dmi'
	icon_state = "oar"
	inhand_icon_state = "oar"
	icon_angle = 45
	lefthand_file = 'icons/mob/inhands/items/lavaland_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/lavaland_righthand.dmi'
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	custom_materials = list(/datum/material/bone = SHEET_MATERIAL_AMOUNT * 2)

/datum/crafting_recipe/oar
	name = "Goliath Bone Oar"
	result = /obj/item/oar
	reqs = list(/obj/item/stack/sheet/bone = 2)
	time = 1.5 SECONDS
	category = CAT_TOOLS

/datum/crafting_recipe/boat
	name = "Goliath Hide Boat"
	result = /obj/vehicle/ridden/lavaboat
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 3)
	time = 5 SECONDS
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

// Dragon Boat
/obj/item/ship_in_a_bottle
	name = "ship in a bottle"
	desc = "A tiny ship inside a bottle."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "ship_bottle"

/obj/item/ship_in_a_bottle/attack_self(mob/user)
	to_chat(user, span_notice("You're not sure how they get the ships in these things, but you're pretty sure you know how to get it out."))
	create_boat(get_turf(src))

/obj/item/ship_in_a_bottle/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if (!.) // Shatter when not caught
		create_boat(get_turf(src))

/obj/item/ship_in_a_bottle/proc/create_boat(drop_loc)
	playsound(drop_loc, 'sound/effects/glass/glassbr1.ogg', 100, TRUE)
	new /obj/vehicle/ridden/lavaboat/dragon(drop_loc)
	qdel(src)

/obj/vehicle/ridden/lavaboat/dragon
	name = "mysterious boat"
	desc = "This boat moves where you will it, without the need for an oar."
	icon_state = "dragon_boat"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF
	key_type = null

/obj/vehicle/ridden/lavaboat/dragon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/lavaboat/dragonboat)

/obj/vehicle/ridden/lavaboat/dragon/examine(mob/user)
	. = ..()
	. += span_notice("You can reform [src] into its bottled shape by rubbing the dragon's nose with [EXAMINE_HINT("Alt-Click")].")

/obj/vehicle/ridden/lavaboat/dragon/click_alt(mob/user)
	balloon_alert(user, "bottling the boat...")
	if (!do_after(user, 2 SECONDS, src))
		return CLICK_ACTION_BLOCKING
	balloon_alert(user, "bottled the boat!")
	var/obj/item/ship_in_a_bottle/bottled_ship = new(user.drop_location())
	user.put_in_hands(bottled_ship)
	return CLICK_ACTION_SUCCESS
