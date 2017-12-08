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
		M.visible_message("<span class='boldnotice'>[M] climbs into \the [src]!</span>")
	M.forceMove(src)
	add_occupant(M)
	return TRUE

/obj/vehicle/sealed/proc/mob_try_exit(mob/M, mob/user, silent = FALSE)
	mob_exit(M, silent)

/obj/vehicle/sealed/proc/mob_exit(mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	remove_occupant(M)
	M.forceMove(exit_location(M))
	if(!silent)
		M.visible_message("<span class='boldnotice'>[M] drops out of \the [src]!</span>")
	return TRUE

/obj/vehicle/sealed/proc/exit_location(M)
	return drop_location()
