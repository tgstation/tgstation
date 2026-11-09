/// When attached to a living mob, causes it to take damage over time when pressure is too low or too high as defined by the element's arguments.
/datum/element/pressure_sensitive
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	argument_hash_end_idx = 5

	/// The pressure (in kilopascals) below which low_pressure_damage is taken.
	var/min_pressure = WARNING_LOW_PRESSURE
	/// The pressure (in kilopascals) above which high_pressure_damage is taken.
	var/max_pressure = HAZARD_HIGH_PRESSURE
	/// The damage taken when pressure is below min_pressure. 0 or below disables low pressure damage.
	var/low_pressure_damage = 1
	/// The damage taken when pressure is above max_pressure. 0 or below disables high pressure damage.
	var/high_pressure_damage = 1

/datum/element/pressure_sensitive/Attach(datum/target, min_pressure, max_pressure, low_pressure_damage, high_pressure_damage, mapload = FALSE)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	if (isnum(min_pressure))
		src.min_pressure = min_pressure
	if (isnum(max_pressure))
		src.max_pressure = max_pressure
	if (isnum(low_pressure_damage))
		src.low_pressure_damage = low_pressure_damage
	if (isnum(high_pressure_damage))
		src.high_pressure_damage = high_pressure_damage

	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))

	if(mapload && PERFORM_ALL_TESTS(focus_only/atmos_and_temp_requirements))
		check_safe_environment(target)

/datum/element/pressure_sensitive/Detach(datum/target)
	if(target)
		UnregisterSignal(target, COMSIG_LIVING_LIFE)
	return ..()

/datum/element/pressure_sensitive/proc/on_life(mob/living/target, seconds_per_tick)
	SIGNAL_HANDLER

	if (HAS_TRAIT(target, TRAIT_STASIS))
		return

	var/gave_alert = FALSE
	var/datum/gas_mixture/environment = target.loc.return_air()
	var/pressure = target.calculate_affecting_pressure(environment.return_pressure())

	if(pressure < min_pressure && low_pressure_damage > 0 && !HAS_TRAIT(target, TRAIT_RESISTLOWPRESSURE))
		target.adjust_brute_loss(low_pressure_damage * seconds_per_tick)

		switch(low_pressure_damage)
			if(5 to INFINITY)
				target.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 2)
			if(-INFINITY to 5)
				target.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 1)

		gave_alert = TRUE

	else if(pressure > max_pressure && high_pressure_damage > 0 && !HAS_TRAIT(target, TRAIT_RESISTHIGHPRESSURE))
		target.adjust_brute_loss(high_pressure_damage * seconds_per_tick)

		switch(high_pressure_damage)
			if(5 to INFINITY)
				target.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 2)
			if(-INFINITY to 5)
				target.throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 1)

		gave_alert = TRUE

	if(!gave_alert)
		target.clear_alert(ALERT_PRESSURE)

/// Ensures that the given mob is in a safe environment.
/datum/element/pressure_sensitive/proc/check_safe_environment(mob/living/target)
	if(target.stat == DEAD || isnull(target.loc))
		return

	var/atom/loc = target.loc
	var/datum/gas_mixture/environment = loc.return_air()
	var/pressure = target.calculate_affecting_pressure(environment.return_pressure())

	if(!ISINRANGE(pressure, min_pressure, max_pressure))
		stack_trace("[target] loaded on in a loc with unsafe pressure at \[[loc.x], [loc.y], [loc.z]\] (area : [get_area(loc)]): [pressure]kPa. Acceptable Range: [min_pressure]kPa - [max_pressure]kPa,")
