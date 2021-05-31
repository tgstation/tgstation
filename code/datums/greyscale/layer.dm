/datum/greyscale_layer
	var/layer_type
	var/list/color_ids
	var/blend_mode

	var/static/list/blend_modes = list(
		"add" = ICON_ADD,
		"subtract" = ICON_SUBTRACT,
		"multiply" = ICON_MULTIPLY,
		"or" = ICON_OR,
		"overlay" = ICON_OVERLAY,
		"underlay" = ICON_UNDERLAY,
	)

/datum/greyscale_layer/New(icon_file, list/json_data)
	color_ids = json_data["color_ids"]
	for(var/i in color_ids)
		if(isnum(i))
			continue
		if(istext(i) && i[1] == "#")
			continue
		CRASH("Color ids must be a color string or positive integer starting from 1, '[i]' is not valid.")
	blend_mode = blend_modes[lowertext(json_data["blend_mode"])]
	if(isnull(blend_mode))
		CRASH("Greyscale config for [icon_file] is missing a blend mode on a layer.")

/// Used to actualy create the layer using the given colors
/// Do not override, use InternalGenerate instead
/datum/greyscale_layer/proc/Generate(list/colors, list/render_steps)
	var/list/processed_colors = list()
	for(var/i in color_ids)
		if(isnum(i))
			processed_colors += colors[i]
		else
			processed_colors += i
	return InternalGenerate(processed_colors, render_steps)

/datum/greyscale_layer/proc/InternalGenerate(list/colors, list/render_steps)

////////////////////////////////////////////////////////
// Subtypes

/// The most basic greyscale layer; a layer which is created from a single icon_state in the given icon file
/datum/greyscale_layer/icon_state
	layer_type = "icon_state"
	var/icon/icon
	var/color_id

/datum/greyscale_layer/icon_state/New(icon_file, list/json_data)
	. = ..()
	var/icon_state = json_data["icon_state"]
	if(!(icon_state in icon_states(icon_file)))
		CRASH("Configured icon state \[[icon_state]\] was not found in [icon_file]. Double check your json configuration.")
	icon = new(icon_file, json_data["icon_state"])

	if(length(color_ids) > 1)
		CRASH("Icon state layers can not have more than one color id")

/datum/greyscale_layer/icon_state/InternalGenerate(list/colors, list/render_steps)
	. = ..()
	var/icon/new_icon = icon(icon)
	if(length(colors))
		new_icon.Blend(colors[1], ICON_MULTIPLY)
	return new_icon

/// A layer created by using another greyscale icon's configuration
/datum/greyscale_layer/reference
	layer_type = "reference"
	var/icon_state
	var/datum/greyscale_config/reference_config

/datum/greyscale_layer/reference/New(icon_file, list/json_data)
	. = ..()
	icon_state = json_data["icon_state"] || ""
	reference_config = SSgreyscale.configurations[json_data["reference_type"]]
	if(!reference_config)
		CRASH("An unknown greyscale configuration was given to a reference layer: [json_data["reference_type"]]")

/datum/greyscale_layer/reference/InternalGenerate(list/colors, list/render_steps)
	return icon(reference_config.Generate(colors.Join(), render_steps), icon_state)
