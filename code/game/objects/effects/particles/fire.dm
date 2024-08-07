// Fire related particles.
/particles/bonfire
	icon = 'icons/effects/particles/bonfire.dmi'
	icon_state = "bonfire"
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 0.7 SECONDS
	fade = 1 SECONDS
	grow = -0.01
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 0, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(1,1), NORMAL_RAND)
	rotation = 30
	spin = generator(GEN_NUM, -20, 20)

/particles/embers
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("dot" = 4,"cross" = 1,"curl" = 1)
	width = 64
	height = 96
	count = 500
	spawning = 5
	lifespan = 3 SECONDS
	fade = 1 SECONDS
	color = 0
	color_change = 0.05
	gradient = list("#FBAF4D", "#FCE6B6", "#FD481C")
	position = generator(GEN_BOX, list(-12,-16,0), list(12,16,0), NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-0.1,0), list(0.1,0.025), UNIFORM_RAND)
	spin = generator(GEN_NUM, list(-15,15), NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(0.5,0.5), list(2,2), NORMAL_RAND)

/particles/embers/spark
	count = 3
	spawning = 2
	gradient = list("#FBAF4D", "#FCE6B6", "#FFFFFF")
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	fadein = 0.1 SECONDS
	grow = -0.1
	velocity = generator(GEN_CIRCLE, 3, 3, SQUARE_RAND)
	position = generator(GEN_SPHERE, 0, 0, LINEAR_RAND)
	scale = generator(GEN_VECTOR, list(0.5, 0.5), list(1,1), NORMAL_RAND)
	drift = list(0)

/particles/embers/spark/severe
	count = 10
	spawning = 5
	gradient = list("#FCE6B6", "#FFFFFF")
