#define CAN_KIDNAP 1

/obj/vehicle/sealed/car
	var/traits = NONE //Bitflag for special behavior such as kidnapping
	var/engine_sound = 'sound/vehicles/carrev.ogg'
	var/last_enginesound_time
	var/engine_sound_length = 20 //Set this to the length of the engine sound
	layer = ABOVE_MOB_LAYER
	anchored = TRUE

/obj/vehicle/sealed/car/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/remove_key, VEHICLE_CONTROL_DRIVE)
	if(traits & CAN_KIDNAP)
		initialize_controller_action_type(/datum/action/vehicle/sealed/DumpKidnappedMobs, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/MouseDrop_T(atom/dropping, mob/M)
	if(!usr.canmove || usr.stat || usr.restrained())
		return FALSE
	if(ismob(dropping) && M != dropping)
		var/mob/D = dropping
		M.visible_message("<span class='warning'>[M] starts forcing [D] into \the [src]!</span>")
		mob_try_forced_enter(M, D)
	return ..()

/obj/vehicle/sealed/car/mob_try_exit(mob/M, mob/user, silent = FALSE)
	if(M == user && occupants[M] & VEHICLE_CONTROL_KIDNAPPED)
		to_chat(user, "<span class='notice'>You push against the back of \the [src] trunk to try and get out.</span>")
		if(!do_after(user, 200, target = src))
			return FALSE
		to_chat(user,"<span class='danger'>[user] gets out of \the [src]</span>")
		mob_exit(M, silent)
		return TRUE
	mob_exit(M, silent)

/obj/vehicle/sealed/car/after_move(direction)
	if(world.time < last_enginesound_time + engine_sound_length)
		return
	last_enginesound_time = world.time
	playsound(src, engine_sound, 100, TRUE)

/obj/vehicle/sealed/car/attack_hand(mob/living/user)
	if(!(traits & CAN_KIDNAP))
		return
	to_chat(user, "<span class='notice'>You start opening \the [src]'s trunk.</span>")
	if(do_after(user, 30))
		if(return_amount_of_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
			to_chat(user, "<span class='notice'>The people stuck in \the [src]'s trunk all come tumbling out.</span>")
			DumpSpecificMobs(VEHICLE_CONTROL_KIDNAPPED)
		else
			to_chat(user, "<span class='notice'>It seems \the [src]'s trunk was empty.</span>")

/obj/vehicle/sealed/car/proc/mob_try_forced_enter(mob/forcer, mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	if(occupant_amount() >= max_occupants)
		return FALSE
	if(do_after(forcer, get_enter_delay(M), target = src))
		mob_forced_enter(M, silent)
		return TRUE
	return FALSE

/obj/vehicle/sealed/car/proc/mob_forced_enter(mob/M, silent = FALSE)
	if(!silent)
		M.visible_message("<span class='warning'>[M] is forced into \the [src]!</span>")
	M.forceMove(src)
	add_occupant(M, VEHICLE_CONTROL_KIDNAPPED)