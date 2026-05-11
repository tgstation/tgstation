
/atom/movable/screen/minimap_element/drawing
	icon = 'icons/ui_icons/minimap/minimap.dmi'

/atom/movable/screen/minimap_element/drawing/proc/clear_canvas(icon/base_map)
	var/icon/new_icon = icon('icons/ui_icons/minimap/minimap.dmi')
	if(base_map)
		new_icon.Scale(base_map.Width(), base_map.Height())
	icon = new_icon

/atom/movable/screen/minimap_element/drawing/proc/draw_box(box_color, start_x, start_y, end_x, end_y, erase_pixel_range = 0, erase_padding_multiplier = 0)
	var/icon/new_icon = icon(src.icon)
	if(!isnull(box_color) || !erase_padding_multiplier)
		new_icon.DrawBox(box_color, start_x, start_y, end_x, end_y)
	else
		var/padding = erase_pixel_range * erase_padding_multiplier
		new_icon.DrawBox(box_color, start_x - padding, start_y - padding, end_x + padding, end_y + padding)
	icon = new_icon

// Unapologetically yoinked from /proc/get_line()
/atom/movable/screen/minimap_element/drawing/proc/draw_line(line_color, x0, y0, x1, y1, erase_pixel_range = 0, erase_padding_multiplier = 0)
	var/icon/canvas = icon(src.icon)
	var/current_x = x0
	var/current_y = y0

	var/x_distance = x1 - current_x
	var/y_distance = y1 - current_y

	var/abs_x_distance = abs(x_distance)
	var/abs_y_distance = abs(y_distance)

	var/x_distance_sign = sign(x_distance)
	var/y_distance_sign = sign(y_distance)

	var/cx = abs_x_distance >> 1
	var/cy = abs_y_distance >> 1

	// draw the start pixel
	var/padding = isnull(line_color) && erase_padding_multiplier ? erase_pixel_range * erase_padding_multiplier : 0
	canvas.DrawBox(line_color, current_x - padding, current_y - padding, current_x + 1 + padding, current_y + 1 + padding)

	if(abs_x_distance >= abs_y_distance)
		for(var/i in 0 to (abs_x_distance - 1))
			cy += abs_y_distance
			if(cy >= abs_x_distance)
				cy -= abs_x_distance
				current_y += y_distance_sign
			current_x += x_distance_sign
			canvas.DrawBox(line_color, current_x - padding, current_y - padding, current_x + 1 + padding, current_y + 1 + padding)
	else
		for(var/i in 0 to (abs_y_distance - 1))
			cx += abs_x_distance
			if(cx >= abs_y_distance)
				cx -= abs_y_distance
				current_x += x_distance_sign
			current_y += y_distance_sign
			canvas.DrawBox(line_color, current_x - padding, current_y - padding, current_x + 1 + padding, current_y + 1 + padding)

	src.icon = canvas
