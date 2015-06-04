/datum/reagent/alchemy/web_of_lies
	name = "Web of Lies"
	id = "web_of_lies"
	description = ""
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16

/datum/reagent/alchemy/web_of_lies/on_mob_life(var/mob/living/M as mob)
	M.adjustToxLoss(0.5)
	M.status_flags |= SLOWDOWN
	..()

/datum/reagent/alchemy/web_of_lies/reaction_turf(var/turf/T, var/volume)
	if(T)
		var/obj/effect/spider/stickyweb/W = locate() in T
		if(!W)
			new /obj/effect/spider/stickyweb(T)
	..()

/datum/reagent/alchemy/web_of_lies/on_move(var/mob/M)
	var/turf/T = get_turf(M)
	if(T)
		var/obj/effect/spider/stickyweb/W = locate() in T
		if(!W)
			new /obj/effect/spider/stickyweb(T)
	..()