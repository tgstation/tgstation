///The base color of light space emits
GLOBAL_VAR_INIT(base_starlight_color, default_starlight_color())
///The color of light space is currently emitting
GLOBAL_VAR_INIT(starlight_color, default_starlight_color())
/proc/default_starlight_color()
	var/turf/open/space/read_from = /turf/open/space
	return initial(read_from.light_color)

///The range of the light space is displaying
GLOBAL_VAR_INIT(starlight_range, default_starlight_range())
/proc/default_starlight_range()
	var/turf/open/space/read_from = /turf/open/space
	return initial(read_from.light_range)

///The power of the light space is throwin out
GLOBAL_VAR_INIT(starlight_power, default_starlight_power())
/proc/default_starlight_power()
	var/turf/open/space/read_from = /turf/open/space
	return initial(read_from.light_power)

/proc/set_base_starlight(star_color = null, range = null, power = null)
	GLOB.base_starlight_color = star_color
	set_starlight(star_color, range, power)

/proc/set_starlight(star_color = null, range = null, power = null)
	if(isnull(star_color))
		star_color = GLOB.starlight_color
	var/old_star_color = GLOB.starlight_color
	GLOB.starlight_color = star_color
	// set light color on all lit turfs
	for(var/turf/open/space/spess as anything in GLOB.starlight)
		spess.set_light(l_range = range, l_power = power, l_color = star_color)

	if(star_color == old_star_color)
		return

	// Update the base overlays
	for(var/obj/light as anything in GLOB.starlight_objects)
		light.color = star_color
	// Send some signals that'll update everything that uses the color
	SEND_GLOBAL_SIGNAL(COMSIG_STARLIGHT_COLOR_CHANGED, old_star_color, star_color)

GLOBAL_LIST_EMPTY(starlight)

/turf/open/space
	icon = 'icons/turf/space.dmi'
	icon_state = "space"
	name = "\proper space"
	overfloor_placed = FALSE
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	rust_resistance = RUST_RESISTANCE_ABSOLUTE

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

	var/destination_z
	var/destination_x
	var/destination_y

	var/static/datum/gas_mixture/immutable/space/space_gas = new
	// We do NOT want atmos adjacent turfs
	init_air = FALSE
	run_later = TRUE
	plane = PLANE_SPACE
	layer = SPACE_LAYER
	light_power = 1
	light_range = 2
	light_color = COLOR_STARLIGHT
	light_height = LIGHTING_HEIGHT_SPACE
	light_on = FALSE
	space_lit = TRUE
	bullet_bounce_sound = null
	vis_flags = VIS_INHERIT_ID //when this be added to vis_contents of something it be associated with something on clicking, important for visualisation of turf in openspace and interraction with openspace that show you turf.

	force_no_gravity = TRUE

/turf/open/space/basic/New() //Do not convert to Initialize
	SHOULD_CALL_PARENT(FALSE)
	//This is used to optimize the map loader
	return

/turf/open/space/Destroy()
	GLOB.starlight -= src
	return ..()

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/turf/open/space/attack_ghost(mob/dead/observer/user)
	if(destination_z)
		var/turf/T = locate(destination_x, destination_y, destination_z)
		user.forceMove(T)

/turf/open/space/TakeTemperature(temp)

/turf/open/space/RemoveLattice()
	return

/turf/open/space/AfterChange()
	..()
	atmos_overlay_types = null

/turf/open/space/Assimilate_Air()
	return

//IT SHOULD RETURN NULL YOU MONKEY, WHY IN TARNATION WHAT THE FUCKING FUCK
/turf/open/space/remove_air(amount)
	return null

