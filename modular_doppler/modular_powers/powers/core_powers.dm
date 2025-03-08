// Mortal

/datum/power/tenacious
	name = "Tenacious"
	desc = "Try to remember some of the basics of CQC."
	is_accessible = FALSE
	power_traits = list(TRAIT_POWER_TENACIOUS)

// Sorcerous

/datum/power/prestidigitation
	name = "Prestidigitation"
	desc = "Allows a Sorcerous individual to perform magical tricks"
	root_power = /datum/power/prestidigitation
	power_type = TRAIT_PATH_SUBTYPE_THAUMATURGE
	is_accessible = FALSE

/datum/power/prestidigitation/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/prestidigitation(target.mind || target)
	new_action.Grant(target)

/datum/action/cooldown/spell/prestidigitation
	name = "Prestidigitation"
	desc = "The knowledge required to perform a variety of magical tricks."
	button_icon_state = "arcane_barrage"

	school = SCHOOL_CONJURATION
	cooldown_time = 12 SECONDS
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = NONE

	invocation_type = INVOCATION_EMOTE

	invocation = "Someone starts performing magic tricks!"
	invocation_self_message = "You start performing magic tricks."

// Resonant

/datum/power/meditate
	name = "Meditate"
	desc = "ooughhh im meditating"
	is_accessible = FALSE
	power_type = TRAIT_PATH_SUBTYPE_PSYKER

/datum/power/meditate/add(mob/living/carbon/human/target)
	var/datum/action/new_action = new /datum/action/cooldown/spell/meditate(target.mind || target)
	new_action.Grant(target)

/datum/action/cooldown/spell/meditate
	name = "Meditate"
	desc = "This state of internal focus allows them to replenish any reserves they have and purge any impurities dredged up by abusing Nature's law."
	button_icon_state = "nose"

	school = SCHOOL_CONJURATION
	cooldown_time = 12 SECONDS
	cooldown_reduction_per_rank = 2.5 SECONDS
	spell_requirements = NONE

	invocation_type = INVOCATION_EMOTE

	invocation = "Someone starts meditating."
	invocation_self_message = "You start meditating"
