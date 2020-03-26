/obj/vehicle/sealed/car
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	default_driver_move = FALSE
	var/car_traits = NONE //Bitflag for special behavior such as kidnapping
	var/engine_sound = 'sound/vehicles/carrev.ogg'
	var/last_enginesound_time
	var/engine_sound_length = 20 //Set this to the length of the engine sound
	var/escape_time = 60 //Time it takes to break out of the car

/obj/vehicle/sealed/car/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = movedelay
	D.slowvalue = 0

/obj/vehicle/sealed/car/generate_actions()
	. = ..()
	if(key_type)
		initialize_controller_action_type(/datum/action/vehicle/sealed/remove_key, VEHICLE_CONTROL_DRIVE)
	if(car_traits & CAN_KIDNAP)
		initialize_controller_action_type(/datum/action/vehicle/sealed/DumpKidnappedMobs, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/driver_move(mob/user, direction)
	if(key_type && !is_key(inserted_key))
		to_chat(user, "<span class='warning'>[src] has no key inserted!</span>")
		return FALSE
	else if(!key_check(user))
		return FALSE
	var/datum/component/riding/R = GetComponent(/datum/component/riding)
	R.handle_ride(user, direction)
	if(world.time < last_enginesound_time + engine_sound_length)
		return
	last_enginesound_time = world.time
	playsound(src, engine_sound, 100, TRUE)
	return TRUE

/obj/vehicle/sealed/car/MouseDrop_T(atom/dropping, mob/M)
	if(M.stat || M.restrained())
		return FALSE
	if((car_traits & CAN_KIDNAP) && isliving(dropping) && M != dropping)
		var/mob/living/L = dropping
		L.visible_message("<span class='warning'>[M] starts forcing [L] into [src]!</span>")
		mob_try_forced_enter(M, L)
	return ..()

/obj/vehicle/sealed/car/mob_try_exit(mob/M, mob/user, silent = FALSE)
	if(M == user && (occupants[M] & VEHICLE_CONTROL_KIDNAPPED))
		to_chat(user, "<span class='notice'>You push against the back of \the [src]'s trunk to try and get out.</span>")
		if(!do_after(user, escape_time, target = src))
			return FALSE
		to_chat(user,"<span class='danger'>[user] gets out of [src].</span>")
		mob_exit(M, silent)
		return TRUE
	mob_exit(M, silent)
	return TRUE

/obj/vehicle/sealed/car/attacked_by(obj/item/I, mob/living/user)
	if(!I.force)
		return
	if(occupants[user])
		to_chat(user, "<span class='notice'>Your attack bounces off \the [src]'s padded interior.</span>")
		return
	return ..()

/obj/vehicle/sealed/car/attack_hand(mob/living/user)
	. = ..()
	if(!(car_traits & CAN_KIDNAP))
		return
	if(occupants[user])
		return
	to_chat(user, "<span class='notice'>You start opening [src]'s trunk.</span>")
	if(do_after(user, 30))
		if(return_amount_of_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
			to_chat(user, "<span class='notice'>The people stuck in [src]'s trunk all come tumbling out.</span>")
			DumpSpecificMobs(VEHICLE_CONTROL_KIDNAPPED)
		else
			to_chat(user, "<span class='notice'>It seems [src]'s trunk was empty.</span>")

/obj/vehicle/sealed/car/proc/mob_try_forced_enter(mob/forcer, mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	if(occupant_amount() >= max_occupants)
		return FALSE
	var/atom/old_loc = loc
	if(do_mob(forcer, M, get_enter_delay(M), extra_checks=CALLBACK(src, /obj/vehicle/sealed/car/proc/is_car_stationary, old_loc)))
		mob_forced_enter(M, silent)
		return TRUE
	return FALSE

/obj/vehicle/sealed/car/proc/is_car_stationary(atom/old_loc)
	return (old_loc == loc)

/obj/vehicle/sealed/car/proc/mob_forced_enter(mob/M, silent = FALSE)
	if(!silent)
		M.visible_message("<span class='warning'>[M] is forced into \the [src]!</span>")
	M.forceMove(src)
	add_occupant(M, VEHICLE_CONTROL_KIDNAPPED)


/obj/vehicle/sealed/car/civ
	name = "car"
	desc = "This used to be a pedastrian focused station, and now all these cars are ruining it!." //ok boomer
	icon_state = "car"
	max_integrity = 300
	armor = list("melee" = 70, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	enter_delay = 50 //No speed escapes
	max_occupants = 5
	movedelay = 1.15
	var/obj/item/card/id/linked_id = null
	var/can_drive = FALSE

/obj/vehicle/sealed/car/civ/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/civ/Cross(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(!(L.mobility_flags & MOBILITY_STAND) && !L.buckle_lying)
		for(var/i in return_drivers())
			if(!ishuman(i))
				continue
			var/mob/living/carbon/human/boomer = i
			boomer.say(pick("DON'T LIE INFRONT OF MY CAR YA FUCKIN KNOB", "GET OUTA DA WAY I'M DRIVIN' HERE", "YOU ARE RUINING MY SUSPENSION CUNT!"), forced="car crash")
		L.adjustBruteLoss(3) //tires burn
		return

/obj/vehicle/sealed/car/civ/Bump(atom/A)
	. = ..()
	if(!isliving(A))
		return
	var/mob/living/L = A
	for(var/i in return_drivers())
		if(!ishuman(i))
			continue
		var/mob/living/carbon/human/boomer = i
		boomer.say(pick("HOLY SHIT MY PAINT IS RUINED", "I LEASED THIS YOU DICK!", "I WILL END YOU GET OUT OF THE WAY!", "WHAT THE FUCK DO YOU KNOW HOW EXPENSIVE CARS ARE?", "GET OF THE ROAD YOU BRAINDEAD TROGLODYTE", "GET OUT OF THE GODDAMN WAY"), forced="car crash")
	var/throw_dir = turn(src.dir, pick(-90, 90))
	var/throw_target = get_edge_target_turf(L, throw_dir)
	playsound(src, pick('sound/vehicles/clowncar_ram1.ogg', 'sound/vehicles/clowncar_ram2.ogg', 'sound/vehicles/clowncar_ram3.ogg'), 75)
	L.throw_at(throw_target, rand(2,3), 4)
	L.adjustBruteLoss(1) //NT guaranteed baby bumpers


/obj/vehicle/sealed/car/civ/auto_assign_occupant_flags(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/card/id/used_id = H.get_idcard(TRUE)
		if(used_id == linked_id)
			add_control_flags(H, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_PERMISSION)
	add_control_flags(M, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/civ/key_check(mob/M)
	if(!can_drive)
		to_chat(M, "<span class='notice'>You need to start the car with the owner's ID!</span>")
		return FALSE
	return TRUE

/obj/vehicle/sealed/car/civ/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(!linked_id)
			linked_id = I
			to_chat(user, "<span class='notice'>You link your ID to the car!</span>")
			return
		can_drive = !can_drive
		if(can_drive)
			to_chat(user, "<span class='notice'>You start the car!</span>")
		else
			to_chat(user, "<span class='notice'>You turn off the car!</span>")
		return
	return ..()

/obj/vehicle/sealed/car/civ/mob_try_enter(mob/M)
	if(!linked_id)
		to_chat(M, "<span class='notice'>You need to link the car to your ID first!</span>")
		return FALSE
	return ..()

/obj/item/car_beacon
	name = "car beacon"
	desc = "Get your NT sponsored vehicle delivered to you."
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beacon"
	var/used

/obj/item/car_beacon/attack_self()
	if(used)
		return
	loc.visible_message("<span class='warning'>\The [src] begins to beep loudly!</span>")
	used = TRUE
	addtimer(CALLBACK(src, .proc/launch_payload), 40)

/obj/item/car_beacon/proc/launch_payload()
	var/obj/structure/closet/supplypod/centcompod/toLaunch = new()

	new /obj/vehicle/sealed/car/civ(toLaunch)

	new /obj/effect/DPtarget(drop_location(), toLaunch)
	qdel(src)

