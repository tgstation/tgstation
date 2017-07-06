/datum/goap_agent/russian
	info = /datum/goap_info_provider/russian
s

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

/datum/goap_agent/russian_sniper
	info = /datum/goap_info_provider/russian
s

/datum/goap_agent/russian_sniper/New() // No melee, strong gun though
	..()
	our_actions += new /datum/goap_action/russian/attack_ranged()
	our_actions += new /datum/goap_action/russian/grenade_out_take_cover()
	our_actions += new /datum/goap_action/russian/reload()