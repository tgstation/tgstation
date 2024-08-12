/datum/organ_trigger/process
	name = "Fast Processing Trigger"
	desc = "Triggers on a frequent interval. (3 Seconds)"

	COOLDOWN_DECLARE(trigger_cooldown)
	var/trigger_cooldown_time = 3 SECONDS

/datum/organ_trigger/process/New(atom/parent)
	. = ..()
	START_PROCESSING(SSabberant, src)

/datum/organ_trigger/process/Destroy(force, ...)
	. = ..()
	STOP_PROCESSING(SSabberant, src)

/datum/organ_trigger/process/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, trigger_cooldown))
		return
	trigger()
	COOLDOWN_START(src, trigger_cooldown, trigger_cooldown_time)

