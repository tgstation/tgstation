/atom/movable/screen/escape_menu/lobby_button
	icon = 'icons/hud/escape_menu_leave_body.dmi'
	icon_state = "template"
	maptext_width = 96
	maptext_y = -32

	VAR_PROTECTED
		font_size = 16
		datum/callback/on_click_callback
		hovered = FALSE
		tooltip_text

/atom/movable/screen/escape_menu/lobby_button/Initialize(
	mapload,
	datum/hud/hud_owner,
	button_text,
	tooltip_text,
	list/pixel_offset,
	on_click_callback,
	button_overlay,
)
	. = ..()

	src.on_click_callback = on_click_callback
	src.tooltip_text = tooltip_text

	if(button_overlay)
		add_overlay(button_overlay)
	if(button_text)
		add_maptext(button_text)

	screen_loc = "CENTER:[pixel_offset[1]],CENTER:[pixel_offset[2]]"

/atom/movable/screen/escape_menu/lobby_button/Destroy()
	on_click_callback = null

	return ..()

/atom/movable/screen/escape_menu/lobby_button/Click(location, control, params)
	on_click_callback?.InvokeAsync()

/atom/movable/screen/escape_menu/lobby_button/MouseEntered(location, control, params)
	if (hovered || isnull(tooltip_text))
		return

	hovered = TRUE

	// The UX on this is pretty shit, but it's okay enough for now.
	// Regularly goes way too far from your cursor. Not designed for large icons.
	openToolTip(usr, src, params, content = tooltip_text)

/atom/movable/screen/escape_menu/lobby_button/MouseExited(location, control, params)
	if (!hovered)
		return

	hovered = FALSE
	closeToolTip(usr)

/atom/movable/screen/escape_menu/lobby_button/proc/add_maptext(button_text)
	animate(src,
		maptext = MAPTEXT_PIXELLARI("<b style='font-size: [font_size]px; text-align: center'>[button_text]</b>"),
		flags = ANIMATION_CONTINUE,
	)

/atom/movable/screen/escape_menu/lobby_button/small
	icon = 'icons/hud/escape_menu_icons.dmi'
	font_size = 6
	maptext_width = 80
	maptext_x = -20
	maptext_y = -14

/atom/movable/screen/escape_menu/lobby_button/small/add_maptext(button_text)
	//overriding parent for a different font here.
	animate(src,
		maptext = MAPTEXT_GRAND9K("<b style='font-size: [font_size]px; text-align: center'>[button_text]</b>"),
		flags = ANIMATION_CONTINUE,
	)

///Amount of time between animations when we fade in and out.
#define COLLAPSIBLE_BUTTON_DURATION (0.4 SECONDS)

/atom/movable/screen/escape_menu/lobby_button/small/collapsible
	maptext_width = 48
	maptext_x = -4
	maptext_y = -44 //we change this during animation to bring it up
	layer = parent_type::layer - 0.01

	///Reference point we animate the x from during the animation we play on its creation.
	var/end_point

/atom/movable/screen/escape_menu/lobby_button/small/collapsible/Initialize(
	mapload,
	datum/hud/hud_owner,
	button_text,
	tooltip_text,
	list/pixel_offset,
	on_click_callback,
	button_overlay,
	end_point,
)
	src.end_point = end_point
	return ..()

/atom/movable/screen/escape_menu/lobby_button/small/collapsible/add_maptext(button_text)
	//more than 6 characters, lets bump the maptext down a bit, because we're smaller buttons we would be overlaying over the icon itself otherwise.
	if(length(button_text) > 6)
		maptext_y -= 10
	//let's take the icons out
	animate(src,
		transform = transform.Translate(x = end_point, y = 0),
		time = COLLAPSIBLE_BUTTON_DURATION,
		easing = CUBIC_EASING|EASE_OUT,
	)
	. = ..()
	//now we'll pull out the maptext
	animate(src,
		maptext_y = (maptext_y + 30),
		time = (COLLAPSIBLE_BUTTON_DURATION / 2),
		easing = CUBIC_EASING|EASE_IN,
		flags = ANIMATION_CONTINUE,
	)

/atom/movable/screen/escape_menu/lobby_button/small/collapsible/proc/collapse(datum/screen_object_holder/page_holder)
	//timers are delayed until MC is done, so we'll directly qdel during setup so it doesn't freeze on players.
	if(MC_RUNNING())
		animate(src,
			maptext_y = (maptext_y -30),
			time = (COLLAPSIBLE_BUTTON_DURATION / 2),
			easing = CUBIC_EASING|EASE_IN,
		)
		animate(src,
			transform = matrix(),
			maptext = null,
			time = COLLAPSIBLE_BUTTON_DURATION,
			easing = CUBIC_EASING|EASE_OUT,
			flags = ANIMATION_CONTINUE,
		)
		addtimer(CALLBACK(page_holder, TYPE_PROC_REF(/datum/screen_object_holder, remove_screen_object), src), COLLAPSIBLE_BUTTON_DURATION)
	else
		page_holder.remove_screen_object(src)

#undef COLLAPSIBLE_BUTTON_DURATION
