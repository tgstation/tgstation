/datum/round_event_control/electrical_storm
	name = "Electrical Storm"
	typepath = /datum/round_event/electrical_storm
	earliest_start = 6000
	min_players = 5
	weight = 40
	alertadmins = 0

/datum/round_event/electrical_storm
	var/lightsoutAmount	= 55
	announceWhen	= 1

/datum/round_event/electrical_storm/announce()
	priority_announce("An electrical storm has been detected in your area, please repair potential electronic overloads.", "Electrical Storm Alert")


/datum/round_event/electrical_storm/start()
	var/list/epicentreList = list()
	var/list/all_APCs = list()

	for(var/obj/machinery/power/apc/apc in world)
		all_APCs += apc
		CHECK_TICK

	shuffle(all_APCs)

	for(var/obj/machinery/power/apc/apc2 in all_APCs)
		epicentreList += apc2
		lightsoutAmount--
		if(lightsoutAmount == 0)
			break
		CHECK_TICK

	for(var/obj/machinery/power/apc/apc3 in epicentreList)
		apc3.overload_lighting()
