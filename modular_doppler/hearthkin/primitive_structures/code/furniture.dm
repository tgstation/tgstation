/obj/item/target/archery
	name = "archery target"
	desc = "A shooting target, specifically for bows."
	icon = 'modular_doppler/tribal_extended/icons/items_and_weapons.dmi'
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
