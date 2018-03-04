/datum/goap_action/cleanbot/clean_decal
	name = "Clean Decal"
	cost = 1

/datum/goap_action/cleanbot/clean_decal/New()
	..()
	preconditions = list()
	effects = list()
	effects["cleanedMess"] = TRUE

/datum/goap_action/cleanbot/clean_decal/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = view(10, agent)
	var/obj/effect/decal/cleanable/P = locate(/obj/effect/decal/cleanable) in viewl
	target = P
	return (target != null)

/datum/goap_action/cleanbot/clean_decal/RequiresInRange()
	return TRUE

/datum/goap_action/cleanbot/clean_decal/Perform(atom/agent)
	var/mob/living/simple_animal/bot/B = agent
	B.icon_state = "cleanbot-c"
	B.visible_message("<span class='notice'>[B] cleans [target].</span>")
	qdel(target)
	B.icon_state = "cleanbot[B.on]"
	return TRUE

/datum/goap_action/cleanbot/clean_decal/CheckDone(atom/agent)
	return QDELETED(target)
/*
Cleaning trash items up
*/
/datum/goap_action/cleanbot/clean_item
	name = "Clean Item"
	cost = 2

/datum/goap_action/cleanbot/clean_item/New()
	..()
	preconditions = list()
	effects = list()
	effects["cleanedMess"] = TRUE

/datum/goap_action/cleanbot/clean_item/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = view(10, agent)
	var/obj/item/trash/P = locate(/obj/item/trash) in viewl
	target = P
	return (target != null)

/datum/goap_action/cleanbot/clean_item/RequiresInRange()
	return TRUE

/datum/goap_action/cleanbot/clean_item/Perform(atom/agent)
	var/mob/living/simple_animal/bot/B = agent
	B.visible_message("<span class='danger'>[B] sprays hydrofluoric acid at [target]!</span>")
	playsound(B.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
	qdel(target)
	return TRUE

/datum/goap_action/cleanbot/clean_item/CheckDone(atom/agent)
	return QDELETED(target)

/*
Removing pests
*/

/datum/goap_action/cleanbot/clean_animal
	name = "Clean Animal"
	cost = 3

/datum/goap_action/cleanbot/clean_animal/New()
	..()
	preconditions = list()
	effects = list()
	effects["cleanedMess"] = TRUE

/datum/goap_action/cleanbot/clean_animal/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = view(10, agent)
	var/mob/living/simple_animal/cockroach/C = locate(/mob/living/simple_animal/cockroach) in viewl
	var/mob/living/simple_animal/mouse/M = locate(/mob/living/simple_animal/mouse) in viewl
	if(C)
		target = C
	if(M)
		target = M
	return (target != null)

/datum/goap_action/cleanbot/clean_animal/RequiresInRange()
	return TRUE

/datum/goap_action/cleanbot/clean_animal/Perform(atom/agent)
	var/mob/living/simple_animal/bot/B = agent
	var/mob/living/simple_animal/S = target
	if(!S.stat)
		B.visible_message("<span class='danger'>[B] smashes [S] with its mop!</span>")
		S.death()
	return TRUE

/datum/goap_action/cleanbot/clean_animal/CheckDone(atom/agent)
	var/mob/living/simple_animal/S = target
	return (S.stat)