/datum/action/cooldown/spell/pointed/rust_construction
	name = "Rust Formation"
	desc = "Transforms a rusted floor into a full wall of rust. Creating a wall underneath a mob will harm it."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "shield"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED

	school = SCHOOL_FORBIDDEN
	cooldown_time = 5 SECONDS

	invocation = "Someone raises a wall of rust."
	invocation_self_message = "You raise a wall of rust."
	invocation_type = INVOCATION_EMOTE
	spell_requirements = NONE

	cast_range = 4
	aim_assist = FALSE

	/// How long does the filter last on walls we make?
	var/filter_duration = 2 MINUTES

/datum/action/cooldown/spell/pointed/rust_construction/is_valid_target(atom/cast_on)
	if(!isfloorturf(cast_on))
		if(isturf(cast_on) && owner)
			cast_on.balloon_alert(owner, "not a floor!")
		return FALSE

	if(!HAS_TRAIT(cast_on, TRAIT_RUSTY))
		if(owner)
			cast_on.balloon_alert(owner, "not rusted!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/rust_construction/before_cast(turf/open/cast_on)
	. = ..()
	if(!isliving(owner))
		return

	var/mob/living/living_owner = owner
	invocation = span_danger("<b>[owner]</b> drags [owner.p_their()] hand[living_owner.usable_hands == 1 ? "":"s"] upwards as a wall of rust rises out of [cast_on]!")
	invocation_self_message = span_notice("You drag [living_owner.usable_hands == 1 ? "a hand":"your hands"] upwards as a wall of rust rises out of [cast_on].")

/datum/action/cooldown/spell/pointed/rust_construction/cast(turf/open/cast_on)
	. = ..()
	var/rises_message = "rises out of [cast_on]"
	var/turf/closed/wall/new_wall = cast_on.PlaceOnTop(/turf/closed/wall)
	if(!istype(new_wall))
		return

	playsound(new_wall, 'sound/effects/constructform.ogg', 50, TRUE)
	new_wall.rust_heretic_act()
	new_wall.name = "\improper enchanted [new_wall.name]"
	new_wall.hardness = 10
	new_wall.sheet_amount = 0
	new_wall.girder_type = null

	// I wanted to do a cool animation of a wall raising from the ground
	// but I guess a fading filter will have to do for now as walls have 0 depth (currently)
	// damn though with 3/4ths walls this'll look sick just imagine it
	new_wall.add_filter("rust_wall", 2, list("type" = "outline", "color" = "#85be299c", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(fade_wall_filter), new_wall), filter_duration * (1/20))
	addtimer(CALLBACK(src,PROC_REF(remove_wall_filter), new_wall), filter_duration)

	var/message_shown = FALSE
	for(var/mob/living/living_mob in cast_on)
		message_shown = TRUE
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == owner)
			living_mob.visible_message(
				span_warning("\A [new_wall] [rises_message] and pushes along [living_mob]!"),
				span_notice("\A [new_wall] [rises_message] beneath your feet and pushes you along!"),
			)
		else
			living_mob.visible_message(
				span_warning("\A [new_wall] [rises_message] and slams into [living_mob]!"),
				span_userdanger("\A [new_wall] [rises_message] beneath your feet and slams into you!"),
			)
			living_mob.apply_damage(10, BRUTE, wound_bonus = 10)
			living_mob.Knockdown(5 SECONDS)
		living_mob.SpinAnimation(5, 1)

		// If we're a multiz map send them to the next floor
		var/turf/above_us = get_step_multiz(cast_on, UP)
		if(above_us)
			living_mob.forceMove(above_us)
			continue

		// If we're not throw them to a nearby (open) turf
		var/list/turfs_by_us = get_adjacent_open_turfs(cast_on)
		// If there is no side by us, hardstun them
		if(!length(turfs_by_us))
			living_mob.Paralyze(5 SECONDS)
			continue

		// If there's an open turf throw them to the side
		living_mob.throw_at(pick(turfs_by_us), 1, 3, thrower = owner, spin = FALSE)

	if(!message_shown)
		new_wall.visible_message(span_warning("\A [new_wall] [rises_message]!"))

/datum/action/cooldown/spell/pointed/rust_construction/proc/fade_wall_filter(turf/closed/wall)
	if(QDELETED(wall))
		return

	var/rust_filter = wall.get_filter("rust_wall")
	if(!rust_filter)
		return

	animate(rust_filter, alpha = 0, time = filter_duration * (19/20))

/datum/action/cooldown/spell/pointed/rust_construction/proc/remove_wall_filter(turf/closed/wall)
	if(QDELETED(wall))
		return

	wall.remove_filter("rust_wall")
