/obj/item/target/archery
	name = "archery target"
	desc = "A shooting target, specifically for bows."
	icon = 'modular_doppler/hearthkin/tribal_extended/icons/items_and_weapons.dmi'
	icon_state = "archery_target"
	// impact_sound = SFX_BULLET_IMPACT_WOOD

/datum/crafting_recipe/archery_target

	name = "archery target"
	category = CAT_FURNITURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF

	reqs = list(
		/obj/item/stack/tile/grass/thatch = 4,
		/obj/item/stack/sheet/mineral/wood = 4,
	)

	result = /obj/item/target/archery

// Hearthkin Exclusive Beds
/obj/structure/bed/double/pelt
	name = "white pelts bed"
	desc = "A luxurious double bed, made with white wolf pelts."
	icon_state = "pelt_bed_white"
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/tribal_beds.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 0.35
	max_buckled_mobs = 2
	/// What material this bed is made of
	build_stack_type = /obj/item/stack/sheet/sinew/wolf
	/// How many mats to drop when deconstructed
	build_stack_amount = 4

/obj/structure/bed/double/pelt/atom_deconstruct(disassembled = TRUE)
	. = ..()
	new /obj/item/stack/sheet/mineral/wood(loc, build_stack_amount)

/datum/crafting_recipe/white_pelt_bed
	name = "White Pelts Bed"
	category = CAT_FURNITURE
	//recipe given to icecats as part of their spawner/team setting
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND

	reqs = list(
		/obj/item/stack/sheet/sinew/wolf = 4,
		/obj/item/stack/sheet/mineral/wood = 4,
	)

	result = /obj/structure/bed/double/pelt

/obj/structure/bed/double/pelt/black
	name = "black pelts bed"
	desc = "A luxurious double bed, made with black wolf pelts."
	icon_state = "pelt_bed_black"
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/tribal_beds.dmi'

/datum/crafting_recipe/black_pelt_bed
	name = "Black Pelts Bed"
	category = CAT_FURNITURE
	//recipe given to icecats as part of their spawner/team setting
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND

	reqs = list(
		/obj/item/stack/sheet/sinew/wolf = 4,
		/obj/item/stack/sheet/mineral/wood = 4,
	)

	result = /obj/structure/bed/double/pelt/black

// Hearthkin Exclusive Decorations
/obj/structure/rugs/pelt/
	name = "white pelts rug"
	desc = "A luxurious rug, made from bear pelts."
	icon_state = "fur_rug_white"
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/fur_rugs.dmi'
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 0.35
	bound_height = 64

//Deconstruct code
/obj/structure/rugs/pelt/attackby(obj/item/attacking_item, mob/user, params)
    if(!istype(attacking_item, /obj/item/knife/))
        return ..()
    balloon_alert_to_viewers("cutting...")
    if(!do_after(user, 5 SECONDS, target = src))
        balloon_alert_to_viewers("stopped cutting")
        return FALSE
    deconstruct(TRUE)

/obj/structure/rugs/pelt/atom_deconstruct(disassembled)
	var/obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide/polar_bear_hide = new(drop_location(), 4)
	transfer_fingerprints_to(polar_bear_hide)
	return ..()

//Anchor code
/obj/structure/rugs/pelt/click_ctrl(mob/user)
	set_anchored(!anchored)
	balloon_alert(user, "[anchored ? "secured" : "unsecured"]")

//Crafting code

/datum/crafting_recipe/white_pelts_rug
	name = "White Pelts Rug"
	category = CAT_FURNITURE
	//recipe given to icecats as part of their spawner/team setting
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED | CRAFT_ONE_PER_TURF

	reqs = list(
		/obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide = 4,
	)

	result = /obj/structure/rugs/pelt/

/obj/structure/rugs/pelt/black
	name = "black pelts rug"
	desc = "A luxurious rug, made from bear pelts, and black dye."
	icon_state = "fur_rug_black"
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/fur_rugs.dmi'

/datum/crafting_recipe/black_pelts_rug
	name = "Black Pelts Rug"
	category = CAT_FURNITURE
	//recipe given to icecats as part of their spawner/team setting
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED | CRAFT_ONE_PER_TURF

	reqs = list(
		/obj/item/stack/sheet/animalhide/goliath_hide/polar_bear_hide = 4,
	)

	result = /obj/structure/rugs/pelt/black
