#define METEOR_TEMPERATURE

/var/meteor_wave_delay = 300 //Default wait between waves in tenths of seconds
/var/meteors_in_wave = 10 //Default absolute size
/var/meteor_wave_active = 0
/var/max_meteor_size = 0
/var/chosen_dir = 1

/proc/meteor_wave(var/number = meteors_in_wave, var/max_size = 0, var/list/types = null) //Call above constants to change
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/meteor_wave() called tick#: [world.time]")
	if(!ticker || meteor_wave_active)
		return
	meteor_wave_active = 1
	meteor_wave_delay = (rand(25, 40)) * 10 //Between 30 and 45 seconds, engineers need time to shuffle in relative safety
	chosen_dir = pick(cardinal) //Pick a direction
	max_meteor_size = max_size
	//Generate a name for our wave
	var/greek_alphabet = list("Alpha", "Beta", "Delta", "Epsilon", "Zeta", "Eta,", "Theta", "Iota", "Kappa", "Lambda", "Mu", \
						 "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
	var/wave_final_name = "[number > 25 ? "Major":"Minor"] Meteor [pick("Wave", "Cluster", "Group")] [pick(greek_alphabet)]-[rand(1, 999)]"
	output_information(meteor_wave_delay, chosen_dir, max_size, number, wave_final_name)
	spawn(meteor_wave_delay)
		for(var/i = 0 to number)
			spawn(rand(15, 20)) //1.5 to 2 seconds between meteors
				var/meteor_type = null
				if(types != null)
					meteor_type = pick(types)
				spawn_meteor(chosen_dir, meteor_type)
		sleep(50) //Five seconds for the chat to scroll
		meteor_wave_active = 0

//A bunch of information to be used by the bhangmeter (doubles as a meteor monitoring computer), and sent to the admins otherwise
/proc/output_information(var/meteor_delay, var/wave_dir, var/meteor_size, var/wave_size, var/wave_name)

	var/meteor_l_size = "normal"
	switch(meteor_size)
		if(1)
			meteor_l_size = "small"
		if(2)
			meteor_l_size = "normal"
		if(3)
			meteor_l_size = "large"
		else
			meteor_l_size = "unknown"
	var/wave_l_dir = "north"
	switch(wave_dir)
		if(1)
			wave_l_dir = "north"
		if(2)
			wave_l_dir = "south"
		if(4)
			wave_l_dir = "east"
		if(8)
			wave_l_dir = "west"

	message_admins("[wave_name], containing [wave_size] objects up to [meteor_l_size] size and incoming from the [wave_l_dir], will strike in [meteor_delay/10] seconds.")

	//Send to all Bhangmeters
	for(var/obj/machinery/computer/bhangmeter/bhangmeter in doppler_arrays)
		if(bhangmeter && !bhangmeter.stat)
			bhangmeter.say("Detected: [wave_name], containing [wave_size] objects up to [meteor_l_size] size and incoming from the [wave_l_dir], will strike in [meteor_delay/10] seconds.")

/proc/spawn_meteor(var/chosen_dir, var/meteorpath = null)

	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/spawn_meteor() called tick#: [world.time]")

	var/startx
	var/starty
	var/endx
	var/endy
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 5 //Try only five times maximum

	do
		switch(chosen_dir)
			if(1) //NORTH
				starty = world.maxy-(TRANSITIONEDGE + 1)
				startx = rand((TRANSITIONEDGE + 1), world.maxx - (TRANSITIONEDGE + 1))
				endy = TRANSITIONEDGE
				endx = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE)
			if(2) //SOUTH
				starty = rand((TRANSITIONEDGE + 1),world.maxy - (TRANSITIONEDGE + 1))
				startx = world.maxx-(TRANSITIONEDGE + 1)
				endy = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)
				endx = TRANSITIONEDGE
			if(4) //EAST
				starty = (TRANSITIONEDGE + 1)
				startx = rand((TRANSITIONEDGE + 1), world.maxx - (TRANSITIONEDGE + 1))
				endy = world.maxy-TRANSITIONEDGE
				endx = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE)
			if(8) //WEST
				starty = rand((TRANSITIONEDGE + 1), world.maxy - (TRANSITIONEDGE + 1))
				startx = (TRANSITIONEDGE + 1)
				endy = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)
				endx = world.maxx-TRANSITIONEDGE

		pickedstart = locate(startx, starty, 1)
		pickedgoal = locate(endx, endy, 1)
		max_i--
		if(max_i <= 0)
			return
	while(!istype(pickedstart, /turf/space))

	var/atom/movable/M
	if(meteorpath)
		M = new meteorpath(pickedstart)
	else
		switch(rand(1, 100))
			if(1 to 5) //5 % chance of huge boom
				if(!max_meteor_size || max_meteor_size >= 3)
					M = new /obj/effect/meteor/big(pickedstart)
			if(6 to 60) //55 % chance of medium boom
				if(!max_meteor_size || max_meteor_size >= 2)
					M = new /obj/effect/meteor(pickedstart)
			if(61 to 100) //40 % chance of small boom
				if(!max_meteor_size || max_meteor_size >= 1)
					M = new /obj/effect/meteor/small(pickedstart)
	if(M)
		// This currently doesn't do dick.
		//M.dest = pickedgoal
		walk_towards(M, pickedgoal, 1)
	return

/obj/effect/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "flaming"
	density = 1
	anchored = 1 //You can't push or pull it to prevent exploiting
	pass_flags = PASSTABLE

//Since meteors explode on impact, we won't allow chain reactions like this
//Maybe one day I wil code explosive recoil, but in the meantime who bombs meteor waves anyways ?
/obj/effect/meteor/ex_act()

	return

//We don't want meteors to bump into eachother and explode, so they pass through eachother
//Reflection on bumping would be better, but I would reckon I'm not sure on how to achieve it
/obj/effect/meteor/CanPass(atom/movable/mover, turf/target, height = 1.5, air_group = 0)

	if(istype(mover, /obj/effect/meteor))
		return 1 //Just move through it, no questions asked
	else
		return ..() //Refer to atom/proc/CanPass

/obj/effect/meteor/Bump(atom/A)

	explosion(get_turf(src), 2, 4, 6, 8, 0, 0, 0) //Medium meteor, medium boom
	qdel(src)

/obj/effect/meteor/Move()
	..()
	return

/obj/effect/meteor/small
	name = "small meteor"
	icon_state = "smallf"
	pass_flags = PASSTABLE

/obj/effect/meteor/small/Bump(atom/A)

	explosion(get_turf(src), -1, 1, 3, 4, 0, 0, 0) //Tiny meteor doesn't cause too much damage
	qdel(src)

/obj/effect/meteor/big
	name = "large meteor"
	pass_flags = 0 //Nope, you're not dodging that table

/obj/effect/meteor/big/Bump(atom/A)

	explosion(get_turf(src), 4, 6, 8, 8, 0, 0, 1) //You have been visited by the nuclear meteor
	qdel(src)

/obj/effect/meteor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pickaxe)) //Yeah, you can totally do that
		qdel(src)
	..()

/obj/effect/meteor/Destroy()
	walk(src, 0) //This cancels the walk_towards() proc
	..()
