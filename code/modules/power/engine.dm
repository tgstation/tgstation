<<<<<<< HEAD
/turf/open/floor/engine/attack_paw(mob/user)
	return src.attack_hand(user)

/turf/open/floor/engine/attack_hand(mob/user)
	user.Move_Pulled(src)

/turf/open/floor/engine/ex_act(severity, target)
	contents_explosion(severity, target)
	switch(severity)
		if(1)
			ChangeTurf(src.baseturf)
		if(2)
			if(prob(50))
				ChangeTurf(src.baseturf)
		else
			return
=======
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
