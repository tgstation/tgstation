/datum/action/cooldown/spell/aoe/rust_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust onto nearby surfaces."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "corrode"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "A'GRSV SPR'D"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	outer_radius = 3

/datum/action/cooldown/spell/aoe/rust_conversion/is_affected_by_aoe(atom/thing)
	return isturf(thing)

/datum/action/cooldown/spell/aoe/rust_conversion/cast_on_thing_in_aoe(turf/victim, atom/caster)
	// We have less chance of rusting stuff that's further
	// Probability of rusting = 100 * (distance - 1) / (radius + 1)
	var/distance_to_caster = get_dist(victim, caster)
	var/chance_of_not_rusting = 100 * (distance_to_caster - 1)  / (outer_radius + 1)
	// We also cheat a bit and ensure that the caster always gets at least a 3x3 of rust
	if(distance_to_caster <= 1)
		chance_of_not_rusting = 0

	if(prob(chance_of_not_rusting))
		return
	victim.rust_heretic_act()

/datum/action/cooldown/spell/aoe/rust_conversion/small
	name = "Rust Conversion"
	desc = "Spreads rust onto nearby surfaces."
	outer_radius = 2
