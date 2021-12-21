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

/obj/structure/destructible/cult/item_dispenser/altar/get_items_to_spawn(mob/living/user)
	. = list()

	var/list/items = list(
		ELDRITCH_WHETSTONE = image(icon = 'icons/obj/kitchen.dmi', icon_state = "cult_sharpener"),
		CONSTRUCT_SHELL = image(icon = 'icons/obj/wizard.dmi', icon_state = "construct_cult"),
		UNHOLY_WATER = image(icon = 'icons/obj/drinks.dmi', icon_state = "holyflask")
		)
	var/choice = show_radial_menu(user, src, items, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	switch(choice)
		if(ELDRITCH_WHETSTONE)
			. += /obj/item/sharpener/cult
		if(CONSTRUCT_SHELL)
			. += /obj/structure/constructshell
		if(UNHOLY_WATER)
			. += /obj/item/reagent_containers/glass/beaker/unholywater

/obj/structure/destructible/cult/item_dispenser/altar/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cultitalic("You kneel before [src] and your faith is rewarded with [spawned_item]!"))

#undef ELDRITCH_WHETSTONE
#undef CONSTRUCT_SHELL
#undef UNHOLY_WATER
