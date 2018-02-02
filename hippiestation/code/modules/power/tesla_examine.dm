/obj/machinery/power/grounding_rod/examine(mob/user)
	..()
	if(anchored)
		to_chat(user, "It is fastened to the floor.")

/obj/machinery/power/tesla_coil/examine(mob/user)
	..()
	if(anchored)
		to_chat(user, "It is fastened to the floor.")