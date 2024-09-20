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

//Deconstruct code
/obj/structure/hearthkin_rune_stone/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert_to_viewers("disassembling...")
	if(!do_after(user, 2 SECONDS, src))
		return
	deconstruct(TRUE)

/obj/structure/hearthkin_rune_stone/atom_deconstruct(disassembled)
	var/obj/item/stack/sheet/mineral/stone/stone = new(drop_location(), 10)
	transfer_fingerprints_to(stone)
	return ..()

//Anchor code
/obj/structure/hearthkin_rune_stone/click_ctrl(mob/user)
	set_anchored(!anchored)
	balloon_alert(user, "[anchored ? "secured" : "unsecured"]")

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
