/atom/movable/screen/screentip
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP,LEFT"
	maptext_height = 480
	maptext_width = 480
	maptext = ""

/atom/movable/screen/screentip/Initialize(mapload, _hud)
	. = ..()
	hud = _hud
	update_view()

/atom/movable/screen/screentip/proc/update_view(datum/source)
	SIGNAL_HANDLER
	if(!hud || !hud.mymob.client.view_size) //Might not have been initialized by now
		return
	maptext_width = getviewsize(hud.mymob.client.view_size.getView())[1] * world.icon_size


