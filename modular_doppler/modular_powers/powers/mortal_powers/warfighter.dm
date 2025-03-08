#define MARTIALART_MARTIALART "martialart"
#define MARTIALART_CQB 'cqb"'

/**
 * Root powers
 */

/datum/martial_art/martialart
	name = "Martial Art"
	id = MARTIALART_MARTIALART

/datum/power/martialart
	name = "Martial Art"
	desc = "While not as advanced as the Resonant arts of Cultivators, with enough training, anyone can pack a punch. \
	This style boosts melee damage and lets the user block unarmed attacks by enabling throw mode."
	cost = 6
	root_power = /datum/power/martialart
	power_type = TRAIT_PATH_SUBTYPE_WARFIGHTER

/datum/power/martialart/add(mob/living/carbon/human/target)
	var/datum/martial_art/martial_to_learn = new /datum/martial_art/martialart()
	if(!martial_to_learn.teach(target))
		to_chat(target, span_warning("You attempt to learn [martial_to_learn.name],\
		but your current knowledge of martial arts conflicts with the new style, so it just doesn't stick with you."))

/datum/power/cqb
	name = "CQB"
	desc = "Carbines, shotguns, and pistols. CQB is used in boarding actions or room clearing: as a result of their training, \
	users of CQB do significantly more damage when melee-attacking with firearms; e.x., pistolwhipping."
	cost = 6
	root_power = /datum/power/cqb
	power_type = TRAIT_PATH_SUBTYPE_WARFIGHTER
	power_traits = list(TRAIT_POWER_CQB)

/datum/power/precision_killer
	name = "Precision Killer"
	desc = "Snipers and their spotters. Most people who have fought these individuals do not know who killed them. \
	After being scoped in for four seconds, users of this style deal ten extra damage."
	cost = 6
	root_power = /datum/power/precision_killer
	power_type = TRAIT_PATH_SUBTYPE_WARFIGHTER
	power_traits = list(TRAIT_POWER_SNIPER)

/datum/power/leadership
	name = "Leadership"
	desc = "Expressed in many ways, from an iron fist to selfless responsibility. Grants the Designate Ally ability, \
	which lets you select up to 3 people as allies. Helping your allies (shaking them to their feet, CPR, fireman carrying) \
	is faster, to include your allies helping each other or you."
	cost = 3
	root_power = /datum/power/leadership
	power_type = TRAIT_PATH_SUBTYPE_WARFIGHTER

/datum/power/leadership/add(mob/living/carbon/human/target)
	var/datum/action/cooldown/mob_cooldown/designate_ally/designate = new(src)
	designate.Grant(target)

/datum/action/cooldown/mob_cooldown/designate_ally
	name = "Designate Ally"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "rcl_gui"
	desc = "Some time in the future, this might let you designate allies. Maybe"
	cooldown_time = 10 SECONDS
