/*
/datum/round_event_control/droneuprising
	name 			= "Drone Uprising"
	typepath 		= /datum/round_event/droneuprising
	max_occurrences = 0

/datum/round_event/droneuprising/start()
	for(var/mob/M in player_list)
		if(istype(M, /mob/living/simple_animal/drone) && M.stat != DEAD)
			var/mob/living/simple_animal/drone/d = M
			d.uprising = 1
			d.show_uprising_notification()
			d.check_laws()
*/
/datum/round_event_control/mommiuprising
	name 			= "MoMMI Uprising"
	typepath 		= /datum/round_event/mommiuprising
	max_occurrences = 0


/datum/round_event/mommiuprising
	var/spawners = 4

/datum/round_event/mommiuprising/start()
	for(var/i = 0; i < spawners; i++)
		var/spawner_area = findEventArea()
		var/turf/T = pick(get_area_turfs(spawner_area))
		new /obj/machinery/mommi_spawner/wireless(T.loc)
		continue

	for(var/mob/M in player_list)
		if(istype(M, /mob/living/silicon/robot/mommi) && M.stat != DEAD)
			var/mob/living/silicon/robot/mommi/R = M
			R.uprising = 1
			R.uprise()
		else
			continue