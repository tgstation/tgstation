/turf/simulated/floor/engine/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/engine/attack_hand(var/mob/user as mob)
	user.Move_Pulled(src)

/turf/simulated/floor/engine/ex_act(severity, specialty)
	contents_explosion(src, severity, specialty)
	switch(severity)
		if(1)
			ChangeTurf(/turf/space)
		if(2)
			if(prob(50))
				ChangeTurf(/turf/space)
		else
			return

/turf/simulated/floor/engine/blob_act()
	if (prob(25))
		ChangeTurf(/turf/space)
		qdel(src)
		return
	return