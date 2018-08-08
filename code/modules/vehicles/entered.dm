/obj/vehicle/sealed
	var/enter_delay = 20

/obj/vehicle/sealed/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/climb_out)

/obj/vehicle/sealed/generate_action_type()
	var/datum/action/vehicle/sealed/E = ..()
	. = E
	if(istype(E))
		E.vehicle_entered_target = src

/obj/vehicle/sealed/MouseDrop_T(atom/dropping, mob/M)
	if(!istype(dropping) || !istype(M))
		return ..()
	if(M == dropping)
		mob_try_enter(M)
	return ..()

/obj/vehicle/sealed/proc/mob_try_enter(mob/M)
	if(!istype(M))
		return FALSE
	if(occupant_amount() >= max_occupants)
		return FALSE
	if(do_after(M, get_enter_delay(M), FALSE, src, TRUE))
		mob_enter(M)
		return TRUE
	return FALSE

/obj/vehicle/sealed/proc/get_enter_delay(mob/M)
	return enter_delay

/obj/vehicle/sealed/proc/mob_enter(mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	if(!silent)
		M.visible_message("<span class='notice'>[M] climbs into \the [src]!</span>")
	M.forceMove(src)
	add_occupant(M)
	return TRUE

/obj/vehicle/sealed/proc/mob_try_exit(mob/M, mob/user, silent = FALSE, randomstep = FALSE)
	mob_exit(M, silent, randomstep)

/obj/vehicle/sealed/proc/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	if(!istype(M))
		return FALSE
	remove_occupant(M)
	if(randomstep)
		var/turf/target_turf = get_step(exit_location(M), pick(GLOB.cardinals))
		M.forceMove(target_turf)
	else
		M.forceMove(exit_location(M))
	if(!silent)
		M.visible_message("<span class='notice'>[M] drops out of \the [src]!</span>")
	return TRUE

/obj/vehicle/sealed/proc/exit_location(M)
	return drop_location()

/obj/vehicle/sealed/attackby(obj/item/I, mob/user, params)
	if(key_type && !is_key(inserted_key) && is_key(I))
		if(user.transferItemToLoc(I, src))
			to_chat(user, "<span class='notice'>You insert \the [I] into \the [src].</span>")
			if(inserted_key)	//just in case there's an invalid key
				inserted_key.forceMove(drop_location())
			inserted_key = I
		else
			to_chat(user, "<span class='notice'>[I] seems to be stuck to your hand!</span>")
		return
	return ..()

/obj/vehicle/sealed/proc/remove_key(mob/user)
	if(!inserted_key)
		return
		to_chat(user, "<span class='notice'>There is no key in \the [src]!</span>")
	if(!is_occupant(user) || !(occupants[user] & VEHICLE_CONTROL_DRIVE))
		to_chat(user, "<span class='notice'>You must be driving \the [src] to remove [src]'s key!</span>")
		return
	to_chat(user, "<span class='notice'>You remove \the [inserted_key] from \the [src].</span>")
	inserted_key.forceMove(drop_location())
	user.put_in_hands(inserted_key)
	inserted_key = null
	return TRUE

/obj/vehicle/sealed/deconstruct(disassembled = TRUE)
	. = ..()
	DumpMobs()
	explosion(src.loc, 0, 1, 2, 3, 0)

/obj/vehicle/sealed/proc/DumpMobs(randomstep = TRUE)
	for(var/i in occupants)
		if(iscarbon(i))
			var/mob/living/carbon/Carbon = i
			mob_exit(Carbon, randomstep)
			Carbon.Knockdown(40)

/obj/vehicle/sealed/proc/DumpSpecificMobs(flag, randomstep = TRUE)
	for(var/i in occupants)
		if((occupants[i] & flag) && iscarbon(i))
			var/mob/living/carbon/C = i
			mob_exit(C, randomstep)
			C.Knockdown(40)
