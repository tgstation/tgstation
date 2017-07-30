/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
	return FINISHONMOBLIFE(M)

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/M)
	M.status_flags |= GOTTAGOFAST
	M.reagents.remove_reagent("nutriment", rand(0,3))
	M.reagents.remove_reagent("vitamin", rand(0,3))
	if(prob(34))
		M.nutrition = max(M.nutrition - rand(0,10), 1) //Cannot go below 1.
	return FINISHONMOBLIFE(M)
