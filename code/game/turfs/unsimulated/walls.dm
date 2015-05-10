/turf/unsimulated/wall
	name = "riveted wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1
	explosion_block = 2
	canSmoothWith = "/turf/unsimulated/wall=0"

	var/walltype = "riveted"

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0
	canSmoothWith = null

turf/unsimulated/wall/splashscreen
	name = "Space Station 13"
	icon = null
	icon_state = null
	layer = FLY_LAYER
	canSmoothWith = null

	New()
		var/path = "icons/splashworks/"
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) == "/")
				filenames -= filename
		icon = file("[path][pick(filenames)]")

/turf/unsimulated/wall/other
	icon_state = "r_wall"
	canSmoothWith = null

/turf/unsimulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult0"
	opacity = 1
	density = 1
	canSmoothWith = null

/turf/unsimulated/wall/cultify()
	ChangeTurf(/turf/unsimulated/wall/cult)
	turf_animation('icons/effects/effects.dmi',"cultwall",0,0,MOB_LAYER-1)
	return

/turf/unsimulated/wall/cult/cultify()
	return