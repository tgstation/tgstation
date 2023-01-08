/**
 * When attached to a basic mob, it gives it the ability to be hurt by cold/hot body temperatures
 */
/datum/element/basic_body_temp_sensitive
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	///Min body temp
	var/min_body_temp = 250
	///Max body temp
	var/max_body_temp = 350
	////Damage when below min temp
	var/cold_damage = 1
	///Damage when above max temp
	var/heat_damage = 1

/datum/element/basic_body_temp_sensitive/Attach(datum/target, min_body_temp, max_body_temp, cold_damage, heat_damage)
	. = ..()
	if(!isbasicmob(target))
		return ELEMENT_INCOMPATIBLE

	if(isnum(min_body_temp))
		src.min_body_temp = min_body_temp

	if(isnum(max_body_temp))
		src.max_body_temp = max_body_temp

	if(isnum(cold_damage))
		src.cold_damage = cold_damage

	if(isnum(heat_damage))
		src.heat_damage = heat_damage

	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/element/basic_body_temp_sensitive/Detach(datum/source)
	if(source)
		UnregisterSignal(source, COMSIG_LIVING_LIFE)
	return ..()


/datum/element/basic_body_temp_sensitive/proc/on_life(datum/target, delta_time, times_fired)
	SIGNAL_HANDLER

	var/mob/living/basic/basic_mob = target
	var/gave_alert = FALSE

	if(basic_mob.bodytemperature < min_body_temp)
		basic_mob.adjust_health(cold_damage * delta_time)
		switch(cold_damage)
			if(1 to 5)
				basic_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 1)
			if(5 to 10)
				basic_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 2)
			if(10 to INFINITY)
				basic_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 3)
		gave_alert = TRUE

	else if(basic_mob.bodytemperature > max_body_temp)
		basic_mob.adjust_health(heat_damage * delta_time)
		switch(heat_damage)
			if(1 to 5)
				basic_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 1)
			if(5 to 10)
				basic_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 2)
			if(10 to INFINITY)
				basic_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 3)
		gave_alert = TRUE

	if(!gave_alert)
		basic_mob.clear_alert(ALERT_TEMPERATURE)
