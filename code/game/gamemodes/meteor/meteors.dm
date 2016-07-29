<<<<<<< HEAD
#define DEFAULT_METEOR_LIFETIME 1800
/var/const/meteor_wave_delay = 625 //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

//Meteors probability of spawning during a given wave
/var/list/meteors_normal = list(/obj/effect/meteor/dust=3, /obj/effect/meteor/medium=8, /obj/effect/meteor/big=3, \
						  /obj/effect/meteor/flaming=1, /obj/effect/meteor/irradiated=3) //for normal meteor event

/var/list/meteors_threatening = list(/obj/effect/meteor/medium=4, /obj/effect/meteor/big=8, \
						  /obj/effect/meteor/flaming=3, /obj/effect/meteor/irradiated=3) //for threatening meteor event

/var/list/meteors_catastrophic = list(/obj/effect/meteor/medium=5, /obj/effect/meteor/big=75, \
						  /obj/effect/meteor/flaming=10, /obj/effect/meteor/irradiated=10, /obj/effect/meteor/tunguska = 1) //for catastrophic meteor event

/var/list/meteorsB = list(/obj/effect/meteor/meaty=5, /obj/effect/meteor/meaty/xeno=1) //for meaty ore event

/var/list/meteorsC = list(/obj/effect/meteor/dust) //for space dust event


///////////////////////////////
//Meteor spawning global procs
///////////////////////////////

/proc/spawn_meteors(number = 10, list/meteortypes)
	for(var/i = 0; i < number; i++)
		spawn_meteor(meteortypes)

/proc/spawn_meteor(list/meteortypes)
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 10//number of tries to spawn meteor.
	while (!istype(pickedstart, /turf/open/space))
		var/startSide = pick(cardinal)
		pickedstart = spaceDebrisStartLoc(startSide, 1)
		pickedgoal = spaceDebrisFinishLoc(startSide, 1)
		max_i--
		if(max_i<=0)
			return
	var/Me = pickweight(meteortypes)
	var/obj/effect/meteor/M = new Me(pickedstart)
	M.dest = pickedgoal
	M.z_original = 1
	spawn(0)
		walk_towards(M, M.dest, 1)

/proc/spaceDebrisStartLoc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(EAST)
			starty = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
			startx = world.maxx-(TRANSITIONEDGE+1)
		if(SOUTH)
			starty = (TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(WEST)
			starty = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
			startx = (TRANSITIONEDGE+1)
	. = locate(startx, starty, Z)

/proc/spaceDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	switch(startSide)
		if(NORTH)
			endy = TRANSITIONEDGE
			endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
		if(EAST)
			endy = rand(TRANSITIONEDGE, world.maxy-TRANSITIONEDGE)
			endx = TRANSITIONEDGE
		if(SOUTH)
			endy = world.maxy-TRANSITIONEDGE
			endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
		if(WEST)
			endy = rand(TRANSITIONEDGE,world.maxy-TRANSITIONEDGE)
			endx = world.maxx-TRANSITIONEDGE
	. = locate(endx, endy, Z)

///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "the concept of meteor"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	density = 1
	anchored = 1
	var/hits = 4
	var/hitpwr = 2 //Level of ex_act to be called on hit.
	var/dest
	pass_flags = PASSTABLE
	var/heavy = 0
	var/meteorsound = 'sound/effects/meteorimpact.ogg'
	var/z_original = 1
	var/threat = 0 // used for determining which meteors are most interesting
	var/lifetime = DEFAULT_METEOR_LIFETIME

	var/list/meteordrop = list(/obj/item/weapon/ore/iron)
	var/dropamt = 2

/obj/effect/meteor/Move()
	if(z != z_original || loc == dest)
		qdel(src)
		return

	. = ..() //process movement...

	if(.)//.. if did move, ram the turf we get in
		var/turf/T = get_turf(loc)
		ram_turf(T)

		if(prob(10) && !istype(T, /turf/open/space))//randomly takes a 'hit' from ramming
			get_hit()

/obj/effect/meteor/Destroy()
	walk(src,0) //this cancels the walk_towards() proc
	. = ..()

/obj/effect/meteor/New()
	..()
	if(SSaugury)
		SSaugury.register_doom(src, threat)
	SpinAnimation()
	QDEL_IN(src, lifetime)

/obj/effect/meteor/Bump(atom/A)
	if(A)
		ram_turf(get_turf(A))
		playsound(src.loc, meteorsound, 40, 1)
		get_hit()

/obj/effect/meteor/proc/ram_turf(turf/T)
	//first bust whatever is in the turf
	for(var/atom/A in T)
		if(A != src)
			if(istype(A, /mob/living))
				A.visible_message("<span class='warning'>[src] slams into [A].</span>", "<span class='userdanger'>[src] slams into you!.</span>")
			A.ex_act(hitpwr)

	//then, ram the turf if it still exists
	if(T)
		T.ex_act(hitpwr)



//process getting 'hit' by colliding with a dense object
//or randomly when ramming turfs
/obj/effect/meteor/proc/get_hit()
	hits--
	if(hits <= 0)
		make_debris()
		meteor_effect()
		qdel(src)

/obj/effect/meteor/ex_act()
	return

/obj/effect/meteor/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pickaxe))
		make_debris()
		qdel(src)
	else
		. = ..()

