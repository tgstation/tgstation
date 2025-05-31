/atom/movable/screen/escape_menu/text
	mouse_opacity = MOUSE_OPACITY_OPAQUE

	VAR_PRIVATE
		atom/movable/screen/escape_menu/home_button_text/home_button_text

/atom/movable/screen/escape_menu/text/Initialize(
	mapload,
	datum/hud/hud_owner,
	button_text,
	list/offset,
)
	. = ..()

	home_button_text = new /atom/movable/screen/escape_menu/home_button_text(
		src,
		/* hud_owner = */ src,
		button_text,
		/* maptext_font_size = */ "12px",
	)

	vis_contents += home_button_text
	screen_loc = "NORTH:[offset[1]],CENTER:[offset[2]]"
