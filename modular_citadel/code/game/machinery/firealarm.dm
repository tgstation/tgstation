/obj/machinery/firealarm/alt_attack_hand(mob/user)
	if(can_interact(usr))
		var/area/A = get_area(src)
		if(istype(A))
			if(A.fire)
				reset()
			else
				alarm()
			return TRUE
	return FALSE
