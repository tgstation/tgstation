/particles/embers
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("dot"=4,"cross"=1,"curl"=1)
	width = 64
	height = 96
	count = 500
	spawning = 5
	lifespan = 3 SECONDS
	fade = 1 SECONDS
	color = 0
	color_change = 0.05
	gradient = list("#FBAF4D", "#FCE6B6", "#FD481C")
	position = generator("box", list(-12,-16,0), list(12,16,0), NORMAL_RAND)
	drift = generator("vector", list(-0.1,0), list(0.1,0.025), UNIFORM_RAND)
	spin = generator("num", list(-15,15), NORMAL_RAND)
	scale = generator("vector", list(0.5,0.5), list(2,2), NORMAL_RAND)
