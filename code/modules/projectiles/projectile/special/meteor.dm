/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	damage = 0
	damage_type = BRUTE
	nodamage = TRUE
	flag = "bullet"

/obj/item/projectile/meteor/Bump(atom/A)
	if(A == firer)
		forceMove(A.loc)
		return
	A.ex_act(EXPLODE_HEAVY)
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, DEFAULT_SOUND_VARY)
	shake_area(A, 3, 1, 1, 1, 1, 10)
	qdel(src)
