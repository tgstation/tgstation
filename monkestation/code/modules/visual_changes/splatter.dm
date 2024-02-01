GLOBAL_LIST_EMPTY(blood_particles)
/particles/splatter
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 20
	spawning = 20
	lifespan = 0.5 SECONDS
	fade = 0.7 SECONDS
	grow = 0.1
	scale = 0.2
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.1, 0.5)
	position = generator(GEN_CIRCLE, 6, 6)

/particles/splatter/New(set_color)
	..()
	if(set_color != "red") // we're already red colored by default
		color = set_color
