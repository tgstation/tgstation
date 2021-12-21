///Atom that manages and controls multiple planes. It's an atom so we can hook into add_filter etc. Multiple controllers can control one plane.
/atom/movable/plane_master_controller
	///List of planes in this controllers control. Initially this is a normal list, but becomes an assoc list of plane numbers as strings | plane instance
	var/list/controlled_planes = list()
	///hud that owns this controller
	var/datum/hud/owner_hud

INITIALIZE_IMMEDIATE(/atom/movable/plane_master_controller)

///Ensures that all the planes are correctly in the controlled_planes list.
/atom/movable/plane_master_controller/Initialize(mapload, datum/hud/hud)
	. = ..()
	if(!istype(hud))
		return

	owner_hud = hud
	var/assoc_controlled_planes = list()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/instance = owner_hud.plane_masters["[i]"]
		if(!instance) //If we looked for a hud that isn't instanced, just keep going
			stack_trace("[i] isn't a valid plane master layer for [owner_hud.type], are you sure it exists in the first place?")
			continue
		assoc_controlled_planes["[i]"] = instance
	controlled_planes = assoc_controlled_planes

///Full override so we can just use filterrific
/atom/movable/plane_master_controller/add_filter(name, priority, list/params)
	. = ..()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.add_filter(name, priority, params)

///Full override so we can just use filterrific
/atom/movable/plane_master_controller/remove_filter(name_or_names)
	. = ..()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.remove_filter(name_or_names)

/atom/movable/plane_master_controller/update_filters()
	. = ..()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.update_filters()

///Gets all filters for this controllers plane masters
/atom/movable/plane_master_controller/proc/get_filters(name)
	. = list()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		. += pm_iterator.get_filter(name)

///Transitions all filters owned by this plane master controller
/atom/movable/plane_master_controller/transition_filter(name, time, list/new_params, easing, loop)
	. = ..()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.transition_filter(name, time, new_params, easing, loop)

///Full override so we can just use filterrific
/atom/movable/plane_master_controller/add_atom_colour(coloration, colour_priority)
	. = ..()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.add_atom_colour(coloration, colour_priority)


///Removes an instance of colour_type from the atom's atom_colours list
/atom/movable/plane_master_controller/remove_atom_colour(colour_priority, coloration)
	. = ..()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.remove_atom_colour(colour_priority, coloration)


///Resets the atom's color to null, and then sets it to the highest priority colour available
/atom/movable/plane_master_controller/update_atom_colour()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.update_atom_colour()


/atom/movable/plane_master_controller/game
	name = PLANE_MASTERS_GAME
	controlled_planes = list(
		FLOOR_PLANE,
		GAME_PLANE,
		GAME_PLANE_FOV_HIDDEN,
		ABOVE_GAME_PLANE,
		MASSIVE_OBJ_PLANE,
		GHOST_PLANE,
		POINT_PLANE,
		LIGHTING_PLANE,
	)


