/particles/embers
	color = generator("color", "#FF2200", "#FF9933", UNIFORM_RAND)
	spawning = 0.5
	count = 30
	lifespan = 30
	fade = 5
	position = generator("vector", list(-3,6,0), list(3,6,0), NORMAL_RAND)
	gravity = list(0, 0.2, 0)
	color_change = 0
	friction = 0.2
	drift = generator("vector", list(0.25,0,0), list(-0.25,0,0), UNIFORM_RAND)
	#ifndef SPACEMAN_DMM
	fadein = 10
	#endif




///GENERIC FIRE EFEFCT
/particles/fire
    width = 500
    height = 500
    count = 3000
    spawning = 3
    lifespan = 10
    fade = 10
    velocity = list(0, 0)
    position = generator("vector", list(-9,3,0), list(9,3,0), NORMAL_RAND)
    drift = generator("vector", list(0, -0.2), list(0, 0.2))
    gravity = list(0, 0.65)
    color = "white"

