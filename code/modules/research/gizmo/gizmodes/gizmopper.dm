/// Gizmo mode that regenerates, cycles and expells reagents in different functions
/datum/gizmodes/mopper
	possible_active_modes = list(
		/datum/gizpulse/wet_tiles/fluid_circle/small = 1,
		/datum/gizpulse/wet_tiles/fluid_circle/medium = 1,
		/datum/gizpulse/wet_tiles/fluid_circle/large = 1,
		/datum/gizpulse/fluid_smoke = 1,
		/datum/gizpulse/swap_reagent = 1,
		)

	min_modes = 3
	max_modes = 5

	/// Reagents that can be selected
	var/list/reagents = list(
		/datum/reagent/water,
		/datum/reagent/toxin/acid,
		/datum/reagent/consumable/salt,
		/datum/reagent/uranium/radium,
	)
	/// Reference to the reagent holder. Preferably access it from the holder instead, but some procs dont like that (process())
	var/datum/reagents/reagent_holder
	/// Reagent that is being generated right now
	var/active_reagent = /datum/reagent/water
	/// Max volume of the reagent holder we hand out
	var/max_volume = 50
	/// Amount of reagents we regenerate per second
	var/regeneration_speed = 2
	/// How many reagents we grab from get_random_reagent_id
	var/random_reagents_to_add = 1
	/// Flags to pass to the reagent holder
	var/reagent_flags = AMOUNT_VISIBLE

/datum/gizmodes/mopper/New()
	. = ..()

	for(var/i in 1 to random_reagents_to_add)
		reagents += get_random_reagent_id()

/datum/gizmodes/mopper/activate(atom/movable/holder)
	if(!holder.reagents)
		holder.create_reagents(max_volume, reagent_flags)
		holder.reagents.add_reagent(active_reagent, max_volume)
		reagent_holder = holder.reagents
		START_PROCESSING(SSdcs, src)
	. = ..()

/datum/gizmodes/mopper/process(seconds_per_tick)
	reagent_holder.add_reagent(active_reagent, regeneration_speed * seconds_per_tick)

/// Wet the surounding tiles
/datum/gizpulse/wet_tiles/activate(atom/movable/holder, datum/gizmodes/mopper/master, datum/gizmo_interface/interface)
	var/list/tiles = get_tiles(holder)
	for(var/turf/open/tile in tiles)
		tile.expose_reagents(holder.reagents.reagent_list, holder.reagents)

		holder.reagents.expose(tile, TOUCH, 1, master.max_volume / tiles.len)
		holder.reagents.remove_reagent(master.active_reagent, master.max_volume / tiles.len)

/// Get the tiles to wet
/datum/gizpulse/wet_tiles/proc/get_tiles(atom/movable/holder)
	return

/// Dump reagents in a circle
/datum/gizpulse/wet_tiles/fluid_circle
	/// Size, in a circle, around the holder for wetting
	var/size = 0

/datum/gizpulse/wet_tiles/fluid_circle/get_tiles(atom/movable/holder)
	return range(size, holder)

/// In a small circle
/datum/gizpulse/wet_tiles/fluid_circle/small
	size = 1

/// In a medium circle
/datum/gizpulse/wet_tiles/fluid_circle/medium
	size = 2

/// In a large circle
/datum/gizpulse/wet_tiles/fluid_circle/large
	size = 3

/// Make a smoke cloud of our fluid
/datum/gizpulse/fluid_smoke/activate(atom/movable/holder, datum/gizmo_interface/interface)
	do_chem_smoke(3, holder, get_turf(holder), carry = holder.reagents)
	holder.reagents.clear_reagents()

/// Select different reagents
/datum/gizpulse/swap_reagent/activate(atom/movable/holder, datum/gizmodes/mopper/master, datum/gizmo_interface/interface)
	holder.reagents.clear_reagents()
	master.active_reagent = pick(master.reagents - master.active_reagent) //maybe also add a cycle one instead of random
