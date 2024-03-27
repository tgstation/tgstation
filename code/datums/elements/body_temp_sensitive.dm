/**
 * When attached to a basic mob, it gives it the ability to be hurt by cold/hot body temperatures
 */
/datum/element/body_temp_sensitive
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	argument_hash_end_idx = 5

	///Min body temp
	var/min_body_temp = 250
	///Max body temp
	var/max_body_temp = 350
	////Damage when below min temp
	var/cold_damage = 1
	///Damage when above max temp
	var/heat_damage = 1

/datum/element/body_temp_sensitive/Attach(datum/target, min_body_temp, max_body_temp, cold_damage, heat_damage, mapload = FALSE)
	. = ..()
	if(!isliving(target))
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

	if(!mapload || !PERFORM_ALL_TESTS(focus_only/atmos_and_temp_requirements))
		return
	check_safe_environment(target)

/datum/element/body_temp_sensitive/Detach(datum/source)
	if(source)
		UnregisterSignal(source, COMSIG_LIVING_LIFE)
	return ..()

/datum/element/body_temp_sensitive/proc/on_life(datum/target, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/mob/living/living_mob = target
	var/gave_alert = FALSE

	if(living_mob.bodytemperature < min_body_temp)
		living_mob.adjustFireLoss(cold_damage * seconds_per_tick, forced = TRUE)
		if(!living_mob.has_status_effect(/datum/status_effect/inebriated))
			switch(cold_damage)
				if(1 to 5)
					living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 1)
				if(5 to 10)
					living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 2)
				if(10 to INFINITY)
					living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 3)
			gave_alert = TRUE

	else if(living_mob.bodytemperature > max_body_temp)
		living_mob.adjustFireLoss(heat_damage * seconds_per_tick, forced = TRUE)
		switch(heat_damage)
			if(1 to 5)
				living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 1)
			if(5 to 10)
				living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 2)
			if(10 to INFINITY)
				living_mob.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 3)
		gave_alert = TRUE

	if(!gave_alert)
		living_mob.clear_alert(ALERT_TEMPERATURE)

///Ensures that maploaded mobs are in a safe environment. Unit test stuff.
/datum/element/body_temp_sensitive/proc/check_safe_environment(mob/living/living_mob)
	if(living_mob.stat == DEAD)
		return
	var/atom/location = living_mob.loc
	var/datum/gas_mixture/environment = location.return_air()
	var/areatemp = living_mob.get_temperature(environment)
	if(!ISINRANGE(areatemp, min_body_temp, max_body_temp))
		stack_trace("[living_mob] loaded on in a loc with unsafe temperature at \[[location.x], [location.y], [location.z]\] (area : [get_area(location)]): [areatemp]K. Acceptable Range: [min_body_temp]K - [max_body_temp]K,")
