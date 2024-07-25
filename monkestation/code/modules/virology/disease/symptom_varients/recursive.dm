/datum/symptom_varient/recursive
	name = "Recursive"
	desc = "Triggers a symptom 3 extra times 2 seconds apart from eachother."

	cooldown_time = 15 SECONDS

/datum/symptom_varient/recursive/Destroy(force, ...)
	. = ..()
	UnregisterSignal(host_symptom, COMSIG_SYMPTOM_TRIGGER)

/datum/symptom_varient/recursive/set_disease_parent(datum/disease/attached)
	. = ..()
	RegisterSignal(host_symptom, COMSIG_SYMPTOM_TRIGGER, PROC_REF(start_chain))

/datum/symptom_varient/recursive/clear_disease_parent()
	. = ..()
	UnregisterSignal(host_symptom, COMSIG_SYMPTOM_TRIGGER)

/datum/symptom_varient/recursive/proc/start_chain()
	trigger_symptom()

	addtimer(CALLBACK(src, PROC_REF(trigger)), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(trigger)), 4 SECONDS)

/datum/symptom_varient/recursive/proc/trigger()
	host_symptom.run_effect(host_disease.affected_mob, host_disease)
