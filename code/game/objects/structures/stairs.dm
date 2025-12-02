#define STAIR_TERMINATOR_AUTOMATIC 0
#define STAIR_TERMINATOR_NO 1
#define STAIR_TERMINATOR_YES 2

/// Range within which stair indicators will appear for approaching mobs
#define STAIR_INDICATOR_RANGE 3

// dir determines the direction of travel to go upwards
// stairs require /turf/open/openspace as the tile above them to work, unless your stairs have 'force_open_above' set to TRUE
// multiple stair objects can be chained together; the Z level transition will happen on the final stair object in the chain

/obj/structure/stairs
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	base_icon_state = "stairs"
	anchored = TRUE
	move_resist = INFINITY
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER

	/// If TRUE replaces the turf above this stair obj with /turf/open/openspace
	var/force_open_above = FALSE
	/// Determines if this stair is the last in a "chain" of stairs, ie next step is upstairs
	VAR_FINAL/terminator_mode = STAIR_TERMINATOR_AUTOMATIC
	/// Upstairs turf. Is observed for changes if force_open_above is TRUE (to re-open if necessary)
	VAR_FINAL/turf/directly_above
	/// If TRUE, we have left/middle/right sprites.
	var/has_merged_sprites = TRUE
	/// Lazyassoc list of weakef to mob viewing stair indicators to their images
	VAR_PRIVATE/list/mob_to_image

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
	has_merged_sprites = FALSE

/obj/structure/stairs/stone
	icon_state = "stairs_stone"
	has_merged_sprites = FALSE

/obj/structure/stairs/material
	icon_state = "stairs_material"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	has_merged_sprites = FALSE

/obj/structure/stairs/Initialize(mapload)
	. = ..()

	GLOB.stairs += src
	if(force_open_above)
		force_open_above()
		build_signal_listener()
	update_surrounding()

	var/static/list/exit_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit_stairs),
	)

	AddElement(/datum/element/connect_loc, exit_connections)

	var/static/list/range_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_enter_range),
		COMSIG_ATOM_EXITED = PROC_REF(on_exit_range),
	)
	AddComponent(/datum/component/connect_range, tracked = src, connections = range_connections, range = STAIR_INDICATOR_RANGE)


/obj/structure/stairs/Destroy()
	if(directly_above)
		UnregisterSignal(directly_above, COMSIG_TURF_MULTIZ_NEW)
		directly_above = null
	for(var/climber_ref in mob_to_image)
		clear_climber_image(climber_ref, instant = TRUE)
	GLOB.stairs -= src
	return ..()

/obj/structure/stairs/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change) //Look this should never happen but...
	. = ..()
	if(force_open_above)
		build_signal_listener()
	update_surrounding()

/// Updates the sprite and the sprites of neighboring stairs to reflect merged sprites
/obj/structure/stairs/proc/update_surrounding()
	if(!has_merged_sprites)
		return

	update_appearance()

	for(var/obj/structure/stairs/stair in get_step(src, turn(dir, 90)))
		stair.update_appearance()

	for(var/obj/structure/stairs/stair in get_step(src, turn(dir, -90)))
		stair.update_appearance()

/obj/structure/stairs/update_icon_state()
	. = ..()
	if(!has_merged_sprites)
		return

	var/has_left_stairs = FALSE
	var/has_right_stairs = FALSE
	for(var/obj/structure/stairs/stair in get_step(src, turn(dir, 90)))
		if(stair.dir == dir)
			has_left_stairs = TRUE
			break

	for(var/obj/structure/stairs/stair in get_step(src, turn(dir, -90)))
		if(stair.dir == dir)
			has_right_stairs = TRUE
			break

	if(has_left_stairs && has_right_stairs)
		icon_state = "[base_icon_state]-m"
	else if(has_left_stairs)
		icon_state = "[base_icon_state]-r"
	else if(has_right_stairs)
		icon_state = "[base_icon_state]-l"
	else
		icon_state = base_icon_state

