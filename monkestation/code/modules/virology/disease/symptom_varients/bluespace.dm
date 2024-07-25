GLOBAL_LIST_INIT(bluespace_varient_list, list())

/datum/symptom_varient/bluespace
	name = "Quantumly Entangled"
	desc = "The cloning process seems to have caused genes to communicate through hosts."
	cooldown_time = 30 SECONDS

	weight = 2

	var/bluespace_id = 0
	var/static/last_bluespace_id = 0

/datum/symptom_varient/bluespace/New(datum/symptom/host)
	. = ..()
	GLOB.bluespace_varient_list += src
	last_bluespace_id++
	bluespace_id = last_bluespace_id

/datum/symptom_varient/bluespace/Destroy(force, ...)
	. = ..()
	GLOB.bluespace_varient_list -= src

/datum/symptom_varient/bluespace/setup_varient()
	. = ..()
	RegisterSignal(host_symptom, COMSIG_SYMPTOM_TRIGGER, PROC_REF(propagate))


/datum/symptom_varient/bluespace/proc/propagate()
	for(var/datum/symptom_varient/bluespace/bluespace as anything in GLOB.bluespace_varient_list)
		if(bluespace_id != bluespace.bluespace_id)
			continue
		COOLDOWN_START(bluespace, host_cooldown, cooldown_time)

	for(var/datum/symptom_varient/bluespace/bluespace as anything in GLOB.bluespace_varient_list)
		if(bluespace_id != bluespace.bluespace_id)
			continue
		if(!bluespace.host_disease)
			continue
		bluespace.host_symptom.run_effect(bluespace.host_disease.return_parent(), bluespace.host_disease)
