/// Following recent tomfoolery, we've decided to ban you from space.
/datum/component/banned_from_space
	/// List of recent tiles we walked on that aren't space
	var/list/tiles = list()
	/// The max amount of tiles we store
	var/max_tile_list_size = 4

/datum/component/banned_from_space/Initialize(...)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_ENTERING, PROC_REF(check_if_space))

/datum/component/banned_from_space/proc/check_if_space(atom/source, atom/new_location)
	SIGNAL_HANDLER

	if(!isturf(new_location))
		return

	if(isspaceturf(new_location))
		send_back(parent)

	else
		tiles.Add(new_location)
		if(tiles.len > max_tile_list_size)
			tiles.Cut(1, 2)

/datum/component/banned_from_space/proc/send_back(atom/movable/parent)
	var/new_turf

	if(tiles.len)
		new_turf = tiles[1]
		new /obj/effect/temp_visual/portal_animation(parent.loc, new_turf, parent)
	else
		new_turf = get_random_station_turf()

	parent.forceMove(new_turf)
