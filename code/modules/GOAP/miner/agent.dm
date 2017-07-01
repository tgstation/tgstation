/datum/goap_agent/miner
	info = /datum/goap_info_provider/miner


/datum/goap_agent/miner/New()
	..()

	our_actions += new /datum/goap_action/miner/clear_hand()
	our_actions += new /datum/goap_action/miner/get_pickaxe()
	our_actions += new /datum/goap_action/miner/mine_turf()


/mob/living/carbon/human/dummy/miner/New()
	..()
	var/datum/outfit/job/miner/equipped/E = new /datum/outfit/job/miner/equipped()
	equipOutfit(E)
	var/datum/goap_agent/miner/M = new()
	M.agent = src