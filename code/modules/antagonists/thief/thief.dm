///very low level antagonist that has objectives to steal items and live, but is not allowed to kill.
/datum/antagonist/thief
	name = "\improper Thief"
	job_rank = ROLE_THIEF
	roundend_category = "thieves"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "FOR THE LION'S SHARE!!"
	preview_outfit = /datum/outfit/thief
	ui_name = "AntagInfoThief"
	///assoc list of strings set up for the flavor of the thief.
	var/list/thief_flavor
	///funny little flavor sent to the ui.
	var/honor_among_thieves = FALSE

/datum/antagonist/thief/on_gain()
	. = ..()
	honor_among_thieves = prob(50)
	flavor_and_objectives()

/datum/antagonist/thief/proc/flavor_and_objectives()
	var/picked_flavor
	//this list has a maximum pickweight of 100. if you're adding a new type of thief, DON'T just add pickweight without adjusting the others, numb nuts.
	var/list/weighted_objectives = list(
		/datum/objective/steal = 40, //Thief
		/datum/objective/hoarder = 30, //Hoarder
		/datum/objective/steal_n_of_type/summon_guns/thief = 15, //Outfitter
		/datum/objective/steal_n_of_type/organs = 8, //Collector
		/datum/objective/chronicle = 5, //Chronicler
		/datum/objective/hoarder/bodies = 2 //Deranged
	)
	var/chosen_objective = pick_weight(weighted_objectives)
	//this will make the objective call find_target()
	var/objective_needs_target
	switch(chosen_objective)
		if(/datum/objective/steal)
			picked_flavor = "Thief"
			objective_needs_target = TRUE
		if(/datum/objective/hoarder)
			picked_flavor = "Hoarder"
			objective_needs_target = TRUE
		if(/datum/objective/steal_n_of_type/summon_guns/thief)
			picked_flavor = "Black Market Outfitter"
			objective_needs_target = FALSE
		if(/datum/objective/steal_n_of_type/organs)
			picked_flavor = "Organ Market Collector"
			objective_needs_target = FALSE
		if(/datum/objective/chronicle)
			picked_flavor = "Chronicler"
			objective_needs_target = FALSE
		if(/datum/objective/hoarder/bodies)
			picked_flavor = "Deranged"
			objective_needs_target = TRUE
	thief_flavor = strings(THIEF_FLAVOR_FILE, picked_flavor)

	//whatever main objective this type of thief needs to accomplish
	var/datum/objective/flavor_objective = new chosen_objective
	if(objective_needs_target)
		flavor_objective.find_target(dupe_search_range = list(src))
	flavor_objective.owner = owner
	objectives += flavor_objective

	//all thieves need to escape with their loot (except hoarders, but you know.)
	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective

/datum/antagonist/thief/ui_static_data(mob/user)
	var/list/data = list()
	data["objectives"] = get_objectives()
	data["goal"] = thief_flavor["goal"]
	data["intro"] = thief_flavor["introduction"]
	data["honor"] = honor_among_thieves
	return data

/datum/outfit/thief
	name = "Thief (Preview only)"
	uniform = /obj/item/clothing/under/color/black
	glasses = /obj/item/clothing/glasses/night
	gloves = /obj/item/clothing/gloves/color/latex
	back = /obj/item/storage/backpack/duffelbag/syndie

/datum/outfit/thief/post_equip(mob/living/carbon/human/thief, visualsOnly=FALSE)
	// This outfit is used by the assets SS, which is ran before the atoms SS
	if(SSatoms.initialized == INITIALIZATION_INSSATOMS)
		thief.w_uniform?.update_greyscale()
		thief.update_inv_w_uniform()
