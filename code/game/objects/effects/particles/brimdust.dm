/particles/brimdust
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = "cross"
	width = 100
	height = 100
	count = 1000
	color = "#88304e"
	spawning = 3
	lifespan = 0.7 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 0, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-0.2, 0), list(0.2, 0))
	gravity = list(0, -0.5)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(1,1), NORMAL_RAND)
	rotation = 30
	spin = generator(GEN_NUM, -20, 20)
