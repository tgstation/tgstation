/datum/action/cooldown/spell/aoe/void_pull
	name = "Void Pull"
	desc = "Call the void, this pulls all nearby people closer to you, and damages people already around you. \
		If they are 4 tiles or closer they are also knocked down and a micro-stun is applied."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidpull"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 40 SECONDS

	invocation = "BR'NG F'RTH TH'M T' M'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	outer_radius = 7
	/// The radius of the actual damage circle done before cast
	var/damage_radius = 1
	/// The radius of the stun applied to nearby people on cast
	var/stun_radius = 4

// Before the cast, we do some small AOE damage around the caster
/datum/action/cooldown/spell/aoe/void_pull/before_cast(atom/cast_on)
	. = ..()
	if(!.)
		return

	new /obj/effect/temp_visual/voidin(cast_on.drop_location())
	for(var/mob/living/nearby_living in range(damage_radius, cast_on))
		if(!is_affected_by_aoe(nearby_living))
			continue
		nearby_living.apply_damage(30, BRUTE, wound_bonus = CANT_WOUND)

/datum/action/cooldown/spell/aoe/void_pull/get_things_to_cast_on(atom/center)
	return view(outer_radius, center)

/datum/action/cooldown/spell/aoe/void_pull/is_affected_by_aoe(atom/center, atom/thing)
	if(!isturf(thing.loc))
		return FALSE

	if(!isliving(thing) || thing == owner)
		return FALSE

	var/mob/living/living_thing = thing
	if(IS_HERETIC_OR_MONSTER(living_thing))
		return FALSE

	return TRUE

// For the actual cast, we microstun people nearby and pull them in
/datum/action/cooldown/spell/aoe/void_pull/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	if(get_dist(victim, caster) < stun_radius)
		victim.AdjustKnockdown(3 SECONDS)
		victim.AdjustParalyzed(0.5 SECONDS)

	for(var/i in 1 to 3)
		// Take a few steps closer
		victim.forceMove(get_step_towards(victim, caster))
