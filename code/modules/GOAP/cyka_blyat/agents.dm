/datum/goap_agent/russian
	info = /datum/goap_info_provider/russian

/datum/goap_agent/russian/able_to_run()
	var/mob/living/M = agent
	if(!M)
		qdel(src)
		return FALSE
	if(M.stat)
		return FALSE
	return ..()

/datum/goap_agent/russian/New()
	..()
	our_actions += new /datum/goap_action/russian/attack()
	our_actions += new /datum/goap_action/russian/attack_ranged()
	our_actions += new /datum/goap_action/russian/grenade_out_take_cover()
	our_actions += new /datum/goap_action/russian/reload()

/datum/goap_agent/russian/medic/New()
	..()
	our_actions += new /datum/goap_action/russian/medic()

/datum/goap_agent/russian/engineer/New()
	..()
	our_actions += new /datum/goap_action/russian/resupply()

/datum/goap_agent/russian_melee
	info = /datum/goap_info_provider/russian_melee

/datum/goap_agent/russian_melee/New()
	..()
	our_actions += new /datum/goap_action/russian/dodge()
	our_actions += new /datum/goap_action/russian/melee()
	our_actions += new /datum/goap_action/russian/throw_knives()

/datum/goap_agent/russian_melee/able_to_run()
	var/mob/living/M = agent
	if(!M)
		qdel(src)
		return FALSE
	if(M.stat)
		return FALSE
	return ..()

/datum/goap_agent/russian_sniper
	info = /datum/goap_info_provider/russian

/datum/goap_agent/russian_sniper/able_to_run()
	var/mob/living/M = agent
	if(!M)
		qdel(src)
		return
	if(M.stat)
		return FALSE
	return ..()

/datum/goap_agent/russian_sniper/New() // No melee, strong gun though
	..()
	our_actions += new /datum/goap_action/russian/attack_ranged()
	our_actions += new /datum/goap_action/russian/grenade_out_take_cover()
	our_actions += new /datum/goap_action/russian/reload()
	our_actions += new /datum/goap_action/russian/dodge()
