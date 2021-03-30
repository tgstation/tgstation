GLOBAL_LIST_EMPTY_TYPED(greyscale_sprites, /datum/greyscale_sprite)
GLOBAL_LIST_EMPTY(greyscale_filters)

/proc/greyscale_sprite(sprite_file, list/colors)
	var/datum/greyscale_sprite/sprite_generator
	if(GLOB.greyscale_sprites[sprite_file])
		sprite_generator = GLOB.greyscale_sprites[sprite_file]
	else
		GLOB.greyscale_sprites[sprite_file] = sprite_generator = new(sprite_file)

	return sprite_generator.ProcessedIcon(colors)

/proc/greyscale_filter(sprite_file, list/sprite_colors, list/filter_arguments)
	var/icon/greyscale_icon = greyscale_sprite(sprite_file, sprite_colors)

	var/key = "[sprite_file]&[json_encode(sprite_colors)]&[json_encode(filter_arguments)]"
	if(!GLOB.greyscale_filters[key])
		var/list/arguments = filter_arguments + list("icon" = greyscale_icon)
		GLOB.greyscale_filters[key] = filter(arglist(arguments))
	return GLOB.greyscale_filters[key]

/datum/greyscale_sprite
	var/source
	var/list/layers
	var/list/cached_icons = list()

/datum/greyscale_sprite/New(sprite_file)
	source = sprite_file

	var/list/first_pass = list()
	for(var/state in icon_states(source))
		if(state[1] == "#")
			continue
		first_pass += new /datum/greyscale_layer(source, state)

	layers = ReadIconGroup(first_pass)

/datum/greyscale_sprite/proc/ReadIconGroup(list/input, depth=0)
	var/list/output = list()
	var/list/inner = list()
	var/current_depth = depth
	for(var/i in input)
		var/datum/greyscale_layer/layer = i
		current_depth += layer.depth_modification
		// This means we're currently in some nested group
		if(current_depth > 0)
			inner += layer
			continue
		// This means we're not in a nested group, and weren't before
		if(!length(inner))
			output += layer
			continue
		// This means we're no longer in a nested group but were last iteration
		// Time to clean up this group
		inner += layer
		output += list(inner)
		inner = list()

	// Now that we've handled all the layers directly in our group, let's start the next layer of nested groups
	for(var/i in 1 to length(output))
		var/thing = output[i]
		if(islist(thing))
			output[i] = ReadIconGroup(output[i], depth - 1)

	return output

/datum/greyscale_sprite/proc/ProcessedIcon(list/colors)
	var/cache_key = colors.Join("&");
	var/icon/new_icon = cached_icons[cache_key]
	if(!new_icon)
		new_icon = cached_icons[cache_key] = ProcessIconGroup(layers, null, colors)
	return icon(new_icon)

// foo <= ( bar <= ( boo <= color ) <= ( far <= color ) )
// 1   11   2   6    3   5  4       10   7   9  8
/datum/greyscale_sprite/proc/ProcessIconGroup(list/remaining, icon/target, list/colors)
	for(var/i in remaining)
		if(islist(i))
			target = ProcessIconGroup(i, target, colors)
			continue
		var/datum/greyscale_layer/layer = i
		var/icon/layer_icon = icon(layer.icon)
		var/rgb = rgb(255, 255, 255)
		if(layer.color_id)
			rgb = colors[layer.color_id]
		layer_icon.Blend(rgb, ICON_MULTIPLY)
		if(!target)
			target = layer_icon
			continue
		target.Blend(layer_icon, layer.blend_mode)
	return target

/datum/greyscale_layer
	var/icon/icon
	var/blend_mode
	var/color_id
	var/name
	var/depth_modification

	var/static/list/blend_modes = list(
		"+" = ICON_ADD,
		"-" = ICON_SUBTRACT,
		"*" = ICON_MULTIPLY,
		"|" = ICON_OR,
		"^" = ICON_OVERLAY,
		"v" = ICON_UNDERLAY,
	)

/datum/greyscale_layer/New(icon_file, icon_state)
	icon = new(icon_file, icon_state)

	var/static/regex/config_extractor = new(@"^(\(*)(\S)(\d*)(.*?)(\)*)$")
	config_extractor.Find(icon_state)
	var/list/group = config_extractor.group

	depth_modification = length(group[1]) - length(group[5])

	blend_mode = blend_modes[group[2]]
	color_id = text2num(group[3])
	name = group[4]
