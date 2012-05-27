/area/engine/engineering/poweralert(var/state, var/source)
	if (state != poweralm)
		investigate_log("has a power alarm!","singulo")
	..()