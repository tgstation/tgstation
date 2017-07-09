/datum/goap_agent/cleanbot
	info = /datum/goap_info_provider/cleanbot


/datum/goap_agent/cleanbot/New()
	..()

	our_actions += new /datum/goap_action/cleanbot/clean_decal()
	our_actions += new /datum/goap_action/cleanbot/clean_item()
	our_actions += new /datum/goap_action/cleanbot/clean_animal()
	our_actions += new /datum/goap_action/cleanbot/foam()
	our_actions += new /datum/goap_action/cleanbot/clean_faces()