/datum/goap_agent/cleanbot
	info = /datum/goap_info_provider/cleanbot
	works_when_alone = TRUE


/datum/goap_agent/cleanbot/New()
	..()
	our_actions += new /datum/goap_action/cleanbot/clean()
	our_actions += new /datum/goap_action/bot/patrol()