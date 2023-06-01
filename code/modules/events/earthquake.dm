/datum/round_event_control/earthquake
	name = "Planetary Earthquake"
	typepath = /datum/round_event/earthquake
	min_players = 15
	max_occurrences = 3
	weight = 6
	description = "After a brief warning, creates a large tear in the structure of the station."
	min_wizard_trigger_potency = 3
	max_wizard_trigger_potency = 7
	map_flags = EVENT_PLANETARY_ONLY

/datum/round_event/earthquake
	start_when = 1
	announce_when = 8
	end_when = 25
	///The chosen location and center of our earthquake.
	var/turf/epicenter

/datum/round_event/earthquake/setup()
	epicenter = get_turf(pick(GLOB.generic_event_spawns))
	if(!epicenter)
		message_admins("Earthquake event failed to find a turf! generic_event_spawn landmarks may be absent or bugged. Aborting...")
		return

/datum/round_event/earthquake/announce(fake)
	priority_announce("Planetary monitoring systems indicate a devastating seismic event in the near future.", "Seismic Report")

/datum/round_event/earthquake/start()
	notify_ghosts("The earthquake's epicenter has been located!", source = epicenter, header = "BWOOSHHRgHGhSHHrHGh")

/datum/round_event/earthquake/tick()
	if(ISMULTIPLE(activeFor, 5))
		for(var/mob/earthquake_witness as anything in GLOB.player_list)
			if(!is_station_level(earthquake_witness.z))
				continue
			shake_camera(earthquake_witness, 20, 2)

/datum/round_event/earthquake/end()
	for(var/mob/earthquake_witness as anything in GLOB.player_list)
		if(!is_station_level(earthquake_witness.z) || !is_mining_level(earthquake_witness.z))
			continue
		shake_camera(earthquake_witness, 10, 5)
