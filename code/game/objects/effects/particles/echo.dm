// Echolocation particles.
/particles/echo
	icon = 'icons/effects/particles/echo.dmi'
	icon_state = list("echo1" = 1, "echo2" = 1, "echo3" = 2)
	width = 480
	height = 480
	count = 1000
	spawning = 0.5
	lifespan = 2 SECONDS
	fade = 1 SECONDS
	gravity = list(0, -0.1)
	position = generator(GEN_BOX, list(-240, -240), list(240, 240), NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-0.1, 0), list(0.1, 0))
	rotation = generator(GEN_NUM, 0, 360, NORMAL_RAND)
