///Atom that manages and controls multiple planes. It's an atom so we can hook into add_filter etc. Multiple controllers can control one plane.
/atom/movable/plane_master_controller
	///List of planes as defines in this controllers control
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

/atom/movable/plane_master_controller/proc/get_planes()
	var/returned_planes = list()
	for(var/true_plane in controlled_planes)
		returned_planes += get_true_plane(true_plane)
	return returned_planes

/atom/movable/plane_master_controller/proc/get_true_plane(true_plane)
	var/list/returned_planes = owner_hud.get_true_plane_masters(true_plane)
	if(!length(returned_planes)) //If we looked for a hud that isn't instanced, just keep going
		stack_trace("[plane] isn't a valid plane master layer for [owner_hud.type], are you sure it exists in the first place?")
		return

	return returned_planes

///Full override so we can just use filterrific
/atom/movable/plane_master_controller/add_filter(name, priority, list/params)
	. = ..()
	for(var/atom/movable/screen/plane_master/pm_iterator as anything in get_planes())
		pm_iterator.add_filter(name, priority, params)

///Full override so we can just use filterrific
/atom/movable/plane_master_controller/remove_filter(name_or_names)
	. = ..()
	for(var/atom/movable/screen/plane_master/pm_iterator as anything in get_planes())
		pm_iterator.remove_filter(name_or_names)

/atom/movable/plane_master_controller/update_filters()
	. = ..()
	for(var/atom/movable/screen/plane_master/pm_iterator as anything in get_planes())
		pm_iterator.update_filters()

///Gets all filters for this controllers plane masters
/atom/movable/plane_master_controller/proc/get_filters(name)
	. = list()
	for(var/atom/movable/screen/plane_master/pm_iterator as anything in get_planes())
		. += pm_iterator.get_filter(name)

///Transitions all filters owned by this plane master controller
/atom/movable/plane_master_controller/transition_filter(name, time, list/new_params, easing, loop)
	. = ..()
	for(var/atom/movable/screen/plane_master/pm_iterator as anything in get_planes())
		pm_iterator.transition_filter(name, time, new_params, easing, loop)

///Full override so we can just use filterrific
/atom/movable/plane_master_controller/add_atom_colour(coloration, colour_priority)
	. = ..()
	for(var/atom/movable/screen/plane_master/pm_iterator as anything in get_planes())
		pm_iterator.add_atom_colour(coloration, colour_priority)


///Removes an instance of colour_type from the atom's atom_colours list
/atom/movable/plane_master_controller/remove_atom_colour(colour_priority, coloration)
	. = ..()
	for(var/atom/movable/screen/plane_master/pm_iterator as anything in get_planes())
		pm_iterator.remove_atom_colour(colour_priority, coloration)


///Resets the atom's color to null, and then sets it to the highest priority colour available
/atom/movable/plane_master_controller/update_atom_colour()
	for(var/atom/movable/screen/plane_master/pm_iterator as anything in get_planes())
		pm_iterator.update_atom_colour()


/atom/movable/plane_master_controller/game
	name = PLANE_MASTERS_GAME
	controlled_planes = list(
		FLOOR_PLANE,
		RENDER_PLANE_TRANSPARENT,
		GAME_PLANE,
		GAME_PLANE_FOV_HIDDEN,
		GAME_PLANE_UPPER,
		GAME_PLANE_UPPER_FOV_HIDDEN,
		ABOVE_GAME_PLANE,
		MASSIVE_OBJ_PLANE,
		GHOST_PLANE,
		POINT_PLANE,
		LIGHTING_PLANE,
		AREA_PLANE,
	)

/// Controller of all planes we're ok with changing with colorblind logic
/atom/movable/plane_master_controller/colorblind
	name = PLANE_MASTERS_COLORBLIND
	controlled_planes = list(
		PLANE_SPACE_PARALLAX,
		GRAVITY_PULSE_PLANE,
		FLOOR_PLANE,
		GAME_PLANE,
		GAME_PLANE_FOV_HIDDEN,
		GAME_PLANE_UPPER,
		GAME_PLANE_UPPER_FOV_HIDDEN,
		SEETHROUGH_PLANE,
		ABOVE_GAME_PLANE,
		MASSIVE_OBJ_PLANE,
		GHOST_PLANE,
		POINT_PLANE,
		LIGHTING_PLANE,
		O_LIGHTING_VISUAL_PLANE,
		ABOVE_LIGHTING_PLANE,
		CAMERA_STATIC_PLANE,
		PIPECRAWL_IMAGES_PLANE,
		HIGH_GAME_PLANE,
		FULLSCREEN_PLANE,
		RUNECHAT_PLANE,
		HUD_PLANE,
		ABOVE_HUD_PLANE,
		AREA_PLANE,
	)

