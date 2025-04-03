/datum/action/cooldown/spell/aoe/fiery_rebirth
	name = "Nightwatcher's Rebirth"
	desc = "A spell that extinguishes you and drains nearby heathens engulfed in flames of their life force, \
		healing you for each victim drained. Those in critical condition \
		will have the last of their vitality drained, killing them."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "smoke"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation = "GL'RY T' TH' N'GHT'W'TCH'ER."
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
	new /obj/effect/temp_visual/eldritch_smoke(get_turf(victim))
	victim.Beam(caster, icon_state = "r_beam", time = 2 SECONDS)

	//This is essentially a death mark, use this to finish your opponent quicker.
	if(CAN_SUCCUMB(victim))
		victim.investigate_log("has been executed by fiery rebirth.", INVESTIGATE_DEATHS)
		victim.death()
	victim.apply_damage(20, BURN)

	// Heal the caster for every victim damaged
	var/need_mob_update = FALSE
	need_mob_update += caster.adjustBruteLoss(-10, updating_health = FALSE)
	need_mob_update += caster.adjustFireLoss(-10, updating_health = FALSE)
	need_mob_update += caster.adjustToxLoss(-10, updating_health = FALSE)
	need_mob_update += caster.adjustOxyLoss(-10, updating_health = FALSE)
	need_mob_update += caster.adjustStaminaLoss(-10, updating_stamina = FALSE)
	if(need_mob_update)
		caster.updatehealth()

/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
	duration = 10
