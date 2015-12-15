/turf/simulated/floor/engine/attack_paw(mob/user)
	return src.attack_hand(user)

/turf/simulated/floor/engine/attack_hand(mob/user)
	user.Move_Pulled(src)

/turf/simulated/floor/engine/ex_act(severity, target)
	contents_explosion(severity, target)
	switch(severity)
		if(1)
			ChangeTurf(src.baseturf)
		if(2)
			if(prob(50))
				ChangeTurf(src.baseturf)
		else
			return