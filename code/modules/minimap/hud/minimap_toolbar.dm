#define MINIMAP_TOOLBAR_ERASE_RANGE 5

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
	/// Draw color this button represents. null = erase mode.
	var/draw_color = null
	/// HUD key for this tool button. Used to track selection state.
	var/tool_key = null
	/// Coordinates of the last drag position during drawing.
	var/last_drag_x
	var/last_drag_y

/atom/movable/screen/minimap_toolbar_button/Initialize(mapload, datum/hud/hud_owner, atom/movable/screen/minimap_display/minimap_display)
	. = ..()
	display = minimap_display

/atom/movable/screen/minimap_toolbar_button/Destroy()
	display = null
	return ..()

/atom/movable/screen/minimap_toolbar_button/MouseEntered(location, control, params)
	add_filter("mouseover", 1, outline_filter(1, COLOR_LIME))
	if(desc)
		openToolTip(usr, tip_src = display || src, params = params, title = name, content = desc)

/atom/movable/screen/minimap_toolbar_button/MouseExited(location, control, params)
	remove_filter("mouseover")
	if(desc)
		closeToolTip(usr)

/// Returns TRUE if this button should be shown as active.
/atom/movable/screen/minimap_toolbar_button/proc/is_active()
	return display && display.active_button == src

/// Updates the button's visual state to show if it's active.
/atom/movable/screen/minimap_toolbar_button/proc/update_active_state()
	if(is_active())
		add_filter("active", 1, outline_filter(2, COLOR_YELLOW))
	else
		remove_filter("active")

/// Called when this button is activated as the active tool.
/atom/movable/screen/minimap_toolbar_button/proc/on_activate()
	display?.set_cursor_icon(mouse_icon)

/// Called when this button is deactivated.
/atom/movable/screen/minimap_toolbar_button/proc/on_deactivate()
	display?.set_cursor_icon(null)
	last_drag_x = null
	last_drag_y = null

/// Called during mouse drag on the map. Override to implement tool behavior.
/atom/movable/screen/minimap_toolbar_button/proc/on_mouse_drag(x, y)
	return FALSE

/// Called on mouse up. Override to clean up tool state.
/atom/movable/screen/minimap_toolbar_button/proc/on_mouse_up()
	last_drag_x = null
	last_drag_y = null

/// Called on click. Override to implement click behavior like label placement.
/atom/movable/screen/minimap_toolbar_button/proc/on_click(icon_x, icon_y, right_click)
	return FALSE

/atom/movable/screen/minimap_toolbar_button/draw
	desc = "Left-drag on the map to draw."

/atom/movable/screen/minimap_toolbar_button/draw/on_mouse_drag(x, y)
	if(isnull(display) || isnull(display.drawing))
		return FALSE
	var/icon_width = display.minimap?.base_map?.Width()
	var/icon_height = display.minimap?.base_map?.Height()
	if(isnull(icon_width) || isnull(icon_height))
		return FALSE
	if(!ISINRANGE(x, 1, icon_width) || !ISINRANGE(y, 1, icon_height))
		last_drag_x = null
		last_drag_y = null
		return FALSE

	if(last_drag_x && last_drag_y)
		display.drawing.draw_line(draw_color, last_drag_x, last_drag_y + display.draw_offset_y, x, y + display.draw_offset_y, 0, 1)
		last_drag_x = x
		last_drag_y = y
	else
		display.drawing.draw_box(draw_color, x, y + display.draw_offset_y, x + 1, y + 1 + display.draw_offset_y, 0, 1)
		last_drag_x = x
		last_drag_y = y
	return TRUE

/atom/movable/screen/minimap_toolbar_button/draw/Click(location, control, params)
	if(usr == get_mob())
		display?.activate_button(src)

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

/atom/movable/screen/minimap_toolbar_button/erase/on_mouse_drag(x, y)
	if(isnull(display) || isnull(display.drawing))
		return FALSE
	var/icon_width = display.minimap?.base_map?.Width()
	var/icon_height = display.minimap?.base_map?.Height()
	if(isnull(icon_width) || isnull(icon_height))
		return FALSE
	if(!ISINRANGE(x, 1, icon_width) || !ISINRANGE(y, 1, icon_height))
		last_drag_x = null
		last_drag_y = null
		return FALSE

	if(last_drag_x && last_drag_y)
		display.drawing.draw_line(null, last_drag_x, last_drag_y + display.draw_offset_y, x, y + display.draw_offset_y, MINIMAP_TOOLBAR_ERASE_RANGE, 1)
		last_drag_x = x
		last_drag_y = y
	else
		display.drawing.draw_box(null, x, y + display.draw_offset_y, x + 1, y + 1 + display.draw_offset_y, MINIMAP_TOOLBAR_ERASE_RANGE, 1)
		last_drag_x = x
		last_drag_y = y
	return TRUE

/atom/movable/screen/minimap_toolbar_button/erase/Click(location, control, params)
	if(usr == get_mob())
		display?.activate_button(src)

/// Clear tool — removes all drawings and labels.
/atom/movable/screen/minimap_toolbar_button/clear
	icon_state = "clear"
	button_slot = 5
	desc = "Clear all drawings."

/atom/movable/screen/minimap_toolbar_button/clear/is_active()
	return FALSE

/atom/movable/screen/minimap_toolbar_button/clear/Click(location, control, params)
	if(usr == get_mob())
		display?.clear_canvas(usr)

/// Label tool — click the map to place labels, right-click a label to remove it, right-click this button to clear all labels.
/atom/movable/screen/minimap_toolbar_button/label
	icon_state = "label"
	button_slot = 6
	desc = "Toggle label mode. Click the map to place a label. Right-click a nearby label on the map to remove it. Right-click this button to clear all labels."
	mouse_icon = 'icons/ui_icons/minimap/minimap_mouse/label.dmi'

/atom/movable/screen/minimap_toolbar_button/label/on_click(icon_x, icon_y, right_click)
	if(isnull(display))
		return FALSE
	if(right_click)
		display.remove_nearest_label(icon_x, icon_y, usr)
		return TRUE
	// Place label asynchronously
	INVOKE_ASYNC(display, /atom/movable/screen/minimap_display/proc/async_place_label, usr, icon_x, icon_y)
	return TRUE

/atom/movable/screen/minimap_toolbar_button/label/Click(location, control, params)
	if(usr != get_mob())
		return
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		display.clear_all_annotations(usr, /atom/movable/screen/minimap_element/label)
	else
		display?.activate_button(src)

#undef MINIMAP_TOOLBAR_ERASE_RANGE
