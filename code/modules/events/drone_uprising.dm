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
