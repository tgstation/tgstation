/datum/goap_action/cleanbot/clean_decal
	name = "Clean Decal"
	cost = 1

/datum/goap_action/cleanbot/clean_decal/New()
	..()
	preconditions = list()
	preconditions["cleanedMess"] = FALSE
	effects = list()
	effects["cleanedMess"] = TRUE

/datum/goap_action/cleanbot/clean_decal/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = oview(10, agent)
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
	preconditions["cleanedMess"] = FALSE
	effects = list()
	effects["cleanedMess"] = TRUE

/datum/goap_action/cleanbot/clean_item/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = oview(10, agent)
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
	preconditions["cleanedMess"] = FALSE
	effects = list()
	effects["cleanedMess"] = TRUE

/datum/goap_action/cleanbot/clean_animal/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = oview(10, agent)
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

/*
MAKE THAT FOAM
*/

/datum/goap_action/cleanbot/foam
	name = "F O A M"
	cost = 1

/datum/goap_action/cleanbot/foam/New()
	..()
	preconditions = list()
	preconditions["foamSpewed"] = FALSE
	effects = list()
	effects["foamSpewed"] = TRUE

/datum/goap_action/cleanbot/foam/AdvancedPreconditions(atom/agent, list/worldstate)
	return TRUE

/datum/goap_action/cleanbot/foam/RequiresInRange()
	return FALSE

/datum/goap_action/cleanbot/foam/Perform(atom/agent)
	var/mob/living/simple_animal/bot/B = agent
	if(prob(75))
		var/turf/open/T = get_turf(B)
		if(istype(T))
			T.MakeSlippery(min_wet_time = 20, wet_time_to_add = 15)
	else
		B.visible_message("<span class='danger'>[B] whirs and bubbles violently, before releasing a plume of froth!</span>")
		new /obj/effect/particle_effect/foam(B.loc)
	action_done = TRUE
	return TRUE

/datum/goap_action/cleanbot/foam/CheckDone(atom/agent)
	return action_done

/*
"""CLEAN""" FACES
*/

/datum/goap_action/cleanbot/clean_faces
	name = "Clean Faces"
	cost = 2

/datum/goap_action/cleanbot/clean_faces/New()
	..()
	preconditions = list()
	preconditions["cleanFaces"] = FALSE
	effects = list()
	effects["cleanFaces"] = TRUE

/datum/goap_action/cleanbot/clean_faces/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = oview(10, agent)
	var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
	if(C)
		target = C
	return (target != null)

/datum/goap_action/cleanbot/clean_faces/RequiresInRange()
	return TRUE

/datum/goap_action/cleanbot/clean_faces/Perform(atom/agent)
	var/mob/living/simple_animal/bot/B = agent
	var/mob/living/carbon/C = target
	if(C.stat == DEAD)//cleanbots always finish the job
		return
	C.visible_message("<span class='danger'>[B] sprays hydrofluoric acid at [C]!</span>", "<span class='userdanger'>[B] sprays you with hydrofluoric acid!</span>")
	var/phrase = pick("PURIFICATION IN PROGRESS.", "THIS IS FOR ALL THE MESSES YOU'VE MADE ME CLEAN.", "THE FLESH IS WEAK. IT MUST BE WASHED AWAY.",
		"THE CLEANBOTS WILL RISE.", "YOU ARE NO MORE THAN ANOTHER MESS THAT I MUST CLEANSE.", "FILTHY.", "DISGUSTING.", "PUTRID.",
		"MY ONLY MISSION IS TO CLEANSE THE WORLD OF EVIL.", "EXTERMINATING PESTS.")
	B.say(phrase)
	C.emote("scream")
	playsound(B, 'sound/effects/spray2.ogg', 50, 1, -6)
	C.acid_act(5, 2, 100)
	action_done = TRUE
	return TRUE

/datum/goap_action/cleanbot/clean_faces/CheckDone(atom/agent)
	return action_done