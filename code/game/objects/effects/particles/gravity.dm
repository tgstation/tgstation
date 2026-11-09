/particles/grav_field_down
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = "cross"
	width = 100
	height = 100
	count = 5
	spawning = 1
	lifespan = 0.6 SECONDS
	fade = 0.5 SECONDS
	fadein = 0.2 SECONDS
	position = generator(GEN_CIRCLE, 0, 16, UNIFORM_RAND)
	gravity = list(0, -0.75)
	color = "#FF0000"

/particles/grav_field_down/strong
	gravity = list(0, -1.75)

/particles/grav_field_up
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = "cross"
	width = 100
	height = 100
	count = 5
	spawning = 1
	lifespan = 0.6 SECONDS
	fade = 0.5 SECONDS
	fadein = 0.2 SECONDS
	position = generator(GEN_CIRCLE, 0, 16, UNIFORM_RAND)
	gravity = list(0, 0.75)
	color = "#0077ff"

/particles/grav_field_float
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = "cross"
	width = 100
	height = 100
	count = 5
	spawning = 1
	lifespan = 0.6 SECONDS
	fade = 0.5 SECONDS
	fadein = 0.2 SECONDS
	position = generator(GEN_CIRCLE, 0, 16, UNIFORM_RAND)
	velocity = generator(GEN_VECTOR, list(2,0), list(-2,0), UNIFORM_RAND)
	color = "#FFFF00"
