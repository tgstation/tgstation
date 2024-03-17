/// Slime particles.
/particles/slime
	icon = 'icons/effects/particles/goop.dmi'
	icon_state = list("goop_1" = 6, "goop_2" = 2, "goop_3" = 1)
	width = 100
	height = 100
	count = 100
	spawning = 0.5
	color = "#707070a0"
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	grow = -0.025
	gravity = list(0, -0.05)
	position = generator(GEN_BOX, list(-8,-16,0), list(8,16,0), NORMAL_RAND)
	spin = generator(GEN_NUM, -15, 15, NORMAL_RAND)
	scale = list(0.75, 0.75)

/// Rainbow slime particles.
/particles/slime/rainbow
	gradient = list(0, "#f00a", 3, "#0ffa", 6, "#f00a", "loop", "space"=COLORSPACE_HSL)
	color_change = 0.2
	color = generator(GEN_NUM, 0, 6, UNIFORM_RAND)
