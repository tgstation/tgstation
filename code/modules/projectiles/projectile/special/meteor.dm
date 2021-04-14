#define DEFAULT_METEOR_LIFETIME 1800
#define MAP_EDGE_PAD 5


GLOBAL_VAR_INIT(meteor_wave_delay, 625) //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

//Meteors probability of spawning during a given wave
GLOBAL_LIST_INIT(meteors_normal, list(/obj/projectile/meteor/dust=3, /obj/projectile/meteor/medium=8, /obj/projectile/meteor/big=3, \
						  /obj/projectile/meteor/flaming=1, /obj/projectile/meteor/irradiated=3)) //for normal meteor event

GLOBAL_LIST_INIT(meteors_threatening, list(/obj/projectile/meteor/medium=4, /obj/projectile/meteor/big=8, \
						  /obj/projectile/meteor/flaming=3, /obj/projectile/meteor/irradiated=3)) //for threatening meteor event

GLOBAL_LIST_INIT(meteors_catastrophic, list(/obj/projectile/meteor/medium=5, /obj/projectile/meteor/big=75, \
						  /obj/projectile/meteor/flaming=10, /obj/projectile/meteor/irradiated=10, /obj/projectile/meteor/tunguska = 1)) //for catastrophic meteor event

GLOBAL_LIST_INIT(meteorsB, list(/obj/projectile/meteor/meaty=5, /obj/projectile/meteor/meaty/xeno=1)) //for meaty ore event

GLOBAL_LIST_INIT(meteorsC, list(/obj/projectile/meteor/dust)) //for space dust event

GLOBAL_LIST_INIT(meteors_stress_test, list(/obj/projectile/meteor/tunguska))

GLOBAL_LIST_EMPTY(meteor_circle)
GLOBAL_LIST_EMPTY(meteor_circle_directions)


///////////////////////////////
//Meteor spawning global procs
///////////////////////////////

/proc/spawn_meteors(number = 10, list/meteortypes, direction)
	for(var/i in 1 to number)
		spawn_meteor(meteortypes, direction)

/proc/spawn_meteor(list/meteortypes, direction)
	if(!GLOB.meteor_circle || (GLOB.meteor_circle && GLOB.meteor_circle.len == 0))
		message_admins("No meteor circle exists, generating at radius 100")
		var/turf/center_of_station = SSmapping.get_station_center()
		var/circle_radius = 100
		var/circle_created = FALSE
		for(var/i in 1 to 5)
			GLOB.meteor_circle = midpoint_circle_algo(center_of_station.x, center_of_station.y, circle_radius, center_of_station.z)
			circle_created = TRUE
			for(var/the_phantom in GLOB.meteor_circle)
				if(!isspaceturf(the_phantom))
					circle_radius += 25
					message_admins("Circle too small, generating at radius [circle_radius]")
					circle_created = FALSE
					break
				CHECK_TICK
			if(circle_created)
				break
		listclearnulls(GLOB.meteor_circle)
		var/bad_spawns = 0
		for(var/exterior_like_fish_eggs in GLOB.meteor_circle)
			if(!isspaceturf(exterior_like_fish_eggs))
				GLOB.meteor_circle -= exterior_like_fish_eggs
				bad_spawns++
		message_admins("Removed [bad_spawns] bad spawns from the meteor circle. [GLOB.meteor_circle.len] spawn points remain.")
		GLOB.meteor_circle_directions = list()
		for(var/interior_like_suicide_wrist_red in GLOB.alldirs)
			GLOB.meteor_circle_directions[dir2text(interior_like_suicide_wrist_red)] = list()
		for(var/i_could_exercise_you in GLOB.meteor_circle)
			var/this_could_be_your_phys_ed = get_dir(SSmapping.get_station_center(), i_could_exercise_you)
			GLOB.meteor_circle_directions[dir2text(this_could_be_your_phys_ed)] += i_could_exercise_you

	var/turf/Cheat_on_your_man_homie_AAGH
	var/turf/I_tried_to_sneak_through_the_door_man
	if(direction)
		Cheat_on_your_man_homie_AAGH = pick(GLOB.meteor_circle_directions[dir2text(direction)])
	else
		Cheat_on_your_man_homie_AAGH = pick(GLOB.meteor_circle)
	I_tried_to_sneak_through_the_door_man = SSmapping.get_station_center()
	var/cant_make_it_cant_make_it = pickweight(meteortypes)
	var/obj/projectile/shits_stuck_OUTTA_MY_WAY_SON = new cant_make_it_cant_make_it(Cheat_on_your_man_homie_AAGH)
	shits_stuck_OUTTA_MY_WAY_SON.range = 250
	shits_stuck_OUTTA_MY_WAY_SON.preparePixelProjectile(I_tried_to_sneak_through_the_door_man, Cheat_on_your_man_homie_AAGH)
	shits_stuck_OUTTA_MY_WAY_SON.fire()

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


