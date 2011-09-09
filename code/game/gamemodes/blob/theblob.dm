
/obj/blob
	name = "blob"
	icon = 'blob.dmi'
	icon_state = "blob"
	density = 1
	opacity = 0
	anchored = 1
	var/active = 1
	var/health = 40


	New(loc, var/h = 30)
		blobs += src
		src.health = h
		src.dir = pick(1,2,4,8)
		src.update()
		..(loc)


	Del()
		blobs -= src
		..()

/*
	proc/poisoned(iteration)
		src.health -= 20
		src.update()
		for(var/obj/blob/B in orange(1,src))
			if(prob(100/(iteration/2)))
				spawn(rand(10,100))
					if(B)
						B.poisoned(iteration+1)
*/


	proc/Life()
		if(!active)	return

		var/turf/U = src.loc

	/*	if (locate(/obj/movable, U))
			U = locate(/obj/movable, U)
			if(U.density == 1)
				del(src)
		if(U.poison> 200000)
			src.health -= round(U.poison/200000)
			src.update()
			return
	*/
		//Bad blob you can not into space
		if(istype(U, /turf/space))
			src.health -= 15
			src.update()

		var/p = health //TODO: DEFERRED * (U.n2/11376000 + U.oxygen/1008000 + U.co2/200)

		if(!prob(p))	return

		for(var/dirn in cardinal)
			sleep(3) // -- Skie
			var/turf/T = get_step(src, dirn)

			if (istype(T.loc, /area/arrival))
				continue

			var/obj/blob/B = new /obj/blob(U, src.health)

			if(T.Enter(B,src) && !(locate(/obj/blob) in T))
				B.loc = T							// open cell, so expand
			else
				if(prob(60))						// closed cell, 40% chance to not expand
					if(!locate(/obj/blob) in T)
						for(var/atom/A in T)			// otherwise explode contents of turf
							A.blob_act()

						T.blob_act()
				del(B)


	ex_act(severity)
		switch(severity)
			if(1)
				del(src)
			if(2)
				src.health -= rand(60,90)
				src.update()
			if(3)
				src.health -= rand(30,40)
				src.update()


	proc/update()
		if(health <= 0)
			playsound(src.loc, 'splat.ogg', 50, 1)
			del(src)
			return
		if(health<10)
			icon_state = "blob_damaged"
			return
		if(health<20)
			icon_state = "blob_damaged2"
			return


	bullet_act(var/obj/item/projectile/Proj)
		health -= Proj.damage
		update()


	attackby(var/obj/item/weapon/W, var/mob/user)
		playsound(src.loc, 'attackblob.ogg', 50, 1)
		src.visible_message("\red <B>The [src] has been attacked with \the [W][(user ? " by [user]." : ".")]")
		var/damage = W.force / 4.0
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.welding)
				damage = 15
				playsound(src.loc, 'Welder.ogg', 100, 1)

		src.health -= damage
		src.update()


	examine()
		set src in oview(1)
		usr << "Some blob thing."


/datum/station_state/proc/count()
	for(var/turf/T in world)
		if(T.z != 1)
			continue

		if(istype(T,/turf/simulated/floor))
			if(!(T:burnt))
				src.floor+=2
			else
				src.floor++

		else if(istype(T, /turf/simulated/floor/engine))
			src.floor+=2

		else if(istype(T, /turf/simulated/wall))
			if(T:intact)
				src.wall+=2
			else
				src.wall++

		else if(istype(T, /turf/simulated/wall/r_wall))
			if(T:intact)
				src.r_wall+=2
			else
				src.r_wall++

	for(var/obj/O in world)
		if(O.z != 1)
			continue

		if(istype(O, /obj/window))
			src.window++
		else if(istype(O, /obj/grille))
			if(!O:destroyed)
				src.grille++
		else if(istype(O, /obj/machinery/door))
			src.door++
		else if(istype(O, /obj/machinery))
			src.mach++


/datum/station_state/proc/score(var/datum/station_state/result)
	var/r1a = min( result.floor / floor, 1.0)
	var/r1b = min(result.r_wall/ r_wall, 1.0)
	var/r1c = min(result.wall / wall, 1.0)
	var/r2a = min(result.window / window, 1.0)
	var/r2b = min(result.door / door, 1.0)
	var/r2c = min(result.grille / grille, 1.0)
	var/r3 = min(result.mach / mach, 1.0)
	//diary << "Blob scores:[r1b] [r1c] / [r2a] [r2b] [r2c] / [r3] [r1a]"
	return (4*(r1b+r1c) + 2*(r2a+r2b+r2c) + r3+r1a)/16.0

//////////////////////////////****IDLE BLOB***/////////////////////////////////////

/obj/blob/idle
	name = "blob"
	desc = "it looks... tasty"
	icon_state = "blobidle0"

	New(loc, var/h = 10)
		src.health = h
		src.dir = pick(1,2,4,8)
		src.update_idle()


	proc/update_idle()			//put in stuff here to make it transform? Maybe when its down to around 5 health?
		if(health<=0)
			del(src)
			return
		if(health<4)
			icon_state = "blobc0"
			return
		if(health<10)
			icon_state = "blobb0"
			return
		icon_state = "blobidle0"


	Del()		//idle blob that spawns a normal blob when killed.
		var/obj/blob/B = new /obj/blob( src.loc )
		spawn(30)
			B.Life()
		..()

