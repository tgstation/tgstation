/datum/action/cooldown/spell/aoe/sacred_flame
	name = "Sacred Flame"
	desc = "Makes everyone around you more flammable, and lights yourself on fire."
	action_icon_state = "sacredflame"
	sound = 'sound/magic/fireball.ogg'

	school = SCHOOL_EVOCATION
	cooldown_time = 6 SECONDS

	invocation = "FI'RAN DADISKO"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	outer_radius = 6

	/// The amoutn of firestacks to put people afflicted.
	var/firestacks_to_give = 20

// All livings in view are valid, including ourselves
/datum/action/cooldown/spell/aoe/sacred_flame/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/aoe/sacred_flame/get_things_to_cast_on(atom/center)
	return view(outer_radius, center)

/datum/action/cooldown/spell/aoe/sacred_flame/cast_on_thing_in_aoe(mob/living/cast_on)
	if(cast_on.anti_magic_check())
		return

	cast_on.adjust_fire_stacks(firestacks_to_give)
	// Let people who got afflicted know they're suddenly a matchstick
	// But skip the caster - they'll know anyways.
	if(cast_on != owner)
		to_chat(cast_on, span_warning("You suddenly feel very flammable."))

/datum/action/cooldown/spell/aoe/sacred_flame/cast(mob/living/cast_on)
	. = ..()
	cast_on.IgniteMob()
	to_chat(cast_on, span_danger("You feel a roaring flame build up inside you!"))
