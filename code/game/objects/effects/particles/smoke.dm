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

/particles/smoke/cig
	icon_state = list("steam_1" = 2, "steam_2" = 1, "steam_3" = 1)
	count = 1
	spawning = 0.05 // used to pace it out roughly in time with breath ticks
	position = list(-6, -2, 0)
	gravity = list(0, 0.75, 0)
	lifespan = 0.75 SECONDS
	fade = 0.75 SECONDS
	velocity = list(0, 0.2, 0)
	scale = 0.5
	grow = 0.01
	friction = 0.5
	color = "#d0d0d09d"

/particles/smoke/cig/big
	icon_state = list("steam_1" = 1, "steam_2" = 2, "steam_3" = 2)
	gravity = list(0, 0.5, 0)
	velocity = list(0, 0.1, 0)
	lifespan = 1 SECONDS
	fade = 1 SECONDS
	grow = 0.1
	scale = 0.75
	spawning = 1
	friction = 0.75

/particles/smoke/ash
	icon_state = list("ash_1" = 2, "ash_2" = 2, "ash_3" = 1, "smoke_1" = 3, "smoke_2" = 2)
	count = 500
	spawning = 1
	lifespan = 1 SECONDS
	fade = 0.2 SECONDS
	fadein = 0.7 SECONDS
	position = generator(GEN_VECTOR, list(-3, 5, 0), list(3, 6.5, 0), NORMAL_RAND)
	velocity = generator(GEN_VECTOR, list(-0.1, 0.4, 0), list(0.1, 0.5, 0), NORMAL_RAND)

/particles/fog
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("chill_1" = 2, "chill_2" = 2, "chill_3" = 1)

/particles/fog/breath
	count = 1
	spawning = 1
	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	grow = 0.05
	spin = 2
	color = "#fcffff77"

/particles/smoke/cyborg
	count = 5
	spawning = 1
	lifespan = 1 SECONDS
	fade = 1.8 SECONDS
	position = list(0, 0, 0)
	scale = list(0.5, 0.5)
	grow = 0.1

/particles/smoke/cyborg/heavy_damage
	lifespan = 0.8 SECONDS
	fade = 0.8 SECONDS

/particles/hotspring_steam
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list(
		"steam_cloud_1" = 1,
		"steam_cloud_2" = 1,
		"steam_cloud_3" = 1,
		"steam_cloud_4" = 1,
		"steam_cloud_5" = 1,
	)
	color = "#FFFFFFAA"
	count = 6
	spawning = 0.5
	lifespan = 3 SECONDS
	fade = 1.2 SECONDS
	fadein = 0.4 SECONDS
	position = generator(GEN_BOX, list(-17,-15,0), list(24,15,0), NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(0.9,0.9), list(1.1,1.1), NORMAL_RAND)
	drift = generator(GEN_SPHERE, list(-0.01,0), list(0.01,0.01), UNIFORM_RAND)
	spin = generator(GEN_NUM, list(-3,3), NORMAL_RAND)
	gravity = list(0.05, 0.28)
	friction = 0.3
	grow = 0.037
