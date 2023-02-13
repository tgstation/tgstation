/datum/round_event_control/anomaly/anomaly_flux
	name = "Anomaly: Hyper-Energetic Flux"
	typepath = /datum/round_event/anomaly/anomaly_flux

	min_players = 10
	max_occurrences = 5
	weight = 20
	description = "This anomaly shocks and explodes."
	min_wizard_trigger_potency = 1
	max_wizard_trigger_potency = 4

/datum/round_event/anomaly/anomaly_flux
	start_when = 10
	announce_when = 3
	anomaly_path = /obj/effect/anomaly/flux

/datum/round_event/anomaly/anomaly_flux/announce(fake)
	priority_announce("Localized hyper-energetic flux wave detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")