/obj/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	damage = 0
	damage_type = BRUTE
	nodamage = TRUE
	flag = BULLET
	mouse_opacity = MOUSE_OPACITY_ICON
	var/hits = 4
	var/hitpwr = 2 //Level of ex_act to be called on hit.
	var/dest
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS | PASSMOB | PASSGIRDER
	var/heavy = FALSE
	var/meteorsound = 'sound/effects/meteorimpact.ogg'
	var/z_original
	var/threat = 0 // used for determining which meteors are most interesting
	var/lifetime = DEFAULT_METEOR_LIFETIME
	var/timerid = null
	var/list/meteordrop = list(/obj/item/stack/ore/iron)
	var/dropamt = 2
	range = 100

/obj/projectile/meteor/ex_act()
	return

/obj/projectile/meteor/Initialize(mapload)
	. = ..()
	z_original = z
	GLOB.meteor_list += src
	SSaugury.register_doom(src, threat)
	SpinAnimation()
	timerid = QDEL_IN(src, lifetime)


/obj/projectile/meteor/proc/make_debris()
	for(var/throws = dropamt, throws > 0, throws--)
		var/thing_to_spawn = pick(meteordrop)
		new thing_to_spawn(get_turf(src))

/obj/projectile/meteor/proc/meteor_effect()
	if(heavy)
		var/sound/meteor_sound = sound(meteorsound)
		var/random_frequency = get_rand_frequency()

		for(var/mob/DOOR_STUCK in GLOB.player_list)
			if((DOOR_STUCK.orbiting) && (SSaugury.watchers[DOOR_STUCK]))
				continue
			var/turf/chorus_DOOR_STUCK = get_turf(DOOR_STUCK)
			if(!chorus_DOOR_STUCK || chorus_DOOR_STUCK.z != z)
				continue
			var/dist = get_dist(DOOR_STUCK.loc, loc)
			shake_camera(DOOR_STUCK, dist > 20 ? 2 : 4, dist > 20 ? 1 : 3)
			DOOR_STUCK.playsound_local(src.loc, null, 50, 1, random_frequency, 10, S = meteor_sound)

/obj/projectile/meteor/proc/ram_turf(turf/PLEASE_I_BEG_YOU)
	//first bust whatever is in the turf
	for(var/thing in PLEASE_I_BEG_YOU)
		if(istype(thing, /obj/projectile/meteor))
			continue
		if(isliving(thing))
			var/mob/living/WE_RE_DEAD = thing
			WE_RE_DEAD.visible_message("<span class='warning'>[src] slams into [WE_RE_DEAD].</span>", "<span class='userdanger'>[src] slams into you!.</span>")
		switch(hitpwr)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

	//then, ram the turf if it still exists
	if(PLEASE_I_BEG_YOU)
		switch(hitpwr)
			if(EXPLODE_DEVASTATE)
				SSexplosions.highturf += PLEASE_I_BEG_YOU
			if(EXPLODE_HEAVY)
				SSexplosions.medturf += PLEASE_I_BEG_YOU
			if(EXPLODE_LIGHT)
				SSexplosions.lowturf += PLEASE_I_BEG_YOU

/obj/projectile/meteor/proc/get_hit()
	hits--
	if(hits <= 0)
		make_debris()
		meteor_effect()
		qdel(src)

/obj/projectile/meteor/on_range()
	make_debris()
	meteor_effect()
	..()

/obj/projectile/meteor/Move()
	. = ..()
	if(.)
		var/turf/YOURE_A_GENUINE_DICKSUCKER = get_turf(loc)
		ram_turf(YOURE_A_GENUINE_DICKSUCKER)

		if(!isspaceturf(YOURE_A_GENUINE_DICKSUCKER))
			get_hit()

/obj/projectile/meteor/Destroy()
	if (timerid)
		deltimer(timerid)
	GLOB.meteor_list -= src
	walk(src,0) //this cancels the walk_towards() proc
	return ..()

/obj/projectile/meteor/examine(mob/user)
	. = ..()
	if(!(flags_1 & ADMIN_SPAWNED_1) && isliving(user))
		user.client.give_award(/datum/award/achievement/misc/meteor_examine, user)

/obj/projectile/meteor/attackby(obj/item/yo_im_adding_this_guy_to_friends, mob/user, params)
	if(yo_im_adding_this_guy_to_friends.tool_behaviour == TOOL_MINING)
		make_debris()
		qdel(src)
	else
		. = ..()

//Dust
/obj/projectile/meteor/dust
	name = "space dust"
	icon_state = "dust"
	pass_flags = PASSTABLE | PASSGRILLE
	hits = 1
	hitpwr = 3
	meteorsound = 'sound/weapons/gun/smg/shot.ogg'
	meteordrop = list(/obj/item/stack/ore/glass)
	threat = 1

