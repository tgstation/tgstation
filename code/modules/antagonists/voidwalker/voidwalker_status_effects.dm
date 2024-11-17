/// THE GRAVITY!!! IT WEIGHS!!!
/datum/movespeed_modifier/grounded_voidwalker
	multiplicative_slowdown = 1.1

/datum/movespeed_modifier/voidwalker_unsettle
	multiplicative_slowdown = -1

/datum/movespeed_modifier/voidwalker_through_the_void_slowdown
	multiplicative_slowdown = 1

/// Regenerate in space
/datum/status_effect/space_regeneration
	id = "space_regeneration"
	duration = STATUS_EFFECT_PERMANENT
	alert_type = null
	// How much do we heal per tick?
	var/healing = 1.5
	// Healing modifier if we are in soft crit or below.
	var/crit_mod = 1
	// Healing out of space.
	var/out_space_healing = 0

/datum/status_effect/space_regeneration/tick(effect)
	heal_owner()

/// Regenerate health whenever this status effect is applied or reapplied
/datum/status_effect/space_regeneration/proc/heal_owner()
	if(isspaceturf(get_turf(owner)))
		owner.heal_ordered_damage(healing * crit_mod, list(BRUTE, BURN, OXY, STAMINA, TOX, BRAIN))
	else
		owner.heal_ordered_damage(out_space_healing * crit_mod, list(BRUTE, BURN, OXY, STAMINA, TOX, BRAIN))

/datum/status_effect/planet_allergy
	id = "planet_allergy"
	duration = STATUS_EFFECT_PERMANENT
	alert_type = /atom/movable/screen/alert/status_effect/veryhighgravity

/datum/status_effect/planet_allergy/tick()
	owner.adjustBruteLoss(1)

/atom/movable/screen/alert/status_effect/veryhighgravity
	name = "Crushing Gravity"
	desc = "You're getting crushed by high gravity, picking up items and movement will be slowed. You'll also accumulate brute damage!"
	icon_state = "paralysis"

/datum/status_effect/void_eatered
	duration = 10 SECONDS
	remove_on_fullheal = TRUE

/datum/status_effect/void_eatered/on_apply()
	. = ..()

	ADD_TRAIT(owner, TRAIT_NODEATH, REF(src))

/datum/status_effect/void_eatered/on_remove()
	. = ..()

	REMOVE_TRAIT(owner, TRAIT_NODEATH, REF(src))

/datum/status_effect/void_symbol_mark
	id = "void symbol mark"
	duration = -1
	alert_type = null
	/// Our voidwalker and his friends in blessed_peoples.
	var/datum/mind/voidwalker_mind

/datum/status_effect/void_symbol_mark/on_remove()
	. = ..()
	if(isnull(voidwalker_mind))
		return
	var/datum/action/cooldown/spell/pointed/void_symbol/has_ability = locate() in voidwalker_mind.current
	if(!has_ability)
		return
	for(var/mob/living/carbon/human/my_cursed_friend in has_ability.cursed_peoples)
		has_ability.cursed_peoples -= my_cursed_friend
		var/datum/status_effect/agent_pinpointer/scan/voidwalker/scan_pinpointer = locate() in my_cursed_friend.status_effects
		if(!scan_pinpointer)
			continue
		if(scan_pinpointer.scan_target == my_cursed_friend)
			scan_pinpointer.scan_target = null

/datum/status_effect/agent_pinpointer/scan/voidwalker
	duration = -1
