/obj/projectile/goat
	name = "goat"
	icon = 'icons/mob/animal.dmi'
	icon_state = "goat"
	damage = 20
	damage_type = BRUTE
	flag = "bullet"

/obj/projectile/goat/on_hit(atom/target)
	if(target == firer)
		forceMove(target.loc)
		return
	paralyze = 20
	knockdown = 40
	var/turf/location = get_turf(target)
	new/mob/living/simple_animal/hostile/retaliate/goat(location)
	playsound(src.loc, 'sound/items/goatsound.ogg', 40, TRUE)
	qdel(src)