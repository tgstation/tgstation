/datum/symptom_varient/routine
	name = "Clockwork"
	desc = "Like clockwork this symptom triggers every 10 seconds"

	cooldown_time = 5 SECONDS
	COOLDOWN_DECLARE(next_process)

/datum/symptom_varient/routine/Destroy(force, ...)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/datum/symptom_varient/routine/set_disease_parent(datum/disease/attached)
	. = ..()
	START_PROCESSING(SSobj, src)

/datum/symptom_varient/routine/clear_disease_parent()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/datum/symptom_varient/routine/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, next_process))
		return
	COOLDOWN_START(src, next_process, 10 SECONDS)
	trigger_symptom()
