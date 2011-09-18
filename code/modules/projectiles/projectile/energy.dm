/obj/item/projectile/electrode
	name = "electrode"
	icon_state = "spark"
	flag = "taser"
	damage = 0
	nodamage = 1
	New()
		..()
		effects["stun"] = 10
		effects["weak"] = 10
		effects["stutter"] = 10
		effectprob["weak"] = 25



/obj/item/projectile/bolt
	name = "bolt"
	icon_state = "cbbolt"
	flag = "taser"
	damage = 0
	nodamage = 1
	New()
		..()
		effects["weak"] = 10
		effects["stutter"] = 10


