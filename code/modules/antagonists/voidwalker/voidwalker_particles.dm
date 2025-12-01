/particles/void_wall
	icon = 'icons/effects/particles/voidwalker.dmi'
	icon_state = list("kidnap_1" = 1, "kidnap_2" = 1, "kidnap_3" = 2)
	width = 100
	height = 300
	count = 1000
	spawning = 3
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0.4, 0)
	position = generator(GEN_SPHERE, 12, 12, NORMAL_RAND)
	drift = generator(GEN_SPHERE, 0, 1, NORMAL_RAND)
	friction = 0.2
	gravity = list(0, 0.1)
	grow = 0.05

/particles/void_vomit
	icon = 'icons/effects/particles/voidwalker.dmi'
	icon_state = list("void_1" = 1, "void_2" = 5)
	width = 100
	height = 300
	count = 100
	spawning = 1
	lifespan = 3 SECONDS
	fade = 2 SECONDS
	velocity = list(0, 0.1, 0)
	position = generator(GEN_SPHERE, 6, 6, NORMAL_RAND)
	drift = generator(GEN_SPHERE, 0, 0.05, NORMAL_RAND)
	friction = 0.1
	gravity = list(0, 0.50)
