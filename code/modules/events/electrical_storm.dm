/datum/round_event_control/electrical_storm
	name = "Electrical Storm"
	typepath = /datum/round_event/electrical_storm
	earliest_start = 10 MINUTES
	min_players = 5
	weight = 40
	alertadmins = 0
	var/used_epicentres = list()

/datum/round_event/electrical_storm
	var/lightsoutAmount	= 1
	var/lightsoutRange	= 25
	var/intensity = 0
	announceWhen	= 1

/datum/round_event/electrical_storm/announce(fake)
	var/intensitytext =	""
	if(intensity >= 85)
		intensitytext = "very powerful"
	else if(intensity >= 75)
		intensitytext = "powerful"
	else if(intensity >= 50)
		intensitytext = "moderate"
	else if(intensity >= 25)
		intensitytext = "mild"
	else if(intensity >= 15)
		intensitytext = "weak"
	else if(intensity < 15)
		intensitytext = "very weak"
	priority_announce("A [intensitytext] electrical storm has been detected in your area, please repair potential electronic overloads.", "Electrical Storm Alert")

/datum/round_event/electrical_storm/start()
	var/list/epicentreList = list()

	for(var/i=1, i <= lightsoutAmount, i++)
		var/turf/T = find_safe_turf()
		if(istype(T))
			epicentreList += T

	if(!epicentreList.len)
		return

	intensity = rand(1,100)

	for(var/centre in epicentreList)
		for(var/a in GLOB.apcs_list)
			var/obj/machinery/power/apc/A = a
			if(get_dist(centre, A) <= lightsoutRange)
				A.overload_lighting(intensity)
