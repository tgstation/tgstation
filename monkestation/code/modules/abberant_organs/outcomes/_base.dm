/datum/organ_outcome
	var/name = "Generic Outcome"
	var/desc = "Generic outcome description."

	var/complexity_cost = 0

/datum/organ_outcome/proc/trigger(datum/weakref/host, stability)
