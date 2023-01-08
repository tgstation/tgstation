/atom/movable/screen/tutorial_instruction
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	color = COLOR_NEARLY_ALL_BLACK
	alpha = 0
	screen_loc = "TOP-2,CENTER"
	layer = TUTORIAL_INSTRUCTIONS_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/client/client
	var/atom/movable/screen/tutorial_instruction_text/instruction_text

/atom/movable/screen/tutorial_instruction/Initialize(mapload, message, client/client)
	. = ..()

	transform = transform.Scale(36, 2.5)

	src.client = client
	animate(src, alpha = 245, time = 0.8 SECONDS, easing = SINE_EASING)

	instruction_text = new(src, message, client)
	vis_contents += instruction_text

/atom/movable/screen/tutorial_instruction/Destroy()
	client = null
	QDEL_NULL(instruction_text)

	return ..()

/atom/movable/screen/tutorial_instruction/proc/change_message(message)
	instruction_text.change_message(message)

/atom/movable/screen/tutorial_instruction_text
	maptext_height = 480
	maptext_y = -2
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = TUTORIAL_INSTRUCTIONS_LAYER

/atom/movable/screen/tutorial_instruction_text/Initialize(mapload, message, client/client)
	. = ..()

	var/view = client?.view_size.getView()
	maptext_width = view ? view_to_pixels(view)[1] : 480
	pixel_x = (maptext_width - world.icon_size) * -0.5

	change_message(message)

/atom/movable/screen/tutorial_instruction_text/proc/change_message(message)
	// We don't use MAPTEXT macro here because it doesn't handle big text
	message = "<span style='font-family: \"VCR OSD Mono\"; font-size: 22px; text-align: center'>[message]</span>"

	animate(src, alpha = 0, time = (maptext ? 0.5 SECONDS : 0), easing = SINE_EASING)
	animate(alpha = 255, time = 0.5 SECONDS, maptext = message)
