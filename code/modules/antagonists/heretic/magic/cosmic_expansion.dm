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

/datum/action/cooldown/spell/conjure/cosmic_expansion/cast(mob/living/cast_on)
	new expansion_effect(get_turf(cast_on))
	for(var/mob/living/nearby_mob in range(star_mark_range, cast_on))
		if(cast_on == nearby_mob)
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)
	return ..()
