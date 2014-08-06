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

	on_hit(var/atom/target, var/blocked = 0)
		explosion(target, -1, 1, 2, 4)
		if (..(target, blocked))
			var/mob/living/L = target
			shake_camera(L, 3, 2)
			return 1
		return 0
