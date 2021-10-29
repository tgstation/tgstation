//Lets cyborgs drag pulled objects
/atom/proc/attack_robot(mob/user)
	if((isturf(src) || istype(src, /obj/structure/table) || istype(src, /obj/machinery/conveyor)) && get_dist(user, src) <= 1)
		user.Move_Pulled(src)
		return
	attack_ai(user)
	return
