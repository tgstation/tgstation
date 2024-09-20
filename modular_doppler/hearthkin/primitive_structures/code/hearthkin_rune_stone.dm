//Object code.
/obj/structure/hearthkin_rune_stone
	name = "rune stone"
	desc = "A carved stone, with bright cyan runes inscribed upon it. A warning clearly states: HEARTHKIN SACRED LANDS. OUTLANDERS WILL BE KILLED UPON INVADING."
	icon_state = "hearthkin_warning_stone"
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/decorations.dmi'
	anchored = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 0.35
	var/build_stack_type = /obj/item/stack/sheet/mineral/stone/
	/// How many mats to drop when deconstructed
	var/build_stack_amount = 10
	/// If this rune stone can be deconstructed using a wrench
	var/can_deconstruct = TRUE

//Crafting code.

/datum/crafting_recipe/hearthkin_rune_stone
	name = "Rune Stone"
	category = CAT_FURNITURE
	//recipe given to icecats as part of their spawner/team setting
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED | CRAFT_ONE_PER_TURF

	reqs = list(
		/obj/item/stack/sheet/mineral/stone/ = 10,
	)

	result = /obj/structure/hearthkin_rune_stone
