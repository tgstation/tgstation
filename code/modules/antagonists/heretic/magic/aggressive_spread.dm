/datum/action/cooldown/spell/aoe/rust_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust onto nearby surfaces."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "corrode"
	sound = 'sound/items/tools/welder.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "A'GRSV SPR'D."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	aoe_radius = 2

/datum/action/cooldown/spell/aoe/rust_conversion/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	return SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/aoe/rust_conversion/after_cast(atom/cast_on)
	. = ..()
	var/datum/status_effect/heretic_passive/rust/rust_passive = owner.has_status_effect(/datum/status_effect/heretic_passive/rust)
	if(!rust_passive)
		StartCooldown(cooldown_time)
		return

	var/new_cooldown = 35 SECONDS - (rust_passive.passive_level * 5 SECONDS)
	StartCooldown(new_cooldown)

/datum/action/cooldown/spell/aoe/rust_conversion/get_things_to_cast_on(atom/center)

	var/list/things_to_convert = RANGE_TURFS(aoe_radius, center)

	// Also converts things right next to you.
	for(var/atom/movable/nearby_movable in view(1, center))
		if(nearby_movable == owner || !isstructure(nearby_movable) )
			continue
		things_to_convert += nearby_movable

	return things_to_convert

/datum/action/cooldown/spell/aoe/rust_conversion/cast_on_thing_in_aoe(turf/victim, mob/living/caster)
	// We have less chance of rusting stuff that's further
	var/distance_to_caster = get_dist(victim, caster)
	var/chance_of_not_rusting = (max(distance_to_caster, 1) - 1) * 100 / (aoe_radius + 1)

	if(prob(chance_of_not_rusting))
		return

	if(ismob(caster))
		caster.do_rust_heretic_act(victim)
	else
		victim.rust_heretic_act()

/datum/action/cooldown/spell/aoe/rust_conversion/construct
	name = "Construct Spread"
	cooldown_time = 15 SECONDS
