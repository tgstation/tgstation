/obj/effect/mine
	name = "proximity mine"
	desc = "Better stay away from that thing."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglymine"
	var/minepayload = "explosive"
	var/triggered = 0

/obj/effect/mine/New()
	icon_state = "uglyminearmed"

/obj/effect/mine/Crossed(AM as mob|obj)
	Bumped(AM)

/obj/effect/mine/Bumped(AM as mob|obj)

	if(triggered) return
	visible_message("<span class='danger'>[AM] sets off \icon[src] [src]!</span>")
	triggermine(AM, minepayload)

/obj/effect/mine/proc/triggermine(mob/victim, var/triggertype)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	switch(triggertype)
		if("explosive")
			explosion(loc, 0, 1, 2, 3)
		if("triggerkick")
			if(isliving(victim) && victim.client)
				victim << "<font color='red'><b>You have been kicked FOR NO REISIN!<b></font>"
				del(victim.client)
		if("triggerplasma")
			atmos_spawn_air(SPAWN_TOXINS, 360)
		if("triggern2o")
			atmos_spawn_air(SPAWN_N2O, 360)
		if("triggerstun")
			if(isliving(victim))
				victim.Weaken(8)


	triggered = 1
	qdel(src)

/obj/effect/mine/plasma
	name = "plasma mine"
	icon_state = "uglymine"
	minepayload = "triggerplasma"

/obj/effect/mine/n2o
	name = "\improper N2O mine"
	icon_state = "uglymine"
	minepayload = "triggern2o"

/obj/effect/mine/stun
	name = "stun mine"
	icon_state = "uglymine"
	minepayload = "triggerstun"

/obj/effect/mine/kickmine
	name = "kick mine"
	icon_state = "uglymine"
	minepayload = "triggerkick"