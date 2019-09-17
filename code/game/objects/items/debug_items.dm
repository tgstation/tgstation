/* This file contains standalone items for debug purposes. */

/obj/item/debug_item/humanspawner
	name = "human spawner"
	desc = "Spawn a human by aiming at a turf and clicking. Use in hand to change type."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "nothingwand"
	item_state = "wand"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/selected_species
	var/valid_species = list()

/obj/item/debug_item/humanspawner/afterattack(atom/target, mob/user, proximity)
	..()
	new_human(target, selected_species)

/obj/item/debug_item/humanspawner/attack_self(mob/user)
	..()
	var/choice = input("Select a species", "Human Spawner", null) in GLOB.species_list
	selected_species = GLOB.species_list[choice]

/obj/item/debug_item/humanspawner/proc/new_human(atom/target, species)
	if(isturf(target))
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(target)
		if(species)
			H.set_species(species)
