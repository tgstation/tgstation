/datum/component/aging
	///our current age
	var/current_age = 0
	///our maximum age
	var/max_age = 100
	///our age cooldown
	var/age_cooldown = 30 SECONDS
	///our current cooldown
	COOLDOWN_DECLARE(current_cooldown)
	///our old age callback
	var/datum/callback/death_callback


/datum/component/aging/Initialize(max_age = 100, age_cooldown = 30 SECONDS, death_callback)
	. = ..()
	src.max_age = max_age
	src.age_cooldown = age_cooldown
	src.death_callback = death_callback

	START_PROCESSING(SSobj, src)

/datum/component/aging/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_AGE_ADJUSTMENT, PROC_REF(adjust_age))
	RegisterSignal(parent, COMSIG_AGE_RETURN_AGE, PROC_REF(return_age))

/datum/component/aging/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_AGE_ADJUSTMENT)

/datum/component/aging/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, current_cooldown))
		return
	COOLDOWN_START(src, current_cooldown, age_cooldown)
	current_age++
	if(max_age <= current_age)
		if(death_callback)
			death_callback.Invoke()
		STOP_PROCESSING(SSobj, src)

/datum/component/aging/proc/adjust_age(datum/source, adjust)
	current_age += adjust

/datum/component/aging/proc/return_age(datum/source)
	return current_age
