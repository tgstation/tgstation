#define DEFAULT_METEOR_LIFETIME 1800
#define MAP_EDGE_PAD 5

GLOBAL_VAR_INIT(meteor_wave_delay, 625) //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

//Meteors probability of spawning during a given wave
GLOBAL_LIST_INIT(meteors_normal, list(/obj/effect/meteor/dust=3, /obj/effect/meteor/medium=8, /obj/effect/meteor/big=3, \
						  /obj/effect/meteor/flaming=1, /obj/effect/meteor/irradiated=3)) //for normal meteor event

GLOBAL_LIST_INIT(meteors_threatening, list(/obj/effect/meteor/medium=4, /obj/effect/meteor/big=8, \
						  /obj/effect/meteor/flaming=3, /obj/effect/meteor/irradiated=3)) //for threatening meteor event

GLOBAL_LIST_INIT(meteors_catastrophic, list(/obj/effect/meteor/medium=5, /obj/effect/meteor/big=75, \
						  /obj/effect/meteor/flaming=10, /obj/effect/meteor/irradiated=10, /obj/effect/meteor/tunguska = 1)) //for catastrophic meteor event

GLOBAL_LIST_INIT(meteorsB, list(/obj/effect/meteor/meaty=5, /obj/effect/meteor/meaty/xeno=1)) //for meaty ore event

GLOBAL_LIST_INIT(meteorsC, list(/obj/effect/meteor/dust=1)) //for space dust event


///////////////////////////////
//Meteor spawning global procs
///////////////////////////////

/proc/spawn_meteors(number = 10, list/meteortypes)
	for(var/i in 1 to number)
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
	var/Me = pick_weight(meteortypes)
	var/obj/effect/meteor/M = new Me(pickedstart, pickedgoal)
	M.dest = pickedgoal

/proc/spaceDebrisStartLoc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD)
			startx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(EAST)
			starty = rand((TRANSITIONEDGE + MAP_EDGE_PAD),world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			startx = world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD)
		if(SOUTH)
			starty = (TRANSITIONEDGE + MAP_EDGE_PAD)
			startx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(WEST)
			starty = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			startx = (TRANSITIONEDGE + MAP_EDGE_PAD)
	. = locate(startx, starty, Z)

/proc/spaceDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	switch(startSide)
		if(NORTH)
			endy = (TRANSITIONEDGE + MAP_EDGE_PAD)
			endx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(EAST)
			endy = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			endx = (TRANSITIONEDGE + MAP_EDGE_PAD)
		if(SOUTH)
			endy = world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD)
			endx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(WEST)
			endy = rand((TRANSITIONEDGE + MAP_EDGE_PAD),world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			endx = world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD)
	. = locate(endx, endy, Z)

///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "\proper the concept of meteor"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	density = TRUE
	anchored = TRUE
	var/hits = 4
	var/hitpwr = EXPLODE_HEAVY //Level of ex_act to be called on hit.
	var/dest
	pass_flags = PASSTABLE
	var/heavy = FALSE
	var/meteorsound = 'sound/effects/meteorimpact.ogg'
	var/z_original
	var/threat = 0 // used for determining which meteors are most interesting
	var/lifetime = DEFAULT_METEOR_LIFETIME
	var/timerid = null
	var/list/meteordrop = list(/obj/item/stack/ore/iron)
	var/dropamt = 2

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
	walk(src,0) //this cancels the walk_towards() proc
	return ..()

/obj/effect/meteor/Initialize(mapload, target)
	. = ..()
	z_original = z
	GLOB.meteor_list += src
	SSaugury.register_doom(src, threat)
	SpinAnimation()
	timerid = QDEL_IN(src, lifetime)
	chase_target(target)

/obj/effect/meteor/Bump(atom/A)
	if(A)
		ram_turf(get_turf(A))
		playsound(src.loc, meteorsound, 40, TRUE)
		get_hit()

/obj/effect/meteor/proc/ram_turf(turf/T)
	//first bust whatever is in the turf
	for(var/thing in T)
		if(thing == src)
			continue
		if(isliving(thing))
			var/mob/living/living_thing = thing
			living_thing.visible_message(span_warning("[src] slams into [living_thing]."), span_userdanger("[src] slams into you!."))
		switch(hitpwr)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

	//then, ram the turf if it still exists
	if(T)
		switch(hitpwr)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += T
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += T
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += T



