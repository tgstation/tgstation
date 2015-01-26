var/global/disable_rng = 0

/datum/round_event_control/wizard/rng
	name = "RNG Disruption"
	weight = 2
	typepath = /datum/round_event/wizard/rng/
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/rng/
	endWhen = 30 //half a minutes

/datum/round_event/wizard/rng/start()
	disable_rng = 1

/datum/round_event/wizard/rng/end()
	disable_rng = 0

/proc/new_prob(var/prob)
	if(disable_rng)
		return 1
	else
		var/roll_the_dice = prob(prob)
		return roll_the_dice