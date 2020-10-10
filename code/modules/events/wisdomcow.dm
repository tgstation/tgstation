/datum/round_event_control/wisdomcow
	name = "Wisdom cow"
	typepath = /datum/round_event/wisdomcow
	max_occurrences = 1
	weight = 20

/datum/round_event/wisdomcow/announce(fake)
	priority_announce("A wise cow has been spotted in the area. Be sure to ask for her advice.", "Nanotrasen Cow Ranching Agency")

/datum/round_event/wisdomcow/start()
	var/turf/targetloc = get_random_station_turf()
	new /mob/living/simple_animal/cow/wisdom(targetloc)
	do_smoke(1, targetloc)

