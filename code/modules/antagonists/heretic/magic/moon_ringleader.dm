/datum/action/cooldown/spell/aoe/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Big AoE spell that deals more brain damage the lower the sanity of everyone in the AoE and it also causes hallucinations with those who have less sanity getting more. \
			If their sanity is low enough also applies a trauma, the spell then halves their sanity."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "uncuff"
	sound = 'sound/magic/swap.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation = "R''S 'E"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	aoe_radius = 7

/datum/action/cooldown/spell/aoe/moon_ringleader/get_things_to_cast_on(atom/center, radius_override)
	. = list()
	for(var/atom/nearby in orange(center, radius_override ? radius_override : aoe_radius))
		if(nearby == owner || nearby == center || isarea(nearby))
			continue
		if(!ismob(nearby))
			. += nearby
			continue
		var/mob/living/nearby_mob = nearby
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		. += nearby_mob

/datum/action/cooldown/spell/aoe/moon_ringleader/cast_on_thing_in_aoe(mob/living/carbon/human/victim, atom/caster)
	if(!ismob(victim))

		if(victim.can_block_magic(antimagic_flags))
		to_chat(victim, span_notice("Your mind feels closed."))
		to_chat(caster, span_warning("The ring fails to form around [victim]."))
		return FALSE

		new /obj/effect/temp_visual/knockblast(get_turf(victim))
		victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100-victim.mob_mood.sanity, 160)
		repeat_string((120-victim.mob_mood.sanity)/10,victim.cause_hallucination( \
			get_random_valid_hallucination_subtype(/datum/hallucination/body), \
			"ringleaders rise", \
		) )

		if(victim.mob_mood.sanity<10)
			var/trauma_type = pick(/datum/brain_trauma/severe/blindness, /datum/brain_trauma/severe/paralysis/hemiplegic/right, /datum/brain_trauma/severe/paralysis/hemiplegic/left, /datum/brain_trauma/severe/monophobia, /datum/brain_trauma/severe/discoordination )
			victim.gain_trauma(trauma_type, TRAUMA_RESILIENCE_ABSOLUTE)
		victim.mob_mood.set_sanity(victim.mob_mood.sanity*0.5)

/obj/effect/temp_visual/knockblast
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	alpha = 180
	duration = 5 SECONDS
