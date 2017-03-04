/datum/round_event_control/wizard/ghost //The spook is real
	name = "G-G-G-Ghosts!"
	weight = 3
	typepath = /datum/round_event/wizard/ghost
	max_occurrences = 5
	earliest_start = 0

/datum/round_event/wizard/ghost/start()
	for(var/mob/dead/observer/G in player_list)
		G.invisibility = 0
		G << "You suddenly feel extremely obvious..."


//--//

/datum/round_event_control/wizard/possession //Oh shit
	name = "Possessing G-G-G-Ghosts!"
	weight = 2
	typepath = /datum/round_event/wizard/possession
	max_occurrences = 5
	earliest_start = 0

/datum/round_event/wizard/possession/start()
	for(var/mob/dead/observer/G in player_list)
		G.verbs += /mob/dead/observer/verb/boo
		G.verbs += /mob/dead/observer/verb/possess
		G << "You suddenly feel a welling of new spooky powers..."
