// This spell exists mainly for debugging purposes, and also to show how casting works
/datum/action/cooldown/spell/basic_heal
	name = "Lesser Heal"
	desc = "Heals a small amount of brute and burn damage to the caster."

	sound = 'sound/magic/staff_healing.ogg'
	school = SCHOOL_RESTORATION
	cooldown_time = 10 SECONDS
	cooldown_reduction_per_rank = 1.25 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_HUMAN

	invocation = "Victus sano!"
	invocation_type = INVOCATION_WHISPER

	/// Amount of brute to heal to the spell caster on cast
	var/brute_to_heal = 10
	/// Amount of burn to heal to the spell caster on cast
	var/burn_to_heal = 10

/datum/action/cooldown/spell/basic_heal/cast(mob/living/cast_on)
	. = ..()
	cast_on.visible_message(
		span_warning("A wreath of gentle light passes over [cast_on]!"),
		span_notice("You wreath yourself in healing light!"),
	)
	cast_on.adjustBruteLoss(-brute_to_heal, FALSE)
	cast_on.adjustFireLoss(-burn_to_heal)
