// Food related particles.
/particles/stink
	icon = 'icons/effects/particles/stink.dmi'
	icon_state = list("stink_1" = 1, "stink_2" = 2, "stink_3" = 2)
	color = "#0BDA51"
	width = 100
	height = 100
	count = 25
	spawning = 0.25
	lifespan = 1 SECONDS
	fade = 1 SECONDS
	position = generator(GEN_CIRCLE, 0, 16, UNIFORM_RAND)
	gravity = list(0, 0.25)
