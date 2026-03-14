/atom/movable/screen/tutorial_skip
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	screen_loc = "TOP,LEFT"
	color = COLOR_NEARLY_ALL_BLACK
	alpha = 0
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	layer = TUTORIAL_INSTRUCTIONS_LAYER
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/atom/movable/screen/tutorial_skip_text/skip_text

/atom/movable/screen/tutorial_skip/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	transform = transform.Scale(9, 1)
	skip_text = new(null, hud_owner)
	vis_contents += skip_text
	maptext = MAPTEXT_VCR_OSD_MONO("<span style='font-size: 10px; text-align: left'>Remind me later</span>")
	animate(src, alpha = 245, time = 0.8 SECONDS, easing = SINE_EASING)

/atom/movable/screen/tutorial_skip/Destroy()
	QDEL_NULL(skip_text)
	return ..()

/atom/movable/screen/tutorial_skip_text
	alpha = 0
	layer = TUTORIAL_INSTRUCTIONS_LAYER
	appearance_flags = parent_type::appearance_flags | KEEP_APART
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	maptext_height = 32
	maptext_width = 200
	maptext_x = 20
	maptext_y = 9

/atom/movable/screen/tutorial_skip_text/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/newtext = MAPTEXT_VCR_OSD_MONO("<span style='font-size: 10px; text-align: left'>Remind me later</span>")
	animate(src, alpha = 255, time = 0.5 SECONDS, maptext=newtext)
