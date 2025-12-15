/datum/round_event_control/anomaly/anomaly_weather
	name = "Anomaly: Weather"
	typepath = /datum/round_event/anomaly/anomaly_weather

	max_occurrences = 2
	weight = 10
	description = "This anomaly causes weather effects to manifest indoors. \
		It can be cause completely harmless weather like light rain, or something which could harm unprotected individuals like snowstorms. \
		This version will not trigger lightning strikes."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 5

/datum/round_event/anomaly/anomaly_weather
	start_when = ANOMALY_START_HARMFUL_TIME
	announce_when = ANOMALY_ANNOUNCE_HARMFUL_TIME
	anomaly_path = /obj/effect/anomaly/weather

/datum/round_event/anomaly/anomaly_weather/announce(fake)
	if(isnull(impact_area))
		impact_area = placer.findValidArea()
	priority_announce("Barometric anomaly detected on [ANOMALY_ANNOUNCE_HARMFUL_TEXT] [impact_area.name].", "Anomaly Alert")

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
