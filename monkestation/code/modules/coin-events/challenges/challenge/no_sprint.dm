/datum/challenge/no_sprinting
	challenge_name = "No Sprinting"
	challenge_payout = 350
	difficulty = "Hardish"

/datum/challenge/no_sprinting/New()
	. = ..()
	if(!host)
		return
	RegisterSignal(host.mob, COMSIG_MIND_TRANSFERRED, PROC_REF(on_transfer))

/datum/challenge/no_sprinting/on_apply()
	ADD_TRAIT(host.mob, TRAIT_NO_SPRINT, CHALLENGE_TRAIT)

/datum/challenge/no_sprinting/proc/on_transfer(datum/source, mob/previous_body)
	SIGNAL_HANDLER
	REMOVE_TRAIT(previous_body, TRAIT_NO_SPRINT, CHALLENGE_TRAIT)
	var/datum/mind/mind = source
	ADD_TRAIT(mind.current, TRAIT_NO_SPRINT, CHALLENGE_TRAIT)
