//Object code.
/obj/structure/calling_horn/hearthkin
	name = "bronze calling horn"
	desc = "A magnificent bronze calling horn, used by the Hearthkin to call upon their own. It doesn't seem to be working right now, though."
	icon_state = "hearthkin_meeting_horn"
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/bronze_horn.dmi'
	anchored = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 0.35
	var/build_stack_type = /obj/item/stack/sheet/bronze
	/// How many mats to drop when deconstructed
	var/build_stack_amount = 10
	/// If this horn can be deconstructed using a wrench
	var/can_deconstruct = TRUE

//Crafting code.

/datum/crafting_recipe/bronze_calling_horn
	name = "Bronze Calling Horn"
	category = CAT_FURNITURE
	//recipe given to icecats as part of their spawner/team setting
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND

	reqs = list(
		/obj/item/stack/sheet/bronze = 10,
	)

	result = /obj/structure/calling_horn/hearthkin

// Our global message code.
// SOON IN CINEMAS
