/datum/action/cooldown/spell/aoe/void_pull
	name = "Void Pull"
	desc = "Calls the void, damaging, knocking down, and stunning people nearby. \
		Distant foes are also pulled closer to you (but not damaged)."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidpull"
	sound = 'sound/magic/voidblink.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 40 SECONDS

	invocation = "BR'NG F'RTH TH'M T' M'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	aoe_radius = 7
	/// The radius of the actual damage circle done before cast
	var/damage_radius = 1
	/// The radius of the stun applied to nearby people on cast
	var/stun_radius = 4

// Before the cast, we do some small AOE damage around the caster
/datum/action/cooldown/spell/aoe/void_pull/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	new /obj/effect/temp_visual/voidin(get_turf(cast_on))

	// Before we cast the actual effects, deal AOE damage to anyone adjacent to us
	var/list/mob/living/people_near_us = get_things_to_cast_on(cast_on, damage_radius)
	for(var/mob/living/nearby_living as anything in people_near_us)
		nearby_living.apply_damage(30, BRUTE, wound_bonus = CANT_WOUND)

/datum/action/cooldown/spell/aoe/void_pull/get_things_to_cast_on(atom/center, radius_override = 0)
	var/list/things = list()
	for(var/mob/living/nearby_mob in view(radius_override || aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue
		// Don't grab people who are tucked away or something
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue

		things += nearby_mob

	return things

// For the actual cast, we microstun people nearby and pull them in
/datum/action/cooldown/spell/aoe/void_pull/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	// If the victim's within the stun radius, they're stunned / knocked down
	if(get_dist(victim, caster) < stun_radius)
		victim.AdjustKnockdown(3 SECONDS)
		victim.AdjustParalyzed(0.5 SECONDS)

	// Otherwise, they take a few steps closer
	for(var/i in 1 to 3)
		victim.forceMove(get_step_towards(victim, caster))
