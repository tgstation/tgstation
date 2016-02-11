/obj/vehicle/scooter
	name = "scooter"
	desc = "A popular child's toy back on the planets, handcrafted by some greyshirt."
	icon_state = "scooter"
	vehicle_move_delay = 2.2 //slightly slower than other vehicles, due to being made with pipes, rods, and metal

/obj/vehicle/scooter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You begin to remove the pipe..</span>"
		if(do_after(user, 40/I.toolspeed, target = src))
			new/obj/item/scooter_frame(get_turf(src))
			var/pipe = new/obj/item/pipe
			user.put_in_hands(pipe)
			new/obj/item/stack/sheet/metal(get_turf(src),2)
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

/obj/item/scooter_frame
	name = "scooter frame"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "scooter_frame_1"
	var/construction_state = 1

/obj/item/scooter_frame/attackby(obj/item/I, mob/user, params)
	if(construction_state == 1)

		if(istype(I, /obj/item/weapon/wrench))
			user << "<span class='notice'>You deconstruct the [src].</span>"
			new/obj/item/stack/rods(get_turf(src),2)
			qdel(src)
			return

		if(istype(I, /obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/metal/P = I
			if(P.get_amount() < 2)
				user << "<span class='warning'>You need at least 2 shets of metal!</span>"
				return
			user << "<span class='notice'>You add wheels to the [src].</span>"
			P.use(2)
			construction_state = 2
			icon_state = "scooter_frame_2"
			return

	if(construction_state == 2)

		if(istype(I, /obj/item/weapon/screwdriver))
			user << "<span class='notice'>You remove the wheels from the [src].</span>"
			new/obj/item/stack/sheet/metal(get_turf(src),2)
			construction_state = 1
			icon_state = "scooter_frame_1"

		if(istype(I, /obj/item/pipe))
			user << "<span class='notice'>You add the pipe to the [src].</span>"
			qdel(I)
			new/obj/vehicle/scooter(get_turf(src))
			qdel(src)