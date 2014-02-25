/obj/item/key/gokart
	name = "\improper Go-Kart key"
	desc = "A keyring with a small steel key, with a picture of Saint Mario as a fob."
	icon_state = "gokart_keys"

/obj/structure/stool/bed/chair/vehicle/gokart
	name = "\improper Go-Kart"
	desc = "Tiny car for tiny people."
	icon_state = "gokart0"
	//nick = "TRUE POWER"
	keytype = /obj/item/key/gokart

/obj/structure/stool/bed/chair/vehicle/gokart/buckle_mob(mob/M, mob/user)
	..(M,user)
	update_icon()

/obj/structure/stool/bed/chair/vehicle/gokart/unbuckle()
	..()
	update_icon()

/obj/structure/stool/bed/chair/vehicle/gokart/update_icon()
	icon_state="gokart[!isnull(buckled_mob)]"

/obj/structure/stool/bed/chair/vehicle/gokart/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 4
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -4
				buckled_mob.pixel_y = 7