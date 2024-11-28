/datum/action/cooldown/spell/wolves_among_sheep
	name = "Wolves among Sheep"
	desc = "Locks down an area, making it a death battle. You gain more power the more heathens are nearby."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "among_sheep"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 5 SECONDS

	invocation = "D`M``N `XP`NS``N!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	/// Max distance our effect is expected to reach
	var/max_range = 9
	/// Max distance our effect has *actually* reached
	var/greatest_dist = 0
	/// Central turf where the spell was initially casted
	var/turf/center_turf
	/// List of all the turfs we've affected, built during /cast(). We use this to make things appear/disappear and revert once the spell expires
	var/list/to_transform = list()
	/// List of airlocks we've removed, so we can re-place them once the effect expires
	var/list/banished_airlocks = list()

/datum/action/cooldown/spell/wolves_among_sheep/cast(atom/cast_on)
	. = ..()
	center_turf = get_turf(owner)
	to_transform = list()
	new /obj/effect/heretic_rune/big(center_turf)
	addtimer(CALLBACK(src, PROC_REF(create_arena), center_turf), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(revert_effects)), 61 SECONDS) // 1 second to spread out, 60 seconds to fight

	// Loop to make the spreading floor effect before finalizing our arena
	for(var/turf/transform_turf as anything in RANGE_TURFS(max_range, center_turf))
		var/turf_distance = get_dist(center_turf, transform_turf)
		if(turf_distance > greatest_dist)
			greatest_dist = turf_distance
			if(greatest_dist > max_range)
				stack_trace("greatest_dist ([greatest_dist]) has somehow exceeded the expected maximum range ([max_range])")
		if(!to_transform["[turf_distance]"])
			to_transform["[turf_distance]"] = list()
		to_transform["[turf_distance]"] += transform_turf
	for(var/iterator in 1 to greatest_dist)
		if(!to_transform["[iterator]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(apply_visual), to_transform["[iterator]"]), 1 * iterator) // 0.9 SECONDS to convert our area

	// Loop doesnt catch src.loc so we have to handle it manually
	apply_visual(list(center_turf))

/// Applies a visual to each turf
/datum/action/cooldown/spell/wolves_among_sheep/proc/apply_visual(list/turfs)
	for(var/turf/target as anything in turfs)
		if(istype(target, /turf/open))
			target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "heretic_arena", image('icons/turf/floors.dmi', target, "clockwork_floor", layer = ABOVE_OPEN_TURF_LAYER))
		else if(istype(target, /turf/closed))
			target.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "heretic_arena", image('icons/turf/walls.dmi', target, "clockwork_wall", layer = ABOVE_OPEN_TURF_LAYER))

		// Phase out the doors (restore them afterwards)
		for(var/obj/machinery/door/airlock/to_banish in target)
			banished_airlocks += to_banish
			banished_airlocks[to_banish] = to_banish.loc
			to_banish.moveToNullspace()

/// Sets up the proximity monitor which handles things that are within the area and leave once they get someone to crit
/datum/action/cooldown/spell/wolves_among_sheep/proc/create_arena(turf/target)
	new /obj/effect/abstract/heretic_arena(target, max_range)

/// Undoes our changes
/datum/action/cooldown/spell/wolves_among_sheep/proc/revert_effects()
	for(var/iterator in 1 to greatest_dist)
		var/backwards_iterator = greatest_dist - iterator + 1 //We go backwards
		if(!to_transform["[backwards_iterator]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(do_revert), to_transform["[backwards_iterator]"]), 1 * iterator)
	addtimer(CALLBACK(src, PROC_REF(do_revert), list(center_turf)), 1 SECONDS)

/// Transforms all the turfs and restores the airlocks
/datum/action/cooldown/spell/wolves_among_sheep/proc/do_revert(list/turfs)
	for(var/turf/target as anything in turfs)
		target.remove_alt_appearance("heretic_arena")
	for(var/obj/machinery/door/airlock/to_restore in banished_airlocks)
		to_restore.forceMove(banished_airlocks[to_restore])