/obj/structure/stairs/proc/on_exit_stairs(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return //Let's not block ourselves.

	if(!isobserver(leaving) && isTerminator() && direction == dir)
		leaving.set_currently_z_moving(CURRENTLY_Z_ASCENDING)
		INVOKE_ASYNC(src, PROC_REF(stair_ascend), leaving)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

#define POINT_X_COMPONENT(pdir) ((pdir & EAST) ? 2 : ((pdir & WEST) ? -2 : 0))
#define POINT_Y_COMPONENT(pdir) ((pdir & SOUTH) ? 2 : ((pdir & NORTH) ? -2 : 0))

/obj/structure/stairs/proc/on_enter_range(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(!isliving(entered))
		return

	var/mob/living/climber = entered
	var/datum/weakref/climber_ref = WEAKREF(climber)
	if(!climber.client || !climber.client.prefs.read_preference(/datum/preference/toggle/stair_indicator))
		return
	if(climber.dir == REVERSE_DIR(dir))
		return // walking away
	if(LAZYACCESS(mob_to_image, climber_ref))
		return // already see it
	if(!(climber in viewers(STAIR_INDICATOR_RANGE + 1, src)))
		return // can't see the staircase (+1 tile for some leeway)
	if(!isopenturf(get_step_multiz(src, UP)))
		return // no place to go up to

	var/image/pointing_image = get_pointing_image()
	climber.client.images += pointing_image
	pointing_image.alpha = 0
	animate(pointing_image, pixel_x = POINT_X_COMPONENT(dir), pixel_y = POINT_Y_COMPONENT(dir), time = 0.5 SECONDS, easing = SINE_EASING|EASE_OUT, loop = -1, tag = "point_xy")
	animate(pixel_x = 0, pixel_y = 0, time = 0.5 SECONDS, easing = SINE_EASING|EASE_IN)
	animate(pointing_image, alpha = 180, time = 0.75 SECONDS, tag = "point_fadein")
	LAZYSET(mob_to_image, climber_ref, pointing_image)

/obj/structure/stairs/proc/on_exit_range(datum/source, atom/movable/exited)
	SIGNAL_HANDLER

	if(!isliving(exited))
		return

	var/datum/weakref/climber_ref = WEAKREF(exited)
	if(!LAZYACCESS(mob_to_image, climber_ref))
		return // not seeing anything
	if(exited in viewers(STAIR_INDICATOR_RANGE, src))
		return // still in range and can see the staircase

	clear_climber_image(climber_ref)

/obj/structure/stairs/proc/clear_climber_image(datum/weakref/climber_ref, instant = FALSE)
	var/image/pointing_image = LAZYACCESS(mob_to_image, climber_ref)
	if(!pointing_image)
		LAZYREMOVE(mob_to_image, climber_ref) // just in case
		return
	if(instant)
		clear_climber_image_callback(climber_ref, pointing_image)
		return

	animate(pointing_image, alpha = 0, time = 0.75 SECONDS, tag = "point_fadeout")
	// note: the player won't see a new indicator until the image is fully a removed, so this timer also serves as a cooldown
	addtimer(CALLBACK(src, PROC_REF(clear_climber_image_callback), climber_ref, pointing_image), 1.5 SECONDS, TIMER_UNIQUE)

/obj/structure/stairs/proc/clear_climber_image_callback(datum/weakref/climber_ref, image/pointing_image)
	PRIVATE_PROC(TRUE)
	var/mob/living/climber = climber_ref?.resolve()
	climber?.client?.images -= pointing_image
	LAZYREMOVE(mob_to_image, climber_ref)

/obj/structure/stairs/proc/get_pointing_image()
	PROTECTED_PROC(TRUE)
	var/image/point_image = image('icons/hud/screen_gen.dmi', src, "arrow_large_white_still")
	point_image.color = COLOR_DARK_MODERATE_LIME_GREEN
	point_image.appearance_flags |= KEEP_APART
	point_image.transform = matrix().Turn(dir2angle(REVERSE_DIR(dir)))
	point_image.layer = BELOW_MOB_LAYER
	SET_PLANE(point_image, GAME_PLANE, src)
	return point_image

#undef POINT_X_COMPONENT
#undef POINT_Y_COMPONENT

/obj/structure/stairs/Cross(atom/movable/AM)
	if(isTerminator() && (get_dir(src, AM) == dir))
		return FALSE
	return ..()

/obj/structure/stairs/proc/stair_ascend(atom/movable/climber)
	var/turf/checking = get_step_multiz(src, UP)
	if(!istype(checking))
		return
	// I'm only interested in if the pass is unobstructed, not if the mob will actually make it
	if(!climber.can_z_move(UP, get_turf(src), checking, z_move_flags = ZMOVE_ALLOW_BUCKLED))
		return
	var/turf/target = get_step_multiz(src, dir|UP)
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
		if(directly_above)
			UnregisterSignal(directly_above, COMSIG_TURF_MULTIZ_NEW)
			directly_above = null
	else
		build_signal_listener()
		force_open_above()

/obj/structure/stairs/proc/build_signal_listener()
	if(directly_above)
		UnregisterSignal(directly_above, COMSIG_TURF_MULTIZ_NEW)
	var/turf/open/openspace/T = get_step_multiz(src, UP)
	RegisterSignal(T, COMSIG_TURF_MULTIZ_NEW, PROC_REF(on_multiz_new))
	directly_above = T

/obj/structure/stairs/proc/force_open_above()
	var/turf/open/openspace/T = get_step_multiz(src, UP)
	if(T && !istype(T))
		T.ChangeTurf(/turf/open/openspace, flags = CHANGETURF_INHERIT_AIR)

/obj/structure/stairs/proc/on_multiz_new(turf/source, dir)
	SIGNAL_HANDLER

	if(dir == UP)
		var/turf/open/openspace/T = get_step_multiz(src, UP)
		if(T && !istype(T))
			T.ChangeTurf(/turf/open/openspace, flags = CHANGETURF_INHERIT_AIR)

/obj/structure/stairs/intercept_zImpact(list/falling_movables, levels = 1)
	. = ..()
	// falling from a higher z level onto stairs
	if(levels != 1 || !isTerminator())
		return
	for(var/mob/living/guy in falling_movables)
		if(!can_fall_down_stairs(guy))
			continue
		to_chat(guy, span_warning("You fall down [src]!"))
		on_fall(guy)
	. |= FALL_INTERCEPTED | FALL_NO_MESSAGE | FALL_RETAIN_PULL

/// Will the passed mob tumble down the stairs instead of walking?
/obj/structure/stairs/proc/can_fall_down_stairs(mob/living/falling)
	if(falling.buckled || falling.pulledby)
		return FALSE
	if(falling.stat >= UNCONSCIOUS) // if you shove someone unconscious down the stairs, they'd probably roll
		return TRUE
	if(falling.has_status_effect(/datum/status_effect/staggered)) // off balance
		return TRUE
	return FALSE

/// What happens when a mob tumbles down the stairs
/obj/structure/stairs/proc/on_fall(mob/living/falling)
	falling.AdjustParalyzed(2 SECONDS)
	falling.adjust_staggered(2 SECONDS)
	falling.AdjustKnockdown(5 SECONDS)
	falling.spin(1 SECONDS, 0.25 SECONDS)
	falling.apply_damage(rand(4, 8), BRUTE, spread_damage = TRUE)
	GLOB.move_manager.move_towards(falling, get_ranged_target_turf(src, REVERSE_DIR(dir), 2), delay = 0.4 SECONDS, timeout = 1 SECONDS)

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
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5)
	/// What type of stack will this drop on deconstruction?
	var/frame_stack = /obj/item/stack/rods
	/// How much of frame_stack should this drop on deconstruction?
	var/frame_stack_amount = 10

/obj/structure/stairs_frame/wood
	name = "wooden stairs frame"
	desc = "Everything you need to build a staircase, minus the actual stairs. This one is made of wood."
	frame_stack = /obj/item/stack/sheet/mineral/wood
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 10)

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

/obj/structure/stairs_frame/attackby(obj/item/attacked_by, mob/user, list/modifiers, list/attack_modifiers)
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

#undef STAIR_INDICATOR_RANGE
