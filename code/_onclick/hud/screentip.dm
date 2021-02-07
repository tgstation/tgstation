/atom/movable/screen/screentip
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP,LEFT"
	maptext_height = 480
	maptext_width = 480
	maptext = ""
	var/font_size = 32
	var/enabled = TRUE

/atom/movable/screen/screentip/Initialize(mapload, _hud)
	. = ..()
	hud = _hud
	update_view()
	update_fontsize()

/atom/movable/screen/screentip/proc/update_view(datum/source)
	SIGNAL_HANDLER

	maptext_width = getviewsize(hud.mymob.client.view_size.getView())[1] * world.icon_size

/atom/movable/screen/screentip/proc/update_fontsize()
	switch(hud.mymob.client.prefs.screentip_pref)
		if (SCREENTIP_OFF)
			enabled = FALSE
		if (SCREENTIP_SMALL)
			font_size = 24
			enabled = TRUE
		if (SCREENTIP_MEDIUM)
			font_size = 32
			enabled = TRUE
		else
			font_size = 48
			enabled = TRUE
