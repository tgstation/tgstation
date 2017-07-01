/datum/goap_action/miner/clear_hand
	name = "clear a hand"
	cost = 2

/datum/goap_action/miner/clear_hand/New()
	..()
	preconditions = list()
	preconditions["freeHand"] = FALSE
	effects = list()
	effects["freeHand"] = TRUE

/datum/goap_action/miner/clear_hand/AdvancedPreconditions(atom/agent, list/worldstate)
	var/mob/living/carbon/human/H = agent
	if(H.get_empty_held_indexes())
		return FALSE
	else
		return TRUE

/datum/goap_action/miner/clear_hand/RequiresInRange()
	return FALSE

/datum/goap_action/miner/clear_hand/Perform(atom/agent)
	var/mob/living/carbon/human/H = agent
	var/obj/item/I = H.get_active_held_item()
	if(H.get_empty_held_indexes())
		return TRUE
	if(!I.equip_to_best_slot(H))
		H.drop_item()
	if(H.get_empty_held_indexes())
		return TRUE
	else
		return FALSE

/datum/goap_action/miner/clear_hand/CheckDone(atom/agent)
	var/mob/living/carbon/human/H = agent
	return (H.get_empty_held_indexes())

// get a pickaxe

/datum/goap_action/miner/get_pickaxe
	name = "get pickaxe"
	cost = 2

/datum/goap_action/miner/get_pickaxe/New()
	..()
	preconditions = list()
	preconditions["hasPickaxe"] = FALSE
	preconditions["freeHand"] = TRUE
	effects = list()
	effects["hasPickaxe"] = TRUE

/datum/goap_action/miner/get_pickaxe/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = oview(10, agent)
	var/mob/living/carbon/human/H = agent
	var/obj/item/weapon/pickaxe/pickax = locate(/obj/item/weapon/pickaxe) in H.get_contents()
	if(pickax != null)
		target = pickax
	else
		var/obj/item/weapon/pickaxe/P = locate(/obj/item/weapon/pickaxe) in viewl
		target = P
	return (target != null)

/datum/goap_action/miner/get_pickaxe/RequiresInRange()
	return TRUE

/datum/goap_action/miner/get_pickaxe/Perform(atom/agent)
	var/mob/living/carbon/human/H = agent
	if(target.loc == H)
		if(!H.is_holding(target))
			if(H.putItemFromInventoryInHandIfPossible(target, H.active_hand_index))
				return TRUE
		else
			return TRUE
	if(H.put_in_hands(target))
		return TRUE
	else
		return FALSE

/datum/goap_action/miner/get_pickaxe/CheckDone(atom/agent)
	var/mob/living/carbon/human/H = agent
	var/obj/item/weapon/pickaxe/P = locate(/obj/item/weapon/pickaxe) in H.get_contents()
	return (P != null)

// mine the turf

/datum/goap_action/miner/mine_turf
	name = "mine minerals"
	cost = 2

/datum/goap_action/miner/mine_turf/New()
	..()
	preconditions = list()
	preconditions["hasPickaxe"] = TRUE
	effects = list()
	effects["turfMined"] = TRUE

/datum/goap_action/miner/mine_turf/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = oview(10, agent)
	var/turf/closed/mineral/T = locate(/turf/closed/mineral) in viewl
	target = T
	return (target != null)

/datum/goap_action/miner/mine_turf/RequiresInRange()
	return TRUE

/datum/goap_action/miner/mine_turf/Perform(atom/agent)
	var/turf/closed/mineral/M = target
	var/mob/living/carbon/human/H = agent
	var/obj/item/weapon/pickaxe/P = locate(/obj/item/weapon/pickaxe) in H.get_contents()
	H.put_in_hands(P)
	M.attackby(P, H)
	return TRUE

/datum/goap_action/miner/mine_turf/CheckDone(atom/agent)
	return (!istype(target, /turf/closed/mineral))