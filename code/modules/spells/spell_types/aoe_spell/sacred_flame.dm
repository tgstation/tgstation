/datum/action/cooldown/spell/aoe/sacred_flame
	name = "Sacred Flame"
	desc = "Makes everyone around you more flammable, and lights yourself on fire."
	button_icon_state = "sacredflame"
	sound = 'sound/magic/fireball.ogg'

	school = SCHOOL_EVOCATION
	cooldown_time = 6 SECONDS

	invocation = "FI'RAN DADISKO"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	aoe_radius = 6

	/// The amount of firestacks to put people afflicted.
	var/firestacks_to_give = 20

/datum/action/cooldown/spell/aoe/sacred_flame/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/nearby_mob in view(aoe_radius, center))
		things += nearby_mob

	return things

/datum/action/cooldown/spell/aoe/sacred_flame/cast_on_thing_in_aoe(mob/living/victim, mob/living/caster)
	if(victim.can_block_magic(antimagic_flags))
		return

	victim.adjust_fire_stacks(firestacks_to_give)
	// Let people who got afflicted know they're suddenly a matchstick
	// But skip the caster - they'll know anyways.
	if(victim != caster)
		to_chat(victim, span_warning("You suddenly feel very flammable."))

/datum/action/cooldown/spell/aoe/sacred_flame/cast(mob/living/cast_on)
	. = ..()
	cast_on.ignite_mob()
	to_chat(cast_on, span_danger("You feel a roaring flame build up inside you!"))
