GLOBAL_LIST_EMPTY(announcements_huds)

/atom/movable/screen/screentip
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP,LEFT"
	maptext_height = 480
	maptext_width = 480
	maptext = ""
	layer = SCREENTIP_LAYER //Added to make screentips appear above action buttons (and other /atom/movable/screen objects)

/atom/movable/screen/screentip/Initialize(mapload, _hud)
	. = ..()
	hud = _hud
	update_view()

/atom/movable/screen/screentip/proc/update_view(datum/source)
	SIGNAL_HANDLER
	if(!hud || !hud.mymob.client.view_size) //Might not have been initialized by now
		return
	maptext_width = view_to_pixels(hud.mymob.client.view_size.getView())[1]

/atom/movable/screen/screentip/announcements
	screen_loc = "TOP,CENTER"
	maptext_y = -30
	maptext_x = -130
	maptext_width = 300
	maptext_height = 480

/atom/movable/screen/screentip/announcements/Initialize(mapload, _hud)
	. = ..()
	GLOB.announcements_huds += src
	maptext_width = 300

/atom/movable/screen/screentip/announcements/Destroy()
	GLOB.announcements_huds -= src
	. = ..()

/atom/movable/screen/screentip/announcements/proc/set_text(text, raw_msg)
	maptext = text
	addtimer(CALLBACK(src, .proc/clear_text), 10 SECONDS)

/atom/movable/screen/screentip/announcements/proc/clear_text()
	maptext = ""
