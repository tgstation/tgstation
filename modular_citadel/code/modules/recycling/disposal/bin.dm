/obj/machinery/disposal/bin/alt_attack_hand(mob/user)
	if(can_interact(usr))
		flush = !flush
		update_icon()
		return TRUE
	return FALSE
