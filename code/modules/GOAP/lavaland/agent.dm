/datum/goap_agent/lavaland
	info = /datum/goap_info_provider/lavaland
s

/datum/goap_agent/lavaland/New()
	..()
	if(!is_megafauna)
		our_actions += new /datum/goap_action/lavaland/attack_enemy()
		our_actions += new /datum/goap_action/lavaland/attack_ranged()
	else
		our_actions += new /datum/goap_action/lavaland/rip_and_tear()
		our_actions += new /datum/goap_action/lavaland/your_guts() // ARE OFF THE BOAT

/datum/goap_agent/lavaland/megafauna
	is_megafauna = TRUE