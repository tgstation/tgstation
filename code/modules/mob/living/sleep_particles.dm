/particles/sleeping_zs
	icon = 'icons/effects/particles/notes/note_sleepy.dmi'
	icon_state = list(
		"sleepy_9" = 1,
	)
	width = 100
	height = 100
	count = 10
	spawning = 0.05
	lifespan = 0.7 SECONDS
	fade = 1 SECONDS
	grow = -0.01
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 0, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.5)
