/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	mobdamage = list(BRUTE = 0, BURN = 20, TOX = 0, OXY = 0, CLONE = 0)
	flag = "laser"
	New()
		..()
		effects["eyeblur"] = 5
		effectprob["eyeblur"] = 50



/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	mobdamage = list(BRUTE = 10, BURN = 40, TOX = 0, OXY = 0, CLONE = 0)



/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	mobdamage = list(BRUTE = 0, BURN = 40, TOX = 0, OXY = 0, CLONE = 0)



/obj/item/projectile/beam/deathlaser
	name = "death laser"
	icon_state = "heavylaser"
	damage = 60
	mobdamage = list(BRUTE = 10, BURN = 60, TOX = 0, OXY = 0, CLONE = 0)
	New()
		..()
		effects["weak"] = 5
		effectprob["weak"] = 15



/obj/item/projectile/beam/fireball
	name = "shock"
	icon_state = "fireball"
	damage = 25
	mobdamage = list(BRUTE = 0, BURN = 25, TOX = 0, OXY = 0, CLONE = 0)
	New()
		..()
		effects["stun"] = 10
		effects["weak"] = 10
		effectprob["weak"] = 25
		effects["stutter"] = 10
