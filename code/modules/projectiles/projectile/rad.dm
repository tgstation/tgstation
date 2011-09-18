/obj/item/projectile/largebolt
	name = "largebolt"
	icon_state = "cbbolt"
	flag = "rad"
	damage = 20
	mobdamage = list(BRUTE = 10, BURN = 0, TOX = 10, OXY = 0, CLONE = 0)
	New()
		..()
		effects["radiation"] = 40
		effectprob["radiation"] = 95
		effects["drowsyness"] = 10
		effectprob["drowsyness"] = 25
		effectmod["radiation"] = ADD
		effectmod["drowsyness"] = SET