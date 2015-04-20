/obj/effect/mine
	name = "proximity mine"
	desc = "Better stay away from that thing."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglymine"
	var/triggered = 0

/obj/effect/mine/proc/mineEffect(mob/victim)
	explosion(loc, 0, 1, 2, 3)

/obj/effect/mine/Crossed(AM as mob|obj)
	if(isanimal(AM))
		var/mob/living/simple_animal/SA = AM
		if(!SA.flying)
			Bumped(SA)
	else
		Bumped(AM)

/obj/effect/mine/Bumped(AM as mob|obj)

	if(triggered) return
	visible_message("<span class='danger'>[AM] sets off \icon[src] [src]!</span>")
	triggermine(AM)

/obj/effect/mine/proc/triggermine(mob/victim)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	mineEffect(victim)
	triggered = 1
	qdel(src)


/obj/effect/mine/plasma
	name = "plasma mine"

/obj/effect/mine/plasma/mineEffect(mob/victim)
	atmos_spawn_air(SPAWN_TOXINS, 360)


/obj/effect/mine/n2o
	name = "\improper N2O mine"

/obj/effect/mine/n2o/mineEffect(mob/victim)
	atmos_spawn_air(SPAWN_N2O, 360)


/obj/effect/mine/stun
	name = "stun mine"

/obj/effect/mine/stun/mineEffect(mob/victim)
	if(isliving(victim))
		victim.Weaken(8)

/obj/effect/mine/kickmine
	name = "kick mine"

/obj/effect/mine/kickmine/mineEffect(mob/victim)
	if(isliving(victim) && victim.client)
		victim << "<span class='userdanger'>You have been kicked FOR NO REISIN!</span>"
		del(victim.client)
