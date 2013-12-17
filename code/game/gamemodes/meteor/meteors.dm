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

/obj/effect/meteor/Bump(atom/A)
	if (A)
		A.meteorhit(src)
		playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)
	if (--src.hits <= 0)

		//Prevent meteors from blowing up the singularity's containment.
		//Changing emitter and generator ex_act would result in them being bomb and C4 proof.
		if(!istype(A,/obj/machinery/power/emitter) && \
			!istype(A,/obj/machinery/field/generator) && \
			prob(15))
			explosion(src.loc, 4, 5, 6, 7, 0)
		del(src)


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
		//Prevent meteors from blowing up the singularity's containment.
		//Changing emitter and generator ex_act would result in them being bomb and C4 proof
		if(!istype(A,/obj/machinery/power/emitter) && \
			!istype(A,/obj/machinery/field/generator))
			if(--src.hits <= 0)
				del(src) //Dont blow up singularity containment if we get stuck there.

		if (A)
			for(var/mob/M in player_list)
				var/turf/T = get_turf(M)
				if(!T || T.z != src.z)
					continue
				shake_camera(M, 3, get_dist(M.loc, src.loc) > 20 ? 1 : 3)
				M.playsound_local(src.loc, 'sound/effects/meteorimpact.ogg', 50, 1, get_rand_frequency(), 10)
			explosion(src.loc, 0, 1, 2, 3, 0)

		if (--src.hits <= 0)
			if(prob(15) && !istype(A, /obj/structure/grille))
				explosion(src.loc, 1, 2, 3, 4, 0)
			del(src)

/obj/effect/meteor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pickaxe))
		del(src)
		return
	..()