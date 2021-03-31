/datum/greyscale_config
	/// Reference to the json config file
	var/json_config
	/// Reference to the dmi file for this config
	var/icon_file

	// Do not set any further vars, the json file specified above is what generates the object

	/// Layer objects that the sprite is made up of
	var/list/layers

	/// How many colors are expected to be given when building the sprite
	var/expected_colors = 0

	/// Generated icons keyed by their color arguments
	var/list/icon_cache = list()

// There's more sanity checking here than normal because this is designed for spriters to work with
// Sensible error messages that tell you exactly what's wrong is the best way to make this easy to use
/datum/greyscale_config/New()
	if(!json_config)
		CRASH("Greyscale config object [DebugName()] is missing a json configuration, make sure `json_config` has been assigned a value.")
	if(!icon_file)
		CRASH("Greyscale config object [DebugName()] is missing an icon file, make sure `icon_file` has been assigned a value.")

	var/list/raw = json_decode(file2text(json_config))
	layers = ReadLayersFromJson(raw["layers"])
	if(!length(layers))
		CRASH("The json configuration [DebugName()] is missing any layers.")

	ReadMetadata()

/// Gets the name used for debug purposes
/datum/greyscale_config/proc/DebugName()
	return "([icon_file]|[json_config])"

/// Takes the json layers configuration and puts it into a more processed format
/datum/greyscale_config/proc/ReadLayersFromJson(list/data)
	var/list/output = ReadLayerGroup(data)
	return output[1]

/datum/greyscale_config/proc/ReadLayerGroup(list/data)
	if(!islist(data[1]))
		return new /datum/greyscale_layer(icon_file, data)
	var/list/output = list()
	for(var/list/group as anything in data)
		output += ReadLayerGroup(group)
	if(length(output)) // Adding lists to lists unwraps the top level so here we are
		output = list(output)
	return output

/// Reads layer configurations to take out some useful overall information
/datum/greyscale_config/proc/ReadMetadata()
	var/list/datum/greyscale_layer/all_layers = list()
	var/list/to_process = list(layers)
	while(length(to_process))
		var/current = to_process[length(to_process)]
		to_process.len--
		if(islist(current))
			to_process += current
		else
			all_layers += current

	var/list/color_groups = list()
	for(var/datum/greyscale_layer/layer as anything in all_layers)
		color_groups[layer.color_id] = TRUE

	expected_colors = length(color_groups)

/// Actually create the icon and color it in, handles caching
/datum/greyscale_config/proc/Generate(list/colors)
	if(length(colors) != expected_colors)
		CRASH("[DebugName()] expected [expected_colors] color arguments but only received [length(colors)]")
	var/key = colors.Join("&")
	var/icon/new_icon = icon_cache[key]
	if(new_icon)
		return new_icon
	new_icon = icon_cache[key] = GenerateLayerGroup(colors, layers)
	return new_icon

/// Internal recursive proc to handle nested layer groups
/datum/greyscale_config/proc/GenerateLayerGroup(list/colors, list/group)
	var/icon/new_icon
	for(var/datum/greyscale_layer/layer as anything in group)
		if(islist(layer))
			layer = GenerateLayerGroup(colors, group)
		var/icon/layer_icon = layer.Generate(colors)
		if(!new_icon)
			new_icon = layer_icon
			continue
		new_icon.Blend(layer_icon, layer.blend_mode)
	return new_icon
