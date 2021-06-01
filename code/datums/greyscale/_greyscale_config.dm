/datum/greyscale_config
	/// User friendly name used in the debug menu
	var/name

	/// Reference to the json config file
	var/json_config

	/// Reference to the dmi file for this config
	var/icon_file

	/// An optional var to set that tells the material system what material this configuration is for.
	/// Use a typepath here, not an instance.
	var/datum/material/material_skin

	///////////////////////////////////////////////////////////////////////////////////////////
	// Do not set any further vars, the json file specified above is what generates the object

	/// Spritesheet width of the icon_file
	var/width

	/// Spritesheet height of the icon_file
	var/height

	/// String path to the json file, used for reloading
	var/string_json_config

	/// String path to the icon file, used for reloading
	var/string_icon_file

	/// A list of icon states and their layers
	var/list/icon_states

	/// How many colors are expected to be given when building the sprite
	var/expected_colors = 0

	/// Generated icons keyed by their color arguments
	var/list/icon_cache

// There's more sanity checking here than normal because this is designed for spriters to work with
// Sensible error messages that tell you exactly what's wrong is the best way to make this easy to use
/datum/greyscale_config/New()
	if(!json_config)
		stack_trace("Greyscale config object [DebugName()] is missing a json configuration, make sure `json_config` has been assigned a value.")
	string_json_config = "[json_config]"
	if(!icon_file)
		stack_trace("Greyscale config object [DebugName()] is missing an icon file, make sure `icon_file` has been assigned a value.")
	string_icon_file = "[icon_file]"
	if(!name)
		stack_trace("Greyscale config object [DebugName()] is missing a name, make sure `name` has been assigned a value.")

/datum/greyscale_config/proc/Refresh(loadFromDisk=FALSE)
	if(loadFromDisk)
		json_config = file(string_json_config)
		icon_file = file(string_icon_file)

	var/icon/source = icon(icon_file)
	height = source.Height()
	width = source.Width()

	icon_states = list()

	var/list/raw = json_decode(file2text(json_config))
	ReadIconStateConfiguration(raw)

	if(!length(icon_states))
		CRASH("The json configuration [DebugName()] is missing any icon_states.")

	icon_cache = list()

	ReadMetadata()

/// Gets the name used for debug purposes
/datum/greyscale_config/proc/DebugName()
	var/display_name = name || "MISSING_NAME"
	return "[display_name] ([icon_file]|[json_config])"

/// Takes the json icon state configuration and puts it into a more processed format
/datum/greyscale_config/proc/ReadIconStateConfiguration(list/data)
	for(var/state in data)
		var/list/raw_layers = data[state]
		if(!length(raw_layers))
			stack_trace("The json configuration [DebugName()] for icon state '[state]' is missing any layers.")
			continue
		if(icon_states[state])
			stack_trace("The json configuration [DebugName()] has a duplicate icon state '[state]' and is being overriden.")
		icon_states[state] = ReadLayersFromJson(raw_layers)

/// Takes the json layers configuration and puts it into a more processed format
/datum/greyscale_config/proc/ReadLayersFromJson(list/data)
	var/list/output = ReadLayerGroup(data)
	return output[1]

/datum/greyscale_config/proc/ReadLayerGroup(list/data)
	if(!islist(data[1]))
		var/layer_type = SSgreyscale.layer_types[data["type"]]
		if(!layer_type)
			CRASH("An unknown layer type was specified in greyscale configuration json: [data["layer_type"]]")
		return new layer_type(icon_file, data)
	var/list/output = list()
	for(var/list/group as anything in data)
		output += ReadLayerGroup(group)
	if(length(output)) // Adding lists to lists unwraps the top level so here we are
		output = list(output)
	return output

/// Reads layer configurations to take out some useful overall information
/datum/greyscale_config/proc/ReadMetadata()
	var/list/datum/greyscale_layer/all_layers = list()
	var/list/to_process = list()
	for(var/state in icon_states)
		to_process += icon_states[state]
	while(length(to_process))
		var/current = to_process[length(to_process)]
		to_process.len--
		if(islist(current))
			to_process += current
		else
			all_layers += current

	var/list/color_groups = list()
	for(var/datum/greyscale_layer/layer as anything in all_layers)
		for(var/id in layer.color_ids)
			if(!isnum(id))
				continue
			color_groups["[id]"] = TRUE

	expected_colors = length(color_groups)

/// Actually create the icon and color it in, handles caching
/datum/greyscale_config/proc/Generate(color_string)
	var/key = color_string
	var/icon/new_icon = icon_cache[key]
	if(new_icon)
		return icon(new_icon)

	var/icon/icon_bundle = GenerateBundle(color_string)

	// This block is done like this because generated icons are unable to be scaled before getting added to the rsc
	icon_bundle = fcopy_rsc(icon_bundle)
	icon_bundle = icon(icon_bundle)
	icon_bundle.Scale(width, height)
	icon_bundle = fcopy_rsc(icon_bundle)

	icon_cache[key] = icon_bundle
	var/icon/output = icon(icon_bundle)
	return output

/// Handles the actual icon manipulation to create the spritesheet
/datum/greyscale_config/proc/GenerateBundle(list/colors, list/render_steps)
	if(!istype(colors))
		colors = SSgreyscale.ParseColorString(colors)
	if(length(colors) != expected_colors)
		CRASH("[DebugName()] expected [expected_colors] color arguments but only received [length(colors)]")

	var/list/generated_icons = list()
	for(var/icon_state in icon_states)
		var/icon/generated_icon = GenerateLayerGroup(colors, icon_states[icon_state], render_steps)
		// We read a pixel to force the icon to be fully generated before we let it loose into the world
		// I hate this
		generated_icon.GetPixel(1, 1)
		generated_icons[icon_state] = generated_icon

	var/icon/icon_bundle = icon('icons/testing/greyscale_error.dmi')
	for(var/icon_state in generated_icons)
		icon_bundle.Insert(generated_icons[icon_state], icon_state)

	return icon_bundle

/// Internal recursive proc to handle nested layer groups
/datum/greyscale_config/proc/GenerateLayerGroup(list/colors, list/group, list/render_steps)
	var/icon/new_icon
	for(var/datum/greyscale_layer/layer as anything in group)
		var/icon/layer_icon
		if(islist(layer))
			layer_icon = GenerateLayerGroup(colors, layer, render_steps)
			layer = layer[1] // When there are multiple layers in a group like this we use the first one's blend mode
		else
			layer_icon = layer.Generate(colors, render_steps)

		if(!new_icon)
			new_icon = layer_icon
		else
			new_icon.Blend(layer_icon, layer.blend_mode)

		// These are so we can see the result of every step of the process in the preview ui
		if(render_steps)
			render_steps[icon(layer_icon)] = icon(new_icon)
	return new_icon

/datum/greyscale_config/proc/GenerateDebug(colors)
	var/list/output = list()
	var/list/debug_steps = list()
	output["steps"] = debug_steps

	output["icon"] = GenerateBundle(colors, debug_steps)
	return output
