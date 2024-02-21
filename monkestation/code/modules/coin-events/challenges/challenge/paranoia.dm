/datum/quirk/extra_sensory_paranoia
	name = "Extra-Sensory Paranoia"
	desc = "You feel like something wants to kill you..."
	mob_trait = TRAIT_PARANOIA
	value = -8
	icon = FA_ICON_OPTIN_MONSTER

/datum/quirk/extra_sensory_paranoia/add()
	var/datum/brain_trauma/magic/stalker/T = new()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/extra_sensory_paranoia/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H.cure_trauma_type(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/challenge/paranoia
	challenge_name = "Paranoia"
	challenge_payout = 600
	difficulty = "Hellish"
	applied_trait = TRAIT_PARANOIA
	var/added = FALSE


/datum/challenge/paranoia/on_apply(client/owner)
	. = ..()
	var/mob/living/carbon/human/H = host.mob
	if(!ishuman(H))
		return
	var/datum/brain_trauma/magic/stalker/T = new()
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)
	added = TRUE

/datum/challenge/paranoia/on_process()
	if(added)
		return

	var/mob/living/carbon/human/H = host.mob
	if(!ishuman(H))
		return
	var/datum/brain_trauma/magic/stalker/T = new()
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)
	added = TRUE

/datum/challenge/paranoia/on_transfer(datum/source, mob/previous_body)
	. = ..()
	var/mob/living/carbon/human/H = previous_body
	H.cure_trauma_type(/datum/brain_trauma/magic/stalker, TRAUMA_RESILIENCE_ABSOLUTE)

	var/datum/mind/mind = source
	var/datum/brain_trauma/magic/stalker/T = new()
	if(isliving(mind.current))
		var/mob/living/carbon/human/current_human = mind.current
		if(!ishuman(current_human))
			return
		current_human.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)
