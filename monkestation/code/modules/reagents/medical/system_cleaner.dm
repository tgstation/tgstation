/datum/reagent/medicine/system_cleaner
	name = "System Cleaner"
	description = "Neutralizes harmful chemical compounds inside synthetic systems."
	reagent_state = LIQUID
	color = "#F1C40F"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	process_flags = SYNTHETIC
	affected_biotype = MOB_ROBOTIC

/datum/reagent/medicine/system_cleaner/on_mob_life(mob/living/M)
	M.adjustToxLoss(-2 * REM, FALSE, required_biotype = affected_biotype)
	. = 1
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.type,1)
	..()
