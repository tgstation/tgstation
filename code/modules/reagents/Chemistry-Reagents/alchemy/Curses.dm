/datum/reagent/alchemy/web_of_lies
	name = "Web of Lies"
	id = "web_of_lies"
	description = ""
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16
	speed_modifier = 4

/datum/reagent/alchemy/web_of_lies/on_mob_life(var/mob/living/M as mob)
	M.adjustToxLoss(0.5)
	..()

/datum/reagent/alchemy/web_of_lies/reaction_turf(var/turf/T, var/volume)
	if(T)
		var/obj/effect/spider/stickyweb/W = locate() in T
		if(!W)
			new /obj/effect/spider/stickyweb(T)
	..()

/datum/reagent/alchemy/web_of_lies/on_move()
	var/turf/T = get_turf(holder.my_atom)
	if(T)
		var/obj/effect/spider/stickyweb/W = locate() in T
		if(!W)
			new /obj/effect/spider/stickyweb(T)
	..()

/datum/reagent/alchemy/weakness_serum
	name = "Weakness Serum"
	id = "weakness_serum"
	description = ""
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16
	speed_modifier = 1
	damage_modifier = -5

/datum/reagent/alchemy/weakness_serum/on_mob_life(var/mob/living/M as mob)
	M.adjustToxLoss(1)
	..()