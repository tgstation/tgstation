/**
 * given to a mob to set a key on or off when a storm is coming or ending
 */
/datum/component/ai_listen_to_weather
	///what weather type are we listening to
	var/weather_type
	///what blackboard key are we setting
	var/weather_key

/datum/component/ai_listen_to_weather/Initialize(weather_type = /datum/weather/ash_storm, weather_key = BB_STORM_APPROACHING)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.weather_type = weather_type
	src.weather_key = weather_key

/datum/component/ai_listen_to_weather/RegisterWithParent()
	RegisterSignal(SSdcs, COMSIG_WEATHER_START(weather_type), PROC_REF(storm_start))
	RegisterSignal(SSdcs, COMSIG_WEATHER_END(weather_type), PROC_REF(storm_end))

/datum/component/ai_listen_to_weather/UnregisterFromParent()
	UnregisterSignal(SSdcs, list(COMSIG_WEATHER_START(weather_type), COMSIG_WEATHER_END(weather_type)))

/datum/component/ai_listen_to_weather/proc/storm_start()
	SIGNAL_HANDLER

	var/mob/living/basic/source = parent
	if(!source.ai_controller)
		return
	source.ai_controller.CancelActions()
	source.ai_controller.set_blackboard_key(weather_key, TRUE)

/datum/component/ai_listen_to_weather/proc/storm_end()
	SIGNAL_HANDLER

	var/mob/living/basic/source = parent
	source.ai_controller?.set_blackboard_key(weather_key, FALSE)
