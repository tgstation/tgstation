/// Datum tracker for storage UI
/datum/storage_ui_theme
	/// UI elements for this theme
	var/atom/movable/screen/close/closer
	var/atom/movable/screen/storage/cells
	var/atom/movable/screen/storage/corner/corner1
	var/atom/movable/screen/storage/corner/corner2
	var/atom/movable/screen/storage/corner/corner3
	var/atom/movable/screen/storage/corner/corner4
	var/atom/movable/screen/storage/rowjoin/rowjoin1
	var/atom/movable/screen/storage/rowjoin/rowjoin2

	/// How many people are currently observing us.
	/// Defaults to one since this is only generated if someone opens the UI
	var/current_viewers = 1
	/// Storage that owns us
	var/datum/storage/parent_storage

/datum/storage_ui_theme/New(ui_style, parent_storage)
	src.parent_storage = parent_storage
	closer = new(null, null, parent_storage)
	closer.icon = ui_style

	cells = new(null, null, parent_storage)
	corner1 = new(null, null, parent_storage)
	corner2 = new(null, null, parent_storage)
	corner3 = new(null, null, parent_storage)
	corner4 = new(null, null, parent_storage)
	rowjoin1 = new(null, null, parent_storage)
	rowjoin2 = new(null, null, parent_storage)

	cells.icon = ui_style
	corner1.icon = ui_style
	corner2.icon = ui_style
	corner3.icon = ui_style
	corner4.icon = ui_style
	rowjoin1.icon = ui_style
	rowjoin2.icon = ui_style

	corner2.icon_state = "storage_corner_topright"
	corner3.icon_state = "storage_corner_bottomleft"
	corner4.icon_state = "storage_corner_bottomright"
	corner2.update_appearance()
	corner3.update_appearance()
	corner4.update_appearance()

	rowjoin2.icon_state = "storage_rowjoin_right"
	rowjoin2.update_appearance()

/// Returns all UI elements under this theme
/datum/storage_ui_theme/proc/list_ui_elements()
	return list(cells, corner1, corner2, corner3, corner4, rowjoin1, rowjoin2, closer)

/// Called when someone closes the UI, deducts one from current_viewers and if it hits zero - deletes all UI elements and returns TRUE
/datum/storage_ui_theme/proc/deduct_viewer()
	current_viewers -= 1
	if (current_viewers > 0)
		return FALSE

	QDEL_NULL(cells)
	QDEL_NULL(corner1)
	QDEL_NULL(corner2)
	QDEL_NULL(corner3)
	QDEL_NULL(corner4)
	QDEL_NULL(rowjoin1)
	QDEL_NULL(rowjoin2)
	return TRUE


/// Updates position of all UI elements
/datum/storage_ui_theme/proc/update_position(screen_start_x, screen_pixel_x, screen_start_y, screen_pixel_y, columns, rows)
	cells.screen_loc = "[screen_start_x]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [screen_start_x + columns - 1]:[screen_pixel_x],[screen_start_y + rows - 1]:[screen_pixel_y]"

	corner1.screen_loc = "[screen_start_x + 1]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [screen_start_x + columns - 1]:[screen_pixel_x],[screen_start_y + rows - 1]:[screen_pixel_y]"
	corner2.screen_loc = "[screen_start_x]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [screen_start_x + max(0, columns - 2)]:[screen_pixel_x],[screen_start_y + rows - 1]:[screen_pixel_y]"
	corner3.screen_loc = "[screen_start_x + 1]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [screen_start_x + columns - 1]:[screen_pixel_x],[screen_start_y + rows - 1]:[screen_pixel_y]"
	corner4.screen_loc = "[screen_start_x]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [screen_start_x + max(0, columns - 2)]:[screen_pixel_x],[screen_start_y + rows - 1]:[screen_pixel_y]"

	rowjoin1.screen_loc = "[screen_start_x]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y + 27] to [screen_start_x]:[screen_pixel_x],[screen_start_y + max(0, rows - 2)]:[screen_pixel_y + 27]"
	rowjoin1.alpha = (rows > 1) * 255

	rowjoin2.screen_loc = "[screen_start_x + columns - 1]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y + 27] to [screen_start_x + columns - 1]:[screen_pixel_x],[screen_start_y + max(0, rows - 2)]:[screen_pixel_y + 27]"
	rowjoin2.alpha = (rows > 1) * 255

	closer.screen_loc = "[screen_start_x + columns]:[screen_pixel_x - 5],[screen_start_y]:[screen_pixel_y]"
