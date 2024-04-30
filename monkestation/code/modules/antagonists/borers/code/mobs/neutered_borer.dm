/**
 * A version of the standard borer that can't reproduce
 */

/mob/living/basic/cortical_borer/neutered
	antagonist_datum = /datum/antagonist/cortical_borer
	neutered = TRUE
	skip_status_tab = TRUE
	generation = 1

/mob/living/basic/cortical_borer/neutered/get_status_tab_items()
	. = ..()
	. += "Chemical Storage: [chemical_storage]/[max_chemical_storage]"
	. += "Chemical Evolution Points: [chemical_evolution]"
	. += "Stat Evolution Points: [stat_evolution]"
	. += ""
	if(host_sugar())
		. += "Sugar detected! Unable to generate resources!"
