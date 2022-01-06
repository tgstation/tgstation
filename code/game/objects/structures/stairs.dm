#define STAIR_TERMINATOR_AUTOMATIC 0
#define STAIR_TERMINATOR_NO 1
#define STAIR_TERMINATOR_YES 2

// dir determines the direction of travel to go upwards
// stairs require /turf/open/openspace as the tile above them to work, unless your stairs have 'force_open_above' set to TRUE
// multiple stair objects can be chained together; the Z level transition will happen on the final stair object in the chain

/obj/structure/stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	anchored = TRUE

	var/force_open_above = FALSE // replaces the turf above this stair obj with /turf/open/openspace
	var/terminator_mode = STAIR_TERMINATOR_AUTOMATIC
	var/turf/listeningTo

/obj/structure/stairs/north
	dir = NORTH

/obj/structure/stairs/south
	dir = SOUTH

/obj/structure/stairs/east
	dir = EAST

/obj/structure/stairs/west
	dir = WEST

/obj/structure/stairs/Initialize(mapload)
	if(force_open_above)
		force_open_above()
		build_signal_listener()
	update_surrounding()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = .proc/on_exit,
	)

	AddElement(/datum/element/connect_loc, loc_connections)

	return ..()

/obj/structure/stairs/Destroy()
	listeningTo = null
	return ..()

/obj/structure/stairs/Move() //Look this should never happen but...
	. = ..()
	if(force_open_above)
		build_signal_listener()
	update_surrounding()

/obj/structure/stairs/proc/update_surrounding()
	update_appearance()
	for(var/i in GLOB.cardinals)
		var/turf/T = get_step(get_turf(src), i)
		var/obj/structure/stairs/S = locate() in T
		if(S)
			S.update_appearance()

/obj/structure/stairs/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return //Let's not block ourselves.

	if(!isobserver(leaving) && isTerminator() && direction == dir)
		leaving.set_currently_z_moving(CURRENTLY_Z_ASCENDING)
		INVOKE_ASYNC(src, .proc/stair_ascend, leaving)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/stairs/CanPass(atom/movable/AM, border_dir) //TODOKYLER: check if this works
	if(isTerminator() && (border_dir == dir))
		return FALSE
	return ..()

/obj/structure/stairs/update_icon_state()
	icon_state = "stairs[isTerminator() ? "_t" : null]"
	return ..()

/obj/structure/stairs/proc/stair_ascend(atom/movable/climber)
	var/turf/checking = get_step_multiz(get_turf(src), UP)
	if(!istype(checking))
		return
	if(!checking.zPassIn(climber, UP, get_turf(src)))
		return
	var/turf/target = get_step_multiz(get_turf(src), (dir|UP))
	if(istype(target) && !climber.can_z_move(DOWN, target, z_move_flags = ZMOVE_FALL_FLAGS)) //Don't throw them into a tile that will just dump them back down.
		climber.zMove(target = target, z_move_flags = ZMOVE_STAIRS_FLAGS)
		/// Moves anything that's being dragged by src or anything buckled to it to the stairs turf.
		climber.pulling?.move_from_pull(climber, loc, climber.glide_size)
		for(var/mob/living/buckled as anything in climber.buckled_mobs)
			buckled.pulling?.move_from_pull(buckled, loc, buckled.glide_size)


/obj/structure/stairs/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, force_open_above))
		return
	if(!var_value)
		if(listeningTo)
			UnregisterSignal(listeningTo, COMSIG_TURF_MULTIZ_NEW)
			listeningTo = null
	else
		build_signal_listener()
		force_open_above()

/obj/structure/stairs/proc/build_signal_listener()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_TURF_MULTIZ_NEW)
	var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
	RegisterSignal(T, COMSIG_TURF_MULTIZ_NEW, .proc/on_multiz_new)
	listeningTo = T

/obj/structure/stairs/proc/force_open_above()
	var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
	if(T && !istype(T))
		T.ChangeTurf(/turf/open/openspace, flags = CHANGETURF_INHERIT_AIR)

/obj/structure/stairs/proc/on_multiz_new(turf/source, dir)
	SIGNAL_HANDLER

	if(dir == UP)
		var/turf/open/openspace/T = get_step_multiz(get_turf(src), UP)
		if(T && !istype(T))
			T.ChangeTurf(/turf/open/openspace, flags = CHANGETURF_INHERIT_AIR)

/obj/structure/stairs/intercept_zImpact(list/falling_movables, levels = 1)
	. = ..()
	if(levels == 1 && isTerminator()) // Stairs won't save you from a steep fall.
		. |= FALL_INTERCEPTED | FALL_NO_MESSAGE | FALL_RETAIN_PULL

/obj/structure/stairs/proc/isTerminator() //If this is the last stair in a chain and should move mobs up
	if(terminator_mode != STAIR_TERMINATOR_AUTOMATIC)
		return (terminator_mode == STAIR_TERMINATOR_YES)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	var/turf/them = get_step(T, dir)
	if(!them)
		return FALSE
	for(var/obj/structure/stairs/S in them)
		if(S.dir == dir)
			return FALSE
	return TRUE
