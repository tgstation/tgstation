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

//Deconstruct code
/obj/structure/calling_horn/hearthkin/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert_to_viewers("disassembling...")
	if(!do_after(user, 2 SECONDS, src))
		return
	deconstruct(TRUE)

/obj/structure/calling_horn/hearthkin/atom_deconstruct(disassembled)
	var/obj/item/stack/sheet/bronze/bronze = new(drop_location(), 10)
	transfer_fingerprints_to(bronze)
	return ..()

//Anchor code
/obj/structure/calling_horn/hearthkin/click_ctrl(mob/user)
	set_anchored(!anchored)
	balloon_alert(user, "[anchored ? "secured" : "unsecured"]")

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