/// Updates starlight. Called when we're unsure of a turf's starlight state
/// Returns TRUE if we succeed, FALSE otherwise
/turf/open/space/proc/update_starlight()
	for(var/t in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
		// I've got a lot of cordons near spaceturfs, be good kids
		if(isspaceturf(t) || istype(t, /turf/cordon))
			//let's NOT update this that much pls
			continue
		enable_starlight()
		return TRUE
	GLOB.starlight -= src
	set_light(l_on = FALSE)
	return FALSE

/// Turns on the stars, if they aren't already
/turf/open/space/proc/enable_starlight()
	if(!light_on)
		set_light(l_on = TRUE, l_range = GLOB.starlight_range, l_power = GLOB.starlight_power, l_color = GLOB.starlight_color)
		GLOB.starlight += src

/turf/open/space/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/turf/open/space/proc/CanBuildHere()
	if(destination_z)
		return FALSE
	return TRUE

/turf/open/space/handle_slip()
	return

/turf/open/space/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	..()
	if(!CanBuildHere())
		return
	if(istype(attacking_item, /obj/item/stack/rods))
		build_with_rods(attacking_item, user)
	else if(ismetaltile(attacking_item))
		build_with_floor_tiles(attacking_item, user)


/turf/open/space/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!arrived || src != arrived.loc)
		return

	if(destination_z && destination_x && destination_y && !arrived.pulledby && !arrived.currently_z_moving)
		var/tx = destination_x
		var/ty = destination_y
		var/turf/DT = locate(tx, ty, destination_z)
		var/itercount = 0
		while(DT.density || istype(DT.loc,/area/shuttle)) // Extend towards the center of the map, trying to look for a better place to arrive
			if (itercount++ >= 100)
				log_game("SPACE Z-TRANSIT ERROR: Could not find a safe place to land [arrived] within 100 iterations.")
				break
			if (tx < 128)
				tx++
			else
				tx--
			if (ty < 128)
				ty++
			else
				ty--
			DT = locate(tx, ty, destination_z)

		arrived.zMove(null, DT, ZMOVE_ALLOW_BUCKLED)

		var/atom/movable/current_pull = arrived.pulling
		while (current_pull)
			var/turf/target_turf = get_step(current_pull.pulledby.loc, REVERSE_DIR(current_pull.pulledby.dir)) || current_pull.pulledby.loc
			current_pull.zMove(null, target_turf, ZMOVE_ALLOW_BUCKLED)
			current_pull = current_pull.pulling


/turf/open/space/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/space/singularity_act()
	return

/turf/open/space/can_have_cabling()
	if(locate(/obj/structure/lattice/catwalk, src))
		return TRUE
	return FALSE

/turf/open/space/is_transition_turf()
	if(destination_x || destination_y || destination_z)
		return TRUE


/turf/open/space/acid_act(acidpwr, acid_volume)
	return FALSE

/turf/open/space/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	generate_space_underlay(underlay_appearance, asking_turf)
	return TRUE


/turf/open/space/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(!CanBuildHere())
		return FALSE

	if(the_rcd.mode == RCD_TURF)
		if(the_rcd.rcd_design_path == /turf/open/floor/plating/rcd)
			var/obj/structure/lattice/lattice = locate(/obj/structure/lattice, src)
			if(lattice)
				return list("delay" = 0, "cost" = 1)
			else
				return list("delay" = 0, "cost" = 3)
		else if(the_rcd.rcd_design_path == /obj/structure/lattice/catwalk)
			var/obj/structure/lattice/lattice = locate(/obj/structure/lattice, src)
			if(lattice)
				return list("delay" = 0, "cost" = 2)
			else
				return list("delay" = 0, "cost" = 4)
		else
			return FALSE

	return FALSE

/turf/open/space/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(the_rcd.mode == RCD_TURF)
		if(rcd_data["[RCD_DESIGN_PATH]"] == /turf/open/floor/plating/rcd)
			place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
		else if(rcd_data["[RCD_DESIGN_PATH]"] == /obj/structure/lattice/catwalk)
			var/obj/structure/lattice/lattice = locate(/obj/structure/lattice, src)
			if(lattice)
				qdel(lattice)
			new /obj/structure/lattice/catwalk(src)
			return TRUE
		else
			return FALSE

	return FALSE

