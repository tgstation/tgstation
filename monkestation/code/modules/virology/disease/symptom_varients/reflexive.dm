/datum/symptom_varient/reflexive
	name = "Reflexive"
	desc = "Automatically takes effect when the host is damaged."

	cooldown_time = 15 SECONDS

	var/mob/living/host_mob

/datum/symptom_varient/reflexive/Destroy(force, ...)
	. = ..()
	if(host_mob)
		UnregisterSignal(host_mob, COMSIG_CARBON_TAKE_BRUTE_DAMAGE)
		host_mob = null

/datum/symptom_varient/reflexive/set_disease_parent(datum/disease/attached)
	. = ..()
	if(attached.return_parent())
		host_mob = attached.return_parent()
		RegisterSignal(host_mob, COMSIG_CARBON_TAKE_BRUTE_DAMAGE, PROC_REF(trigger_symptom))

/datum/symptom_varient/reflexive/clear_disease_parent()
	. = ..()
	UnregisterSignal(host_mob, COMSIG_CARBON_TAKE_BRUTE_DAMAGE)
	host_mob = null
