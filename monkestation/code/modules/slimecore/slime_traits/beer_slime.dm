/datum/slime_trait/beer_slime
	name = "Beer Slime"
	desc = "Modifies their genomes to allow them to produce beer instead of ooze"
	menu_buttons = list(BEHAVIOUR_CHANGE)

/datum/slime_trait/beer_slime/on_add(mob/living/basic/slime/parent)
	. = ..()
	var/datum/reagent/reagent = pick(typesof(/datum/reagent/consumable/ethanol))
	parent.chemical_injection = reagent
	parent.overriding_name_prefix = initial(reagent.name)
	parent.update_slime_varience()

/datum/slime_trait/beer_slime/on_remove(mob/living/basic/slime/parent)
	. = ..()
	parent.chemical_injection = null
	parent.overriding_name_prefix = null
	parent.update_slime_varience()
