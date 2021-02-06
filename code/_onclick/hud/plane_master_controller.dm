///Atom that manages and controls multiple planes. It's an atom so we can hook into add_filter etc. Multiple controllers can control one plane.
/datum/plane_master_controller
	///Identifier to use as assoc key
	var/name
	///List of planes in this controllers control. Initially this is a normal list, but becomes an assoc list of plane numbers as strings | plane instance
	var/list/controlled_planes = list()
	///hud that owns this controller
	var/datum/hud/owner_hud

///Ensures that all the planes are correctly in the controlled_planes list.
/datum/plane_master_controller/New(hud)
	. = ..()
	owner_hud = hud
	var/assoc_controlled_planes = list()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/instance = owner_hud.plane_masters["[i]"]
		assoc_controlled_planes["[i]"] = instance
	controlled_planes = assoc_controlled_planes

///Full override so we can just use filterrific
/datum/plane_master_controller/proc/add_filter(name, priority, list/params)
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.add_filter(name, priority, params)

///Full override so we can just use filterrific
/datum/plane_master_controller/proc/remove_filter(name_or_names)
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.remove_filter(name_or_names)


///Full override so we can just use filterrific
/datum/plane_master_controller/proc/add_atom_colour(coloration, colour_priority)
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.add_atom_colour(coloration, colour_priority)


///Removes an instance of colour_type from the atom's atom_colours list
/datum/plane_master_controller/proc/remove_atom_colour(colour_priority, coloration)
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.remove_atom_colour(colour_priority, coloration)


///Resets the atom's color to null, and then sets it to the highest priority colour available
/datum/plane_master_controller/proc/update_atom_colour()
	for(var/i in controlled_planes)
		var/atom/movable/screen/plane_master/pm_iterator = controlled_planes[i]
		pm_iterator.update_atom_colour()


/datum/plane_master_controller/game
	name = PLANE_MASTERS_GAME
	controlled_planes = list(FLOOR_PLANE, GAME_PLANE, LIGHTING_PLANE, EMISSIVE_PLANE, EMISSIVE_UNBLOCKABLE_PLANE)