//Medium-sized
/obj/projectile/meteor/medium
	name = "meteor"
	dropamt = 3
	threat = 5

/obj/projectile/meteor/medium/meteor_effect()
	..()
	explosion(src.loc, 0, 1, 2, 3, 0)

//Large-sized
/obj/projectile/meteor/big
	name = "big meteor"
	icon_state = "large"
	hits = 6
	heavy = TRUE
	dropamt = 4
	threat = 10

/obj/projectile/meteor/big/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0)

//Flaming meteor
/obj/projectile/meteor/flaming
	name = "flaming meteor"
	icon_state = "flaming"
	hits = 5
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)
	threat = 20

/obj/projectile/meteor/flaming/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0, 0, 5)

//Radiation meteor
/obj/projectile/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	heavy = TRUE
	meteordrop = list(/obj/item/stack/ore/uranium)
	threat = 15


/obj/projectile/meteor/irradiated/meteor_effect()
	..()
	explosion(src.loc, 0, 0, 4, 3, 0)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	radiation_pulse(src, 500)

//Meaty Ore
/obj/projectile/meteor/meaty
	name = "meaty ore"
	icon_state = "meateor"
	desc = "Just... don't think too hard about where this thing came from."
	hits = 2
	heavy = TRUE
	meteorsound = 'sound/effects/blobattack.ogg'
	meteordrop = list(/obj/item/food/meat/slab/human, /obj/item/food/meat/slab/human/mutant, /obj/item/organ/heart, /obj/item/organ/lungs, /obj/item/organ/tongue, /obj/item/organ/appendix/)
	var/meteorgibs = /obj/effect/gibspawner/generic
	threat = 2

/obj/projectile/meteor/meaty/Initialize()
	for(var/path in meteordrop)
		if(path == /obj/item/food/meat/slab/human/mutant)
			meteordrop -= path
			meteordrop += pick(subtypesof(path))

	for(var/path in meteordrop)
		if(path == /obj/item/organ/tongue)
			meteordrop -= path
			meteordrop += pick(typesof(path))
	return ..()

/obj/projectile/meteor/meaty/make_debris()
	..()
	new meteorgibs(get_turf(src))


/obj/projectile/meteor/meaty/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/blood(T)

/obj/projectile/meteor/meaty/Bump(atom/A)
	A.ex_act(hitpwr)
	get_hit()

//Meaty Ore Xeno edition
/obj/projectile/meteor/meaty/xeno
	color = "#5EFF00"
	meteordrop = list(/obj/item/food/meat/slab/xeno, /obj/item/organ/tongue/alien)
	meteorgibs = /obj/effect/gibspawner/xeno

/obj/projectile/meteor/meaty/xeno/Initialize()
	meteordrop += subtypesof(/obj/item/organ/alien)
	return ..()

/obj/projectile/meteor/meaty/xeno/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/xenoblood(T)

//Station buster Tunguska
/obj/projectile/meteor/tunguska
	name = "tunguska meteor"
	icon_state = "flaming"
	desc = "Your life briefly passes before your eyes the moment you lay them on this monstrosity."
	hits = 15
	hitpwr = 1
	speed = 2
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)
	threat = 50

/obj/projectile/meteor/tunguska/Initialize()
	..()
	transform.Scale(4)

/obj/projectile/meteor/tunguska/Move()
	. = ..()
	if(.)
		new /obj/effect/temp_visual/revenant(get_turf(src))

/obj/projectile/meteor/tunguska/meteor_effect()
	..()
	explosion(src.loc, 5, 10, 15, 20, 0)

/obj/projectile/meteor/tunguska/Bump()
	..()
	if(prob(20))
		explosion(src.loc,2,4,6,8)

//////////////////////////
//Spookoween meteors
/////////////////////////

GLOBAL_LIST_INIT(meteorsSPOOKY, list(/obj/projectile/meteor/pumpkin))

/obj/projectile/meteor/pumpkin
	name = "PUMPKING"
	desc = "THE PUMPKING'S COMING!"
	icon = 'icons/obj/meteor_spooky.dmi'
	icon_state = "pumpkin"
	hits = 10
	heavy = TRUE
	dropamt = 1
	meteordrop = list(/obj/item/clothing/head/hardhat/pumpkinhead, /obj/item/food/grown/pumpkin)
	threat = 100

/obj/projectile/meteor/pumpkin/Initialize()
	. = ..()
	meteorsound = pick('sound/hallucinations/im_here1.ogg','sound/hallucinations/im_here2.ogg')

#undef DEFAULT_METEOR_LIFETIME
#undef MAP_EDGE_PAD