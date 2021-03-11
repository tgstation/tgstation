/// Adventure wrapper event
/datum/exploration_event/adventure
	discovery_log = "Ecountered something unexpected"
	var/datum/adventure/adventure
	root_abstract_type = /datum/exploration_event/adventure

/datum/exploration_event/adventure/ecounter(obj/item/exodrone/drone)
	. = ..()
	drone.start_adventure(adventure)
