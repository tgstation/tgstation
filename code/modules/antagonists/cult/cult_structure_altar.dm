/// Some defines for items the cult altar can create.
#define ELDRITCH_WHETSTONE "Eldritch Whetstone"
#define CONSTRUCT_SHELL "Construct Shell"
#define UNHOLY_WATER "Flask of Unholy Water"
#define PROTEON_ORB "Portal Summoning Orb"

// Cult altar. Gives out consumable items.
/obj/structure/destructible/cult/item_dispenser/altar
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar'Sie."
	cult_examine_tip = "Can be used to create eldritch whetstones, construct shells, and flasks of unholy water."
	icon_state = "talismanaltar"
	break_message = span_warning("The altar shatters, leaving only the wailing of the damned!")
	mansus_conversion_path = /obj/effect/heretic_rune

/obj/structure/destructible/cult/item_dispenser/altar/setup_options()
	var/static/list/altar_items = list(
		ELDRITCH_WHETSTONE = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/antags/cult/items.dmi', icon_state = "cult_sharpener"),
			OUTPUT_ITEMS = list(/obj/item/sharpener/cult),
			),
		CONSTRUCT_SHELL = list(
			PREVIEW_IMAGE = image(icon = 'icons/mob/shells.dmi', icon_state = "construct_cult"),
			OUTPUT_ITEMS = list(/obj/structure/constructshell),
			),
		UNHOLY_WATER = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/drinks/bottles.dmi', icon_state = "unholyflask"),
			OUTPUT_ITEMS = list(/obj/item/reagent_containers/cup/beaker/unholywater),
			),
	)

	var/extra_item = extra_options()

	options = altar_items
	if(!isnull(extra_item))
		options += extra_item

/obj/structure/destructible/cult/item_dispenser/altar/extra_options()
	if(!cult_team?.unlocked_heretic_items[PROTEON_ORB_UNLOCKED])
		return
	return list(PROTEON_ORB = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/antags/cult/items.dmi', icon_state = "summoning_orb"),
			OUTPUT_ITEMS = list(/obj/item/proteon_orb),
			),
	)

/obj/structure/destructible/cult/item_dispenser/altar/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cult_italic("You kneel before [src] and your faith is rewarded with [spawned_item]!"))

#undef ELDRITCH_WHETSTONE
#undef CONSTRUCT_SHELL
#undef UNHOLY_WATER
#undef PROTEON_ORB
