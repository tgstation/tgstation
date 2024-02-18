/datum/challenge/no_heals
	challenge_name = "No Healing"
	challenge_payout = 500
	difficulty = "Hard"
	applied_trait = TRAIT_NO_HEALS

/datum/challenge/no_heals/New()
	. = ..()
	if(!host)
		return
	RegisterSignal(host.mob, COMSIG_MIND_TRANSFERRED, PROC_REF(on_transfer))

/datum/challenge/no_heals/on_apply()
	ADD_TRAIT(host.mob, TRAIT_NO_HEALS, CHALLENGE_TRAIT)

/datum/challenge/no_heals/proc/on_transfer(datum/source, mob/previous_body)
	SIGNAL_HANDLER
	REMOVE_TRAIT(previous_body, TRAIT_NO_HEALS, CHALLENGE_TRAIT)
	var/datum/mind/mind = source
	ADD_TRAIT(mind.current, TRAIT_NO_HEALS, CHALLENGE_TRAIT)
