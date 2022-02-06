/// Adventure wrapper event
/datum/exploration_event/adventure
	discovery_log = "Encountered something unexpected"
	var/datum/adventure/adventure
	root_abstract_type = /datum/exploration_event/adventure

/datum/exploration_event/adventure/encounter(obj/item/exodrone/drone)
	. = ..()
	drone.start_adventure(adventure)
