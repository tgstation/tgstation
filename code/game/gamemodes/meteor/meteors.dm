#define DEFAULT_METEOR_LIFETIME 1800
GLOBAL_VAR_INIT(meteor_wave_delay, 625) //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

//Meteors probability of spawning during a given wave
GLOBAL_LIST_INIT(meteors_normal, list(/obj/effect/meteor/dust=3, /obj/effect/meteor/medium=8, /obj/effect/meteor/big=3, \
						  /obj/effect/meteor/flaming=1, /obj/effect/meteor/irradiated=3)) //for normal meteor event

GLOBAL_LIST_INIT(meteors_threatening, list(/obj/effect/meteor/medium=4, /obj/effect/meteor/big=8, \
						  /obj/effect/meteor/flaming=3, /obj/effect/meteor/irradiated=3)) //for threatening meteor event

GLOBAL_LIST_INIT(meteors_catastrophic, list(/obj/effect/meteor/medium=5, /obj/effect/meteor/big=75, \
						  /obj/effect/meteor/flaming=10, /obj/effect/meteor/irradiated=10, /obj/effect/meteor/tunguska = 1)) //for catastrophic meteor event

GLOBAL_LIST_INIT(meteors_meaty_normal, list(/obj/effect/meteor/meaty=5, /obj/effect/meteor/meaty/xeno=1)) //for meaty ore event

GLOBAL_LIST_INIT(meteors_meaty_ball, list(/obj/effect/meteor/meaty=50, \
						  /obj/effect/meteor/meaty/xeno=10, /obj/effect/meteor/meaty/mouldy=20, \
						  /obj/effect/meteor/meaty/bone=20, /obj/effect/meteor/meaty/meatball_man = 5)) //for meatball event

GLOBAL_LIST_INIT(meteorsC, list(/obj/effect/meteor/dust)) //for space dust event


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
	while(!isspaceturf(pickedstart))
		var/startSide = pick(GLOB.cardinals)
		var/startZ = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
		pickedstart = spaceDebrisStartLoc(startSide, startZ)
		pickedgoal = spaceDebrisFinishLoc(startSide, startZ)
		max_i--
		if(max_i<=0)
			return
	var/Me = pickweight(meteortypes)
	var/obj/effect/meteor/M = new Me(pickedstart, pickedgoal)
	M.dest = pickedgoal

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
			endy = (TRANSITIONEDGE+1)
			endx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(EAST)
			endy = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
			endx = (TRANSITIONEDGE+1)
		if(SOUTH)
			endy = world.maxy-(TRANSITIONEDGE+1)
			endx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(WEST)
			endy = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
			endx = world.maxx-(TRANSITIONEDGE+1)
	. = locate(endx, endy, Z)

///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "the concept of meteor"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	density = TRUE
	anchored = TRUE
	var/hits = 4
	var/hitpwr = 2 //Level of ex_act to be called on hit.
	var/dest
	pass_flags = PASSTABLE
	var/heavy = 0
	var/meteorsound = 'sound/effects/meteorimpact.ogg'
	var/z_original
	var/threat = 0 // used for determining which meteors are most interesting
	var/lifetime = DEFAULT_METEOR_LIFETIME
	var/timerid = null
	var/list/meteordrop = list(/obj/item/stack/ore/iron)
	var/dropamt = 2
	var/move_delay = 1
	var/spin = TRUE

/obj/effect/meteor/Move()
	if(z != z_original || loc == dest)
		qdel(src)
		return FALSE

	. = ..() //process movement...

	if(.)//.. if did move, ram the turf we get in
		var/turf/T = get_turf(loc)
		ram_turf(T)

		if(prob(10) && !isspaceturf(T))//randomly takes a 'hit' from ramming
			get_hit()

/obj/effect/meteor/Destroy()
	if (timerid)
		deltimer(timerid)
	GLOB.meteor_list -= src
	SSaugury.unregister_doom(src)
	walk(src,0) //this cancels the walk_towards() proc
	. = ..()

/obj/effect/meteor/Initialize(mapload, target)
	. = ..()
	z_original = z
	GLOB.meteor_list += src
	SSaugury.register_doom(src, threat)
	if(spin)
		SpinAnimation()
	if(lifetime)
		timerid = QDEL_IN(src, lifetime)
	chase_target(target)

/obj/effect/meteor/Bump(atom/A)
	if(A)
		ram_turf(get_turf(A))
		playsound(src.loc, meteorsound, 40, TRUE)
		get_hit()

/obj/effect/meteor/proc/ram_turf(turf/T)
	//first bust whatever is in the turf
	for(var/atom/A in T)
		if(A != src)
			if(isliving(A))
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

/obj/effect/meteor/examine(mob/user)
	. = ..()
	if(!(flags_1 & ADMIN_SPAWNED_1) && isliving(user))
		user.client.give_award(/datum/award/achievement/misc/meteor_examine, user)

