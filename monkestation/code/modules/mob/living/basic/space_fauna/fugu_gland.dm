/obj/item/fugu_gland/extrapolator_act(mob/user, obj/item/extrapolator/E, scan = TRUE)
	if(scan)
		to_chat(user, "<span class='info'>[src] has potential for extrapolation.</span>")
	else
		var/datum/disease/advance/R = new /datum/disease/advance/random(rand(1, 6), 4+(rand(1, 5)))
		if(E.create_culture(R, user))
			qdel(src)
	return TRUE
