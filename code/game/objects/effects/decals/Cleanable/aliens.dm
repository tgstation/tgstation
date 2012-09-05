// Note: BYOND is object oriented. There is no reason for this to be copy/pasted blood code.

/obj/effect/decal/cleanable/xenoblood
	name = "xeno blood"
	desc = "It's green and acidic. It looks like... <i>blood?</i>"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")
	var/list/viruses = list()
	blood_DNA = list()

	Del()
		for(var/datum/disease/D in viruses)
			D.cure(0)
		..()

/obj/effect/decal/cleanable/xenoblood/xgibs/proc/streak(var/list/directions)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if (i > 0)
				var/obj/effect/decal/cleanable/xenoblood/b = new /obj/effect/decal/cleanable/xenoblood/xsplatter(src.loc)
				for(var/datum/disease/D in src.viruses)
					b.viruses += D
			if (step_to(src, get_step(src, direction), 0))
				break

/obj/effect/decal/cleanable/xenoblood/xsplatter
	random_icon_states = list("xgibbl1", "xgibbl2", "xgibbl3", "xgibbl4", "xgibbl5")

/obj/effect/decal/cleanable/xenoblood/xgibs
	name = "xeno gibs"
	desc = "Gnarly..."
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'
	icon_state = "xgib1"
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6")

/obj/effect/decal/cleanable/xenoblood/xgibs/up
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibup1","xgibup1","xgibup1")

/obj/effect/decal/cleanable/xenoblood/xgibs/down
	random_icon_states = list("xgib1", "xgib2", "xgib3", "xgib4", "xgib5", "xgib6","xgibdown1","xgibdown1","xgibdown1")

/obj/effect/decal/cleanable/xenoblood/xgibs/body
	random_icon_states = list("xgibhead", "xgibtorso")

/obj/effect/decal/cleanable/xenoblood/xgibs/limb
	random_icon_states = list("xgibleg", "xgibarm")

/obj/effect/decal/cleanable/xenoblood/xgibs/core
	random_icon_states = list("xgibmid1", "xgibmid2", "xgibmid3")

/obj/effect/decal/cleanable/blood/xtracks
	icon_state = "xtracks"
	random_icon_states = null