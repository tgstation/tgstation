/* This file contains standalone items for debug purposes. */

/obj/item/debug/human_spawner
	name = "human spawner"
	desc = "Spawn a human by aiming at a turf and clicking. Use in hand to change type."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "nothingwand"
	item_state = "wand"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/species/selected_species
	var/valid_species = list()

/obj/item/debug/human_spawner/afterattack(atom/target, mob/user, proximity)
	..()
	if(isturf(target))
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(target)
		if(selected_species)
			H.set_species(selected_species)

/obj/item/debug/human_spawner/attack_self(mob/user)
	..()
	var/choice = input("Select a species", "Human Spawner", null) in GLOB.species_list
	selected_species = GLOB.species_list[choice]
