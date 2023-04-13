/datum/action/cooldown/spell/conjure/cosmic_expansion
	name = "Cosmic Expansion"
	desc = "This spell generates a 3x3 domain of cosmic fields. \
		Creatures up to 7 tiles away will also recieve a star mark."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cosmic_domain"

	sound = 'sound/magic/cosmic_expansion.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "C'SM'S 'XP'ND"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	summon_amount = 9
	summon_radius = 1
	summon_type = list(/obj/effect/forcefield/cosmic_field)
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 7
	/// Effect for when the spell triggers
	var/obj/effect/expansion_effect = /obj/effect/temp_visual/cosmic_domain
	/// If the heretic is ascended or not
	var/ascended = FALSE

/datum/action/cooldown/spell/conjure/cosmic_expansion/cast(mob/living/cast_on)
	new expansion_effect(get_turf(cast_on))
	for(var/mob/living/nearby_mob in range(star_mark_range, cast_on))
		if(cast_on == nearby_mob)
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)
	if (ascended)
		for(var/turf/cast_turf as anything in get_turfs(get_turf(cast_on)))
			new /obj/effect/forcefield/cosmic_field(cast_turf)
	return ..()

/datum/action/cooldown/spell/conjure/cosmic_expansion/proc/get_turfs(turf/target_turf)
	return list(
		get_far_step(target_turf, NORTH),
		get_further_step(target_turf, NORTH),
		get_far_step(target_turf, SOUTH),
		get_further_step(target_turf, SOUTH),
		get_far_step(target_turf, EAST),
		get_further_step(target_turf, EAST),
		get_far_step(target_turf, WEST),
		get_further_step(target_turf, WEST))

/datum/action/cooldown/spell/conjure/cosmic_expansion/proc/get_far_step(turf/target_turf, direction)
	return get_step(get_step(target_turf, direction), direction)

/datum/action/cooldown/spell/conjure/cosmic_expansion/proc/get_further_step(turf/target_turf, direction)
	return get_step(get_step(get_step(target_turf, direction), direction), direction)
