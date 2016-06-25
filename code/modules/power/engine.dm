/turf/simulated/floor/engine/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/engine/attack_hand(var/mob/user as mob)
	user.Move_Pulled(src)
	return

/turf/simulated/floor/engine/blob_act()
	if(prob(25))
		ChangeTurf(get_underlying_turf())
		return
	return
