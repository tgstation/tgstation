/atom/movable/screen/escape_menu/home_button
	mouse_opacity = MOUSE_OPACITY_OPAQUE

	var/atom/movable/screen/escape_menu/home_button_text/home_button_text
	VAR_PRIVATE
		datum/escape_menu/escape_menu
		datum/callback/on_click_callback

/atom/movable/screen/escape_menu/home_button/Initialize(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	offset,
	on_click_callback,
	font_size,
	pixel_x,
)
	. = ..()

	src.escape_menu = escape_menu
	src.on_click_callback = on_click_callback

	home_button_text = new /atom/movable/screen/escape_menu/home_button_text(
		src,
		/* hud_owner = */ src,
		button_text,
		/* maptext_font_size = */ font_size,
		/* pixel_x = */ pixel_x,
	)

	vis_contents += home_button_text

/atom/movable/screen/escape_menu/home_button/Destroy()
	escape_menu = null
	on_click_callback = null

	return ..()

/atom/movable/screen/escape_menu/home_button/Click(location, control, params)
	if (!enabled())
		return

	on_click_callback.InvokeAsync(src)

/atom/movable/screen/escape_menu/home_button/MouseEntered(location, control, params)
	home_button_text.set_hovered(TRUE)

/atom/movable/screen/escape_menu/home_button/MouseExited(location, control, params)
	home_button_text.set_hovered(FALSE)

/atom/movable/screen/escape_menu/home_button/ordered/Initialize(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	offset,
	on_click_callback,
	pixel_x,
)
	. = ..()
	screen_loc = "NORTH:-[100 + (32 * offset)],WEST:110"
	transform = transform.Scale(6, 1)

// Needs to be separated so it doesn't scale
/atom/movable/screen/escape_menu/home_button_text
	maptext_width = 300
	maptext_height = 50
	pixel_x = -80

	VAR_PRIVATE
		maptext_font_size
		button_text
		hovered = FALSE

/atom/movable/screen/escape_menu/home_button_text/Initialize(
	mapload,
	datum/hud/hud_owner,
	button_text,
	maptext_font_size = "24px",
	pixel_x = -80
)
	. = ..()

	src.pixel_x = pixel_x
	src.maptext_font_size = maptext_font_size
	src.button_text = button_text
	update_text()

/// Sets the hovered state of the button, and updates the text
/atom/movable/screen/escape_menu/home_button_text/proc/set_hovered(hovered)
	if (src.hovered == hovered)
		return

	src.hovered = hovered
	update_text()

/atom/movable/screen/escape_menu/home_button_text/proc/update_text()
	var/atom/movable/screen/escape_menu/escape_menu_loc = loc

	maptext = MAPTEXT_PIXELLARI("<span style='font-size: [maptext_font_size]; color: [istype(escape_menu_loc) ? escape_menu_loc.text_color() : "white"]'>[button_text]</span>")

	if (hovered)
		maptext = "<u>[maptext]</u>"
