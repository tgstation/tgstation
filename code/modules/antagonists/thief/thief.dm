///very low level antagonist that has objectives to steal items and live, but is not allowed to kill.
/datum/antagonist/thief
	name = "\improper Thief"
	job_rank = ROLE_THIEF
	roundend_category = "thieves"
	show_in_antagpanel = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "FOR THE LION'S SHARE!!"
	///assoc list of strings set up for the flavor of the thief. Thief flavor also decides what objectives are forged, FYI.
	var/list/thief_flavor

/datum/antagonist/thief/proc/roll_flavor()
	var/picked_flavor
	switch(rand(1, 100))
		if(1 to 40)
			picked_flavor = "Thief"
		if(41 to 70)
			picked_flavor = "Hoarder"
		if(71 to 90)
			picked_flavor = "Black Market Outfitter"
		if(91 to 100)
			picked_flavor = "Organ Market Collector"
	thief_flavor = strings(THIEF_FLAVOR_FILE, picked_flavor)

/datum/antagonist/thief/proc/forge_objectives()
	//thieves get their main objective from their flavor.
	var/datum/objective/flavor_objective = new thief_flavor["objective_type"]
	if(thief_flavor["objective_needs_target"])
		flavor_objective.find_target(dupe_search_range = list(src))
	flavor_objective.owner = owner
	objectives += flavor_objective

	//all thieves need to escape with their loot
	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective
