/particles/drill_sparks
	width = 124
	height = 124
	count = 1600
	spawning = 4
	lifespan = 1.5 SECONDS
	fade = 0.25 SECONDS
	position = generator("circle", -3, 3, NORMAL_RAND)
	gravity = list(0, -1)
	velocity = generator("box", list(-3, 2, 0), list(3, 12, 5), NORMAL_RAND)
	friction = 0.25
	gradient = list(0, COLOR_WHITE, 1, COLOR_ORANGE)
	color_change = 0.125
	color = 0
	transform = list(1,0,0,0, 0,1,0,0, 0,0,1,1/5, 0,0,0,1)

/particles/fire_sparks
    width = 500
    height = 500
    count = 3000
    spawning = 1
    lifespan = 40
    fade = 20
    position = 0
    gravity = list(0, 1)

    friction = 0.25
    drift = generator("sphere", 0, 2)
    gradient = list(0, "yellow", 1, "red")
    color = "yellow"

/particles/fire_sparks/phoenix
	spawning = 2
	position = generator("circle", -6, 6, NORMAL_RAND)
	lifespan = 15

/particles/flare_sparks
	width = 500
	height = 500
	count = 2000
	spawning = 12
	lifespan = 0.75 SECONDS
	fade = 0.95 SECONDS
	position = generator("vector", list(10,0,0), list(10,0,0), NORMAL_RAND)
	velocity = generator("circle", -6, 6, NORMAL_RAND)
	friction = 0.15
	gradient = list(0, COLOR_WHITE, 0.4, COLOR_RED)
	color_change = 0.125

/particles/drill_sparks/debris
	friction = 0.25
	gradient = null
	color = COLOR_WHITE
	transform = list(1/2,0,0,0, 0,1/2,0,0, 0,0,1/2,1/5, 0,0,0,1)
	icon = 'icons/effects/particles/rocks.dmi'
	icon_state = list("rock1", "rock2", "rock3", "rock4", "rock5")
