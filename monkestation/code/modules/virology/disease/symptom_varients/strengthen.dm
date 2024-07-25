/datum/symptom_varient/strength
	name = "Strengthen"
	desc = "Raises a symptoms strength."

	cooldown_time = 15 SECONDS

/datum/symptom_varient/strength/Destroy(force, ...)
	. = ..()
	UnregisterSignal(host_symptom, COMSIG_SYMPTOM_TRIGGER)

/datum/symptom_varient/strength/set_disease_parent(datum/disease/attached)
	. = ..()
	RegisterSignal(host_symptom, COMSIG_SYMPTOM_TRIGGER, PROC_REF(increase_strength))

/datum/symptom_varient/strength/clear_disease_parent()
	. = ..()
	UnregisterSignal(host_symptom, COMSIG_SYMPTOM_TRIGGER)

/datum/symptom_varient/strength/proc/increase_strength()
	host_symptom.multiplier = min(host_symptom.multiplier++, host_symptom.max_multiplier)
