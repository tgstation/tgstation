
/obj/mecha/working/hoverpod
	name = "hover pod"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "engineering_pod"
	desc = "Stubby and round, it has a human sized access hatch on the top."

//duplicate of parent proc, but without space drifting
/obj/mecha/working/hoverpod/dyndomove(direction)
	if(!can_move)
		return 0
	if(src.pr_inertial_movement.active())
		return 0
	if(!has_charge(step_energy_drain))
		return 0
	var/move_result = 0
	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		move_result = mechsteprand()
	else if(src.dir!=direction)
		move_result = mechturn(direction)
	else
		move_result	= mechstep(direction)
	if(move_result)
		can_move = 0
		use_power(step_energy_drain)
		/*if(istype(src.loc, /turf/space))
			if(!src.check_for_support())
				src.pr_inertial_movement.start(list(src,direction))
				src.log_message("Movement control lost. Inertial movement started.")*/
		if(do_after(step_in))
			can_move = 1
		return 1
	return 0

//these three procs overriden to play different sounds
/obj/mecha/mechturn(direction)
	dir = direction
	//playsound(src,'sound/machines/hiss.ogg',40,1)
	return 1

/obj/mecha/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result


/obj/mecha/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src,'sound/machines/hiss.ogg',40,1)
	return result