//process getting 'hit' by colliding with a dense object
//or randomly when ramming turfs
/obj/effect/meteor/proc/get_hit()
	hits--
	if(hits <= 0)
		make_debris()
		meteor_effect()
		qdel(src)

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

/obj/effect/meteor/proc/chase_target(atom/chasing, delay = 1)
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
			M.playsound_local(src.loc, null, 50, 1, random_frequency, 10, sound_to_use = meteor_sound)

///////////////////////
//Meteor types
///////////////////////

//Dust
/obj/effect/meteor/dust
	name = "space dust"
	icon_state = "dust"
	pass_flags = PASSTABLE | PASSGRILLE
	hits = 1
	hitpwr = EXPLODE_LIGHT
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
	explosion(src, heavy_impact_range = 1, light_impact_range = 2, flash_range = 3, adminlog = FALSE)

//Large-sized
/obj/effect/meteor/big
	name = "big meteor"
	icon_state = "large"
	hits = 6
	heavy = TRUE
	dropamt = 4
	threat = 10

/obj/effect/meteor/big/meteor_effect()
	..()
	explosion(src, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flash_range = 4, adminlog = FALSE)

//Flaming meteor
/obj/effect/meteor/flaming
	name = "flaming meteor"
	icon_state = "flaming"
	hits = 5
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)
	threat = 20

/obj/effect/meteor/flaming/meteor_effect()
	..()
	explosion(src, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flame_range = 5, flash_range = 4, adminlog = FALSE)

//Radiation meteor
/obj/effect/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	heavy = TRUE
	meteordrop = list(/obj/item/stack/ore/uranium)
	threat = 15


/obj/effect/meteor/irradiated/meteor_effect()
	..()
	explosion(src, light_impact_range = 4, flash_range = 3, adminlog = FALSE)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	radiation_pulse(src, max_range = 3, threshold = RAD_MEDIUM_INSULATION, chance = 80)

//Meaty Ore
/obj/effect/meteor/meaty
	name = "meaty ore"
	icon_state = "meateor"
	desc = "Just... don't think too hard about where this thing came from."
	hits = 2
	heavy = TRUE
	meteorsound = 'sound/effects/blobattack.ogg'
	meteordrop = list(/obj/item/food/meat/slab/human, /obj/item/food/meat/slab/human/mutant, /obj/item/organ/heart, /obj/item/organ/lungs, /obj/item/organ/tongue, /obj/item/organ/appendix/)
	var/meteorgibs = /obj/effect/gibspawner/generic
	threat = 2

/obj/effect/meteor/meaty/Initialize(mapload)
	for(var/path in meteordrop)
		if(path == /obj/item/food/meat/slab/human/mutant)
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
	meteordrop = list(/obj/item/food/meat/slab/xeno, /obj/item/organ/tongue/alien)
	meteorgibs = /obj/effect/gibspawner/xeno

/obj/effect/meteor/meaty/xeno/Initialize(mapload)
	meteordrop += subtypesof(/obj/item/organ/alien)
	return ..()

/obj/effect/meteor/meaty/xeno/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/xenoblood(T)

//Station buster Tunguska
/obj/effect/meteor/tunguska
	name = "tunguska meteor"
	icon_state = "flaming"
	desc = "Your life briefly passes before your eyes the moment you lay them on this monstrosity."
	hits = 30
	hitpwr = EXPLODE_DEVASTATE
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)
	threat = 50

/obj/effect/meteor/tunguska/Move()
	. = ..()
	if(.)
		new /obj/effect/temp_visual/revenant(get_turf(src))

/obj/effect/meteor/tunguska/meteor_effect()
	..()
	explosion(src, devastation_range = 5, heavy_impact_range = 10, light_impact_range = 15, flash_range = 20, adminlog = FALSE)

/obj/effect/meteor/tunguska/Bump()
	..()
	if(prob(20))
		explosion(src, devastation_range = 2, heavy_impact_range = 4, light_impact_range = 6, flash_range = 8, adminlog = FALSE)

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
	heavy = TRUE
	dropamt = 1
	meteordrop = list(/obj/item/clothing/head/hardhat/pumpkinhead, /obj/item/food/grown/pumpkin)
	threat = 100

/obj/effect/meteor/pumpkin/Initialize(mapload)
	. = ..()
	meteorsound = pick('sound/hallucinations/im_here1.ogg','sound/hallucinations/im_here2.ogg')
//////////////////////////
#undef DEFAULT_METEOR_LIFETIME
#undef MAP_EDGE_PAD
