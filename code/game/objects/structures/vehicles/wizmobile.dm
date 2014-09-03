/obj/item/key/wizmobile
	name = "\improper Firebird key"
	desc = "A keyring with a small steel key, and a fancy blue and gold fob."
	icon_state = "magic_keys"

/obj/structure/stool/bed/chair/vehicle/wizmobile
	name = "\improper Firebird"
	desc = "A Pontiac Firebird Trans Am with skulls and crossbones on the hood, dark grey paint, and gold trim.  No magic required for this baby."
	icon_state = "wizmobile"
	//nick = "TRUE POWER"
	keytype = /obj/item/key/wizmobile
	can_spacemove=1
	//ethereal=1 // NERF
	var/can_move=1

// Shit be ethereal.
/obj/structure/stool/bed/chair/vehicle/wizmobile/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return 1

/obj/structure/stool/bed/chair/vehicle/wizmobile/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 3 // 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -3 // -13
				buckled_mob.pixel_y = 7

/obj/structure/stool/bed/chair/vehicle/wizmobile/handle_rotation()
	//if(dir == SOUTH)
	layer = FLY_LAYER
	//else
	//	layer = OBJ_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()

/obj/structure/stool/bed/chair/vehicle/wizmobile/Bump(var/atom/obstacle)
	if(can_move)
		can_move = 0
		alpha=128
		forceMove(get_step(src,src.dir))
		if(buckled_mob)
			if(buckled_mob.loc != loc)
				buckled_mob.buckled = null //Temporary, so Move() succeeds.
				buckled_mob.buckled = src //Restoring
		sleep(10) // 1s
		alpha=255
		can_move = 1
	else
		. = ..()
	return