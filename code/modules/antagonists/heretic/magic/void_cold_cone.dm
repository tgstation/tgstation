/datum/action/cooldown/spell/cone/staggered/cone_of_cold/void
	name = "Cone of Cold"
	desc = "Shoots out a freezing cone in front of you."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "entropic_plume"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation = "FR'ZE!"
	invocation_type = INVOCATION_SHOUT

	turf_freeze_type = TURF_WET_ICE
	unfreeze_turf_duration = 20 SECONDS
	frozen_status_effect_path = /datum/status_effect/void_chill/lasting

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/void/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(IS_HERETIC_OR_MONSTER(target_mob))
		return

	return ..()
