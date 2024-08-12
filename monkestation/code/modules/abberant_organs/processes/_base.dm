/datum/organ_process
	var/name = "Generic Process"
	var/desc = "Generic process description."

	var/complexity_cost = 0
	var/process_flags = NONE

/datum/organ_process/proc/trigger(datum/weakref/host, stability)
