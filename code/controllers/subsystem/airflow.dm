#define CLEAR_OBJECT(TARGET) \
	processing -= TARGET; \
	TARGET.airflow_dest = null; \
	TARGET.airflow_speed = 0; \
	TARGET.airflow_time = 0; \
	TARGET.airflow_skip_speedcheck = FALSE; \
	if (TARGET.airflow_od) { \
		TARGET.set_density(FALSE); \
	}


SUBSYSTEM_DEF(airflow)
	name = "Airflow"
	wait = 1
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_AIRFLOW

	var/static/tmp/list/processing = list()
	var/static/tmp/list/current = list()


/datum/controller/subsystem/airflow/Recover()
	current.Cut()


/datum/controller/subsystem/airflow/fire(resumed, no_mc_tick)
	if (!resumed)
		current = processing.Copy()
	var/atom/movable/target
	for (var/i = current.len to 1 step -1)
		target = current[i]
		if (QDELETED(target))
			if (target)
				CLEAR_OBJECT(target)
			if (MC_TICK_CHECK)
				current.Cut(i)
				return
			continue
		if (target.airflow_speed <= 0)
			CLEAR_OBJECT(target)
			if (MC_TICK_CHECK)
				current.Cut(i)
				return
			continue
		if (target.airflow_process_delay > 0)
			target.airflow_process_delay -= 1
			if (MC_TICK_CHECK)
				current.Cut(i)
				return
			continue
		else if (target.airflow_process_delay)
			target.airflow_process_delay = 0
		target.airflow_speed = min(target.airflow_speed, 15)
		target.airflow_speed -= SSzas.settings.airflow_speed_decay
		if (!target.airflow_skip_speedcheck)
			if (target.airflow_speed > 7)
				if (target.airflow_time++ >= target.airflow_speed - 7)
					if (target.airflow_od)
						target.set_density(FALSE)
					target.airflow_skip_speedcheck = TRUE
					if (MC_TICK_CHECK)
						current.Cut(i)
						return
					continue
			else
				if (target.airflow_od)
					target.set_density(FALSE)
				target.airflow_process_delay = max(1, 10 - (target.airflow_speed + 3))
				target.airflow_skip_speedcheck = TRUE
				if (MC_TICK_CHECK)
					current.Cut(i)
					return
				continue
		target.airflow_skip_speedcheck = FALSE
		if (target.airflow_od)
			target.set_density(TRUE)
		if (!target.airflow_dest || target.loc == target.airflow_dest)
			target.airflow_dest = locate(min(max(target.x + target.airflow_xo, 1), world.maxx), min(max(target.y + target.airflow_yo, 1), world.maxy), target.z)
		if ((target.x == 1) || (target.x == world.maxx) || (target.y == 1) || (target.y == world.maxy))
			CLEAR_OBJECT(target)
			if (MC_TICK_CHECK)
				current.Cut(i)
				return
			continue
		if (!isturf(target.loc))
			CLEAR_OBJECT(target)
			if (MC_TICK_CHECK)
				current.Cut(i)
				return
			continue
		step_towards(target, target.airflow_dest)
		if (ismob(target))
			var/mob/M = target
			M.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/atmos_pressure, TRUE, SSzas.settings.airflow_mob_slowdown)
			addtimer(CALLBACK(M, /mob/proc/remove_movespeed_modifier, /datum/movespeed_modifier/atmos_pressure, TRUE))
		if (MC_TICK_CHECK)
			current.Cut(i)
			return

#undef CLEAR_OBJECT


/atom/movable/var/tmp/airflow_xo
/atom/movable/var/tmp/airflow_yo
/atom/movable/var/tmp/airflow_od
/atom/movable/var/tmp/airflow_process_delay
/atom/movable/var/tmp/airflow_skip_speedcheck


/atom/movable/proc/prepare_airflow(strength)
	if (!airflow_dest || airflow_speed < 0 || last_airflow > world.time - SSzas.settings.airflow_delay)
		return FALSE
	if (airflow_speed)
		airflow_speed = strength / max(get_dist(src, airflow_dest), 1)
		return FALSE
	if (airflow_dest == loc)
		step_away(src, loc)
	if (!AirflowCanMove(strength))
		return FALSE
	if (ismob(src))
		to_chat(src, span_danger("You are pushed away by a rush of air!"))
	last_airflow = world.time
	var/airflow_falloff = 9 - sqrt((x - airflow_dest.x) ** 2 + (y - airflow_dest.y) ** 2)
	if (airflow_falloff < 1)
		airflow_dest = null
		return FALSE
	airflow_speed = min(max(strength * (9 / airflow_falloff), 1), 9)
	airflow_od = FALSE
	if (!density)
		set_density(TRUE)
		airflow_od = TRUE
	return TRUE


/atom/movable/proc/GotoAirflowDest(strength)
	if (!prepare_airflow(strength))
		return
	airflow_xo = airflow_dest.x - x
	airflow_yo = airflow_dest.y - y
	airflow_dest = null
	SSairflow.processing += src


/atom/movable/proc/RepelAirflowDest(strength)
	if (!prepare_airflow(strength))
		return
	airflow_xo = -(airflow_dest.x - x)
	airflow_yo = -(airflow_dest.y - y)
	airflow_dest = null
	SSairflow.processing += src