/obj/effect/meteor/proc/make_debris()
	for(var/throws = dropamt, throws > 0, throws--)
		var/thing_to_spawn = pick(meteordrop)
		new thing_to_spawn(get_turf(src))

/obj/effect/meteor/proc/meteor_effect()
	if(heavy)
		for(var/mob/M in player_list)
			if((M.orbiting) && (SSaugury.watchers[M]))
				continue
			var/turf/T = get_turf(M)
			if(!T || T.z != src.z)
				continue
			var/dist = get_dist(M.loc, src.loc)
			shake_camera(M, dist > 20 ? 2 : 4, dist > 20 ? 1 : 3)
			M.playsound_local(src.loc, meteorsound, 50, 1, get_rand_frequency(), 10)

///////////////////////
//Meteor types
///////////////////////

//Dust
/obj/effect/meteor/dust
	name = "space dust"
	icon_state = "dust"
	pass_flags = PASSTABLE | PASSGRILLE
	hits = 1
	hitpwr = 3
	meteorsound = 'sound/weapons/Gunshot_smg.ogg'
	meteordrop = list(/obj/item/weapon/ore/glass)
	threat = 1

//Medium-sized
/obj/effect/meteor/medium
	name = "meteor"
	dropamt = 3
	threat = 5

/obj/effect/meteor/medium/meteor_effect()
	..()
	explosion(src.loc, 0, 1, 2, 3, 0)

//Large-sized
/obj/effect/meteor/big
	name = "big meteor"
	icon_state = "large"
	hits = 6
	heavy = 1
	dropamt = 4
	threat = 10

/obj/effect/meteor/big/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0)

//Flaming meteor
/obj/effect/meteor/flaming
	name = "flaming meteor"
	icon_state = "flaming"
	hits = 5
	heavy = 1
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/weapon/ore/plasma)
	threat = 20

/obj/effect/meteor/flaming/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0, 0, 5)

//Radiation meteor
/obj/effect/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	heavy = 1
	meteordrop = list(/obj/item/weapon/ore/uranium)
	threat = 15


/obj/effect/meteor/irradiated/meteor_effect()
	..()
	explosion(src.loc, 0, 0, 4, 3, 0)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	radiation_pulse(get_turf(src), 2, 5, 50, 1)

//Meaty Ore
/obj/effect/meteor/meaty
	name = "meaty ore"
	icon_state = "meateor"
	desc = "Just... don't think too hard about where this thing came from."
	hits = 2
	heavy = 1
	meteorsound = 'sound/effects/blobattack.ogg'
	meteordrop = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/human, /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant, /obj/item/organ/heart, /obj/item/organ/lungs, /obj/item/organ/tongue, /obj/item/organ/appendix/)
	var/meteorgibs = /obj/effect/gibspawner/generic
	threat = 2

/obj/effect/meteor/meaty/New()
	for(var/path in meteordrop)
		if(path == /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant)
			meteordrop -= path
			meteordrop += pick(subtypesof(path))

	for(var/path in meteordrop)
		if(path == /obj/item/organ/tongue)
			meteordrop -= path
			meteordrop += pick(typesof(path))
	..()

/obj/effect/meteor/meaty/make_debris()
	..()
	new meteorgibs(get_turf(src))


/obj/effect/meteor/meaty/ram_turf(turf/T)
	if(!istype(T, /turf/open/space))
		new /obj/effect/decal/cleanable/blood(T)

/obj/effect/meteor/meaty/Bump(atom/A)
	A.ex_act(hitpwr)
	get_hit()

