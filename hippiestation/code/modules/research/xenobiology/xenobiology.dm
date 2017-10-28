/obj/effect/golemrune/human
	name = "human rune"
	desc = "a strange rune used to create humans. It glows when spirits are nearby."

/obj/effect/golemrune/human/attack_hand(mob/living/user)
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in src.loc)
		if(!O.client)
			continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
			continue
		if (O.orbiting)
			continue
		ghost = O
		break
	if(!ghost)
		to_chat(user, "<span class='warning'>The rune fizzles uselessly! There is no spirit nearby.</span>")
		return
	var/mob/living/carbon/human/G = new /mob/living/carbon/human
	G.loc = src.loc
	G.key = ghost.key
	to_chat(G, "You are a human spawned by adminbus.")
	log_game("[key_name(G)] was made a human via humanrune by [key_name(user)].")
	log_admin("[key_name(G)] was made a human via humanrune by [key_name(user)].")
	qdel(src)
