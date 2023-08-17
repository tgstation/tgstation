/**
 * toggles a key to true or false when a weather is starting/ending
 */
/datum/element/ai_listen_to_weather
	element_flags = ELEMENT_BESPOKE
	var/weather_type
	var/weather_key = BB_STORM_APPROACHING

/datum/element/ai_listen_to_weather/Attach(datum/target, weather_type = /datum/weather/ash_storm)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.weather_type = weather_type
	RegisterSignal(target, COMSIG_WEATHER_START(weather_type), PROC_REF(storm_start))
	RegisterSignal(target, COMSIG_WEATHER_END(weather_type), PROC_REF(storm_end))

/datum/element/ai_listen_to_weather/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_WEATHER_START(weather_type), COMSIG_WEATHER_END(weather_type)))

/datum/element/ai_listen_to_weather/proc/storm_start(mob/living/basic/source)
	SIGNAL_HANDLER

	if(!source.ai_controller)
		return
	source.ai_controller.CancelActions()
	source.ai_controller.set_blackboard_key(weather_key, TRUE)

/datum/element/ai_listen_to_weather/proc/storm_end(mob/living/basic/source)
	SIGNAL_HANDLER

	source.ai_controller?.set_blackboard_key(weather_key, FALSE)
