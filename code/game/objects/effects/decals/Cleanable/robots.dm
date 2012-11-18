// Note: BYOND is object oriented. There is no reason for this to be copy/pasted blood code.

/obj/effect/decal/cleanable/robot_debris
	name = "robot debris"
	desc = "It's a useless heap of junk... <i>or is it?</i>"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/mob/robots.dmi'
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")

/obj/effect/decal/cleanable/robot_debris/proc/streak(var/list/directions)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if (i > 0)
				if (prob(40))
					/*var/obj/effect/decal/cleanable/oil/o =*/
					new /obj/effect/decal/cleanable/oil/streak(src.loc)
				else if (prob(10))
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(3, 1, src)
					s.start()
			if (step_to(src, get_step(src, direction), 0))
				break

/obj/effect/decal/cleanable/robot_debris/limb
	random_icon_states = list("gibarm", "gibleg")

/obj/effect/decal/cleanable/robot_debris/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibup1","gibup1") //2:7 is close enough to 1:4

/obj/effect/decal/cleanable/robot_debris/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7","gibdown1","gibdown1") //2:7 is close enough to 1:4

/obj/effect/decal/cleanable/oil
	name = "motor oil"
	desc = "It's black and greasy. Looks like Beepsky made another mess."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/mob/robots.dmi'
	icon_state = "floor1"
	var/viruses = list()
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")

	Del()
		for(var/datum/disease/D in viruses)
			D.cure(0)
		..()

/obj/effect/decal/cleanable/oil/streak
	random_icon_states = list("streak1", "streak2", "streak3", "streak4", "streak5")