/datum/gizmo_effect_combination/mopper/New()
	. = ..()

	for(var/i in 1 to random_reagents_to_add)
		reagents += get_random_reagent_id()

/datum/gizmo_effect_combination/mopper/activate(atom/movable/holder)
	if(!holder.reagents)
		holder.create_reagents(max_volume, reagent_flags)
		holder.reagents.add_reagent(active_reagent, max_volume)
		reagent_holder = holder.reagents
		START_PROCESSING(SSdcs, src)
	return ..()

/datum/gizmo_effect_combination/mopper/process(seconds_per_tick)
	reagent_holder.add_reagent(active_reagent, regeneration_speed * seconds_per_tick)

/// Wet the surounding tiles
/datum/gizmo_effect/wet_tiles/activate(atom/movable/holder, datum/gizmo_effect_combination/mopper/master, datum/gizmo_interface/interface)
	var/list/tiles = get_tiles(holder)
	for(var/turf/open/tile in tiles)
		tile.expose_reagents(holder.reagents.reagent_list, holder.reagents)

		holder.reagents.expose(tile, TOUCH, 1, master.max_volume / tiles.len)
		holder.reagents.remove_reagent(master.active_reagent, master.max_volume / tiles.len)

/// Get the tiles to wet
/datum/gizmo_effect/wet_tiles/proc/get_tiles(atom/movable/holder)
	return

/// Dump reagents in a circle
/datum/gizmo_effect/wet_tiles/fluid_circle
	/// Size, in a circle, around the holder for wetting
	var/size = 0

/datum/gizmo_effect/wet_tiles/fluid_circle/get_tiles(atom/movable/holder)
	return RANGE_TURFS(size, holder)

/// In a small circle
/datum/gizmo_effect/wet_tiles/fluid_circle/small
	size = 1

/// In a medium circle
/datum/gizmo_effect/wet_tiles/fluid_circle/medium
	size = 2

/// In a large circle
/datum/gizmo_effect/wet_tiles/fluid_circle/large
	size = 3

/// Make a smoke cloud of our fluid
/datum/gizmo_effect/fluid_smoke/activate(atom/movable/holder, datum/gizmo_interface/interface)
	do_chem_smoke(3, holder, get_turf(holder), carry = holder.reagents)
	holder.reagents.clear_reagents()

/// Select different reagents
/datum/gizmo_effect/swap_reagent/activate(atom/movable/holder, datum/gizmo_effect_combination/mopper/master, datum/gizmo_interface/interface)
	holder.reagents.clear_reagents()
	master.active_reagent = pick(master.reagents - master.active_reagent) //maybe also add a cycle one instead of random
