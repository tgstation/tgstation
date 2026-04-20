/atom/movable/screen/minimap_drawing
	name = ""
	icon = 'icons/ui_icons/minimap/minimap.dmi'
	layer = MINIMAP_LABELS_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE

/atom/movable/screen/minimap_drawing/proc/clear_canvas(icon/base_map)
	var/icon/new_icon = icon('icons/ui_icons/minimap/minimap.dmi')
	if(base_map)
		new_icon.Scale(base_map.Width(), base_map.Height())
	icon = new_icon

/atom/movable/screen/minimap_drawing/proc/draw_box(box_color, start_x, start_y, end_x, end_y, erase_pixel_range = 0, erase_padding_multiplier = 0)
	var/icon/new_icon = icon(src.icon)
	if(!isnull(box_color) || !erase_padding_multiplier)
		new_icon.DrawBox(box_color, start_x, start_y, end_x, end_y)
	else
		var/padding = erase_pixel_range * erase_padding_multiplier
		new_icon.DrawBox(box_color, start_x - padding, start_y - padding, end_x + padding, end_y + padding)
	icon = new_icon
