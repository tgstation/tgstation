/datum/round_event_control/electrical_storm
	name = "Electrical Storm"
	typepath = /datum/round_event/electrical_storm
	earliest_start = 6000
	weight = 40
	alertadmins = 0

/datum/round_event/electrical_storm
	var/lightsoutAmount	= 1
	var/lightsoutRange	= 25
	announceWhen	= 1

/datum/round_event/electrical_storm/announce()
	priority_announce("An electrical storm has been detected in your area, please repair potential electronic overloads.", "Electrical Storm Alert")


/datum/round_event/electrical_storm/start()
	var/list/epicenterList = list()

	for(var/i=1, i <= lightsoutAmount, i++)
		var/list/possibleEpicenters = list()
		for(var/obj/effect/landmark/newEpicenter in landmarks_list)
			if(newEpicenter.name == "lightsout" && !(newEpicenter in epicenterList))
				possibleEpicenters += newEpicenter
		if(possibleEpicenters.len)
			epicenterList += pick(possibleEpicenters)
		else
			break

	if(!epicenterList.len)
		return

	for(var/obj/effect/landmark/epicenter in epicenterList)
		for(var/obj/machinery/power/apc/apc in range(epicenter,lightsoutRange))
			apc.overload_lighting()
