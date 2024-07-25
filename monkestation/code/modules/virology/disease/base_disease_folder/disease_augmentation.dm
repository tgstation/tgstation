/datum/disease/proc/new_effect(badness = 2, stage = 0)
	var/list/datum/symptom/list = list()
	var/list/to_choose = subtypesof(/datum/symptom)
	for(var/e in to_choose)
		var/datum/symptom/f = new e
		if(!f.restricted && f.stage == stage && text2num(f.badness) == badness)
			list += f
	if (list.len <= 0)
		return new_random_effect(badness+1,badness-1,stage)
	else
		var/datum/symptom/e = pick(list)
		e.chance = rand(1, e.max_chance)
		return e

/datum/disease/proc/new_random_effect(var/max_badness = 5, var/min_badness = 0, var/stage = 0, var/old_effect)
	var/list/datum/symptom/list = list()
	var/list/to_choose = subtypesof(/datum/symptom)
	if(old_effect) //So it doesn't just evolve right back into the previous virus type
		to_choose.Remove(old_effect)
	for(var/e in to_choose)
		var/datum/symptom/f = new e
		if(!f.restricted && f.stage == stage && text2num(f.badness) <= max_badness && text2num(f.badness) >= min_badness)
			list += f
	if (list.len <= 0)
		return new_random_effect(min(max_badness+1,5),max(0,min_badness-1),stage)
	else
		var/datum/symptom/e = pick(list)
		e.chance = rand(1, e.max_chance)
		return e

/datum/disease/proc/randomize_spread()
	spread_flags = DISEASE_SPREAD_BLOOD	//without blood spread_flags, the disease cannot be extracted or cured, we don't want that for regular diseases
	if (prob(5))			//5% chance of spreading through both contact and the air.
		spread_flags |= DISEASE_SPREAD_CONTACT_SKIN
		spread_flags |= DISEASE_SPREAD_AIRBORNE
	else if (prob(40))		//38% chance of spreading through the air only.
		spread_flags |= DISEASE_SPREAD_AIRBORNE
	else if (prob(60))		//34,2% chance of spreading through contact only.
		spread_flags |= DISEASE_SPREAD_CONTACT_SKIN
							//22,8% chance of staying in blood