//Meaty Ore Xeno edition
/obj/effect/meteor/meaty/xeno
	color = "#5EFF00"
	meteordrop = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno, /obj/item/organ/tongue/alien)
	meteorgibs = /obj/effect/gibspawner/xeno

/obj/effect/meteor/meaty/xeno/New()
	meteordrop += subtypesof(/obj/item/organ/alien)
	..()

/obj/effect/meteor/meaty/xeno/ram_turf(turf/T)
	if(!istype(T, /turf/open/space))
		new /obj/effect/decal/cleanable/xenoblood(T)

//Station buster Tunguska
/obj/effect/meteor/tunguska
	name = "tunguska meteor"
	icon_state = "flaming"
	desc = "Your life briefly passes before your eyes the moment you lay \
		them on this monstrosity."
	hits = 30
	hitpwr = 1
	heavy = 1
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/weapon/ore/plasma)
	threat = 50

/obj/effect/meteor/tunguska/Move()
	. = ..()
	if(.)
		PoolOrNew(/obj/effect/overlay/temp/revenant, get_turf(src))

/obj/effect/meteor/tunguska/meteor_effect()
	..()
	explosion(src.loc, 5, 10, 15, 20, 0)

/obj/effect/meteor/tunguska/Bump()
	..()
	if(prob(20))
		explosion(src.loc,2,4,6,8)

//////////////////////////
//Spookoween meteors
/////////////////////////

/var/list/meteorsSPOOKY = list(/obj/effect/meteor/pumpkin)

/obj/effect/meteor/pumpkin
	name = "PUMPKING"
	desc = "THE PUMPKING'S COMING!"
	icon = 'icons/obj/meteor_spooky.dmi'
	icon_state = "pumpkin"
	hits = 10
	heavy = 1
	dropamt = 1
	meteordrop = list(/obj/item/clothing/head/hardhat/pumpkinhead, /obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin)
	threat = 100

/obj/effect/meteor/pumpkin/New()
	..()
	meteorsound = pick('sound/hallucinations/im_here1.ogg','sound/hallucinations/im_here2.ogg')
//////////////////////////
#undef DEFAULT_METEOR_LIFETIME
=======
#define METEOR_TEMPERATURE

/var/meteor_wave_delay = 300 //Default wait between waves in tenths of seconds
/var/meteors_in_wave = 10 //Default absolute size
/var/meteor_wave_active = 0
/var/max_meteor_size = 0 //One for small waves, two for big waves, three for massive waves, four for boss waves
/var/chosen_dir = 1

