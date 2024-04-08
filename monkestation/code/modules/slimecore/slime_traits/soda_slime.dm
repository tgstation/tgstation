/datum/slime_trait/soda_slime
	name = "Soda Slime"
	desc = "Modifies their genomes to allow them to produce soda instead of ooze"
	menu_buttons = list(BEHAVIOUR_CHANGE)

/datum/slime_trait/soda_slime/on_add(mob/living/basic/slime/parent)
	. = ..()
	var/datum/reagent/reagent = pick(
		/datum/reagent/consumable/space_cola,
		/datum/reagent/consumable/dr_gibb,
		/datum/reagent/consumable/grenadine,
		/datum/reagent/consumable/icetea,
		/datum/reagent/consumable/menthol,
		/datum/reagent/consumable/pwr_game,
		/datum/reagent/consumable/shamblers,
		/datum/reagent/consumable/spacemountainwind,
		/datum/reagent/consumable/sodawater,
		/datum/reagent/consumable/sol_dry,
		/datum/reagent/consumable/space_up,
		/datum/reagent/consumable/tonic,
		/datum/reagent/consumable/ethanol/thirteenloko,
		/datum/reagent/consumable/ethanol/whiskey_cola,
	)
	parent.chemical_injection = reagent
	parent.overriding_name_prefix = initial(reagent.name)
	parent.update_slime_varience()

/datum/slime_trait/soda_slime/on_remove(mob/living/basic/slime/parent)
	. = ..()
	parent.chemical_injection = null
	parent.overriding_name_prefix = null
	parent.update_slime_varience()
