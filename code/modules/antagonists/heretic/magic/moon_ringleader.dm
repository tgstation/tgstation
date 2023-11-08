/datum/action/cooldown/spell/aoe/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Big AoE spell that deals more brain damage the lower the sanity of everyone in the AoE and it also causes hallucinations with those who have less sanity getting more. \
			If their sanity is low enough they snap and go insane, the spell then halves their sanity."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "moon_ringleader"
	sound = 'sound/effects/moon_parade.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation = "R''S 'E"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	aoe_radius = 7

/datum/action/cooldown/spell/aoe/moon_ringleader/get_things_to_cast_on(atom/center, radius_override)
	var/list/stuff = list()
	for(var/mob/living/carbon/nearby_mob in orange(center, radius_override || aoe_radius))
		if(nearby_mob == owner || nearby_mob == center)
			continue
		if(nearby_mob.stat == DEAD)
			continue
		if(!nearby_mob.mob_mood)
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		stuff += nearby_mob

	return stuff

/datum/action/cooldown/spell/aoe/moon_ringleader/cast_on_thing_in_aoe(mob/living/carbon/victim, mob/living/caster)
	var/victim_sanity = victim.mob_mood.sanity

	new /obj/effect/temp_visual/moon_ringleader(get_turf(victim))
	victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100-victim_sanity, 160)
	repeat_string((120-victim_sanity)/10,victim.cause_hallucination( \
		get_random_valid_hallucination_subtype(/datum/hallucination/body), \
		"ringleaders rise", \
	) )

	if(victim_sanity<15)
		victim.apply_status_effect(/datum/status_effect/moon_converted)
		caster.log_message("made [victim] insane.", LOG_GAME)
		victim.log_message("was driven insane by [caster]")
	victim.mob_mood.set_sanity(victim_sanity*0.5)

/obj/effect/temp_visual/moon_ringleader
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "ring_leader_effect"
	alpha = 180
	duration = 3 SECONDS
