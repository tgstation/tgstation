/particles/rain
	width = 672
	height = 480
	count = 2500    // 2500 particles
	spawning = 48
	bound1 = list(-1000, -240, -1000)   // end particles at Y=-240
	lifespan = 60 SECONDS
	fade = 35       // fade out over the last 3.5s if still on screen
	icon = 'icons/effects/particles/weather.dmi'
	icon_state = "rain_small"
	position = generator("box", list(-300,50,0), list(300,300,50))
	gravity = list(0, -3)
	friction = 0.05
	drift = generator("sphere", 0, 1)

/particles/rain/dense
		spawning = 60

/particles/rain/sideways
	rotation = generator("num", -10, -20 )
	gravity = list(0.4, -3)
	drift = generator("box", list(0.1, -1, 0), list(0.4, 0, 0))

/particles/rain/sideways/tile
	count = 5
	spawning = 1.1
	fade = 5
	lifespan = generator("num", 4, 6, LINEAR_RAND)
	position = generator("box", list(-96,32,0), list(300,64,50))
	bound1 = list(-32, -48, -1000)
	bound2 = list(32, 64, 1000)
	// Start up initial speed and gain for tile based emitter due to shorter travel (acceleration)
	gravity = list(0.4*3, -3*3)
	drift = generator("box", list(0.1, -1*2, 0), list(0.4*2, 0, 0))
	width = 96
	height = 96
