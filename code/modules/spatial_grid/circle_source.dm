/// Most entries in the spatial gridmap are points, they occupy the space around them and that's it
/// Some sources want to be a range though, if I want a maxamalist (maybe has too much but will not miss anything)
/// List of say, sounds impacting a turf, I'd want to insert sounds into all the grid cells in RANGE of my origin
/// This datum manages that work for you
/// Owned by the source that created it
/datum/circle_grid_source
	/// The datum source we're managing
	var/datum/source
	/// The grid type we insert into
	var/spatial_type
	/// The radius of this source
	var/radius
	/// The center of this source
	var/atom/movable/center
	/// List of locs used to generate our current
	/// (lower left corner of every cell we're in)
	var/list/obj/effect/abstract/dummy_grid_source/current_locs = list()

/datum/circle_grid_source/New(datum/source, spatial_type, radius, atom/movable/center)
	. = ..()
	src.source = source
	src.spatial_type = spatial_type
	src.radius = radius
	set_center(center)
	refresh_cells()

/datum/circle_grid_source/Destroy(force)
	remove_from_cells()
	set_center(null)
	source = null
	return ..()

/datum/circle_grid_source/proc/set_radius(new_radius)
	radius = new_radius
	refresh_cells()

/datum/circle_grid_source/proc/set_center(atom/movable/new_center)
	if(center == new_center)
		return
	if(center)
		UnregisterSignal(center, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	center = new_center
	if(new_center)
		RegisterSignal(new_center, COMSIG_MOVABLE_MOVED, PROC_REF(center_moved))
		RegisterSignal(new_center, COMSIG_QDELETING, PROC_REF(center_deleted))

/datum/circle_grid_source/proc/center_moved(datum/source)
	SIGNAL_HANDLER
	refresh_cells()

/datum/circle_grid_source/proc/center_deleted(datum/source)
	SIGNAL_HANDLER
	set_center(null)

/datum/circle_grid_source/proc/refresh_cells()
	if(!current_locs)
		add_to_cells()
		return
	var/list/old_locs = current_locs
	current_locs = get_useful_locs()
	for(var/obj/effect/abstract/dummy_grid_source/past_location as anything in old_locs - current_locs)
		past_location.remove_from_contents(source, spatial_type)
	for(var/obj/effect/abstract/dummy_grid_source/new_location as anything in current_locs - old_locs)
		new_location.add_to_contents(source, spatial_type)

/datum/circle_grid_source/proc/get_useful_locs()
	var/list/useful_locs = list()
	var/turf/center_turf = get_turf(center)
	if(!center_turf)
		return useful_locs
	// We care about the bottom left edge of every cell in our radius
	for(var/x in GET_SPATIAL_INDEX(center_turf.x - radius) to GET_SPATIAL_INDEX(center_turf.x + radius))
		for(var/y in GET_SPATIAL_INDEX(center_turf.y - radius) to GET_SPATIAL_INDEX(center_turf.y + radius))
			useful_locs += GLOB.dummy_grid_atoms[center_turf.z][x][y]
	return useful_locs

/datum/circle_grid_source/proc/add_to_cells()
	current_locs = get_useful_locs()
	for(var/obj/effect/abstract/dummy_grid_source/new_location as anything in current_locs)
		new_location.add_to_contents(source, spatial_type)

/datum/circle_grid_source/proc/remove_from_cells()
	for(var/obj/effect/abstract/dummy_grid_source/past_location as anything in current_locs)
		past_location.remove_from_contents(source, spatial_type)
	current_locs = null
