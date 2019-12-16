/datum/goap_agent/monkey
	info = /datum/goap_info_provider/monkey

/datum/goap_agent/monkey/able_to_run()
	var/mob/living/carbon/monkey/C = agent
	if(!C)
		qdel(src)
		return FALSE
	if(C.IsDeadOrIncap())
		return FALSE
	return ..()

/datum/goap_agent/monkey/New()
	. = ..()
	our_actions += new /datum/goap_action/monkey/shoot()
	our_actions += new /datum/goap_action/monkey/harm()
	our_actions += new /datum/goap_action/monkey/disarm()
	our_actions += new /datum/goap_action/monkey/flee()
	our_actions += new /datum/goap_action/monkey/grab()
	our_actions += new /datum/goap_action/monkey/GetItem()
	our_actions += new /datum/goap_action/monkey/pickpocket()
	our_actions += new /datum/goap_action/monkey/disposal()
	our_actions += new /datum/goap_action/monkey/throwitem()
