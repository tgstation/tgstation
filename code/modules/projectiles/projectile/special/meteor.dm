/obj/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	damage = 0
	damage_type = BRUTE
	nodamage = TRUE
	flag = "bullet"

/obj/projectile/meteor/Bump(atom/A)
	if(A == firer)
		forceMove(A.loc)
		return
	if(isobj(A))
		SSexplosions.medobj += A
	else if(isturf(A))
		SSexplosions.medturf += A
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, TRUE)
	for(var/mob/M in urange(10, src))
		if(!M.stat)
			shake_camera(M, 3, 1)
	qdel(src)
