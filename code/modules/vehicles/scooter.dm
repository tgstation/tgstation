/obj/vehicle/scooter
	name = "scooter"
	desc = "A popular child's toy back on the planets, handcrafted by some greyshirt."
	icon_state = "scooter"
	vehicle_move_delay = 2.2 //slightly slower than other vehicles, due to being made with pipes, rods, and metal
	var/pipetype = 1 //so the pipe created on deconstruction doesn't have a blank icon_state, changes on construction of the scooter
	var/pipename	 //same
/obj/vehicle/scooter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You begin to remove the pipe..</span>"
		if(do_after(user, 40/I.toolspeed, target = src))
			new/obj/item/scooter_frame(get_turf(src))
			var/obj/item/pipe/Q = new/obj/item/pipe
			Q.pipe_type = pipetype
			Q.pipename = pipename
			user.put_in_hands(Q)
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
			construction_state = SCOOTER_STATE_WHEELS
			icon_state = "scooter_frame_2"
			return

	if(construction_state == SCOOTER_STATE_WHEELS)

		if(istype(I, /obj/item/weapon/screwdriver))
			user << "<span class='notice'>You remove the wheels from the [src].</span>"
			new/obj/item/stack/sheet/metal(get_turf(src),2)
			construction_state = SCOOTER_STATE_FRAME
			icon_state = "scooter_frame_1"

		if(istype(I, /obj/item/pipe))
			var/obj/item/pipe/C = I
			user << "<span class='notice'>You add the pipe to the [src].</span>"
			var/obj/vehicle/scooter/M = new/obj/vehicle/scooter(get_turf(src))
			M.pipetype = C.pipe_type
			M.pipename = C.pipename
			qdel(I)
			qdel(src)