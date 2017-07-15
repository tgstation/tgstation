
/obj/vehicle
	name = "vehicle"
	desc = "A basic vehicle, vroom"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "fuckyou"
	density = TRUE
	anchored = FALSE
	can_buckle = 1
	buckle_lying = 0
	max_integrity = 300
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 0, bomb = 30, bio = 0, rad = 0, fire = 60, acid = 60)
	var/auto_door_open = TRUE
	var/view_range = 7
	var/datum/riding/riding_datum = null

/obj/vehicle/Destroy()
	QDEL_NULL(riding_datum)
	return ..()

/obj/vehicle/update_icon()
	return

/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY

//BUCKLE HOOKS
/obj/vehicle/unbuckle_mob(mob/living/buckled_mob,force = 0)
	if(riding_datum)
		riding_datum.restore_position(buckled_mob)
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
	if(user.client)
		user.client.change_view(view_range)
	if(riding_datum)
		riding_datum.ridden = src
		riding_datum.handle_vehicle_offsets()

//MOVEMENT
/obj/vehicle/relaymove(mob/user, direction)
	if(riding_datum)
		riding_datum.handle_ride(user, direction)


/obj/vehicle/Moved()
	. = ..()
	if(riding_datum)
		riding_datum.handle_vehicle_layer()
		riding_datum.handle_vehicle_offsets()


/obj/vehicle/Collide(atom/movable/M)
	. = ..()
	if(auto_door_open)
		if(istype(M, /obj/machinery/door) && has_buckled_mobs())
			for(var/m in buckled_mobs)
				M.CollidedWith(m)


/obj/vehicle/Process_Spacemove(direction)
	if(has_gravity())
		return 1

	if(pulledby && (pulledby.loc != loc))
		return 1

	return 0

/obj/vehicle/space
	pressure_resistance = INFINITY


/obj/vehicle/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 20)
		return 0
	. = ..()

/obj/vehicle/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)

/obj/vehicle/examine(mob/user)
	..()
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			to_chat(user, "<span class='warning'>It's on fire!</span>")
		var/healthpercent = (obj_integrity/max_integrity) * 100
		switch(healthpercent)
			if(50 to 99)
				to_chat(user,  "It looks slightly damaged.")
			if(25 to 50)
				to_chat(user,  "It appears heavily damaged.")
			if(0 to 25)
				to_chat(user,  "<span class='warning'>It's falling apart!</span>")