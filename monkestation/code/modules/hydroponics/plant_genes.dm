/*
 * this limits potency, it is used for plants that have strange behavior above 100 potency.
 *
 */
/datum/plant_gene/trait/potencylimit
	name = "potency limiter"
	icon = "lightbulb"
	description = "limits potency to 100, used for some plants to avoid lag and similar issues."
	trait_flags = TRAIT_LIMIT_POTENCY
	mutability_flags = PLANT_GENE_GRAFTABLE

/datum/plant_gene/trait/potencylimit/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return
