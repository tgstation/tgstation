/// Allows carbons with heads to attempt to bite mobs if attacking with cuffed hands / missing arms
/datum/element/human_biter

/datum/element/human_biter/Attach(datum/target)
	. = ..()
	if(!iscarbon(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(try_bite))

/datum/element/human_biter/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_EARLY_UNARMED_ATTACK)

/datum/element/human_biter/proc/try_bite(mob/living/carbon/human/source, atom/target, proximity_flag, modifiers)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return NONE

	// If we can attack like normal, just go ahead and do that
	if(source.can_unarmed_attack())
		return NONE // do normal unarmedattack

	. = COMPONENT_SKIP_ATTACK // we will fail anyways if we try to attack normally, so skip the rest

	// cannot attack at all if muzzled
	if(source.is_muzzled())
		return .

	// and obvously we need a mouth to bite
	var/obj/item/bodypart/head/mouth = source.get_bodypart(BODY_ZONE_HEAD)
	if(isnull(mouth))
		return .

	. = COMPONENT_CANCEL_ATTACK_CHAIN // this was our attack, stop the rest

	var/mob/living/carbon/victim = target
	var/obj/item/bodypart/affecting = victim.get_bodypart(victim.get_random_valid_zone(even_weights = TRUE))
	var/armor = victim.run_armor_check(affecting, MELEE)

	if(prob(MONKEY_SPEC_ATTACK_BITE_MISS_CHANCE))
		victim.visible_message(
			span_danger("[source]'s bite misses [victim]!"),
			span_danger("You avoid [source]'s bite!"),
			span_hear("You hear jaws snapping shut!"),
			COMBAT_MESSAGE_RANGE,
			source,
		)
		to_chat(source, span_danger("Your bite misses [victim]!"))
		return .

	victim.apply_damage(rand(mouth.unarmed_damage_low, mouth.unarmed_damage_high), BRUTE, affecting, armor)

	victim.visible_message(
		span_danger("[name] bites [victim]!"),
		span_userdanger("[name] bites you!"),
		span_hear("You hear a chomp!"),
		COMBAT_MESSAGE_RANGE,
		name,
	)
	to_chat(source, span_danger("You bite [victim]!"))

	if(armor < 2) // if they have basic armor on the limb we bit, don't spread diseases
		for(var/datum/disease/bite_infection as anything in source.diseases)
			if(bite_infection.spread_flags & (DISEASE_SPREAD_SPECIAL | DISEASE_SPREAD_NON_CONTAGIOUS))
				continue // ignore diseases that have special spread logic, or are not contagious
			victim.ForceContractDisease(bite_infection)

	return .
