//Will include consumable gene mods in the future.

/obj/item/genemod
	name = "genetic modifier"
	desc = "Microbodies which can grow, morph, or otherwise change an organism into something else."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "dnainjector"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/applied_region = "chest"
	var/list/add_mutations = list()
	var/list/remove_mutations = list()

	var/list/add_mutations_static = list()
	var/list/remove_mutations_static = list()

	var/used = 0

/obj/item/genemod/proc/use(mob/living/carbon/human/target)
	return