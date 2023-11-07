/atom/movable/shadowcasting_holder
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	plane = SHADOWCASTING_PLANE
	animate_movement = NO_STEPS
	invisibility = INVISIBILITY_LIGHTING
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/image/reflector

/atom/movable/shadowcasting_holder/Initialize(mapload)
	. = ..()
	reflector = new()
	reflector.override = TRUE
	reflector.loc = src

/atom/movable/shadowcasting_holder/Destroy(force)
	. = ..()
	reflector = null
