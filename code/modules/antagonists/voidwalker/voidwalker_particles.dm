/particles/void_kidnap
	icon = 'icons/effects/particles/voidwalker.dmi'
	icon_state = list("kidnap_1" = 1, "kidnap_2" = 1, "kidnap_3" = 2)
	width = 100
	height = 300
	count = 1000
	spawning = 20
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0.4, 0)
	position = generator(GEN_SPHERE, 12, 12, NORMAL_RAND)
	drift = generator(GEN_SPHERE, 0, 1, NORMAL_RAND)
	friction = 0.2
	gravity = list(0.95, 0)
	grow = 0.05