/obj/effect/meteor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MINING)
		make_debris()
		qdel(src)
	else
		. = ..()

/obj/effect/meteor/proc/make_debris()
	for(var/throws = dropamt, throws > 0, throws--)
		var/thing_to_spawn = pick(meteordrop)
		new thing_to_spawn(get_turf(src))

/obj/effect/meteor/proc/chase_target(atom/chasing, delay = move_delay)
	set waitfor = FALSE
	if(chasing)
		walk_towards(src, chasing, delay)

/obj/effect/meteor/proc/meteor_effect()
	if(heavy)
		var/sound/meteor_sound = sound(meteorsound)
		var/random_frequency = get_rand_frequency()

		for(var/mob/M in GLOB.player_list)
			if((M.orbiting) && (SSaugury.watchers[M]))
				continue
			var/turf/T = get_turf(M)
			if(!T || T.z != src.z)
				continue
			var/dist = get_dist(M.loc, src.loc)
			shake_camera(M, dist > 20 ? 2 : 4, dist > 20 ? 1 : 3)
			M.playsound_local(src.loc, null, 50, 1, random_frequency, 10, S = meteor_sound)

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
	meteorsound = 'sound/weapons/gun/smg/shot.ogg'
	meteordrop = list(/obj/item/stack/ore/glass)
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
	meteordrop = list(/obj/item/stack/ore/plasma)
	threat = 20

/obj/effect/meteor/flaming/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0, 0, 5)

//Radiation meteor
/obj/effect/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	heavy = 1
	meteordrop = list(/obj/item/stack/ore/uranium)
	threat = 15


/obj/effect/meteor/irradiated/meteor_effect()
	..()
	explosion(src.loc, 0, 0, 4, 3, 0)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	radiation_pulse(src, 500)

//Station buster Tunguska
/obj/effect/meteor/tunguska
	name = "tunguska meteor"
	icon_state = "flaming"
	desc = "Your life briefly passes before your eyes the moment you lay them on this monstrosity."
	hits = 30
	hitpwr = 1
	heavy = 1
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)
	threat = 50

/obj/effect/meteor/tunguska/Move()
	. = ..()
	if(.)
		new /obj/effect/temp_visual/revenant(get_turf(src))

/obj/effect/meteor/tunguska/meteor_effect()
	..()
	explosion(src.loc, 5, 10, 15, 20, 0)

/obj/effect/meteor/tunguska/Bump()
	..()
	if(prob(20))
		explosion(src.loc,2,4,6,8)

//////////////////////////
//Meatyores
/////////////////////////

/obj/effect/meteor/meaty
	name = "meaty ore"
	icon_state = "meateor"
	desc = "Just... don't think too hard about where this thing came from."
	hits = 2
	heavy = 1
	meteorsound = 'sound/effects/blobattack.ogg'
	meteordrop = list(/obj/item/reagent_containers/food/snacks/meat/slab/human, /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant, /obj/item/organ/heart, /obj/item/organ/lungs, /obj/item/organ/tongue, /obj/item/organ/appendix/)
	var/meteorgibs = /obj/effect/gibspawner/generic
	threat = 2

/obj/effect/meteor/meaty/Initialize()
	for(var/path in meteordrop)
		if(path == /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant)
			meteordrop -= path
			meteordrop += pick(subtypesof(path))

	for(var/path in meteordrop)
		if(path == /obj/item/organ/tongue)
			meteordrop -= path
			meteordrop += pick(typesof(path))
	return ..()

/obj/effect/meteor/meaty/make_debris()
	..()
	new meteorgibs(get_turf(src))


/obj/effect/meteor/meaty/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/blood(T)

/obj/effect/meteor/meaty/Bump(atom/A)
	A.ex_act(hitpwr)
	get_hit()

//Meaty Ore Xeno edition
/obj/effect/meteor/meaty/xeno
	color = "#5EFF00"
	meteordrop = list(/obj/item/reagent_containers/food/snacks/meat/slab/xeno, /obj/item/organ/tongue/alien)
	meteorgibs = /obj/effect/gibspawner/xeno

/obj/effect/meteor/meaty/xeno/Initialize()
	meteordrop += subtypesof(/obj/item/organ/alien)
	return ..()

/obj/effect/meteor/meaty/xeno/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/xenoblood(T)

//Blobby-Meaty Ore
/obj/effect/meteor/meaty/mouldy
	name = "mouldy ore"
	desc = "Ewww."
	color = "#654321"
	meteorsound = 'sound/effects/splat.ogg'
	meteordrop = list(/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie, /obj/item/organ/tongue/zombie)
	threat = 10
	var/spawn_max = 4
	var/blobbo_chance = 25

