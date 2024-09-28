/proc/create_lost_crew(list/recovered_items)
	var/mob/living/carbon/human/new_body = new(null)
	new_body.death()

	var/static/list/scenarios = list()
	if(!scenarios.len)
		var/list/types = subtypesof(/datum/corpse_damage_class)
		for(var/datum/corpse_damage_class/scenario as anything in types)
			scenarios[scenario] = initial(scenario.weight)

	var/datum/corpse_damage_class/scenario = pick_weight(scenarios)
	scenario = new()

	scenario.apply_character(new_body, recovered_items)
	scenario.apply_injuries(new_body, recovered_items)
	return new_body
