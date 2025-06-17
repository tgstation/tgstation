/datum/hud
	var/atom/movable/screen/holomap/holomap

/datum/hud/New(mob/owner)
	. = ..()

	holomap = new /atom/movable/screen/holomap()
	holomap.name = "holomap"
	holomap.icon = null
	holomap.screen_loc = ui_holomap
	holomap.mouse_opacity = MOUSE_OPACITY_ICON


/atom/movable/screen/holomap
	/// The owner. Used to get z-level data.
	var/obj/machinery/station_map/used_station_map
	var/image/used_base_map

/atom/movable/screen/holomap/Click(location, control, params)
	. = ..()
	if(!used_station_map)
		return

	if(LAZYACCESS(params2list(params), RIGHT_CLICK))
		used_station_map.close_map()
		return

	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))

	if(icon_x < HOLOMAP_LEGEND_X || icon_x > HOLOMAP_LEGEND_X + HOLOMAP_LEGEND_WIDTH || icon_y < HOLOMAP_LEGEND_Y || icon_y > used_station_map.holomap_datum.total_legend_y)
		return

	var/selected_entry = round(icon_y / 10, 1) - 1 // Always round for a whole number, and subtract one cause I have no fucking idea what I'm doing
	var/list/overlay_data = used_station_map.holomap_datum.overlay_data

	if(!("[selected_entry]" in overlay_data))
		return

	var/list/disabled_overlays = used_station_map.holomap_datum.disabled_overlays

	if(overlay_data["[selected_entry]"] in disabled_overlays)
		disabled_overlays -= overlay_data["[selected_entry]"]
	else
		disabled_overlays += overlay_data["[selected_entry]"]

	used_station_map.holomap_datum.update_map(used_station_map.handle_overlays())

/atom/movable/screen/holomap/MouseEntered(location, control, params)
	. = ..()
	MouseMove(location, control, params)

/atom/movable/screen/holomap/MouseMove(location, control, params)
	if(!used_station_map)
		return

	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/list/position_to_name = SSholomaps.holomap_position_to_name["[used_station_map.current_z_level]"]

	if(!position_to_name || !usr.hud_used)
		return

	var/text_for_screentip = position_to_name["[icon_x]:[icon_y]"]

	used_base_map.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align: center'>[text_for_screentip]</span>")
	used_base_map.maptext_x = icon_x
	used_base_map.maptext_y = icon_y
	used_base_map.maptext_width = 96
	used_base_map.maptext_height = 96
