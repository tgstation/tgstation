// Simple datum to keep track of a running holomap. Each machine capable of displaying the holomap will have one.
/datum/station_holomap
	var/image/base_map
	var/image/cursor

	var/list/overlay_data = list()
	var/list/disabled_overlays = list()
	var/total_legend_y

	var/map_x
	var/map_y
	var/map_z

/datum/station_holomap/New()
	. = ..()
	cursor = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "you")

/datum/station_holomap/proc/initialize_holomap(map_x, map_y, map_z, var/mob/user = null, var/reinit_base_map = FALSE, extra_overlays = list())
	src.map_x = map_x
	src.map_y = map_y
	src.map_z = map_z

	if(!base_map || reinit_base_map)
		base_map = image(SSholomaps.extra_holomaps["[HOLOMAP_EXTRA_STATIONMAP]_[map_z]"])

	if(isAI(user) || isaicamera(user))
		var/turf/eye_turf = get_turf(user?.client?.eye)
		if(!eye_turf)
			return
		src.map_x = eye_turf.x
		src.map_y = eye_turf.y

	update_map(extra_overlays)

/datum/station_holomap/proc/generate_legend(list/overlays_to_use = list())
	var/legend_y = HOLOMAP_LEGEND_Y
	for(var/list/overlay_name as anything in overlays_to_use)
		var/image/overlay_icon = overlays_to_use[overlay_name]["icon"]

		overlay_icon.pixel_x = HOLOMAP_LEGEND_X
		overlay_icon.pixel_y = legend_y
		overlay_icon.maptext = "<span class='maptext' style='font-size: 6px'>[overlay_name]</span>"
		overlay_icon.maptext_x = 10
		overlay_icon.maptext_width = 64
		base_map.add_overlay(overlay_icon)

		if(length(overlays_to_use[overlay_name]["markers"]))
			overlay_data["[round(legend_y / 10)]"] = overlay_name

		if(overlay_name in disabled_overlays)
			var/image/disabled_marker = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "legend_cross")
			disabled_marker.pixel_x = HOLOMAP_LEGEND_X
			disabled_marker.pixel_y = legend_y
			base_map.add_overlay(disabled_marker)

		legend_y += 10

	total_legend_y = legend_y

/// Updates the map with the provided overlays, with any, removing any overlays it already had that aren't the cursor or legend.
/// If there is no turf, then it doesn't add the cursor or legend back.
/// Make sure to set the pixel x and y of your overlays, or they'll render in the far bottom left.
/datum/station_holomap/proc/update_map(list/overlays_to_use = list())
	base_map.cut_overlays()

	if(map_x && map_y && SSmapping.level_has_all_traits(map_z, ZTRAIT_STATION))
		cursor.pixel_x = map_x - 3 + HOLOMAP_CENTER_X
		cursor.pixel_y = map_y - 3 + HOLOMAP_CENTER_Y

		base_map.add_overlay(cursor)

	for(var/overlay as anything in overlays_to_use)
		if(overlay in disabled_overlays)
			continue

		for(var/image/map_layer in overlays_to_use[overlay]["markers"])
			base_map.add_overlay(map_layer)

	generate_legend(overlays_to_use)

/datum/station_holomap/proc/initialize_holomap_bogus()
	base_map = image('monkestation/code/modules/holomaps/icons/480x480.dmi', "stationmap")

	var/image/legend = image('monkestation/code/modules/holomaps/icons/64x64.dmi', "notfound")
	legend.pixel_x = 192
	legend.pixel_y = 224

	update_map(overlays_to_use = list(legend))
