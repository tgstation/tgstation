/datum/challenge/heavy_bleeder
	challenge_name = "Heavy Bleeder"
	challenge_payout = 250
	difficulty = "Medium"

/datum/challenge/heavy_bleeder/New()
	. = ..()
	if(!host)
		return
	RegisterSignal(host.mob, COMSIG_MIND_TRANSFERRED, PROC_REF(on_transfer))

/datum/challenge/heavy_bleeder/on_apply()
	ADD_TRAIT(host.mob, TRAIT_HEAVY_BLEEDER, CHALLENGE_TRAIT)

/datum/challenge/heavy_bleeder/proc/on_transfer(datum/source, mob/previous_body)
	SIGNAL_HANDLER
	REMOVE_TRAIT(previous_body, TRAIT_HEAVY_BLEEDER, CHALLENGE_TRAIT)
	var/datum/mind/mind = source
	ADD_TRAIT(mind.current, TRAIT_HEAVY_BLEEDER, CHALLENGE_TRAIT)
