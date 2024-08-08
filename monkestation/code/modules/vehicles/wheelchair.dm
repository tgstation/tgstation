//modular modification of 'code\modules\vehicles\wheelchair.dm' so that there is a do_after
/obj/vehicle/ridden/wheelchair/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	if(usr == buckled_mob)
		. = ..()
	else
		if(do_after(usr, 1 SECONDS))
			. = ..()
