/datum/action/cooldown/spell/conjure/cosmic_expansion
	name = "Cosmic Expansion"
	desc = "This spell generates a 3x3 domain of cosmic fields. \
		Creatures up to 7 tiles away will also receive a star mark."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cosmic_domain"

	sound = 'sound/magic/cosmic_expansion.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "An'gar baltil!"
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
		if(cast_on == nearby_mob || cast_on.buckled == nearby_mob)
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)
	if (ascended)
		for(var/turf/cast_turf as anything in get_turfs(get_turf(cast_on)))
			new /obj/effect/forcefield/cosmic_field(cast_turf)
	return ..()

/datum/action/cooldown/spell/conjure/cosmic_expansion/proc/get_turfs(turf/target_turf)
	var/list/target_turfs = list()
	for (var/direction as anything in GLOB.cardinals)
		target_turfs += get_ranged_target_turf(target_turf, direction, 2)
		target_turfs += get_ranged_target_turf(target_turf, direction, 3)
	return target_turfs
