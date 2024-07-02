/obj/effect/landmark/bitrunning
	name = "Generic bitrunning effect"
	icon = 'icons/effects/bitrunning.dmi'
	icon_state = "crate"

/// In case you want to gate the crate behind a special condition.
/obj/effect/landmark/bitrunning/loot_signal
	name = "Mysterious aura"

/// Where the exit hololadder spawns
/obj/effect/landmark/bitrunning/hololadder_spawn
	name = "Bitrunning hololadder spawn"
	icon_state = "hololadder"

/// A permanent exit for the domain
/obj/effect/landmark/bitrunning/permanent_exit
	name = "Bitrunning permanent exit"
	icon_state = "perm_exit"

/// Where the crates need to be taken
/obj/effect/landmark/bitrunning/cache_goal_turf
	name = "Bitrunning goal turf"
	icon_state = "goal"

/// Where you want the crate to spawn
/obj/effect/landmark/bitrunning/cache_spawn
	name = "Bitrunning crate spawn"
	icon_state = "crate"

/// Where you want secondary objectives to spawn
/obj/effect/landmark/bitrunning/curiosity_spawn
	name = "Bitrunning curiosity spawn"
	icon_state = "crate"

///Swaps the locations of an encrypted crate in the area with another randomly selected crate.
///Randomizes names, so you have to inspect crates manually.
/obj/effect/landmark/bitrunning/crate_replacer
	name = "Bitrunning Goal Crate Randomizer"
	icon_state = "crate"

/obj/effect/landmark/bitrunning/crate_replacer/Initialize(mapload)
	. = ..()

#ifdef UNIT_TESTS
	return
#endif

	var/list/crate_list = list()
	var/obj/structure/closet/crate/secure/bitrunning/encrypted/encrypted_crate
	var/area/my_area = get_area(src)

	for (var/list/zlevel_turfs as anything in my_area.get_zlevel_turf_lists())
		for (var/turf/area_turf as anything in zlevel_turfs)
			for(var/obj/structure/closet/crate/crate_to_check in area_turf)
				if(istype(crate_to_check, /obj/structure/closet/crate/secure/bitrunning/encrypted))
					encrypted_crate = crate_to_check
					crate_to_check.desc += span_hypnophrase(" This feels like the crate we're looking for!")
				else
					crate_list += crate_to_check
				crate_to_check.name = "Unidentified Crate"

	if(!encrypted_crate)
		stack_trace("Bitrunning Goal Crate Randomizer failed to find an encrypted crate to swap positions for.")
		return
	if(!length(crate_list))
		stack_trace("Bitrunning Goal Crate Randomizer failed to find any NORMAL crates to swap positions for.")
		return

	var/original_location = encrypted_crate.loc
	var/obj/structure/closet/crate/selected_crate = pick(crate_list)

	encrypted_crate.abstract_move(selected_crate.loc)
	selected_crate.abstract_move(original_location)

/// A location for mobs to spawn.
/obj/effect/landmark/bitrunning/mob_segment
	name = "Bitrunning modular mob segment"
	icon_state = "mob_segment"

/// Bitrunning safehouses. Typically 7x6 rooms with a single entrance.
/obj/modular_map_root/safehouse
	config_file = "strings/modular_maps/safehouse.toml"
	icon = 'icons/effects/bitrunning.dmi'
	icon_state = "safehouse"
