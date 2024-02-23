/client
	var/list/active_challenges = list()
	var/list/applied_challenges = list()

/datum/challenge
	///the challenge name
	var/challenge_name = "God's Weakest Challenge"
	///the challenge payout
	var/challenge_payout = 100
	///our host
	var/client/host
	///have we failed if we are a fail action
	var/failed = FALSE
	///the difficulty of the channgle
	var/difficulty = "Easy"
	///do we need to process?
	var/processes = FALSE
	///the current mob we are in
	var/mob/current_mob
	///the trait we apply if any
	var/applied_trait

/datum/challenge/New(client/creator)
	. = ..()
	if(!creator)
		return
	host = creator
	current_mob = host.mob
	if(!host)
		return
	RegisterSignal(host.mob, COMSIG_MIND_TRANSFERRED, PROC_REF(on_transfer))

///we just use the client to try and apply this as its easier to track mobs
/datum/challenge/proc/on_apply(client/owner)
	if(applied_trait)
		ADD_TRAIT(host.mob, applied_trait, CHALLENGE_TRAIT)

///this fires every 10 seconds
/datum/challenge/proc/on_process()
	return

///this fires when the mob dies
/datum/challenge/proc/on_death()
	return

///this fires when a mob is revived
/datum/challenge/proc/on_revive()
	return

/datum/challenge/proc/on_transfer(datum/source, mob/previous_body)
	SIGNAL_HANDLER
	if(applied_trait)
		REMOVE_TRAIT(previous_body, applied_trait, CHALLENGE_TRAIT)
		var/datum/mind/mind = source
		ADD_TRAIT(mind.current, applied_trait, CHALLENGE_TRAIT)
