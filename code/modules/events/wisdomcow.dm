/datum/round_event_control/wisdomcow
	name = "Wisdom cow"
	typepath = /datum/round_event/wisdomcow
	max_occurrences = 1
	weight = 20

/datum/round_event/wisdomcow/announce(fake)
	priority_announce("A wise cow has been spotted in the area. Be sure to ask his advice.", "Nanotrasen Cow Ranching Agency")

/datum/round_event/wisdomcow/start()
	var/turf/targetloc = get_random_station_turf()
	new /mob/living/simple_animal/cow/wisdom(targetloc)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, targetloc)
	smoke.start()

