/datum/round_event_control/anomaly/anomaly_weather
	name = "Anomaly: Weather"
	typepath = /datum/round_event/anomaly/anomaly_weather

	max_occurrences = 2
	weight = 10
	description = "This anomaly causes weather effects to manifest indoors. \
		It can be cause completely harmless weather like light rain, or something which could harm unprotected individuals like snowstorms. \
		Note, triggering multiple at once will likely break weather sound effects."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 5
	admin_setup = list(
		/datum/event_admin_setup/set_location/anomaly,
		/datum/event_admin_setup/listed_options/weather_anomaly,
		/datum/event_admin_setup/listed_options/weather_thunder,
	)

/datum/round_event_control/anomaly/anomaly_weather/can_spawn_event(players_amt, allow_magic = FALSE)
	// weathers have some funky global state that may break if multiple are running. better safe than sorry.
	return ..() && !length(SSweather.processing)

/datum/round_event/anomaly/anomaly_weather
	start_when = ANOMALY_START_HARMFUL_TIME
	announce_when = ANOMALY_ANNOUNCE_HARMFUL_TIME
	anomaly_path = /obj/effect/anomaly/weather

	var/forced_weather_type = null
	var/forced_thunder_chance = null

/datum/round_event/anomaly/anomaly_weather/announce(fake)
	if(isnull(impact_area))
		impact_area = placer.findValidArea()
	priority_announce("Barometric anomaly detected on [ANOMALY_ANNOUNCE_HARMFUL_TEXT] [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/anomaly_weather/make_anomaly(turf/anomaly_turf)
	return new anomaly_path(anomaly_turf, null, null, forced_weather_type, forced_thunder_chance)

/datum/round_event_control/anomaly/anomaly_weather/thundering
	name = "Anomaly: Thundering Weather"
	typepath = /datum/round_event/anomaly/anomaly_weather/thundering

	max_occurrences = 1
	weight = 5
	description = "This anomaly causes more hazardous weather effects to manifest indoors, like thunderstorms with frequent lightning strikes. \
		This version will trigger lightning strikes which can cause decent damage to people and equipment alike."
	min_wizard_trigger_potency = 2
	max_wizard_trigger_potency = 7

/datum/round_event/anomaly/anomaly_weather/thundering
	start_when = ANOMALY_START_DANGEROUS_TIME
	announce_when = ANOMALY_ANNOUNCE_DANGEROUS_TIME
	anomaly_path = /obj/effect/anomaly/weather/thundering

/datum/round_event/anomaly/anomaly_weather/thundering/announce(fake)
	if(isnull(impact_area))
		impact_area = placer.findValidArea()
	priority_announce("Severe barometric anomaly detected on [ANOMALY_ANNOUNCE_DANGEROUS_TEXT] [impact_area.name].", "Anomaly Alert")

/datum/event_admin_setup/listed_options/weather_anomaly
	input_text = "Weather type? Be very careful with the dangerous ones!"
	normal_run_option = "Default"

/datum/event_admin_setup/listed_options/weather_anomaly/get_list()
	return valid_subtypesof(/datum/weather)

/datum/event_admin_setup/listed_options/weather_anomaly/apply_to_event(datum/round_event/anomaly/anomaly_weather/event)
	event.forced_weather_type = chosen

/datum/event_admin_setup/listed_options/weather_thunder
	input_text = "Thunder chance? Be careful with high values!"
	normal_run_option = "Default"

/datum/event_admin_setup/listed_options/weather_thunder/get_list()
	return GLOB.thunder_chance_options.Copy()

/datum/event_admin_setup/listed_options/weather_thunder/apply_to_event(datum/round_event/anomaly/anomaly_weather/event)
	event.forced_thunder_chance = GLOB.thunder_chance_options[chosen]
