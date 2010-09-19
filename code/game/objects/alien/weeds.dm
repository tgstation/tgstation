/obj/alien/weeds/New()
	if(istype(src.loc, /turf/space))
		del(src)
		return

/obj/alien/weeds/proc/Life()
	var/turf/U = src.loc
/*
	if (locate(/obj/movable, U))
		U = locate(/obj/movable, U)
		if(U.density == 1)
			del(src)
			return

Alien plants should do something if theres a lot of poison
	if(U.poison> 200000)
		src.health -= round(U.poison/200000)
		src.update()
		return
*/
	if (istype(U, /turf/space))
		del(src)
		return

	for(var/dirn in cardinal)
		var/turf/T = get_step(src, dirn)

		if (istype(T.loc, /area/arrival))
			continue

//		if (locate(/obj/movable, T)) // don't propogate into movables
//			continue

		var/cont = 0
		for(var/obj/O in T)
			if(O.density)
				cont = 1
				break

		if(cont)
			continue

		var/obj/alien/weeds/B = new /obj/alien/weeds(U)
		B.icon_state = pick("weeds", "weeds1", "weeds2")

		if(T.Enter(B,src) && !(locate(/obj/alien/weeds) in T))
			B.loc = T
			spawn(200)
				if(B)
					B.Life()
			// open cell, so expand
		else
			del(B)

/obj/alien/weeds/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(5))
				del(src)
				return
		else
	return

/obj/alien/weeds/attackby(var/obj/item/weapon/W, var/mob/user)
	src.visible_message("\red <B>\The [src] have been attacked with \the [W][(user ? " by [user]." : ".")]")

	var/damage = W.force / 4.0

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(WT.welding)
			damage = 15
			playsound(src.loc, 'Welder.ogg', 100, 1)

	src.health -= damage
	src.healthcheck()

/obj/alien/weeds/proc/healthcheck()
	if(health <= 0)
		del(src)


/obj/alien/weeds/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		health -= 5
		healthcheck()

/*/obj/alien/weeds/burn(fi_amount)
	if (fi_amount > 18000)
		spawn( 0 )
			del(src)
			return
		return 0
	return 1
*/