//Call above constants to change
/proc/meteor_wave(var/number = meteors_in_wave, var/max_size = 0, var/list/types = null)

	if(!ticker || meteor_wave_active)
		return
	meteor_wave_active = 1
	meteor_wave_delay = (rand(30, 45)) * 10 //Between 30 and 45 seconds, engineers need time to shuffle in relative safety
	chosen_dir = pick(cardinal) //Pick a direction
	max_meteor_size = max_size
	//Generate a name for our wave
	var/greek_alphabet = list("Alpha", "Beta", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", \
						 "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
	var/wave_final_name = "[number > 25 ? "Major":"Minor"] Meteor [pick("Wave", "Cluster", "Group")] [pick(greek_alphabet)]-[rand(1, 999)]"
	output_information(meteor_wave_delay, chosen_dir, max_size, number, wave_final_name)
	spawn(meteor_wave_delay)
		for(var/i = 0 to number)
			sleep(rand(1, 3)) //0.1 to 0.3 seconds between meteors
			var/meteor_type = null
			if(types != null)
				meteor_type = pick(types)
			spawn_meteor(chosen_dir, meteor_type)
		sleep(50) //Five seconds for the chat to scroll
		meteor_wave_active = 0
	return chosen_dir

//A bunch of information to be used by the bhangmeter (doubles as a meteor monitoring computer), and sent to the admins otherwise
/proc/output_information(var/meteor_delay, var/wave_dir, var/meteor_size, var/wave_size, var/wave_name)

	var/meteor_l_size = "unknown"
	switch(meteor_size)
		if(1)
			meteor_l_size = "small"
		if(2)
			meteor_l_size = "medium"
		if(3)
			meteor_l_size = "large"
		if(4)
			meteor_l_size = "apocalyptic"
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

	var/startx
	var/starty
	var/endx
	var/endy
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 5 //Try only five times maximum

	do
		switch(chosen_dir)

			if(1) //North, along the y = max edge
				starty = world.maxy - (TRANSITIONEDGE + 2)
				startx = rand((TRANSITIONEDGE + 2), world.maxx - (TRANSITIONEDGE + 2))
				endy = TRANSITIONEDGE
				endx = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE)

			if(2) //South, along the y = 0 edge
				starty = (TRANSITIONEDGE + 2)
				startx = rand((TRANSITIONEDGE + 2), world.maxx - (TRANSITIONEDGE + 2))
				endy = world.maxy - (TRANSITIONEDGE + 2)
				endx = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE)

			if(4) //East, along the x = max edge
				starty = rand((TRANSITIONEDGE + 2), world.maxy - (TRANSITIONEDGE + 2))
				startx = world.maxx - (TRANSITIONEDGE + 2)
				endy = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)
				endx = (TRANSITIONEDGE + 2)

			if(8) //West, along the x = 0 edge
				starty = rand((TRANSITIONEDGE + 2), world.maxy - (TRANSITIONEDGE + 2))
				startx = (TRANSITIONEDGE + 2)
				endy = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)
				endx = world.maxx - (TRANSITIONEDGE + 2)

		pickedstart = locate(startx, starty, 1)
		pickedgoal = locate(endx, endy, 1)
		max_i--
		if(max_i <= 0)
			return

	while(!istype(pickedstart, /turf/space))

	if(meteorpath)
		new meteorpath(pickedstart, pickedgoal)
	else
		var/list/possible_meteors = list()
		if(!max_meteor_size || max_meteor_size >= 1) //Small waves
			possible_meteors[/obj/item/projectile/meteor/small] = 80
			possible_meteors[/obj/item/projectile/meteor/small/flash] = 8
		if(!max_meteor_size || max_meteor_size >= 2) //Medium waves
			possible_meteors[/obj/item/projectile/meteor] = 100
			possible_meteors[/obj/item/projectile/meteor/radioactive] = 10
		if(!max_meteor_size || max_meteor_size >= 3) //Big waves
			possible_meteors[/obj/item/projectile/meteor/big] = 10
			possible_meteors[/obj/item/projectile/meteor/big/cluster] = 1
		var/chosen = pick(possible_meteors)
		new chosen(pickedstart, pickedgoal)

/*
 * Below are all meteor types
 */

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "medium"
	density = 1
	anchored = 1 //You can't push or pull it to prevent exploiting
	grillepasschance = 0
	mouse_opacity = 1

/obj/item/projectile/meteor/New(atom/start, atom/end)
	..()
	if(end)
		throw_at(end)

/obj/item/projectile/meteor/throw_at(atom/end)
	original = end
	starting = loc
	current = loc
	OnFired()
	yo = target.y - y
	xo = target.x - x
	process()

//Since meteors explode on impact, we won't allow chain reactions like this
//Maybe one day I wil code explosive recoil, but in the meantime who bombs meteor waves anyways ?
/obj/item/projectile/meteor/ex_act()

	return

//We don't want meteors to bump into eachother and explode, so they pass through eachother
//Reflection on bumping would be better, but I would reckon I'm not sure on how to achieve it
/obj/item/projectile/meteor/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)

	if(istype(mover, /obj/item/projectile/meteor))
		return 1 //Just move through it, no questions asked
	if(isliving(mover))
		return 0 //Collision
	else
		return ..() //Refer to atom/proc/Cross

/obj/item/projectile/meteor/Bump(atom/A)

	if(loc == null)
		return

	explosion(get_turf(src), 2, 4, 6, 8, 0, 1, 0) //Medium meteor, medium boom
	qdel(src)

/obj/item/projectile/meteor/process_step()
	if(z != starting.z)
		qdel(src)
		return
	..()

/obj/item/projectile/meteor/radioactive
	name = "radioactive meteor"
	desc = "The Engineer's bane"
	icon_state = "medium_radioactive"

/obj/item/projectile/meteor/radioactive/Bump(atom/a)

	if(loc == null)
		return

	for(var/mob/living/M in viewers(src, null))
		M.radiation += rand(5, 10)

	..()

/obj/item/projectile/meteor/small
	name = "small meteor"
	desc = "The mineral version of armed C4, coming right for your walls."
	icon_state = "small"
	pass_flags = PASSTABLE

/obj/item/projectile/meteor/small/Bump(atom/A)
	if(loc == null)
		return

	explosion(get_turf(src), -1, 1, 3, 4, 0, 1, 0) //Tiny meteor doesn't cause too much damage
	qdel(src)

