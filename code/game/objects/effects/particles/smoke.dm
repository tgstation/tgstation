// All the smoke variant particles.
/particles/smoke
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0.4, 0)
	position = list(6, 0, 0)
	drift = generator(GEN_SPHERE, 0, 2, NORMAL_RAND)
	friction = 0.2
	gravity = list(0, 0.95)
	grow = 0.05

/particles/smoke/burning
	position = list(0, 0, 0)

/particles/smoke/burning/fireplace
	position = list(0, 29, 0)

/particles/smoke/burning/small
	spawning = 1
	scale = list(0.8, 0.8)
	velocity = list(0, 0.4, 0)

/particles/smoke/steam
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	fade = 1.5 SECONDS

/particles/smoke/steam/mild
	spawning = 1
	velocity = list(0, 0.3, 0)
	friction = 0.25

/particles/smoke/steam/bad
	icon_state = list("steam_1" = 1, "smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 1)
	spawning = 2
	velocity = list(0, 0.25, 0)

/particles/smoke/ash
	icon_state = list("ash_1" = 2, "ash_2" = 2, "ash_3" = 1, "smoke_1" = 3, "smoke_2" = 2)
	count = 500
	spawning = 1
	lifespan = 1 SECONDS
	fade = 0.2 SECONDS
	fadein = 0.7 SECONDS
	position = generator(GEN_VECTOR, list(-3, 5, 0), list(3, 6.5, 0), NORMAL_RAND)
	velocity = generator(GEN_VECTOR, list(-0.1, 0.4, 0), list(0.1, 0.5, 0), NORMAL_RAND)
