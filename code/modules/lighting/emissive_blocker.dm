/atom/movable/emissive_blocker
	name = ""
	plane = EMISSIVE_BLOCKER_PLANE
	layer = EMISSIVE_BLOCKER_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = RESET_TRANSFORM

/atom/movable/emissive_blocker/Initialize(mapload, source)
	. = ..()
	verbs.Cut() //Cargo culting from lighting object, this maybe affects memory usage?

	render_source = source
