/**
 * Root powers
 */

/datum/power/burden_shared

	name = "A Burden Shared"
	desc = "A channeled ability. Every four seconds, attempt to equalize both your and the target's health, in increments of 10 damage. \
	Has a cooldown of 2 minutes after use. Grants 1 Piety after health is equalized if you were at least 10 points less damaged than the target, \
	and takes 1 Piety if you were at least 10 points more damaged. Mutually exclusive with A Burden Twisted and A Burden Revered."
	cost = 5
	root_power = /datum/power/burden_shared
	power_type = TRAIT_PATH_SUBTYPE_THEOLOGIST
	blacklist = list(/datum/power/burden_twist, /datum/power/burden_revered)


/datum/power/burden_shared/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/burden_shared(target.mind || target)
	new_action.Grant(target)

/datum/action/cooldown/spell/burden_shared
	name = "A Burden Shared"
	desc = "The knowledge required to share one's burden."
	button_icon_state = "arcane_barrage"

	school = SCHOOL_CONJURATION
	cooldown_time = 2 MINUTES
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = NONE

	invocation_type = INVOCATION_EMOTE

	invocation = "Someone starts sharing their burden!"
	invocation_self_message = "You start sharing your burden."

/datum/power/burden_twist

	name = "A Burden Twisted"
	desc = "A channeled ability. Every ten seconds, heal an adjacent carbon for up to 30 damage, then deal half of that damage back to them as \
	a random proportion of brute, burn, and oxygen damage. Has a cooldown of 2 minutes after use. Has a chance to give Piety when used on someone \
	with more than 30 damage. Mutually exclusive with A Burden Shared and A Burden Revered."
	cost = 5
	root_power = /datum/power/burden_twist
	power_type = TRAIT_PATH_SUBTYPE_THEOLOGIST
	blacklist = list(/datum/power/burden_shared, /datum/power/burden_revered)


/datum/power/burden_twist/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/burden_twist(target.mind || target)
	new_action.Grant(target)

/datum/action/cooldown/spell/burden_twist
	name = "A Burden Twisted"
	desc = "The knowledge required to twist one's burden."
	button_icon_state = "arcane_barrage"

	school = SCHOOL_CONJURATION
	cooldown_time = 2 MINUTES
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = NONE

	invocation_type = INVOCATION_EMOTE

	invocation = "Someone starts twisting their burden!"
	invocation_self_message = "You start twisting your burden."

/datum/power/burden_revered

	name = "A Burden Revered"
	desc = "Use on an adjacent carbon or yourself to nullify their pain and heal up to 30 damage over a long duration of time. \
	Grants Piety based on how injured the target was. Mutually exclusive with A Burden Shared and A Burden Twisted."
	cost = 5
	root_power = /datum/power/burden_revered
	power_type = TRAIT_PATH_SUBTYPE_THEOLOGIST
	blacklist = list(/datum/power/burden_twist, /datum/power/burden_shared)


/datum/power/burden_revered/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/burden_revered(target.mind || target)
	new_action.Grant(target)

/datum/action/cooldown/spell/burden_revered
	name = "A Burden Revered."
	desc = "The knowledge required to revere one's burden."
	button_icon_state = "arcane_barrage"

	school = SCHOOL_CONJURATION
	cooldown_time = 2 MINUTES
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = NONE

	invocation_type = INVOCATION_EMOTE

	invocation = "Someone starts revering their burden!"
	invocation_self_message = "You start revering your burden."

/datum/power/check_piety

	name = "Check Piety"
	desc = "Tells you your current Piety."
	cost = 0
	root_power = /datum/power/check_piety
	power_type = TRAIT_PATH_SUBTYPE_THEOLOGIST

/datum/power/check_piety/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/mob_cooldown/check_piety(target.mind || target)
	new_action.Grant(target)


/datum/action/cooldown/mob_cooldown/check_piety
	name = "Check Piety"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "scan_mode"
	desc = "Allows you to check your piety."
	cooldown_time = 1.5 SECONDS

/datum/action/cooldown/mob_cooldown/dash/Activate(atom/target_atom)
	to_chat(owner, span_notice("You have no piety. You are NOT pious. You will NEVER be pious . . . "))
	return TRUE
