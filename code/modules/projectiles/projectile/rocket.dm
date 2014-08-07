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
	explosion(rocket, -1, 1, 4, 8)
	qdel(src)
