#define METEOR_TEMPERATURE

/var/const/meteor_wave_delay = 625 //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

/var/const/meteors_in_wave = 20
/var/const/meteors_in_small_wave = 10

/proc/meteor_wave(var/number = meteors_in_wave)
	if(!ticker || wavesecret)
		return

	var/startx
	var/starty
	var/endx
	var/endy
	var/turf/pickedstart
	var/turf/pickedgoal
	switch(pick(1,2,3,4))
		if(1) //NORTH
			starty = world.maxy-3
			startx = rand(1, world.maxx-1)
			endy = 1
			endx = rand(1, world.maxx-1)
		if(2) //EAST
			starty = rand(1,world.maxy-1)
			startx = world.maxx-3
			endy = rand(1, world.maxy-1)
			endx = 1
		if(3) //SOUTH
			starty = 3
			startx = rand(1, world.maxx-1)
			endy = world.maxy-1
			endx = rand(1, world.maxx-1)
		if(4) //WEST
			starty = rand(1, world.maxy-1)
			startx = 3
			endy = rand(1,world.maxy-1)
			endx = world.maxx-1
	pickedstart = locate(startx, starty, 1)
	pickedgoal = locate(endx, endy, 1)
	wavesecret = 1
	for(var/i = 0 to number)
		spawn(rand(10,100))
			spawn_meteor(pickedstart, pickedgoal)
	spawn(meteor_wave_delay)
		wavesecret = 0

/proc/spawn_meteors(var/turf/pickedstart, var/turf/pickedgoal, var/number = meteors_in_small_wave)
	for(var/i = 0; i < number; i++)
		spawn(0)
			spawn_meteor(pickedstart, pickedgoal)

/proc/spawn_meteor(var/turf/pickedstart, var/turf/pickedgoal)

	var/route = rand(1,5)
	var/turf/tempgoal = pickedgoal
	for(var/i, i < route, i++)
		tempgoal = get_step(tempgoal,rand(1,8))

	var/obj/effect/meteor/M
	switch(rand(1, 100))
		if(1 to 15)
			M = new /obj/effect/meteor/big(pickedstart)
		if(16 to 75)
			M = new /obj/effect/meteor( pickedstart )
		if(76 to 100)
			M = new /obj/effect/meteor/small( pickedstart )

	M.dest = tempgoal

	do
		sleep(1)
		walk_towards(M, M.dest, 1)
	while (!istype(M.loc, /turf/space) || pickedstart.loc.name != "Space" ) //FUUUCK, should never happen.

	return

/obj/effect/meteor
	name = "meteor"
	icon = 'meteor.dmi'
	icon_state = "flaming"
	density = 1
	anchored = 1.0
	var/hits = 1
	var/dest
	pass_flags = PASSTABLE

/obj/effect/meteor/small
	name = "small meteor"
	icon_state = "smallf"
	pass_flags = PASSTABLE | PASSGRILLE

/obj/effect/meteor/Move()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(METEOR_TEMPERATURE, 1000)
	..()
	return

/obj/effect/meteor/Bump(atom/A)
	spawn(0)
		for(var/mob/M in range(10, src))
			if(!M.stat && !istype(M, /mob/living/silicon/ai)) //bad idea to shake an ai's view
				shake_camera(M, 3, 1)
		if (A)
			A.meteorhit(src)
			playsound(get_turf(src), 'meteorimpact.ogg', 40, 1)
		if (--src.hits <= 0)
			if(prob(15))// && !istype(A, /obj/structure/grille))
				explosion(get_turf(src), 4, 5, 6, 7, 0)
				playsound(get_turf(src), "explosion", 50, 1)
			del(src)
	return


/obj/effect/meteor/ex_act(severity)
	spawn(0)
		del(src)
	return

/obj/effect/meteor/big
	name = "big meteor"
	hits = 5

	ex_act(severity)
		return

	Bump(atom/A)
		spawn(0)
			for(var/mob/M in range(10, src))
				if(!M.stat && !istype(M, /mob/living/silicon/ai)) //bad idea to shake an ai's view
					shake_camera(M, 3, 1)
			if (A)
				if(isobj(A))
					del(A)
				else
					A.meteorhit(src)
				src.hits--
				return
				playsound(get_turf(src), 'meteorimpact.ogg', 40, 1)
			if (--src.hits <= 0)
				if(prob(15) && !istype(A, /obj/structure/grille))
					explosion(get_turf(src), 1, 2, 3, 4, 0)
					playsound(get_turf(src), "explosion", 50, 1)
				del(src)
		return

/obj/effect/meteor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pickaxe))
		del(src)
		return
	..()