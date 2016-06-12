
/obj/vehicle
	name = "vehicle"
	desc = "A basic vehicle, vroom"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "fuckyou"
	density = 1
	anchored = 0
	can_buckle = 1
	buckle_lying = 0
	var/keytype = null //item typepath, if non-null an item of this type is needed in your hands to drive this vehicle
	var/next_vehicle_move = 0 //used for move delays
	var/vehicle_move_delay = 2 //tick delay between movements, lower = faster, higher = slower
	var/auto_door_open = TRUE
	var/view_range = 7

	//Pixels
	var/generic_pixel_x = 0 //All dirs show this pixel_x for the driver
	var/generic_pixel_y = 0 //All dirs shwo this pixel_y for the driver


/obj/vehicle/New()
	..()
	handle_vehicle_layer()


//APPEARANCE
/obj/vehicle/proc/handle_vehicle_layer()
	if(dir != NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER


//Override this to set your vehicle's various pixel offsets
//if they differ between directions, otherwise use the
//generic variables
/obj/vehicle/proc/handle_vehicle_offsets()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(dir)
			buckled_mob.pixel_x = generic_pixel_x
			buckled_mob.pixel_y = generic_pixel_y


/obj/vehicle/update_icon()
	return



//KEYS
/obj/vehicle/proc/keycheck(mob/user)
	if(keytype)
		if(istype(user.l_hand, keytype) || istype(user.r_hand, keytype))
			return 1
	else
		return 1
	return 0

/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = 1


//BUCKLE HOOKS
/obj/vehicle/unbuckle_mob(mob/living/buckled_mob,force = 0)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
		if(buckled_mob.client)
			buckled_mob.client.view = world.view
	. = ..()


/obj/vehicle/user_buckle_mob(mob/living/M, mob/user)
	if(user.incapacitated())
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density)
			if(A != src && A != M)
				return
	M.loc = get_turf(src)
	..()
	handle_vehicle_offsets()
	if(user.client)
		user.client.view = view_range


//MOVEMENT
/obj/vehicle/relaymove(mob/user, direction)
	if(user.incapacitated())
		unbuckle_mob(user)

	if(keycheck(user))
		if(!Process_Spacemove(direction) || world.time < next_vehicle_move || !isturf(loc))
			return
		next_vehicle_move = world.time + vehicle_move_delay

		step(src, direction)

		handle_vehicle_layer()
		handle_vehicle_offsets()
	else
		user << "<span class='notice'>You'll need the keys in one of your hands to drive \the [name].</span>"


/obj/vehicle/Move(NewLoc,Dir=0,step_x=0,step_y=0)
	. = ..()
	handle_vehicle_layer()
	handle_vehicle_offsets()


/obj/vehicle/attackby(obj/item/I, mob/user, params)
	if(keytype && istype(I, keytype))
		user << "Hold [I] in one of your hands while you drive \the [name]."
	else
		return ..()

/obj/vehicle/Bump(atom/movable/M)
	. = ..()
	if(auto_door_open)
		if(istype(M, /obj/machinery/door) && has_buckled_mobs())
			for(var/m in buckled_mobs)
				M.Bumped(m)


/obj/vehicle/Process_Spacemove(direction)
	if(has_gravity(src))
		return 1

	if(pulledby)
		return 1

	return 0

/obj/vehicle/space
	pressure_resistance = INFINITY

/obj/vehicle/space/Process_Spacemove(direction)
	return 1
