
SUBSYSTEM_DEF(ore_generation)
	name = "Ore Generation"
	wait = 60 SECONDS
	init_order = INIT_ORDER_DEFAULT
	runlevels = RUNLEVEL_GAME

	/// All ore vents that are currently producing boulders.
	var/list/processed_vents = list()
	/// All the boulders that have been produced by ore vents to be pulled by BRM machines.
	var/list/available_boulders = list()
	/// All the ore vents that are currently in the game, not just the ones that are producing boulders.
	var/list/possible_vents = list()
	/// A list of all the minerals that are being mined by ore vents. We reset this list every time cave generation is done.
	var/list/ore_vent_minerals = list()
	/**
	 * Associated list of minerals to be associated with our ore vents.
	 * Generally Should be empty by the time initialize ends on lavaland.
	 * Each key value is the number of vents that will have this ore as a unique possible choice.
	 */
	var/static/list/ore_vent_minerals_default = list(
		/datum/material/iron = 13,
		/datum/material/glass = 12,
		/datum/material/plasma = 9,
		/datum/material/titanium = 6,
		/datum/material/silver = 5,
		/datum/material/gold = 5,
		/datum/material/diamond = 3,
		/datum/material/uranium = 3,
		/datum/material/bluespace = 3,
		/datum/material/plastic = 1,
	)
	var/list/post_ore_r = list(
		"1" = 0,
		"2" = 0,
		"3" = 0,
		"4" = 0,
		"5" = 0,
	)
	var/list/post_ore_m = list(
		"1" = 0,
		"2" = 0,
		"3" = 0,
		"4" = 0,
		"5" = 0,
	)

/datum/controller/subsystem/ore_generation/Initialize()
	//Basically, we're going to round robin through the list of ore vents and assign a mineral to them until complete.
	while(ore_vent_minerals.len > 0)
		for(var/obj/structure/ore_vent/vent in possible_vents)
			if(vent.unique_vent)
				continue //Ya'll already got your minerals.
			if(ore_vent_minerals.len <= 0)
				break
			vent.generate_mineral_breakdown(max_minerals = 1, map_loading = TRUE)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ore_generation/fire(resumed)
	available_boulders = list() // reset upon new fire.
	for(var/vent in processed_vents)
		var/obj/structure/ore_vent/current_vent = vent

		var/local_vent_count = 0
		for(var/obj/item/boulder/old_rock as anything in current_vent.loc) // Optimize?
			if(!isitem(old_rock))
				continue
			available_boulders += old_rock
			local_vent_count++

		if(local_vent_count >= MAX_BOULDERS_PER_VENT)
			continue //We don't want to be accountable for literally hundreds of unprocessed boulders for no reason.

		var/obj/item/boulder/new_rock = current_vent.produce_boulder()
		available_boulders += new_rock

