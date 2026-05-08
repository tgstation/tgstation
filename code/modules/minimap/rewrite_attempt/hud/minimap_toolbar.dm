/atom/movable/screen/minimap_toolbar_button
	icon = 'icons/ui_icons/minimap/minimap_buttons.dmi'
	icon_state = "draw"
	mouse_over_pointer = MOUSE_HAND_POINTER
	/// The minimap display this button controls.
	var/atom/movable/screen/minimap_display/display
	/// Vertical slot index (0 = topmost). Used by reposition_toolbar_buttons to calculate screen_loc.
	var/button_slot = 0
	/// Mouse cursor icon set when this button's tool is active. null = default cursor.
	var/icon/mouse_icon = null

/atom/movable/screen/minimap_toolbar_button/Initialize(mapload, datum/hud/hud_owner, atom/movable/screen/minimap_display/minimap_display)
	. = ..()
	src.display = minimap_display

/atom/movable/screen/minimap_toolbar_button/Destroy()
	display = null
	return ..()

/atom/movable/screen/minimap_toolbar_button/MouseEntered(location, control, params)
	add_filter("mouseover", 1, outline_filter(1, COLOR_LIME))
	if(desc)
		openToolTip(usr, src, params, title = name, content = desc)

/atom/movable/screen/minimap_toolbar_button/MouseExited(location, control, params)
	remove_filter("mouseover")
	if(desc)
		closeToolTip(usr)

/atom/movable/screen/minimap_toolbar_button/draw
	desc = "Left-drag on the map to draw."
	/// The color written to [/atom/movable/screen/minimap_display/var/draw_color] when selected.
	var/draw_color = COLOR_PINK

/atom/movable/screen/minimap_toolbar_button/draw/Click(location, control, params)
	if(usr == get_mob())
		display?.select_draw_tool(draw_color, mouse_icon)

/atom/movable/screen/minimap_toolbar_button/draw/red
	button_slot = 0
	color = TACMAP_DRAWING_RED
	draw_color = TACMAP_DRAWING_RED
	mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/draw_red.dmi'

/atom/movable/screen/minimap_toolbar_button/draw/yellow
	button_slot = 1
	color = TACMAP_DRAWING_YELLOW
	draw_color = TACMAP_DRAWING_YELLOW
	mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/draw_yellow.dmi'

/atom/movable/screen/minimap_toolbar_button/draw/purple
	button_slot = 2
	color = TACMAP_DRAWING_PURPLE
	draw_color = TACMAP_DRAWING_PURPLE
	mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/draw_purple.dmi'

/atom/movable/screen/minimap_toolbar_button/draw/blue
	button_slot = 3
	color = TACMAP_DRAWING_BLUE
	draw_color = TACMAP_DRAWING_BLUE
	mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/draw_blue.dmi'

/// Erase tool — left-drag on the map to erase a line.
/atom/movable/screen/minimap_toolbar_button/erase
	icon_state = "erase"
	button_slot = 4
	desc = "Left-drag on the map to erase."
	mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/draw_erase.dmi'

/atom/movable/screen/minimap_toolbar_button/erase/Click(location, control, params)
	if(usr == get_mob())
		display?.select_draw_tool(null, mouse_icon)

/// Clear tool — removes all drawings and labels.
/atom/movable/screen/minimap_toolbar_button/clear
	icon_state = "clear"
	button_slot = 5
	desc = "Clear all drawings and labels."

/atom/movable/screen/minimap_toolbar_button/clear/Click(location, control, params)
	if(usr == get_mob())
		display?.clear_canvas_and_labels(usr)

/// Label tool — left-click the map to place a text label. Right-click to clear all labels.
/atom/movable/screen/minimap_toolbar_button/label
	icon_state = "label"
	button_slot = 6
	desc = "Toggle label mode. Click the map to place a label. Right-click this button to clear all labels."
	mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/label.dmi'

/atom/movable/screen/minimap_toolbar_button/label/Click(location, control, params)
	if(usr != get_mob())
		return
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		display.clear_all_annotations(usr, /atom/movable/screen/minimap_label)
	else
		display.toggle_label_mode(mouse_icon)
