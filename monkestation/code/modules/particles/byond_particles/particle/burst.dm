/particles/dust
	width = 124
	height = 124
	count = 256
	spawning = SPAWN_ALL_PARTICLES_INSTANTLY //spawn all instantly
	lifespan = 0.75 SECONDS
	fade = 0.35 SECONDS
	position = generator("box", list(-16, -16), list(16, 16), NORMAL_RAND)
	velocity = generator("circle", -8, 8, NORMAL_RAND)
	friction = 0.125
	color = COLOR_WHITE

/particles/debris
	width = 124
	height = 124
	count = 16
	spawning = SPAWN_ALL_PARTICLES_INSTANTLY //spawn all instantly
	lifespan = 0.75 SECONDS
	fade = 0.35 SECONDS
	position = generator("box", list(-10, -10), list(10, 10), NORMAL_RAND)
	velocity = generator("circle", -15, 15, NORMAL_RAND)
	friction = 0.225
	gravity = list(0, -1)
	icon = 'icons/effects/particles/rocks.dmi'
	icon_state = list("rock1", "rock2", "rock3", "rock4", "rock5")
	rotation = generator("num", 0, 360, NORMAL_RAND)
