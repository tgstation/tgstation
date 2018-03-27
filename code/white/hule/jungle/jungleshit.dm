/turf/open/floor/jungle
	name = "jungle grass"
	icon = 'code/white/hule/jungle/jungleshit.dmi'
	icon_state = "grass1"
	slowdown = 0.75
	broken_states = list("sand")
	initial_gas_mix = "o2=22;n2=82;TEMP=300"

/turf/open/floor/jungle/Initialize()
	. = ..()
	if(prob(50))
		icon_state = "grass[rand(2, 5)]"


/datum/map_template/ruin/space/jungle_asteoid
	id = "jungleasteroid"
	prefix = "code/white/hule/jungle/"
	suffix = "asteroidj.dmm"
	name = "Jungle Asteroid"
	description = "Strange piece of rock floating nearby..."
