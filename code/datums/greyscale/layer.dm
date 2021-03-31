/datum/greyscale_layer
	var/icon/icon
	var/blend_mode
	var/color_id

	var/static/list/blend_modes = list(
		"add" = ICON_ADD,
		"subtract" = ICON_SUBTRACT,
		"multiply" = ICON_MULTIPLY,
		"or" = ICON_OR,
		"overlay" = ICON_OVERLAY,
		"underlay" = ICON_UNDERLAY,
	)

/datum/greyscale_layer/New(icon_file, list/json_data)
	icon = new(icon_file, json_data["icon_state"])
	blend_mode = blend_modes[lowertext(json_data["blend_mode"])]
	color_id = text2num(json_data["color_id"])

/datum/greyscale_layer/proc/Generate(list/colors)
	var/icon/new_icon = icon(icon)
	if(color_id)
		new_icon.Blend(colors[color_id], ICON_MULTIPLY)
	return new_icon
