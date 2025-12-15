/obj/effect/anomaly/weather
	name = "weather anomaly"
	anomaly_core = /obj/item/assembly/signaler/anomaly/weather
	lifespan = ANOMALY_COUNTDOWN_TIMER * 2.5

	/// Chance per turf per second that we will produce thunder. Use the defines
	var/thunder_chance = 0
	/// The type of weather this anomaly will produce. If unset, will be picked from select_weather()
	var/datum/weather/weather_type
	/// List of active weathers spawned by this anomaly
	VAR_PRIVATE/list/active_weathers

/obj/effect/anomaly/weather/Initialize(mapload, new_lifespan, drops_core)
	. = ..()

	weather_type ||= select_weather()

	active_weathers = list()

	var/telegraph = lifespan / 5 // 1/5th of the time is dedicated to telegraphing, to give people time to find and defuse it
	var/end_dur = lifespan / 15 // then 1/15th of the time is dedicated to winding down
	var/total_dur = lifespan - telegraph - end_dur

	var/list/affected_areas = list(impact_area)
	var/list/num_turfs = length(impact_area.get_turfs_from_all_zlevels())
	for(var/area/station/nearby in range(7, src))
		// prevents nearby the central hallway from basically always being included
		if(length(nearby.get_turfs_from_all_zlevels()) > num_turfs * 1.5)
			continue
		affected_areas |= nearby

	var/datum/weather/weather = SSweather.run_weather(
		weather_datum_type = weather_type,
		z_levels = z,
		weather_data = list(
			WEATHER_FORCED_AREAS = affected_areas,
			WEATHER_FORCED_FLAGS = weather_type::weather_flags | WEATHER_INDOORS,
			WEATHER_FORCED_THUNDER = thunder_chance,
			WEATHER_FORCED_TELEGRAPH = telegraph,
			WEATHER_FORCED_END = end_dur,
			WEATHER_FORCED_DURATION = total_dur,
		)
	)
	RegisterSignal(weather, COMSIG_QDELETING, PROC_REF(clear_ref))

/obj/effect/anomaly/weather/proc/clear_ref(datum/weather/weather_datum)
	SIGNAL_HANDLER
	active_weathers -= weather_datum
	UnregisterSignal(weather_datum, COMSIG_QDELETING)

/obj/effect/anomaly/weather/proc/select_weather()
	return pick(
		/datum/weather/rain_storm,
		/datum/weather/snow_storm,
		/datum/weather/sand_storm,
	)

/obj/effect/anomaly/weather/anomalyNeutralize()
	for(var/datum/weather/weather_datum as anything in active_weathers)
		weather_datum?.wind_down()
	return ..()

/obj/effect/anomaly/weather/detonate()
	playsound(src, 'sound/effects/magic/repulse.ogg', 100, TRUE)
	for(var/atom/movable/repulsed in range(src, 5))
		if(repulsed == src || repulsed.anchored)
			continue
		var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(repulsed, src)))
		repulsed.safe_throw_at(throwtarget, 6, 2, src, force = MOVE_FORCE_EXTREMELY_STRONG)

/obj/effect/anomaly/weather/Destroy()
	active_weathers = null
	return ..()

/obj/effect/anomaly/weather/thundering
	name = "thundering weather anomaly"

	thunder_chance = THUNDER_CHANCE_HIGH
	// maybe we can put acid rain in this later?
	// though it'd feel unfair if it showed up and immediately dumped acid on people.
	// we would need an even longer telegraphing time for that
	weather_type = /datum/weather/rain_storm
