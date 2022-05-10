/atom/movable/screen/screentip
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP,CENTER-1"
	maptext_height = 128
	maptext_width = 128
	maptext = ""
	layer = SCREENTIP_LAYER //Added to make screentips appear above action buttons (and other /atom/movable/screen objects)

/atom/movable/screen/screentip/Initialize(mapload, _hud)
	. = ..()
	hud = _hud

