// Invisible effect that doesnt exist outside of containing the prox monitor
/obj/effect/abstract/heretic_arena
	/// Proximity monitor that handles the effects we are looking for
	var/datum/proximity_monitor/advanced/heretic_arena/arena

/obj/effect/abstract/heretic_arena/Initialize(mapload, range)
	. = ..()
	arena = new(src, range)
	QDEL_IN(src, 60 SECONDS)

/obj/effect/abstract/heretic_arena/Destroy(force)
	. = ..()
	QDEL_NULL(arena)

/datum/proximity_monitor/advanced/heretic_arena
	/// List of mobs inside our arena
	var/list/contained_mobs = list()
	/// List of border walls we have placed on the edges of the monitor
	var/list/border_walls = list()
	/// List of immunities given to our combatants
	var/static/list/given_immunities = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NO_SLIP_ALL,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
		TRAIT_NO_TELEPORT,
	)

/datum/proximity_monitor/advanced/heretic_arena/New(atom/_host, range, _ignore_if_not_on_turf)
	. = ..()
	recalculate_field(full_recalc = TRUE)
	var/list/things_in_range = range(range)
	for(var/mob/living/carbon/human/human_in_range in things_in_range)
		human_in_range.add_traits(given_immunities, HERETIC_ARENA_TRAIT)
		contained_mobs += human_in_range
		if(!IS_HERETIC(human_in_range))
			var/obj/item/melee/sickly_blade/training/new_blade = new(get_turf(human_in_range))
			INVOKE_ASYNC(human_in_range, TYPE_PROC_REF(/mob, put_in_hands), new_blade)

		//XANTODO placeholder sprite
		var/mutable_appearance/new_halo_overlay = mutable_appearance('icons/mob/effects/halo.dmi', "halo[rand(1, 6)]", -HALO_LAYER)
		human_in_range.overlays_standing[HALO_LAYER] = new_halo_overlay
		human_in_range.apply_overlay(HALO_LAYER)

/datum/proximity_monitor/advanced/heretic_arena/Destroy()
	for(var/mob/living/carbon/human/mob in contained_mobs)
		mob.remove_traits(given_immunities, HERETIC_ARENA_TRAIT)
		mob.remove_overlay(HALO_LAYER)
		mob.update_body()
	for(var/turf/to_restore in border_walls)
		to_restore.ChangeTurf(border_walls[to_restore])
	return ..()

/datum/proximity_monitor/advanced/heretic_arena/setup_edge_turf(turf/target)
	. = ..()
	var/old_turf = target.type
	target.ChangeTurf(/turf/closed/indestructible/heretic_wall)
	border_walls += target
	border_walls[target] += old_turf

/datum/proximity_monitor/advanced/heretic_arena/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()

/turf/closed/indestructible/heretic_wall
	name = "eldritch wall"
	desc = "A wall? Made of something incomprehensible. You really don't want to be touching this..."
	icon = 'icons/turf/walls.dmi'
	icon_state = "eldritch_wall"
	opacity = FALSE

/turf/closed/indestructible/heretic_wall/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(isliving(bumped_atom))
		var/mob/living/living_mob = bumped_atom
		var/atom/target = get_edge_target_turf(living_mob, get_dir(src, get_step_away(living_mob, src)))
		living_mob.throw_at(target, 4, 10)
		to_chat(living_mob, span_userdanger("The wall repels you with tremendous force!"))

/*
/obj/machinery/field/proc/bump_field(atom/movable/considered_atom as mob|obj)
	if(has_shocked)
		return FALSE
	has_shocked = TRUE
	do_sparks(5, TRUE, considered_atom.loc)
	var/atom/target = get_edge_target_turf(considered_atom, get_dir(src, get_step_away(considered_atom, src)))
	if(isliving(considered_atom))
		to_chat(considered_atom, span_userdanger("The field repels you with tremendous force!"))
	playsound(src, 'sound/effects/gravhit.ogg', 50, TRUE)
	considered_atom.throw_at(target, 200, 4)
	addtimer(CALLBACK(src, PROC_REF(clear_shock)), 0.5 SECONDS)
*/


/*
/datum/proximity_monitor/advanced/heretic_arena/ona_pply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_THROW, PROC_REF(on_pre_throw))
	RegisterSignal(owner, COMSIG_MOVABLE_TELEPORTING, PROC_REF(on_teleport))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/proximity_monitor/advanced/heretic_arena/on_remove()
	UnregisterSignal(owner, list(
		COMSIG_MOVABLE_PRE_THROW,
		COMSIG_MOVABLE_TELEPORTING,
		COMSIG_MOVABLE_MOVED,
	))

	return ..()

/// Checks if the movement from moving_from to going_to leaves our [var/locked_to] area. Returns TRUE if so.
/datum/proximity_monitor/advanced/heretic_arena/proc/is_escaping_locked_area(atom/moving_from, atom/going_to)
	if(!locked_to)
		return FALSE

	// If moving_from isn't in our locked area, it means they've
	// somehow completely escaped, so we'll opt not to act on them.
	if(get_area(moving_from) != locked_to)
		return FALSE

	// If going_to is in our locked area,
	// they're just moving within the area like normal.
	if(get_area(going_to) == locked_to)
		return FALSE

	return TRUE

/// Signal proc for [COMSIG_MOVABLE_PRE_THROW] that prevents people from escaping our locked area via throw.
/datum/proximity_monitor/advanced/heretic_arena/proc/on_pre_throw(mob/living/source, list/throw_args)
	SIGNAL_HANDLER

	var/atom/throw_dest = throw_args[1]
	if(!is_escaping_locked_area(source, throw_dest))
		return

	var/mob/thrower = throw_args[4]
	if(istype(thrower))
		to_chat(thrower, span_hypnophrase("An otherworldly force prevents you from throwing [source] out of [get_area_name(locked_to)]!"))

	to_chat(source, span_hypnophrase("An otherworldly force prevents you from being thrown out of [get_area_name(locked_to)]!"))

	return COMPONENT_CANCEL_THROW

/// Signal proc for [COMSIG_MOVABLE_TELEPORTED] that blocks any teleports from our locked area.
/datum/proximity_monitor/advanced/heretic_arena/proc/on_teleport(mob/living/source, atom/destination, channel)
	SIGNAL_HANDLER

	if(!is_escaping_locked_area(source, destination))
		return

	to_chat(source, span_hypnophrase("An otherworldly force prevents your escape from [get_area_name(locked_to)]!"))

	source.Stun(1 SECONDS)
	return COMPONENT_BLOCK_TELEPORT

/// Signal proc for [COMSIG_MOVABLE_MOVED] that blocks any movement out of our locked area
/datum/proximity_monitor/advanced/heretic_arena/proc/on_move(mob/living/source, turf/old_loc, movement_dir, forced)
	SIGNAL_HANDLER

	// Let's not mess with heretics dragging a potential victim.
	if(ismob(source.pulledby) && IS_HERETIC(source.pulledby))
		return

	// If the movement's forced, just let it happen regardless.
	if(forced || !is_escaping_locked_area(old_loc, source))
		return

	to_chat(source, span_hypnophrase("An otherworldly force prevents your escape from [get_area_name(locked_to)]!"))

	var/turf/further_behind_old_loc = get_edge_target_turf(old_loc, REVERSE_DIR(movement_dir))

	source.Stun(1 SECONDS)
	source.throw_at(further_behind_old_loc, 3, 1, gentle = TRUE) // Keeping this gentle so they don't smack into the heretic max speed
*/
