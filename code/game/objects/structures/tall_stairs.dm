/obj/structure/tall_stairs
	name = "stairs"
	icon = 'icons/obj/structures_tall.dmi'
	icon_state = "stairs_start"
	anchored = TRUE
	move_resist = INFINITY

	/// Our paired stairs, used for tracking destruction
	var/obj/structure/tall_stairs/paired
	/// Should we destroy our paired stairs?
	var/destroy_paired = TRUE

/obj/structure/tall_stairs/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/climb_walkable)
	locate_pair()

/obj/structure/tall_stairs/proc/locate_pair()
	return

/obj/structure/tall_stairs/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if (!isnull(paired))
		paired.paired = null
		paired = null
	locate_pair()

/obj/structure/tall_stairs/Destroy(force)
	. = ..()
	if (!QDELETED(paired) && destroy_paired)
		paired.destroy_paired = FALSE
		QDEL_NULL(paired)

/obj/structure/tall_stairs/start
	icon_state = "stairs_start"

/obj/structure/tall_stairs/start/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/elevation, pixel_shift = 8)

/obj/structure/tall_stairs/start/locate_pair()
	if (paired)
		return
	paired = locate(/obj/structure/tall_stairs/end) in get_step(src, dir)
	if (paired)
		paired.paired = src

/obj/structure/tall_stairs/end
	icon_state = "stairs_end"

/obj/structure/tall_stairs/end/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/elevation, pixel_shift = 20)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/tall_stairs/end/intercept_zImpact(list/falling_movables, levels = 1)
	. = ..()
	if (levels > 1)
		return
	for(var/mob/living/fallen_mob in falling_movables)
		if (fallen_mob.get_timed_status_effect_duration(/datum/status_effect/staggered) || HAS_TRAIT(fallen_mob, TRAIT_WADDLING) && prob(5))
			addtimer(CALLBACK(src, PROC_REF(flop), fallen_mob), 1)

	. |= FALL_INTERCEPTED | FALL_NO_MESSAGE | FALL_RETAIN_PULL

/obj/structure/tall_stairs/end/proc/flop(mob/living/fallen_mob)
	var/turf/target_turf = get_step(get_step(src, REVERSE_DIR(dir)), REVERSE_DIR(dir))
	fallen_mob.throw_at(target_turf, 2, 1, spin = TRUE)
	fallen_mob.visible_message(span_warning("[fallen_mob] falls down [src]!"), span_userdanger("You painfully fall down [src]!"))
	fallen_mob.Knockdown(5 SECONDS)
	fallen_mob.apply_damage(5, BRUTE)

/obj/structure/tall_stairs/end/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving == src)
		return

	if(isobserver(leaving))
		return

	if (direction & dir)
		leaving.set_currently_z_moving(CURRENTLY_Z_ASCENDING)
		INVOKE_ASYNC(src, PROC_REF(stair_ascend), leaving)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

	if (!isliving(leaving) || (!isnull(paired) && get_turf(paired) == get_step(src, direction)))
		return

	var/mob/living/loser = leaving
	var/graceful_landing = FALSE
	if(!loser.incapacitated(IGNORE_RESTRAINTS))
		var/obj/item/organ/external/wings/gliders = loser.get_organ_by_type(/obj/item/organ/external/wings)
		if(HAS_TRAIT(loser, TRAIT_FREERUNNING) || gliders?.can_soften_fall())
			graceful_landing = HAS_TRAIT(loser, TRAIT_CATLIKE_GRACE)

	if(graceful_landing)
		loser.add_movespeed_modifier(/datum/movespeed_modifier/landed_on_feet)
		addtimer(CALLBACK(loser, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/landed_on_feet), 2 SECONDS)
		new /obj/effect/temp_visual/mook_dust/small(get_step(src, direction))
	else
		loser.Knockdown(3 SECONDS)

	loser.visible_message(span_warning("[loser] falls from [src]!"), span_warning("You fall from [src]!"))

/obj/structure/tall_stairs/end/proc/stair_ascend(atom/movable/climber)
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

/obj/structure/tall_stairs/end/locate_pair()
	if (paired)
		return
	paired = locate(/obj/structure/tall_stairs/start) in get_step(src, REVERSE_DIR(dir))
	if (paired)
		paired.paired = src

/obj/structure/tall_stairs/end/CanAllowThrough(atom/movable/mover, border_dir)
	if (isnull(paired) || get_turf(mover) != get_turf(paired))
		return FALSE
	return ..()

/obj/structure/tall_stairs/small
	icon_state = "stairs_small"
	destroy_paired = FALSE

MAPPING_DIRECTIONAL_HELPERS_EMPTY(/obj/structure/tall_stairs/start)
MAPPING_DIRECTIONAL_HELPERS_EMPTY(/obj/structure/tall_stairs/end)
MAPPING_DIRECTIONAL_HELPERS_EMPTY(/obj/structure/tall_stairs/small)
