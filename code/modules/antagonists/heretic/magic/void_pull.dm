/datum/action/cooldown/spell/aoe/void_pull
	name = "Void Pull"
	desc = "Calls the void, damaging, knocking down, pulling people closer, and stunning people nearby."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidpull"
	sound = 'sound/effects/magic/voidblink.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "BR'NG F'RTH TH'M T' M'."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	aoe_radius = 2

// Before the cast, we do some small AOE damage around the caster
/datum/action/cooldown/spell/aoe/void_pull/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	new /obj/effect/temp_visual/voidin(get_turf(cast_on))

/datum/action/cooldown/spell/aoe/void_pull/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/nearby_mob in view(aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue
		// Don't grab people who are tucked away or something
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		things += nearby_mob

	return things

// For the actual cast, we microstun people nearby and pull them in
/datum/action/cooldown/spell/aoe/void_pull/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	victim.apply_damage(30, BRUTE, wound_bonus = CANT_WOUND)
	victim.apply_status_effect(/datum/status_effect/void_chill, 3)
	victim.AdjustKnockdown(3 SECONDS)
	victim.AdjustParalyzed(0.5 SECONDS)
	for(var/i in 1 to 3)
		victim.forceMove(get_step_towards(victim, caster))
