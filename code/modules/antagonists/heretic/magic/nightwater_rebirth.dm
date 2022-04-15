/datum/action/cooldown/spell/aoe/fiery_rebirth
	name = "Nightwatcher's Rebirth"
	desc = "A spell that extinguishes you drains nearby heathens engulfed in flames of their life force, \
		healing you for each victim drained. Those in critical condition \
		will have the last of their vitality drained, killing them."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "smoke"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation = "GL'RY T' TH' N'GHT'W'TCH'ER"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/aoe/fiery_rebirth/cast(mob/living/carbon/human/cast_on)
	cast_on.extinguish_mob()
	return ..()

/datum/action/cooldown/spell/aoe/fiery_rebirth/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/carbon/nearby_mob in range(aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue
		if(!nearby_mob.mind || !nearby_mob.client)
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.stat == DEAD || !nearby_mob.on_fire)
			continue

		things += nearby_mob

	return things

/datum/action/cooldown/spell/aoe/fiery_rebirth/cast_on_thing_in_aoe(mob/living/carbon/victim, mob/living/carbon/human/caster)
	new /obj/effect/temp_visual/eldritch_smoke(victim.drop_location())

	//This is essentially a death mark, use this to finish your opponent quicker.
	if(HAS_TRAIT(victim, TRAIT_CRITICAL_CONDITION) && !HAS_TRAIT(victim, TRAIT_NODEATH))
		victim.death()
	victim.apply_damage(20, BURN)

	// Heal the caster for every victim damaged
	caster.adjustBruteLoss(-10, FALSE)
	caster.adjustFireLoss(-10, FALSE)
	caster.adjustToxLoss(-10, FALSE)
	caster.adjustOxyLoss(-10, FALSE)
	caster.adjustStaminaLoss(-10)

/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
	duration = 10