/obj/item/projectile/meteor/small/flash
	name = "flash meteor"
	desc = "A absolutely stunning rock specimen of blinding beauty."
	icon_state = "small_flash"

/obj/item/projectile/meteor/small/flash/Bump(atom/A)

	if(loc == null)
		return

	//Adjusted from flashbangs, should be its own global proc
	visible_message("<span class='danger'>BANG</span>")
	playsound(get_turf(src), 'sound/effects/bang.ogg', 25, 1)

	for(var/mob/living/M in viewers(src, null))

		//Checking for protections
		var/eye_safety = 0
		var/ear_safety = 0
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			eye_safety = C.eyecheck()
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(H.earprot())
					ear_safety += 2
				if(M_HULK in H.mutations)
					ear_safety += 1
				if(istype(H.head, /obj/item/clothing/head/helmet))
					ear_safety += 1

		//Flashing everyone
		if(eye_safety < 2)
			M.flash_eyes(visual = 1)
			switch(eye_safety)
				if(1)
					M.Stun(2)
				if(0)
					M.Stun(4)
					M.Weaken(10)
				if(-1)
					M.Stun(7)
					M.Weaken(15)

		if(ear_safety < 2)
			switch(ear_safety)
				if(1)
					M.ear_damage += rand(0, 3)
				if(0)
					M.ear_damage += rand(5, 15)
					M.ear_deaf = max(M.ear_deaf, 10)
			//Shouldn't have to do this here, this is what life.dm and organ checks are for
			//Not even going to bother with eye damage
			if(prob(M.ear_damage - 10 + 5))
				to_chat(M, "<span class='warning'>You can't hear anything!</span>")
				M.sdisabilities |= DEAF

	explosion(get_turf(src), -1, 1, 3, 4, 0, 1, 0) //Tiny meteor doesn't cause too much damage
	qdel(src)

/obj/item/projectile/meteor/piercing
	name = "piercing meteor"
	desc = "Takes a page out of armor-piercing rounds, blowing its way through cover once, and then blowing up normally."
	icon_state = "medium_piercing"
	var/pierce_health = 1 //When 0, piercing meteor explodes like normal

/obj/item/projectile/meteor/piercing/Bump(atom/A)

	if(loc == null)
		return

	if(pierce_health)
		explosion(get_turf(A), 1, 0, 0, 0, 0, 1, 0) //Blow up the resisting object
		pierce_health--
	else
		explosion(get_turf(src), 2, 4, 6, 8, 0, 1, 0) //Blow ourselves up, in glory
		qdel(src)

/obj/item/projectile/meteor/big
	name = "large meteor"
	desc = "It might look large, but it is only a small splinter of a much bigger thing."
	icon_state = "big"

/obj/item/projectile/meteor/big/Bump(atom/A)

	if(loc == null)
		return

	explosion(get_turf(src), 4, 6, 8, 8, 0, 1, 0) //You have been visited by the nuclear meteor
	qdel(src)

/obj/item/projectile/meteor/big/cluster
	name = "cluster meteor"
	desc = "Makes up for its lack of explosiveness by splitting into multiple, fairly explosive meteors."
	icon_state = "big_cluster"

/obj/item/projectile/meteor/big/cluster/Bump(atom/A)

	if(loc == null)
		return

	explosion(get_turf(A), 1, 0, 0, 0, 0, 1, 0) //Enough to destroy whatever was in the way
	for(var/i = 0, i < 3, i++)
		var/c_endx = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE)
		var/c_endy = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)
		var/c_pickedgoal = locate(c_endx, c_endy, 1)
		if(c_pickedgoal)
			new /obj/item/projectile/meteor(get_turf(src), c_pickedgoal)
	qdel(src)

//Placeholder for actual meteors of this kind, will be included SOON
/obj/item/projectile/meteor/boss
	name = "apocalytic meteor"
	desc = "And behold, a white meteor. And on that meteor..."

/obj/item/projectile/meteor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pickaxe)) //Yeah, you can totally do that
		qdel(src)
		return
	..()

/obj/item/projectile/meteor/Destroy()
	..()

/obj/effect/meteor/gib    //non explosive meteor, appears to be a corpse spinning in space before impacting something and spraying gibs everywhere
	name = "human corpse"
	icon_state = "human"

