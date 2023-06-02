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
	///A list of turfs that will be damaged by this event.
	var/list/turfs_to_shred

/datum/round_event/earthquake/setup()
	epicenter = get_turf(pick(GLOB.generic_event_spawns))
	if(!epicenter)
		message_admins("Earthquake event failed to find a turf! generic_event_spawn landmarks may be absent or bugged. Aborting...")
		return

	message_admins("An earthquake is about to strike the [get_area_name(epicenter)] at [ADMIN_FLW(epicenter)].")

	///Picks two points generally opposite from each other
	var/turf/fracture_point_high = locate(epicenter.x + rand(3, 6), epicenter.y + rand(3, 6), epicenter.z)

	var/turf/fracture_point_low = locate(epicenter.x - rand(3, 6), epicenter.y - rand(3, 6), epicenter.z)

	turfs_to_shred = block(fracture_point_high, fracture_point_low)

/datum/round_event/earthquake/announce(fake)
	priority_announce("Planetary monitoring systems indicate a devastating seismic event in the near future.", "Seismic Report")

/datum/round_event/earthquake/start()
	notify_ghosts("The earthquake's epicenter has been located!", source = epicenter, header = "BWOOSHHRgHGhSHHrHGh")

/datum/round_event/earthquake/tick()
	if(ISMULTIPLE(activeFor, 5))
		for(var/mob/earthquake_witness as anything in GLOB.player_list)
			if(!is_station_level(earthquake_witness.z))
				continue
			shake_camera(earthquake_witness, 10, activeFor)

		for(var/turf/turf_to_quake in turfs_to_shred)
			turf_to_quake.Shake(0.1, 0.1)

/datum/round_event/earthquake/end()
	for(var/mob/earthquake_witness as anything in GLOB.player_list)
		if(!is_station_level(earthquake_witness.z) || !is_mining_level(earthquake_witness.z))
			continue
		shake_camera(earthquake_witness, 10, 5)

	for(var/turf/turf_to_shred in turfs_to_shred)
		SSexplosions.highturf += turf_to_shred
