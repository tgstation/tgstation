/particles/stink_lines
	icon = 'icons/effects/particles/shapes.dmi'
	icon_state = list("line")
	color = generator("color", "#808000", "#806900", NORMAL_RAND)
	spawning = 0.3
	lifespan = 30
	fade = 10
	#ifndef SPACEMAN_DMM
	fadein = 10
	#endif
	gravity = list(0, 0.2, 0)
	position = generator("circle", 10, 12, NORMAL_RAND)
	friction = generator("num", 0.1, 0.3, NORMAL_RAND)
	drift = generator("box", list(0.1,0.05,0), list(-0.1,0,0), UNIFORM_RAND)
	rotation = generator("num", -45, 45, UNIFORM_RAND)
