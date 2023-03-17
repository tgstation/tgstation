/datum/round_event_control/anomaly/anomaly_dimensional
	name = "Anomaly: Dimensional"
	typepath = /datum/round_event/anomaly/anomaly_dimensional

	min_players = 10
	max_occurrences = 5
	weight = 20
	description = "This anomaly replaces the materials of the surrounding area."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 2
	admin_setup = list(/datum/event_admin_setup/set_location/anomaly, /datum/event_admin_setup/listed_options/anomaly_dimensional)

/datum/round_event/anomaly/anomaly_dimensional
	start_when = ANOMALY_START_MEDIUM_TIME
	announce_when = ANOMALY_ANNOUNCE_MEDIUM_TIME
	anomaly_path = /obj/effect/anomaly/dimensional
	/// What theme should the anomaly initially apply to the area?
	var/anomaly_theme

/datum/round_event/anomaly/anomaly_dimensional/apply_anomaly_properties(obj/effect/anomaly/dimensional/new_anomaly)
	if (!anomaly_theme)
		return
	new_anomaly.prepare_area(new_theme_path = anomaly_theme)

/datum/round_event/anomaly/anomaly_dimensional/announce(fake)
	priority_announce("Dimensional instability detected on [ANOMALY_ANNOUNCE_MEDIUM_TEXT] [impact_area.name].", "Anomaly Alert")

/datum/event_admin_setup/listed_options/anomaly_dimensional
	input_text = "Select a dimensional anomaly theme?"
	normal_run_option = "Random Theme"

/datum/event_admin_setup/listed_options/anomaly_dimensional/get_list()
	return subtypesof(/datum/dimension_theme)

/datum/event_admin_setup/listed_options/anomaly_dimensional/apply_to_event(datum/round_event/anomaly/anomaly_dimensional/event)
	event.anomaly_theme = chosen