/obj/effect/meteor/meaty/mouldy/meteor_effect()
	..()
	if(prob(blobbo_chance))
		new /mob/living/simple_animal/hostile/blob/blobbernaut/independent(src.loc, src)
	else
		for(var/i in 1 to spawn_max)
			var/mob/living/simple_animal/hostile/blob/blobspore/BS = new /mob/living/simple_animal/hostile/blob/blobspore(src.loc, src)
			for(var/j = 1, j <= rand(1, 3), j++)
				step(BS, pick(NORTH,SOUTH,EAST,WEST))

//Bone-Meaty Ore
/obj/effect/meteor/meaty/bone
	name = "boney ore"
	desc = "This thing sure drank its calcium."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "skull"
	meteordrop = list(/obj/item/stack/sheet/bone, /obj/item/organ/tongue/bone, /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton)
	dropamt = 8 //No bone gib spawner, so lots of bones instead. Besides, bones would survive impact better than meat.
	hits = 4 // Bone is pretty hard.
	meteorsound = 'sound/magic/RATTLEMEBONES2.ogg' // ME BONES
	threat = 5
	
/obj/effect/meteor/meaty/bone/make_debris()
	for(var/throws = dropamt, throws > 0, throws--)
		var/thing_to_spawn = pick(meteordrop)
		var/atom/thing = new thing_to_spawn(get_turf(src))
		for(var/j = 1, j <= rand(1, 3), j++)
			step(thing, pick(NORTH,SOUTH,EAST,WEST))

//Long ago in a distant fairy land, there was a man known far and wide...
/obj/effect/meteor/meaty/meatball_man
	name = "meatball man"
	icon = 'icons/effects/512x512.dmi'
	icon_state = "meatball_man"
	pixel_x = -240
	pixel_y = -240
	desc = "Oh, what a feat! He's one with the meat!"
	hits = INFINITY // You cannot stop the Meatball Man.
	lifetime = 0 // Meatball Man is eternal.
	spin = FALSE
	hitpwr = 1
	heavy = 1
	meteorsound = 'sound/effects/blobattack.ogg'
	threat = 200
	move_delay = 40 // Meatball Man never rushes, for all will become Meat in time.
	var/meaty_range = 14
	var/eaty_range = 7
	var/meat_spreadiness = 20
	var/he_is_close = FALSE

/obj/effect/meteor/meaty/meatball_man/Move()
	. = ..()
	for(var/tile in spiral_range_turfs(eaty_range, src))
		var/turf/T = tile
		if(!T || !isturf(loc))
			continue
		T.ex_act(hitpwr)
		for(var/atom/thing in T)
			if(isturf(loc) && thing != src)
				thing.ex_act(hitpwr)
	for(var/i = 1, i <= meat_spreadiness, i++)
		var/chosen_x = src.x + rand(-1, 1)*(eaty_range + rand(0, (meaty_range - eaty_range)))
		var/chosen_y = src.y + rand(-1, 1)*(eaty_range + rand(0, (meaty_range - eaty_range)))
		var/turf/T = locate(chosen_x, chosen_y, src.z)
		if(T && !isspaceturf(T))
			new meteorgibs(T)
			if(!he_is_close)
				he_is_close = TRUE
				waltz()

/obj/effect/meteor/meaty/meatball_man/Initialize()
	for(var/obj/effect/meteor/meaty/meatball_man/M in GLOB.meteor_list)
		if(M != src)
			qdel(src) // There is only one Meatball Man.
			return INTIALIZE_HINT_QDEL
	. = ..()

/obj/effect/meteor/meaty/meatball_man/singularity_act()
	return // ♫ And he decided to munch, on a singularity for lunch... ♫

/obj/effect/meteor/meaty/meatball_man/proc/waltz()
	for(var/V in GLOB.player_list)
		var/mob/M = V
		if((M.client.prefs.toggles & SOUND_MIDI) && is_station_level(M.z))
			M.playsound_local(M, 'sound/misc/meaty_waltz.ogg', 20, FALSE, pressure_affected = FALSE)

//////////////////////////
//Spookoween meteors
/////////////////////////

GLOBAL_LIST_INIT(meteorsSPOOKY, list(/obj/effect/meteor/pumpkin))

/obj/effect/meteor/pumpkin
	name = "PUMPKING"
	desc = "THE PUMPKING'S COMING!"
	icon = 'icons/obj/meteor_spooky.dmi'
	icon_state = "pumpkin"
	hits = 10
	heavy = 1
	dropamt = 1
	meteordrop = list(/obj/item/clothing/head/hardhat/pumpkinhead, /obj/item/reagent_containers/food/snacks/grown/pumpkin)
	threat = 100

/obj/effect/meteor/pumpkin/Initialize()
	. = ..()
	meteorsound = pick('sound/hallucinations/im_here1.ogg','sound/hallucinations/im_here2.ogg')
//////////////////////////
#undef DEFAULT_METEOR_LIFETIME
