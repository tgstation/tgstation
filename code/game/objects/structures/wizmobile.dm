/obj/item/key/wizmobile
	name = "janicart key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "magic_keys"

/obj/structure/stool/bed/chair/vehicle/wizmobile
	name = "\improper Pontiac"
	desc = "A Pontiac Firebird Trans Am with skulls and crossbones on the hood, dark grey paint, and gold trim.  No magic required for this baby."
	icon_state = "wizmobile"
	//nick = "TRUE POWER"
	keytype = /obj/item/key/wizmobile
	can_spacemove=1

// Shit be ethereal.
/obj/structure/stool/bed/chair/vehicle/wizmobile/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/obj/structure/stool/bed/chair/vehicle/wizmobile/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -13
				buckled_mob.pixel_y = 7