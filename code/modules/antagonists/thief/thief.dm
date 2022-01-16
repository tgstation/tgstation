
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
	///assoc list of strings set up for the flavor of the thief. Thief flavor also decides what objectives are forged, FYI.
	var/list/thief_flavor
	///funny little flavor sent to the ui.
	var/honor_among_thieves = FALSE

/datum/antagonist/thief/on_gain()
	. = ..()
	honor_among_thieves = prob(50)
	roll_flavor()
	forge_objectives()

/datum/antagonist/thief/proc/roll_flavor()
	var/picked_flavor
	switch(rand(1, 100))
		if(1 to 40)
			picked_flavor = "Thief"
		if(41 to 70)
			picked_flavor = "Hoarder"
		if(71 to 84)
			picked_flavor = "Black Market Outfitter"
		if(85 to 93)
			picked_flavor = "Organ Market Collector"
		if(94 to 99)
			picked_flavor = "Chronicler"
		if(100)
			picked_flavor = "Deranged"
	thief_flavor = strings(THIEF_FLAVOR_FILE, picked_flavor)

/datum/antagonist/thief/proc/forge_objectives()
	//thieves get their main objective from their flavor.
	var/objective_path = text2path(thief_flavor["objective_type"])
	var/datum/objective/flavor_objective = new objective_path
	if(thief_flavor["objective_needs_target"])
		flavor_objective.find_target(dupe_search_range = list(src))
	flavor_objective.owner = owner
	objectives += flavor_objective

	//all thieves need to escape with their loot
	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective

/datum/antagonist/thief/ui_static_data(mob/user)
	var/list/data = list()
	data["objectives"] = get_objectives()
	data["goal"] = thief_flavor["goal"]
	data["intro"] = thief_flavor["intro"]
	data["honor"] = honor_among_thieves
	return data

/datum/outfit/thief
	name = "Thief (Preview only)"
	uniform = /obj/item/clothing/under/color/black
	glasses = /obj/item/clothing/glasses/night
	gloves = /obj/item/clothing/gloves/color/latex
	back = /obj/item/storage/backpack/duffelbag/syndie
