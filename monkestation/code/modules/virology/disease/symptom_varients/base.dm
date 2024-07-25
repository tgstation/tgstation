/datum/symptom_varient
	var/name = "Generic Varient"
	var/desc = "An amalgamation of genes."

	var/weight = 10

	var/datum/symptom/host_symptom
	var/datum/disease/host_disease
	var/cooldown_time = 5 SECONDS
	COOLDOWN_DECLARE(host_cooldown)

/datum/symptom_varient/New(datum/symptom/host, datum/disease/disease)
	. = ..()
	host_symptom = host
	if(disease)
		set_disease_parent(disease)
	else
		RegisterSignal(host_symptom, COMSIG_SYMPTOM_ATTACH, PROC_REF(set_disease_parent))

	setup_varient()
	host_symptom.update_name()

/datum/symptom_varient/proc/set_disease_parent(datum/disease/attached)
	SIGNAL_HANDLER

	UnregisterSignal(host_symptom, COMSIG_SYMPTOM_ATTACH)
	RegisterSignal(host_symptom, COMSIG_SYMPTOM_DETACH, PROC_REF(clear_disease_parent))
	host_disease = attached

/datum/symptom_varient/proc/clear_disease_parent()
	SIGNAL_HANDLER

	host_disease = null
	UnregisterSignal(host_symptom, COMSIG_SYMPTOM_DETACH)
	RegisterSignal(host_symptom, COMSIG_SYMPTOM_ATTACH, PROC_REF(set_disease_parent))

/datum/symptom_varient/proc/setup_varient()
	return TRUE

/datum/symptom_varient/proc/trigger_symptom()
	if(!host_disease)
		return FALSE
	if(!COOLDOWN_FINISHED(src, host_cooldown))
		return FALSE
	host_symptom.run_effect(host_disease.affected_mob, host_disease)
	COOLDOWN_START(src, host_cooldown, cooldown_time)

/datum/symptom_varient/proc/Copy(datum/symptom/new_symp)
	var/datum/symptom_varient/new_varient = new (new_symp)
	return new_varient
