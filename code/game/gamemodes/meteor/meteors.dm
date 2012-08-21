#define METEOR_TEMPERATURE

/var/const/meteor_wave_delay = 625 //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

/var/const/meteors_in_wave = 50
/var/const/meteors_in_small_wave = 10

/proc/meteor_wave(var/number = meteors_in_wave)
	if(!ticker || wavesecret)
		return

	wavesecret = 1
	for(var/i = 0 to number)
		spawn(rand(10,100))
			spawn_meteor()
	spawn(meteor_wave_delay)
		wavesecret = 0

/proc/spawn_meteors(var/number = meteors_in_small_wave)
	for(var/i = 0; i < number; i++)
		spawn(0)
			spawn_meteor()

/proc/spawn_meteor()

	var/startx
	var/starty
	var/endx
	var/endy
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 10//number of tries to spawn meteor.


	do
		switch(pick(1,2,3,4))
			if(1) //NORTH
				starty = world.maxy-(TRANSITIONEDGE+1)
				startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
				endy = TRANSITIONEDGE
				endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
			if(2) //EAST
				starty = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
				startx = world.maxx-(TRANSITIONEDGE+1)
				endy = rand(TRANSITIONEDGE, world.maxy-TRANSITIONEDGE)
				endx = TRANSITIONEDGE
			if(3) //SOUTH
				starty = (TRANSITIONEDGE+1)
				startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
				endy = world.maxy-TRANSITIONEDGE
				endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
			if(4) //WEST
				starty = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
				startx = (TRANSITIONEDGE+1)
				endy = rand(TRANSITIONEDGE,world.maxy-TRANSITIONEDGE)
				endx = world.maxx-TRANSITIONEDGE

		pickedstart = locate(startx, starty, 1)
		pickedgoal = locate(endx, endy, 1)
		max_i--
		if(max_i<=0) return

	while (!istype(pickedstart, /turf/space) || pickedstart.loc.name != "Space" ) //FUUUCK, should never happen.


	var/obj/effect/meteor/M
	switch(rand(1, 100))

		if(1 to 10)
			M = new /obj/effect/meteor/big( pickedstart )
		if(11 to 75)
			M = new /obj/effect/meteor( pickedstart )
		if(76 to 100)
			M = new /obj/effect/meteor/small( pickedstart )

	M.dest = pickedgoal
	spawn(0)
		walk_towards(M, M.dest, 1)

	return

/obj/effect/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
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
			playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)
		if (--src.hits <= 0)

			//Prevent meteors from blowing up the singularity's containment.
			//Changing emitter and generator ex_act would result in them being bomb and C4 proof.
			if(!istype(A,/obj/machinery/emitter) && \
				!istype(A,/obj/machinery/field_generator) && \
				prob(15))

				explosion(src.loc, 4, 5, 6, 7, 0)
				playsound(src.loc, "explosion", 50, 1)
			del(src)
	return


/obj/effect/meteor/ex_act(severity)

	if (severity < 4)
		del(src)
	return

/obj/effect/meteor/big
	name = "big meteor"
	hits = 5

	ex_act(severity)
		return

	Bump(atom/A)
		spawn(0)
			//Prevent meteors from blowing up the singularity's containment.
			//Changing emitter and generator ex_act would result in them being bomb and C4 proof
			if(!istype(A,/obj/machinery/emitter) && \
				!istype(A,/obj/machinery/field_generator))
				if(--src.hits <= 0)
					del(src) //Dont blow up singularity containment if we get stuck there.

			for(var/mob/M in range(10, src))
				if(!M.stat && !istype(M, /mob/living/silicon/ai)) //bad idea to shake an ai's view
					shake_camera(M, 3, 1)
			if (A)
				explosion(src.loc, 0, 1, 2, 3, 0)
				playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)
			if (--src.hits <= 0)
				if(prob(15) && !istype(A, /obj/structure/grille))
					explosion(src.loc, 1, 2, 3, 4, 0)
					playsound(src.loc, "explosion", 50, 1)
				del(src)
		return

/obj/effect/meteor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pickaxe))
		del(src)
		return
	..()

/*
//Testing purposes only!
/obj/item/weapon/meteorgun
	name = "Meteor Gun"
	desc = "This beast fires meteors!. TESTING PURPOSES ONLY, This gun is <b>incomplete</b>!"
	icon = 'icons/obj/gun.dmi'
	icon_state = "lasercannon"
	item_state = "gun"

/obj/item/weapon/meteorgun/attack_self()
	var/start_x = usr.loc.x
	var/start_y = usr.loc.y
	var/start_z = usr.loc.z
	var/end_x = 0
	var/end_y = 0
	var/end_z = 0

	switch(usr.dir)
		if(NORTH)
			end_x = start_x
			end_y = world.maxy-TRANSITIONEDGE
		if(SOUTH)
			end_x = start_x
			end_y = TRANSITIONEDGE
		if(EAST)
			end_x = world.maxx-TRANSITIONEDGE
			end_y = start_y
		if(WEST)
			end_x = TRANSITIONEDGE
			end_y = start_y
		else //north
			end_x = start_x
			end_y = TRANSITIONEDGE
	end_z = start_z

	var/start = locate(start_x, start_y, start_z)
	var/end = locate(end_x, end_y, end_z)
	var/obj/effect/meteor/M = new /obj/effect/meteor(start)

	M.dest = end

	spawn(0)
		walk_towards(M, M.dest, 1)

	return
*/