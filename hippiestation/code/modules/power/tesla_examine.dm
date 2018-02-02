/obj/machinery/power/grounding_rod/examine(mob/user)
    ..()
    if(anchored)
        to_chat("It is fastened to the ground.")

/obj/machinery/power/tesla_coil/examine(mob/user)
	..()
	if(anchored)
		to_chat("It is fastened to the ground.")