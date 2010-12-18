#define METEOR_TEMPERATURE

/var/const/meteor_wave_delay = 625 //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

/var/const/meteors_in_wave = 150
/var/const/meteors_in_small_wave = 3

/proc/meteor_wave()
	if(!ticker || wavesecret)
		return

	wavesecret = 1
	for(var/i = 0 to meteors_in_wave)
		spawn(rand(10,100))
			spawn_meteor()
	spawn(meteor_wave_delay)
		wavesecret = 0

/proc/spawn_meteors()
	for(var/i = 0; i < meteors_in_small_wave; i++)
		spawn(0)
			spawn_meteor()

/proc/spawn_meteor()

	var/startside = pick(cardinal)
	var/startx
	var/starty
	var/endx
	var/endy
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 10//number of tries to spawn meteor.


	do
		switch(startside)
			if(NORTH)
				starty = world.maxy-1
				startx = rand(1, world.maxx-1)
				endy = 1
				endx = rand(1, world.maxx-1)
			if(EAST)
				starty = rand(1,world.maxy-1)
				startx = world.maxx-1
				endy = rand(1, world.maxy-1)
				endx = 1
			if(SOUTH)
				starty = 1
				startx = rand(1, world.maxx-1)
				endy = world.maxy-1
				endx = rand(1, world.maxx-1)
			if(WEST)
				starty = rand(1, world.maxy-1)
				startx = 1
				endy = rand(1,world.maxy-1)
				endx = world.maxx-1

		pickedstart = locate(startx, starty, 1)
		pickedgoal = locate(endx, endy, 1)
		max_i--
		if(max_i<=0) return

	while (!istype(pickedstart, /turf/space) || pickedstart.loc.name != "Space" ) //FUUUCK, should never happen.


	var/obj/meteor/M
	if(rand(50))
		M = new /obj/meteor( pickedstart )
	else
		M = new /obj/meteor/small( pickedstart )

	M.dest = pickedgoal
	spawn(0)
		walk_towards(M, M.dest, 1)

	return

/obj/meteor
	name = "meteor"
	icon = 'meteor.dmi'
	icon_state = "flaming"
	density = 1
	anchored = 1.0
	var/hits = 1
	var/dest

/obj/meteor/small
	name = "small meteor"
	icon_state = "smallf"

/obj/meteor/Move()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(METEOR_TEMPERATURE, 1000)
	..()
	return

/obj/meteor/Bump(atom/A)
	spawn(0)
		for(var/mob/M in range(10, src))
			if(!M.stat && !istype(M, /mob/living/silicon/ai)) //bad idea to shake an ai's view
				shake_camera(M, 3, 1)
		if (A)
			A.meteorhit(src)
			playsound(src.loc, 'meteorimpact.ogg', 40, 1)
		if (--src.hits <= 0)
			if(prob(15) && !istype(A, /obj/grille))
				explosion(src.loc, 0, 1, 2, 3)
				playsound(src.loc, "explosion", 50, 1)
			del(src)
	return


/obj/meteor/ex_act(severity)

	if (severity < 4)
		del(src)
	return
