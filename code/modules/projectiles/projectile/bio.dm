/obj/item/projectile/declone
	name = "declown"
	icon_state = "declone"
	damage = 0
	mobdamage = list(BRUTE = 0, BURN = 0, TOX = 0, OXY = 0, CLONE = 40)
	flag = "bio"
	New()
		..()
		effects["radiation"] = 40
		effectmod["radiation"] = ADD



/obj/item/projectile/dart
	name = "dart"
	icon_state = "toxin"
	flag = "bio"
	damage = 0
	mobdamage = list(BRUTE = 0, BURN = 0, TOX = 10, OXY = 0, CLONE = 0)
	New()
		..()
		effects["weak"] = 5
		effectmod["weak"] = ADD