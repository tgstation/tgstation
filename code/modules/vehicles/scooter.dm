/obj/vehicle/scooter
	name = "scooter"
	desc = "A popular child's toy back on the planets, but handcrafted with pipes and metal."
	icon_state = "scooter"

/obj/vehicle/scooter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You begin to remove the pipe..</span>"
		if(do_after(user, 40/I.toolspeed, target = src))
			new /obj/item/scooter_frame(get_turf(src))
			new /obj/item/wheel(get_turf(src))
			new /obj/item/stack/rods(get_turf(src),2)
			user << "<span class='warning'>It all falls apart!</span>"
			qdel(src)

/obj/vehicle/scooter/handle_vehicle_layer()
	if(dir == SOUTH)
		layer = MOB_LAYER+0.1
	else
		layer = OBJ_LAYER

/obj/vehicle/scooter/handle_vehicle_offsets()
	..()
	if(buckled_mob)
		switch(buckled_mob.dir)
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -2
				buckled_mob.pixel_y = 4
			if(WEST)
				buckled_mob.pixel_x = 2
				buckled_mob.pixel_y = 4
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
//CONSTRUCTION
#define SCOOTER_STATE_FRAME		1
#define SCOOTER_STATE_WHEELS	2
/obj/item/scooter_frame
	name = "scooter frame"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "scooter_frame_1"
	var/construction_state = SCOOTER_STATE_FRAME

/obj/item/scooter_frame/attackby(obj/item/I, mob/user, params)
	if(construction_state == SCOOTER_STATE_FRAME)

		if(istype(I, /obj/item/weapon/wrench))
			user << "<span class='notice'>You deconstruct the [src].</span>"
			new /obj/item/stack/rods(get_turf(src),2)
			qdel(src)
			return

		else if(istype(I, /obj/item/wheel))
			user << "<span class='notice'>You add wheels to the [src].</span>"
			qdel(I)
			construction_state = SCOOTER_STATE_WHEELS
			icon_state = "scooter_frame_2"
			return

	else if(construction_state == SCOOTER_STATE_WHEELS)

		if(istype(I, /obj/item/weapon/screwdriver))
			user << "<span class='notice'>You remove the wheels from the [src].</span>"
			new /obj/item/stack/sheet/metal(get_turf(src),2)
			construction_state = SCOOTER_STATE_FRAME
			icon_state = "scooter_frame_1"

		else if(istype(I, /obj/item/stack/rods))
			var/obj/item/stack/rods/C = I
			if(C.get_amount() < 2)
				user << "<span class='warning'>You need at least two rods!</span>"
				return
			user << "<span class='notice'>You add the rods to the [src].</span>"
			C.use(2)
			new/obj/vehicle/scooter(get_turf(src))
			qdel(src)