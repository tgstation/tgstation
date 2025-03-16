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
	move_resist = INFINITY

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

/obj/structure/stairs/wood
	icon_state = "stairs_wood"

/obj/structure/stairs/stone
	icon_state = "stairs_stone"

/obj/structure/stairs/material
	icon_state = "stairs_material"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/obj/structure/stairs/Initialize(mapload)
	GLOB.stairs += src
	if(force_open_above)
		force_open_above()
		build_signal_listener()
	update_surrounding()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

	return ..()

/obj/structure/stairs/Destroy()
	listeningTo = null
	GLOB.stairs -= src
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
		INVOKE_ASYNC(src, PROC_REF(stair_ascend), leaving)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/stairs/Cross(atom/movable/AM)
	if(isTerminator() && (get_dir(src, AM) == dir))
		return FALSE
	return ..()

/obj/structure/stairs/proc/stair_ascend(atom/movable/climber)
	var/turf/checking = get_step_multiz(get_turf(src), UP)
	if(!istype(checking))
		return
	// I'm only interested in if the pass is unobstructed, not if the mob will actually make it
	if(!climber.can_z_move(UP, get_turf(src), checking, z_move_flags = ZMOVE_ALLOW_BUCKLED))
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
	RegisterSignal(T, COMSIG_TURF_MULTIZ_NEW, PROC_REF(on_multiz_new))
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

/obj/structure/stairs_frame
	name = "stairs frame"
	desc = "Everything you need to call something a staircase, aside from the stuff you actually step on."
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs_frame"
	density = FALSE
	anchored = FALSE
	/// What type of stack will this drop on deconstruction?
	var/frame_stack = /obj/item/stack/rods
	/// How much of frame_stack should this drop on deconstruction?
	var/frame_stack_amount = 10

/obj/structure/stairs_frame/wood
	name = "wooden stairs frame"
	desc = "Everything you need to build a staircase, minus the actual stairs, this one is made of wood."
	frame_stack = /obj/item/stack/sheet/mineral/wood

/obj/structure/stairs_frame/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/structure/stairs_frame/examine(mob/living/carbon/human/user)
	. = ..()
	if(anchored)
		. += span_notice("The frame is anchored and can be made into proper stairs with 10 sheets of material.")
	else
		. += span_notice("The frame will need to be secured with a wrench before it can be completed.")

/obj/structure/stairs_frame/wrench_act(mob/living/user, obj/item/used_tool)
	user.balloon_alert_to_viewers("securing stairs frame", "securing frame")
	used_tool.play_tool_sound(src)
	if(!used_tool.use_tool(src, user, 3 SECONDS))
		return TRUE
	if(anchored)
		anchored = FALSE
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		return TRUE
	anchored = TRUE
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	return TRUE

/obj/structure/stairs_frame/wrench_act_secondary(mob/living/user, obj/item/used_tool)
	to_chat(user, span_notice("You start disassembling [src]..."))
	used_tool.play_tool_sound(src)
	if(!used_tool.use_tool(src, user, 3 SECONDS))
		return TRUE
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	deconstruct(TRUE)
	return TRUE

/obj/structure/stairs_frame/atom_deconstruct(disassembled = TRUE)
	new frame_stack(get_turf(src), frame_stack_amount)

/obj/structure/stairs_frame/attackby(obj/item/attacked_by, mob/user, list/modifiers)
	if(!isstack(attacked_by))
		return ..()
	if(!anchored)
		user.balloon_alert(user, "secure frame first")
		return TRUE
	var/obj/item/stack/material = attacked_by
	if(material.stairs_type)
		if(material.get_amount() < 10)
			to_chat(user, span_warning("You need ten [material.name] sheets to do this!"))
			return
		if(locate(/obj/structure/stairs) in loc)
			to_chat(user, span_warning("There's already stairs built here!"))
			return
		to_chat(user, span_notice("You start adding [material] to [src]..."))
		if(!do_after(user, 10 SECONDS, target = src) || !material.use(10) || (locate(/obj/structure/table) in loc))
			return
		make_new_stairs(material.stairs_type)
	else if(istype(material, /obj/item/stack/sheet))
		if(material.get_amount() < 10)
			to_chat(user, span_warning("You need ten sheets to do this!"))
			return
		if(locate(/obj/structure/stairs) in loc)
			to_chat(user, span_warning("There's already stairs built here!"))
			return
		to_chat(user, span_notice("You start adding [material] to [src]..."))
		if(!do_after(user, 10 SECONDS, target = src) || !material.use(10) || (locate(/obj/structure/table) in loc))
			return
		var/list/material_list = list()
		if(material.material_type)
			material_list[material.material_type] = SHEET_MATERIAL_AMOUNT * 10
		make_new_stairs(/obj/structure/stairs/material, material_list)
	return TRUE

/obj/structure/stairs_frame/proc/make_new_stairs(stairs_type, custom_materials)
	var/obj/structure/stairs/new_stairs = new stairs_type(loc)
	new_stairs.setDir(dir)
	if(custom_materials)
		new_stairs.set_custom_materials(custom_materials)
	qdel(src)

#undef STAIR_TERMINATOR_AUTOMATIC
#undef STAIR_TERMINATOR_NO
#undef STAIR_TERMINATOR_YES
