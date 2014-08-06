/obj/item/projectile/rocket
	name = "rocket"
	icon_state = "rpground"
	damage = 50
	stun = 5
	weaken = 5
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"
	var/embed = 1

/obj/item/projectile/rocket/Bump(var/atom/rocket)
	//if(istype(/obj/item) || istype(/obj/structure) || istype(/mob/living) || istype(/turf/simulated/wall))
	explosion(rocket, -1, 1, 4, 8)
	qdel(src)
/*
	if(istype(A,/turf))
	var/found = 0
	for(var/obj/O in A)
		found = 1
		O.bullet_act(src)
	for(var/mob/M in A)
		found = 1
		M.bullet_act(src, def_zone)
	if(!found)
		on_hit(atom/A as mob|obj|turf|area)
			explosion(A, -1, 2, 4, 8)
*/

