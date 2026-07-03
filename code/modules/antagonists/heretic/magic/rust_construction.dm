/datum/action/cooldown/spell/pointed/rust_construction
	name = "Возведение ржавчины"
	desc = "Превращает ржавый пол в полноценную стену из ржавчины. Создание стены под целью откинет её и нанесет вред."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "shield"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED

	school = SCHOOL_FORBIDDEN
	cooldown_time = 2 SECONDS
	unset_after_click = FALSE

	// Both of these are changed in before_cast
	invocation = "Кто-то поднимает стену из ржавчины."
	invocation_self_message = "Вы поднимаете стену из ржавчины."
	invocation_type = INVOCATION_EMOTE
	spell_requirements = NONE

	cast_range = 4

	/// How long does the filter last on walls we make?
	var/filter_duration = 2 MINUTES

/**
 * Overrides 'aim assist' because we always want to hit just the turf we clicked on.
 */
/datum/action/cooldown/spell/pointed/rust_construction/aim_assist(mob/living/clicker, atom/target)
	return get_turf(target)

/datum/action/cooldown/spell/pointed/rust_construction/is_valid_target(atom/cast_on)
	if(!isturf(cast_on))
		cast_on.balloon_alert(owner, "не стена и не пол!!")
		return FALSE

	if(!HAS_TRAIT(cast_on, TRAIT_RUSTY))
		if(owner)
			cast_on.balloon_alert(owner, "не ржавый!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/rust_construction/before_cast(turf/open/cast_on)
	. = ..()
	if(!isliving(owner))
		return

	var/mob/living/living_owner = owner
	invocation = span_danger("<b>[capitalize(owner.declent_ru(NOMINATIVE))]</b> тянет свою рук[living_owner.usable_hands == 1 ? "у": "и"] вверх, когда стена ржавчины поднимается из [cast_on.declent_ru(GENITIVE)]!")
	invocation_self_message = span_notice("Вы тащите рук[living_owner.usable_hands == 1 ? "у": "и"] вверх, когда из [cast_on.declent_ru(GENITIVE)] поднимается стена ржавчины")

/datum/action/cooldown/spell/pointed/rust_construction/cast(turf/cast_on)
	. = ..()
	var/rises_message = "поднимается из [cast_on.declent_ru(GENITIVE)]"

	// If we casted at a wall we'll try to rust it. In the case of an enchanted wall it'll deconstruct it
	if(isclosedturf(cast_on))
		cast_on.visible_message(span_warning("[capitalize(cast_on.declent_ru(NOMINATIVE))] дрожит, когда ржавчина заставляет сыпаться!"))
		var/mob/living/living_owner = owner
		living_owner?.do_rust_heretic_act(cast_on)
		// ref transfers to floor
		cast_on.Shake(shake_interval = 0.1 SECONDS, duration = 0.5 SECONDS)
		// which we need to re-rust
		living_owner?.do_rust_heretic_act(cast_on)
		playsound(cast_on, 'sound/effects/bang.ogg', 50, vary = TRUE)
		return

	var/turf/closed/wall/new_wall = cast_on.place_on_top(/turf/closed/wall)
	if(!istype(new_wall))
		return

	playsound(new_wall, 'sound/effects/constructform.ogg', 50, TRUE)
	new_wall.rust_heretic_act()
	new_wall.name = "\improper enchanted [new_wall.name]"
	new_wall.AddComponent(/datum/component/torn_wall)
	new_wall.hardness = 60
	new_wall.sheet_amount = 0
	new_wall.girder_type = null

	// I wanted to do a cool animation of a wall raising from the ground
	// but I guess a fading filter will have to do for now as walls have 0 depth (currently)
	// damn though with 3/4ths walls this'll look sick just imagine it
	new_wall.add_filter("rust_wall", 2, list("type" = "outline", "color" = "#85be299c", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(fade_wall_filter), new_wall), filter_duration * 0.5)
	addtimer(CALLBACK(src, PROC_REF(remove_wall_filter), new_wall), filter_duration)

	var/message_shown = FALSE
	for(var/mob/living/living_mob in cast_on)
		message_shown = TRUE
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == owner)
			living_mob.visible_message(
				span_warning("[capitalize(new_wall.declent_ru(NOMINATIVE))] [rises_message] и толкает [living_mob.declent_ru(ACCUSATIVE)]!"),
				span_notice("[capitalize(new_wall.declent_ru(NOMINATIVE))] [rises_message] под вашими ногами и толкает вас!"),
			)
		else
			living_mob.visible_message(
				span_warning("[capitalize(new_wall.declent_ru(NOMINATIVE))] [rises_message] и врезается в [living_mob.declent_ru(ACCUSATIVE)]!"),
				span_userdanger("[capitalize(new_wall.declent_ru(NOMINATIVE))] [rises_message] под вашими ногами и врезается в вас!"),
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

	animate(rust_filter, alpha = 0, time = filter_duration * (9/20))

/datum/action/cooldown/spell/pointed/rust_construction/proc/remove_wall_filter(turf/closed/wall)
	if(QDELETED(wall))
		return

	wall.remove_filter("rust_wall")
