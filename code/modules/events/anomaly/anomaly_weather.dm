/datum/round_event_control/anomaly/anomaly_weather
	name = "Anomaly: Weather"
	typepath = /datum/round_event/anomaly/anomaly_weather

	max_occurrences = 2
	weight = 10
	description = "Эта аномалия приводит к тому, что погодные условия проявляются в помещении. \
		Она может вызвать совершенно безобидную погоду, такую как небольшой дождь, или что-то такое как снежные бури, что может нанести вред незащищенным людям. \
		Обратите внимание, одновременное использование нескольких эффектов, скорее всего, приведет к нарушению звуковых эффектов погоды."
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
	priority_announce("Барометрическая аномалия обнаружена на [ANOMALY_ANNOUNCE_HARMFUL_TEXT] [impact_area.declent_ru(NOMINATIVE)].", "Обнаружена аномалия")

/datum/round_event/anomaly/anomaly_weather/make_anomaly(turf/anomaly_turf)
	return new anomaly_path(anomaly_turf, null, null, forced_weather_type, forced_thunder_chance)

/datum/round_event_control/anomaly/anomaly_weather/thundering
	name = "Anomaly: Thundering Weather"
	typepath = /datum/round_event/anomaly/anomaly_weather/thundering

	max_occurrences = 1
	weight = 5
	description = "Эта аномалия приводит к более опасным погодным явлениям в помещении, таким как грозы с частыми ударами молний. \
		Эта версия вызовет удары молнии, которые могут нанести значительный ущерб как людям, так и оборудованию."
	min_wizard_trigger_potency = 2
	max_wizard_trigger_potency = 7

/datum/round_event/anomaly/anomaly_weather/thundering
	start_when = ANOMALY_START_DANGEROUS_TIME
	announce_when = ANOMALY_ANNOUNCE_DANGEROUS_TIME
	anomaly_path = /obj/effect/anomaly/weather/thundering

/datum/round_event/anomaly/anomaly_weather/thundering/announce(fake)
	if(isnull(impact_area))
		impact_area = placer.findValidArea()
	priority_announce("Серьезная барометрическая аномалия обнаружена на [ANOMALY_ANNOUNCE_DANGEROUS_TEXT] [impact_area.declent_ru(NOMINATIVE)].", "Обнаружена аномалия")

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
