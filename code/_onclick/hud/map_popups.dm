/client
	/**
	 * Assoc list with all the active maps - when a screen obj is added to
	 * a map, it's put in here as well.
	 *
	 * Format: list(<mapname> = list(/obj/screen))
	 */
	var/list/screen_maps = list()

/**
 * A screen object, which acts as a container for turfs and other things
 * you want to show on the map, which you usually attach to "vis_contents".
 */
/obj/screen
	/**
	 * Map name assigned to this object.
	 * Automatically set by /client/proc/add_obj_to_map.
	 */
	var/assigned_map
	/**
	 * Mark this object as garbage-collectible after you clean the map
	 * it was registered on.
	 *
	 * This could probably be changed to be a proc, for conditional removal.
	 * But for now, this works.
	 */
	var/del_on_map_removal = TRUE

/**
 * A generic background object.
 * It is also implicitly used to allocate a rectangle on the map, which will
 * be used for auto-scaling the map.
 */
/obj/screen/background
	name = "background"
	icon = 'icons/mob/map_backgrounds.dmi'
	icon_state = "clear"
	layer = -1
	plane = -1

/**
 * Sets screen_loc of this screen object, in form of point coordinates,
 * with optional pixel offset (px, py).
 *
 * If applicable, "assigned_map" has to be assigned before this proc call.
 */
/obj/screen/proc/set_position(var/x, var/y, var/px = 0, var/py = 0)
	if(assigned_map)
		screen_loc = "[assigned_map]:[x]:[px],[y]:[py]"
	else
		screen_loc = "[x]:[px],[y]:[py]"

/**
 * Sets screen_loc to fill a rectangular area of the map.
 *
 * If applicable, "assigned_map" has to be assigned before this proc call.
 */
/obj/screen/proc/fill_rect(var/x1, var/y1, var/x2, var/y2)
	if(assigned_map)
		screen_loc = "[assigned_map]:[x1],[y1] to [x2],[y2]"
	else
		screen_loc = "[x1],[y1] to [x2],[y2]"

/**
 * Registers screen obj with the client, which makes it visible on the
 * assigned map, and becomes a part of the assigned map's lifecycle.
 */
/client/proc/register_map_obj(var/obj/screen/item)
	if(!item.assigned_map)
		stack_trace("Can't register [item] without 'assigned_map' property.")
		return
	if(!screen_maps[item.assigned_map])
		screen_maps[item.assigned_map] = list()
	// NOTE: Possibly an expensive operation
	var/list/screen_map = screen_maps[item.assigned_map]
	if(!screen_map.Find(item))
		screen_map += item
	if(!screen.Find(item))
		screen += item

/**
 * Clears the map of registered screen objects.
 *
 * Not really needed most of the time, as the client's screen list gets reset
 * on relog. any of the buttons are going to get caught by garbage collection
 * anyway. they're effectively qdel'd.
 */
/client/proc/clear_map(var/map_name)
	if(!map_name || !(map_name in screen_maps))
		return FALSE
	for(var/obj/screen/item in screen_maps[map_name])
		screen_maps[map_name] -= item
		if(item.del_on_map_removal)
			qdel(item)
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
/client/proc/create_popup(var/name, var/ratiox = 100, var/ratioy = 100)
	winclone(src, "popupwindow", name)
	var/list/winparams = list()
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
/client/proc/setup_popup(var/popup_name, var/width = 9, var/height = 9, \
		var/tilesize = 2, var/bg_icon)
	if(!popup_name)
		return
	clear_map("[popup_name]_map")
	var/x_value = world.icon_size * tilesize * width
	var/y_value = world.icon_size * tilesize * height
	var/map_name = create_popup(popup_name, x_value, y_value)

	var/obj/screen/background/background = new
	background.assigned_map = map_name
	background.fill_rect(1, 1, width, height)
	if(bg_icon)
		background.icon_state = bg_icon
	register_map_obj(background)

	return map_name

/**
 * Closes a popup.
 */
/client/proc/close_popup(var/popup)
	winshow(src, popup, 0)
	handle_popup_close(popup)

/**
 * When the popup closes in any way (player or proc call) it calls this.
 */
/client/verb/handle_popup_close(window_id as text)
	set hidden = TRUE
	clear_map("[window_id]_map")