/turf/open/space/ChangeTurf(path, list/new_baseturfs, flags)
	. = ..()
	if (!. || isspaceturf(.))
		return

	var/area/new_turf_area = get_area(.)
	if (istype(new_turf_area, /area/space) && !istype(new_turf_area, /area/space/nearstation))
		set_turf_to_area(., GLOB.areas_by_type[/area/space/nearstation])

/turf/open/space/attempt_lattice_replacement()
	var/dest_x = destination_x
	var/dest_y = destination_y
	var/dest_z = destination_z
	..()
	destination_x = dest_x
	destination_y = dest_y
	destination_z = dest_z

/turf/open/space/can_cross_safely(atom/movable/crossing)
	return HAS_TRAIT(crossing, TRAIT_SPACEWALK)

/turf/open/space/openspace
	icon = 'icons/turf/floors.dmi'
	icon_state = MAP_SWITCH("pure_white", "invisible")
	plane = TRANSPARENT_FLOOR_PLANE

/turf/open/space/openspace/Initialize(mapload) // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	if(PERFORM_ALL_TESTS(focus_only/openspace_clear) && !GET_TURF_BELOW(src))
		stack_trace("[src] was inited as openspace with nothing below it at ([x], [y], [z])")
	icon_state = "pure_white"
	// We make the assumption that the space plane will never be blacklisted, as an optimization
	if(SSmapping.max_plane_offset)
		plane = TRANSPARENT_FLOOR_PLANE - (PLANE_RANGE * SSmapping.z_level_to_plane_offset[z])
	return INITIALIZE_HINT_LATELOAD

/turf/open/space/openspace/LateInitialize()
	ADD_TURF_TRANSPARENCY(src, INNATE_TRAIT)

/turf/open/space/openspace/Destroy()
	// Signals persist through destroy, GO HOME
	var/turf/below = GET_TURF_BELOW(src)
	if(below)
		UnregisterSignal(below, COMSIG_TURF_CHANGE)
	return ..()

/turf/open/space/openspace/zAirIn()
	return TRUE

/turf/open/space/openspace/zAirOut()
	return TRUE

/turf/open/space/openspace/zPassIn(direction)
	if(direction == DOWN)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_IN_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_IN_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/space/openspace/zPassOut(direction)
	if(direction == DOWN)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_OUT_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/contained_object in contents)
			if(contained_object.obj_flags & BLOCK_Z_OUT_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/space/openspace/enable_starlight()
	var/turf/below = GET_TURF_BELOW(src)
	// Override = TRUE beacuse we could have our starlight updated many times without a failure, which'd trigger this
	RegisterSignal(below, COMSIG_TURF_CHANGE, PROC_REF(on_below_change), override = TRUE)
	if(!isspaceturf(below) || light_on)
		return
	set_light(l_on = TRUE, l_range = GLOB.starlight_range, l_power = GLOB.starlight_power, l_color = GLOB.starlight_color)
	GLOB.starlight += src

/turf/open/space/openspace/update_starlight()
	. = ..()
	if(.)
		return
	// If we're here, the starlight is not to be
	var/turf/below = GET_TURF_BELOW(src)
	UnregisterSignal(below, COMSIG_TURF_CHANGE)

/turf/open/space/openspace/proc/on_below_change(turf/source, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	if(isspaceturf(source) && !ispath(path, /turf/open/space))
		GLOB.starlight += src
		set_light(l_on = TRUE, l_range = GLOB.starlight_range, l_power = GLOB.starlight_power, l_color = GLOB.starlight_color)
	else if(!isspaceturf(source) && ispath(path, /turf/open/space))
		GLOB.starlight -= src
		set_light(l_on = FALSE)

/turf/open/space/replace_floor(turf/open/new_floor_path, flags)
	if (!initial(new_floor_path.overfloor_placed))
		ChangeTurf(new_floor_path, flags = flags)
		return
	// Create plating under tiled floor we try to create directly onto space
	place_on_top(/turf/open/floor/plating, flags = flags)
	place_on_top(new_floor_path, flags = flags)
