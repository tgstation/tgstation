/turf/simulated/floor/engine/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/engine/attack_hand(var/mob/user as mob)
	user.Move_Pulled(src)

/turf/simulated/floor/engine/ex_act(severity)
	..()
	if(prob(100 / (2**severity)) && severity < 3)
		ChangeTurf(/turf/space)
		qdel(src)

/turf/simulated/floor/engine/blob_act()
	if (prob(25))
		ChangeTurf(/turf/space)
		qdel(src)
		return
	return