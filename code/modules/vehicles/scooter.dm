/obj/vehicle/scooter
	name = "scooter"
	desc = "A fun way to get around."
	icon_state = "scooter"

/obj/vehicle/scooter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You begin to remove the handlebars...</span>"
		playsound(get_turf(user), 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 40/I.toolspeed, target = src))
			new /obj/vehicle/scooter/skateboard(get_turf(src))
			new /obj/item/stack/rods(get_turf(src),2)
			user << "<span class='notice'>You remove the handlebars from [src].</span>"
			qdel(src)

/obj/vehicle/scooter/handle_vehicle_layer()
	if(dir == SOUTH)
		layer = MOB_LAYER+0.1
	else
		layer = OBJ_LAYER

/obj/vehicle/scooter/handle_vehicle_offsets()
	..()
	if(buckled_mobs.len)
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			switch(buckled_mob.dir)
				if(NORTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 4
				if(EAST)
					buckled_mob.pixel_x = -2
					buckled_mob.pixel_y = 4
				if(SOUTH)
					buckled_mob.pixel_x = 0
					buckled_mob.pixel_y = 4
				if(WEST)
					buckled_mob.pixel_x = 2
					buckled_mob.pixel_y = 4

/obj/vehicle/scooter/skateboard
	name = "skateboard"
	desc = "An unfinished scooter which can only barely be called a skateboard. It's still rideable, but probably unsafe. Looks like you'll need to add a few rods to make handlebars."
	icon_state = "skateboard"
	vehicle_move_delay = 0//fast
	density = 0

/obj/vehicle/scooter/skateboard/post_buckle_mob(mob/living/M)//allows skateboards to be non-dense but still allows 2 skateboarders to collide with each other
	if(buckled_mobs.len)
		density = 1
	else
		density = 0

/obj/vehicle/scooter/skateboard/Bump(atom/A)
	..()
	if(A.density && buckled_mobs.len)
		var/mob/living/carbon/H = buckled_mobs[1]
		var/atom/throw_target = get_edge_target_turf(H, pick(cardinal))
		unbuckle_mob(H)
		H.throw_at_fast(throw_target, 4, 3)
		H.Weaken(5)
		H.adjustStaminaLoss(40)
		visible_message("<span class='danger'>[src] crashes into [A], sending [H] flying!</span>")
		playsound(src, 'sound/effects/bang.ogg', 50, 1)

//CONSTRUCTION
/obj/item/scooter_frame
	name = "scooter frame"
	desc = "A metal frame for building a scooter. Looks like you'll need to add some metal to make wheels."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "scooter_frame"
	w_class = 3

/obj/item/scooter_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You deconstruct [src].</span>"
		new /obj/item/stack/rods(get_turf(src),10)
		playsound(get_turf(user), 'sound/items/Ratchet.ogg', 50, 1)
		qdel(src)
		return

	else if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.amount < 5)
			user << "<span class='warning'>You need at least five metal sheets to make proper wheels!</span>"
			return
		user << "<span class='notice'>You begin to add wheels to [src].</span>"
		if(do_after(user, 80, target = src))
			M.use(5)
			user << "<span class='notice'>You finish making wheels for [src].</span>"
			new /obj/vehicle/scooter/skateboard(user.loc)
			qdel(src)

/obj/vehicle/scooter/skateboard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		user << "<span class='notice'>You begin to deconstruct and remove the wheels on [src]...</span>"
		playsound(get_turf(user), 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20, target = src))
			user << "<span class='notice'>You deconstruct the wheels on [src].</span>"
			new /obj/item/stack/sheet/metal(get_turf(src),5)
			new /obj/item/scooter_frame(get_turf(src))
			qdel(src)

	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/C = I
		if(C.get_amount() < 2)
			user << "<span class='warning'>You need at least two rods to make proper handlebars!</span>"
			return
		user << "<span class='notice'>You begin making handlebars for [src].</span>"
		if(do_after(user, 25, target = src))
			user << "<span class='notice'>You add the rods to [src], creating handlebars.</span>"
			C.use(2)
			new/obj/vehicle/scooter(get_turf(src))
			qdel(src)