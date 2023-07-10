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

/datum/challenge/New(client/creator)
	. = ..()
	if(!creator)
		return
	host = creator
	current_mob = host.mob

///we just use the client to try and apply this as its easier to track mobs
/datum/challenge/proc/on_apply()
	return

///this fires every 10 seconds
/datum/challenge/proc/on_process()
	return

///this fires when the mob dies
/datum/challenge/proc/on_death()
	return

///this fires when a mob is revived
/datum/challenge/proc/on_revive()
	return
