/var/const/meteor_wave_delay = 625 //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

/var/list/meteorsA = list(/obj/effect/meteor/dust=3, /obj/effect/meteor/medium=8, /obj/effect/meteor/big=3, \
						  /obj/effect/meteor/flaming=1, /obj/effect/meteor/irradiated=3)

/var/list/meteorsB = list(/obj/effect/meteor/meaty=5, /obj/effect/meteor/meaty/xeno=1)

/var/list/meteorsC = list(/obj/effect/meteor/dust) //for space dust event

/*
/proc/meteor_wave(var/number = 50) //this proc's unused now.
	if(!ticker || wavesecret)
		return

	wavesecret = 1
	for(var/i = 0 to number)
		spawn(rand(10,100))
			spawn_meteor()
	spawn(meteor_wave_delay)
		wavesecret = 0

*/
/proc/spawn_meteors(var/number = 10, var/list/meteortypes)
	for(var/i = 0; i < number; i++)
		spawn_meteor(meteortypes)

/proc/spawn_meteor(var/list/meteortypes)
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 10//number of tries to spawn meteor.
	while (!istype(pickedstart, /turf/space) || pickedstart.loc.name != "Space" )
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
	return

/proc/spaceDebrisStartLoc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
		if(1) //NORTH
			starty = world.maxy-(TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(2) //EAST
			starty = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
			startx = world.maxx-(TRANSITIONEDGE+1)
		if(3) //SOUTH
			starty = (TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(4) //WEST
			starty = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
			startx = (TRANSITIONEDGE+1)
	var/turf/T = locate(startx, starty, Z)
	return T

/proc/spaceDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	switch(startSide)
		if(1) //NORTH
			endy = TRANSITIONEDGE
			endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
		if(2) //EAST
			endy = rand(TRANSITIONEDGE, world.maxy-TRANSITIONEDGE)
			endx = TRANSITIONEDGE
		if(3) //SOUTH
			endy = world.maxy-TRANSITIONEDGE
			endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
		if(4) //WEST
			endy = rand(TRANSITIONEDGE,world.maxy-TRANSITIONEDGE)
			endx = world.maxx-TRANSITIONEDGE
	var/turf/T = locate(endx, endy, Z)
	return T


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
	var/z_original

	var/meteordrop = /obj/item/weapon/ore/iron
	var/dropamt = 2

/obj/effect/meteor/Move()
	if(z != z_original || loc == dest)
		qdel(src)
	return ..()

/obj/effect/meteor/dust
	name = "space dust"
	icon_state = "dust"
	pass_flags = PASSTABLE | PASSGRILLE
	hits = 1
	hitpwr = 3
	meteorsound = 'sound/weapons/throwtap.ogg'
	meteordrop = /obj/item/weapon/ore/glass

/obj/effect/meteor/medium
	name = "meteor"
	dropamt = 3

/obj/effect/meteor/big
	name = "big meteor"
	icon_state = "large"
	hits = 7
	heavy = 1
	dropamt = 4

/obj/effect/meteor/flaming
	name = "flaming meteor"
	icon_state = "flaming"
	hits = 3
	heavy = 1
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = /obj/item/weapon/ore/plasma

/obj/effect/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	hits = 4
	heavy = 1
	meteordrop = /obj/item/weapon/ore/uranium

/obj/effect/meteor/meaty
	name = "meaty ore"
	icon_state = "meateor"
	desc = "Just... don't think too hard about where this thing came from."
	hits = 2
	heavy = 1
	meteorsound = 'sound/effects/blobattack.ogg'
	meteordrop = /obj/item/weapon/reagent_containers/food/snacks/meat
	var/meteorgibs = /obj/effect/gibspawner/generic

/obj/effect/meteor/meaty/xeno
	color = "#5EFF00"
	meteordrop = /obj/item/weapon/reagent_containers/food/snacks/xenomeat
	meteorgibs = /obj/effect/gibspawner/xeno


/obj/effect/meteor/New()
	..()
	SpinAnimation()

/obj/effect/meteor/Bump(atom/A)
	if(A)
		A.ex_act(hitpwr)
		playsound(src.loc, meteorsound, 40, 1)
	if(--src.hits <= 0)
		make_debris()
		meteor_effect(heavy)
		qdel(src)


/obj/effect/meteor/ex_act()
	return


/obj/effect/meteor/proc/meteor_effect(var/sound=1)
	if(sound)
		for(var/mob/M in player_list)
			var/turf/T = get_turf(M)
			if(!T || T.z != src.z)
				continue
			var/dist = get_dist(M.loc, src.loc)
			shake_camera(M, dist > 20 ? 3 : 5, dist > 20 ? 1 : 3)
			M.playsound_local(src.loc, meteorsound, 50, 1, get_rand_frequency(), 10)


/obj/effect/meteor/medium/meteor_effect()
	..(heavy)
	explosion(src.loc, 1, 2, 3, 4, 0)


/obj/effect/meteor/big/meteor_effect()
	..(heavy)
	explosion(src.loc, 0, 1, 2, 3, 0)


/obj/effect/meteor/flaming/meteor_effect()
	..(heavy)
	explosion(src.loc, 0, 1, 2, 3, 0, 0, 5)


/obj/effect/meteor/irradiated/meteor_effect()
	..(heavy)
	explosion(src.loc, 0, 0, 4, 3, 0)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	for(var/mob/living/L in view(5, src))
		L.apply_effect(40, IRRADIATE)



/obj/effect/meteor/proc/make_debris()
	for(var/throws = dropamt, throws > 0, throws--)
		var/obj/item/O = new meteordrop(get_turf(src))
		O.throw_at(dest, 5, 10)

/obj/effect/meteor/meaty/make_debris()
	..()
	new meteorgibs(get_turf(src))


/obj/effect/meteor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/pickaxe))
		qdel(src)
		return
	..()