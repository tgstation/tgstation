/**
 * A generic background object.
 * It is also implicitly used to allocate a rectangle on the map, which will
 * be used for auto-scaling the map.
 */
/atom/movable/screen/background
	name = "background"
	icon = 'icons/hud/map_backgrounds.dmi'
	icon_state = "clear"
	layer = GAME_PLANE
	plane = GAME_PLANE

/**
 * Sets screen_loc of this screen object, in form of point coordinates,
 * with optional pixel offset (px, py).
 *
 * If applicable, "assigned_map" has to be assigned before this proc call.
 */
/atom/movable/screen/proc/set_position(x, y, px = 0, py = 0)
	if(assigned_map)
		screen_loc = "[assigned_map]:[x]:[px],[y]:[py]"
	else
		screen_loc = "[x]:[px],[y]:[py]"

/**
 * Sets screen_loc to fill a rectangular area of the map.
 *
 * If applicable, "assigned_map" has to be assigned before this proc call.
 */
/atom/movable/screen/proc/fill_rect(x1, y1, x2, y2)
	if(assigned_map)
		screen_loc = "[assigned_map]:[x1],[y1] to [x2],[y2]"
	else
		screen_loc = "[x1],[y1] to [x2],[y2]"

/**
 * Registers screen obj with the client, which makes it visible on the
 * assigned map, and becomes a part of the assigned map's lifecycle.
 */
/client/proc/register_map_obj(atom/movable/screen/screen_obj)
	if(!screen_obj.assigned_map)
		CRASH("Can't register [screen_obj] without 'assigned_map' property.")
	if(!screen_maps[screen_obj.assigned_map])
		screen_maps[screen_obj.assigned_map] = list()
	// NOTE: Possibly an expensive operation
	var/list/screen_map = screen_maps[screen_obj.assigned_map]
	screen_map |= screen_obj
	screen |= screen_obj

/**
 * Clears the map of registered screen objects.
 */
/client/proc/clear_map(map_name)
	if(!map_name || !screen_maps[map_name])
		return FALSE
	for(var/atom/movable/screen/screen_obj in screen_maps[map_name])
		screen_maps[map_name] -= screen_obj
		screen -= screen_obj
		if(screen_obj.del_on_map_removal)
			qdel(screen_obj)
	screen_maps -= map_name

/**
 * Clears all the maps of registered screen objects.
 */
/client/proc/clear_all_maps()
	for(var/map_name in screen_maps)
		clear_map(map_name)

/**
 * Creates a popup window with a basic map element in it, without any
 * further initialization.
 *
 * Ratio is how many pixels by how many pixels (keep it simple).
 *
 * Returns a map name.
 */
/client/proc/create_popup(name, title, ratiox = 100, ratioy = 100)
	winclone(src, "popupwindow", name)
	var/list/winparams = list()
	winparams["title"] = title
	winparams["size"] = "[ratiox]x[ratioy]"
	winparams["on-close"] = "handle-popup-close [name]"
	winset(src, "[name]", list2params(winparams))
	winshow(src, "[name]", 1)

	var/list/params = list()
	params["parent"] = "[name]"
	params["type"] = "map"
	params["size"] = "[ratiox]x[ratioy]"
	params["anchor1"] = "0,0"
	params["anchor2"] = "[ratiox],[ratioy]"
	winset(src, "[name]_map", list2params(params))

	return "[name]_map"

/**
 * Create the popup, and get it ready for generic use by giving
 * it a background.
 *
 * Width and height are multiplied by 64 by default.
 */
/client/proc/setup_popup(popup_name, width = 9, height = 9, \
		tilesize = 2, title, bg_icon)
	if(!popup_name)
		return
	clear_map("[popup_name]_map")
	var/x_value = ICON_SIZE_X * tilesize * width
	var/y_value = ICON_SIZE_Y * tilesize * height
	var/map_name = create_popup(popup_name, title, x_value, y_value)

	var/atom/movable/screen/background/background = new
	background.assigned_map = map_name
	background.fill_rect(1, 1, width, height)
	if(bg_icon)
		background.icon_state = bg_icon
	register_map_obj(background)

	return map_name

/**
 * Closes a popup.
 */
/client/proc/close_popup(popup)
	winshow(src, popup, 0)
	handle_popup_close(popup)

/**
 * When the popup closes in any way (player or proc call) it calls this.
 */
/client/verb/handle_popup_close(window_id as text)
	set hidden = TRUE
	clear_map("[window_id]_map")
	SEND_SIGNAL(src, COMSIG_POPUP_CLEARED, window_id)
