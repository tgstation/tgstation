/datum/round_event_control/anomaly/anomaly_dimensional
	name = "Anomaly: Dimensional"
	typepath = /datum/round_event/anomaly/anomaly_dimensional

	min_players = 10
	max_occurrences = 5
	weight = 20
	description = "This anomaly replaces the materials of the surrounding area."
	admin_setup = /datum/event_admin_setup/listed_options/anomaly_dimensional

/datum/round_event/anomaly/anomaly_dimensional
	start_when = 10
	announce_when = 3
	anomaly_path = /obj/effect/anomaly/dimensional
	/// What theme should the anomaly initially apply to the area?
	var/anomaly_theme

/datum/round_event/anomaly/anomaly_dimensional/apply_anomaly_properties(obj/effect/anomaly/dimensional/new_anomaly)
	if (!anomaly_theme)
		return
	new_anomaly.prepare_area(new_theme_path = anomaly_theme)

/datum/round_event/anomaly/anomaly_dimensional/announce(fake)
	priority_announce("Localized dimensional instability detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/event_admin_setup/listed_options/anomaly_dimensional
	input_text = "Select a dimensional anomaly theme?"
	normal_run_option = "Random Theme"
	///The admin-chosen spawn location.
	var/turf/spawn_location

/datum/event_admin_setup/listed_options/anomaly_dimensional/get_list()
	return subtypesof(/datum/dimension_theme)

/datum/event_admin_setup/listed_options/anomaly_dimensional/prompt_admins()
	. = ..()
	if (. == ADMIN_CANCEL_EVENT)
		return ADMIN_CANCEL_EVENT
	if (tgui_alert(usr, "Spawn anomaly at your current location?", "Anomaly Alert", list("Yes", "No")) == "Yes")
		spawn_location = get_turf(usr)

/datum/event_admin_setup/listed_options/anomaly_dimensional/apply_to_event(datum/round_event/anomaly/anomaly_dimensional/event)
	event.spawn_location = spawn_location
	event.anomaly_theme = chosen
