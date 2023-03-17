/// Some defines for items the cult altar can create.
#define ELDRITCH_WHETSTONE "Eldritch Whetstone"
#define CONSTRUCT_SHELL "Construct Shell"
#define UNHOLY_WATER "Flask of Unholy Water"

// Cult altar. Gives out consumable items.
/obj/structure/destructible/cult/item_dispenser/altar
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar'Sie."
	cult_examine_tip = "Can be used to create eldritch whetstones, construct shells, and flasks of unholy water."
	icon_state = "talismanaltar"
	break_message = "<span class='warning'>The altar shatters, leaving only the wailing of the damned!</span>"

/obj/structure/destructible/cult/item_dispenser/altar/setup_options()
	var/static/list/altar_items = list(
		ELDRITCH_WHETSTONE = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/kitchen.dmi', icon_state = "cult_sharpener"),
			OUTPUT_ITEMS = list(/obj/item/sharpener/cult),
			),
		CONSTRUCT_SHELL = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/wizard.dmi', icon_state = "construct_cult"),
			OUTPUT_ITEMS = list(/obj/structure/constructshell),
			),
		UNHOLY_WATER = list(
			PREVIEW_IMAGE = image(icon = 'icons/obj/drinks/bottles.dmi', icon_state = "holyflask"),
			OUTPUT_ITEMS = list(/obj/item/reagent_containers/cup/beaker/unholywater),
			),
	)

	options = altar_items

/obj/structure/destructible/cult/item_dispenser/altar/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cultitalic("You kneel before [src] and your faith is rewarded with [spawned_item]!"))

#undef ELDRITCH_WHETSTONE
#undef CONSTRUCT_SHELL
#undef UNHOLY_WATER
