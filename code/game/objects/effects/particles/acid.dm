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
	color = "#34ff19a1"
	lifespan = 45 SECONDS
	fade = 0.9 SECONDS
	grow = -0.08
	velocity = list(0, 1, 0)
	position = generator(GEN_CIRCLE, 0, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.5)
	rotation = 25
	spin = generator(GEN_NUM, -20, 20)
