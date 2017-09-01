/datum/reagent/proc/FINISHONMOBLIFE(mob/living/M)
	current_cycle++
	M.reagents.remove_reagent(src.id, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.
	return TRUE
