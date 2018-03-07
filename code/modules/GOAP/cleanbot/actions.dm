/datum/goap_action/cleanbot/clean
	name = "Clean"
	cost = 1

/datum/goap_action/cleanbot/clean/New()
	..()
	preconditions = list()
	effects = list()
	effects["cleanedMess"] = TRUE

/datum/goap_action/cleanbot/clean/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = view(10, agent)
	var/P = locate(/obj/effect/decal/cleanable) in viewl
	if(!P)
		P = locate(/obj/item/trash) in viewl
		if(!P)
			P = locate(/mob/living/simple_animal/cockroach) in viewl
			if(!P)
				P = locate(/mob/living/simple_animal/mouse) in viewl
	target = P
	return (target != null)

/datum/goap_action/cleanbot/clean/RequiresInRange()
	return TRUE

/datum/goap_action/cleanbot/clean/Perform(atom/agent)
	var/mob/living/simple_animal/bot/B = agent
	B.icon_state = "cleanbot-c"
	if(istype(target, /obj/effect/decal/cleanable))
		B.visible_message("<span class='notice'>[B] cleans [target].</span>")
		qdel(target)
	if(istype(target, /obj/item/trash))
		B.visible_message("<span class='danger'>[B] sprays hydrofluoric acid at [target]!</span>")
		playsound(B.loc, 'sound/effects/spray2.ogg', 50, 1, -6)
		qdel(target)
	if(istype(target, /mob/living/simple_animal))
		var/mob/living/simple_animal/S = target
		if(!S.stat)
			B.visible_message("<span class='danger'>[B] smashes [S] with its mop!</span>")
			S.death()
	B.icon_state = "cleanbot[B.on]"
	return TRUE

/datum/goap_action/cleanbot/clean/CheckDone(atom/agent)
	if(istype(target, /mob/living/simple_animal))
		var/mob/living/simple_animal/S = target
		return (S.stat)
	return QDELETED(target)