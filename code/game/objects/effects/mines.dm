/obj/effect/mine
	name = "dummy mine"
	desc = "Better stay away from that thing."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglymine"
	var/triggered = 0

/obj/effect/mine/proc/mineEffect(mob/victim)
	victim << "<span class='danger'>*click*</span>"

/obj/effect/mine/Crossed(AM as mob|obj)
	if(isanimal(AM))
		var/mob/living/simple_animal/SA = AM
		if(!SA.flying)
			triggermine(SA)
	else
		triggermine(AM)

/obj/effect/mine/proc/triggermine(mob/victim)
	if(triggered)
		return
	visible_message("<span class='danger'>[victim] sets off \icon[src] [src]!</span>")
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	mineEffect(victim)
	triggered = 1
	qdel(src)


/obj/effect/mine/explosive
	name = "explosive mine"
	var/range_devastation = 0
	var/range_heavy = 1
	var/range_light = 2
	var/range_flash = 3

/obj/effect/mine/explosive/mineEffect(mob/victim)
	explosion(loc, range_devastation, range_heavy, range_light, range_flash)


/obj/effect/mine/stun
	name = "stun mine"
	var/stun_time = 8

/obj/effect/mine/stun/mineEffect(mob/victim)
	if(isliving(victim))
		victim.Weaken(stun_time)

/obj/effect/mine/kickmine
	name = "kick mine"

/obj/effect/mine/kickmine/mineEffect(mob/victim)
	if(isliving(victim) && victim.client)
		victim << "<span class='userdanger'>You have been kicked FOR NO REISIN!</span>"
		del(victim.client)


/obj/effect/mine/gas
	name = "oxygen mine"
	var/gas_amount = 360
	var/gas_type = SPAWN_OXYGEN

/obj/effect/mine/gas/mineEffect(mob/victim)
	atmos_spawn_air(gas_type, gas_amount)


/obj/effect/mine/gas/plasma
	name = "plasma mine"
	gas_type = SPAWN_TOXINS


/obj/effect/mine/gas/n2o
	name = "\improper N2O mine"
	gas_type = SPAWN_N2O


/obj/effect/mine/sound
	name = "honkblaster 1000"
	var/sound = 'sound/items/bikehorn.ogg'

/obj/effect/mine/sound/mineEffect(mob/victim)
	playsound(loc, sound, 100, 1)


/obj/effect/mine/sound/bwoink
	name = "bwoink mine"
	sound = 'sound/effects/adminhelp.ogg'