/obj/effect/meteor/gib/Bump(atom/A)

	if(loc == null)
		return

	new /obj/effect/gibspawner/human(src.loc)
	qdel(src)


/obj/item/projectile/meteor/blob
	name = "Blob"
	icon = 'icons/obj/meteor_64x64.dmi'
	icon_state = "meteorblob"
	pixel_x = -16
	pixel_y = -16

/obj/item/projectile/meteor/blob/Bump(atom/A)
	if(!loc)
		return

	if(ismob(A))
		src.loc = A.loc
		A.blob_act()
		return

	playsound(loc, get_sfx("explosion"), 50)

	for (var/mob/M in player_list)
		if(M && M.client)
			var/turf/M_turf = get_turf(M)
			if(M_turf && (M_turf.z == loc.z))
				var/dist = get_dist(M_turf, loc)
				if(dist <= round(world.view + 10, 1))
					shake_camera(M, 3, 2)
				M.playsound_local(loc, 'sound/effects/explosionfar.ogg')

	var/turf/T = get_turf(A)

	for(var/atom/AT in T)
		AT.blob_act(1)

	T.blob_act(1)

	var/obj/effect/blob/is_there_a_blob = (locate(/obj/effect/blob) in T)

	if(is_there_a_blob)
		do_blob_stuff(loc)
	else
		do_blob_stuff(T)

	qdel(src)

/obj/item/projectile/meteor/blob/proc/do_blob_stuff(var/turf/T)
	new/obj/effect/blob/normal(T, no_morph = 1)

/obj/item/projectile/meteor/blob/node
	name = "Blob Node"
	icon = 'icons/obj/meteor_64x64.dmi'
	icon_state = "meteornode"

/obj/item/projectile/meteor/blob/node/do_blob_stuff(var/turf/T)
	new/obj/effect/blob/node(T, no_morph = 1)

var/list/blob_candidates = list()

/obj/item/projectile/meteor/blob/core
	name = "Blob Core"
	icon = 'icons/obj/meteor_64x64.dmi'
	icon_state = "meteorcore"
	var/client/blob_candidate = null

/obj/item/projectile/meteor/blob/core/New()
	..()
	var/list/candidates = list()

	candidates = get_candidates(ROLE_BLOB)

	for(var/client/C in candidates)
		if(istype(C.eye,/obj/item/projectile/meteor/blob/core))
			candidates -= C

	if(candidates.len)
		blob_candidate = pick(candidates)
		blob_candidates += blob_candidate

	if(blob_candidate)
		blob_candidate.perspective = EYE_PERSPECTIVE
		blob_candidate.eye = src
		blob_candidate.mob.see_invisible = SEE_INVISIBLE_MINIMUM

/obj/item/projectile/meteor/blob/core/Destroy()
	if(blob_candidate)
		blob_candidate.perspective = MOB_PERSPECTIVE
		blob_candidate.eye = blob_candidate.mob
		blob_candidates -= blob_candidate
		blob_candidate = null
	..()

/obj/item/projectile/meteor/blob/core/do_blob_stuff(var/turf/T)
	if(blob_candidate && istype(blob_candidate.mob, /mob/dead/observer))
		new/obj/effect/blob/core(T, new_overmind = blob_candidate, no_morph = 1)
	else
		new/obj/effect/blob/core(T, no_morph = 1)

//It's a tool to debug and test stuff, ok? Pls don't hand them out to players unless you just want to set the world on fire.
/obj/item/weapon/meteor_gun
	name = "Meteor Gun"
	desc = "Jesus fucking christ."
	icon = 'icons/obj/gun.dmi'
	icon_state = "meteorgun"
	item_state = "gun"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	w_class = W_CLASS_MEDIUM
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	var/projectile_type = /obj/item/projectile/meteor

/obj/item/weapon/meteor_gun/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack

	user.visible_message(
		"<span class='warning'>[user] fires the [src]!</span>",
		"<span class='warning'>You fire the [src]!</span>")

	playsound(user, 'sound/weapons/rocket.ogg', 100)

	var/obj/item/projectile/meteor/in_chamber = new projectile_type(get_turf(src), get_turf(A))

	add_logs(user,A,"fired \the [src] (proj:[in_chamber.name]) at ",addition="([A.x],[A.y],[A.z])")

/obj/item/weapon/meteor_gun/attack_self(mob/user as mob)
	projectile_type = input(user, "Pick a meteor type.", "Projectile Choice") in typesof(/obj/item/projectile/meteor)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
