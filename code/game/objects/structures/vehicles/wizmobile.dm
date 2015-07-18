/obj/item/key/wizmobile
	name = "\improper Firebird key"
	desc = "A keyring with a small steel key, and a fancy blue and gold fob."
	icon_state = "magic_keys"

/obj/effect/effect/trails/firebird
	base_name = "fire"

/obj/effect/effect/trails/firebird/Play()
	dir=pick(cardinal)
	spawn(rand(10,20))
		if(src)
			returnToPool(src)

/datum/effect/effect/system/trail/firebird
	trail_type = /obj/effect/effect/trails/firebird

/obj/structure/bed/chair/vehicle/wizmobile
	name = "\improper Firebird"
	desc = "A Pontiac Firebird Trans Am with skulls and crossbones on the hood, dark grey paint, and gold trim.  No magic required for this baby."
	icon_state = "wizmobile"
	//nick = "TRUE POWER"
	keytype = /obj/item/key/wizmobile
	can_spacemove=1
	//ethereal=1 // NERF
	var/can_move=1
	layer = FLY_LAYER

	var/datum/effect/effect/system/trail/firebird/ion_trail

/obj/structure/bed/chair/vehicle/wizmobile/New()
	..()
	ion_trail = new /datum/effect/effect/system/trail/firebird()
	ion_trail.set_up(src)
	ion_trail.start()


/* Server vote on 16-12-2014 to disable wallmoving (10-7 Y)
// Shit be ethereal.
/obj/structure/bed/chair/vehicle/wizmobile/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return 1
*/

/obj/structure/bed/chair/vehicle/wizmobile/update_mob()
	if(!occupant)
		return

	switch(dir)
		if(SOUTH)
			occupant.pixel_x = 0
			occupant.pixel_y = 7
		if(WEST)
			occupant.pixel_x = 3 // 13
			occupant.pixel_y = 7
		if(NORTH)
			occupant.pixel_x = 0
			occupant.pixel_y = 4
		if(EAST)
			occupant.pixel_x = -3 // -13
			occupant.pixel_y = 7

/obj/structure/bed/chair/vehicle/wizmobile/handle_layer()
	return

/obj/structure/bed/chair/vehicle/wizmobile/Bump(var/atom/obstacle)

	/*												most likely a bad idea
	if(istype(obstacle, /obj/structure/window/))
		obstacle.Destroy(brokenup = 1)

	if(istype(obstacle, /obj/structure/grille/))
		var/obj/structure/grille/G = obstacle
		G.health = (0.25*initial(G.health))
		G.broken = 1
		G.icon_state = "[initial(G.icon_state)]-b"
		G.density = 0
		getFromPool(/obj/item/stack/rods, get_turf(G.loc))
	*/

	..()


/* Server vote on 16-12-2014 to disable wallmoving (10-7 Y)
/obj/structure/bed/chair/vehicle/wizmobile/Bump(var/atom/obstacle)
	if(can_move)
		can_move = 0
		alpha=128
		forceMove(get_step(src,src.dir))
		if(locked_to_mob)
			if(locked_to_mob.loc != loc)
				locked_to_mob.locked_to = null //Temporary, so Move() succeeds.
				locked_to_mob.locked_to = src //Restoring
		sleep(10) // 1s
		alpha=255
		can_move = 1
	else
		. = ..()
	return
*/