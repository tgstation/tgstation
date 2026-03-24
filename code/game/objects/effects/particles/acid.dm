// Acid related particles.
/particles/acid
	icon = 'icons/effects/particles/goop.dmi'
	icon_state = list("goop_1" = 6, "goop_2" = 2, "goop_3" = 1)
	width = 100
	height = 100
	count = 100
	spawning = 0.5
	color = "#00ea2b80" //to get 96 alpha
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	grow = -0.025
	gravity = list(0, 0.15)
	position = generator(GEN_SPHERE, 0, 16, NORMAL_RAND)
	spin = generator(GEN_NUM, -15, 15, NORMAL_RAND)

/particles/acid/toxic
	count = 1000
	spawning = 4
	color = "#34ff1980"//to get 96 alpha
	lifespan = 0.9 SECONDS
	fade = 1 SECONDS
	grow = -0.01
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 0, 16, NORMAL_RAND)
	friction = 1
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(1,1), NORMAL_RAND)
	rotation = 25
	spin = generator(GEN_NUM, -20, 20)
