/particles/flock_convert_complete
	icon = 'troutstation/icons/effects/particles/flock.dmi'
	icon_state = list("bubble_1" = 3, "bubble_2" = 2, "bubble_3" = 1)
	width = 100
	height = 300
	count = 1000
	spawning = 3
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	velocity = generator(GEN_SPHERE, 2, 2, NORMAL_RAND)
	position = generator(GEN_SPHERE, 24, 24, NORMAL_RAND)
	drift = generator(GEN_SPHERE, 2, 2, NORMAL_RAND)
	friction = 0.2
	gravity = list(0, 0.3)
	grow = 0.05
