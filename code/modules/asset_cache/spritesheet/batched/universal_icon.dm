/// This is intended to replace /icon, allowing rustg to generate icons much faster than DM can at scale.
/// Construct these with the uni_icon() proc, in the same manner as BYOND's icon() proc.
/// Additionally supports a number of transform procs (lowercase, rather than BYOND's uppercase)
/// such as Crop, Scale, and Blend (as blend_icon/blend_color).
/datum/universal_icon
	var/icon/icon_file
	var/icon_state
	var/dir
	var/frame
	var/datum/icon_transformer/transform

/// Don't instantiate these yourself, use uni_icon.
/datum/universal_icon/New(icon/icon_file, icon_state="", dir=SOUTH, frame=1, datum/icon_transformer/transform=null, color=null)
	#ifdef UNIT_TESTS
	// This check is kinda slow and shouldn't fail unless a developer makes a mistake. So it'll get caught in unit tests.
	if(!isicon(icon_file) || !isfile(icon_file) || "[icon_file]" == "/icon" || !length("[icon_file]"))
		// bad! use 'icons/path_to_dmi.dmi' format only
		CRASH("FATAL: universal_icon was provided icon_file: [icon_file] - icons provided to batched spritesheets MUST be DMI files, they cannot be /image, /icon, or other runtime generated icons.")
	#endif
	src.icon_file = icon_file
	src.icon_state = icon_state
	src.dir = dir
	src.frame = frame
	if(isnull(transform) && !isnull(color) && uppertext(color) != "#FFFFFF")
		var/datum/icon_transformer/T = new()
		if(color)
			T.blend_color(color, ICON_MULTIPLY)
		src.transform = T
	else if(!isnull(transform))
		src.transform = transform
	else // null = empty list
		src.transform = null

/datum/universal_icon/proc/copy()
	RETURN_TYPE(/datum/universal_icon)
	var/datum/universal_icon/new_icon = new(icon_file, icon_state, dir, frame)
	if(!isnull(src.transform))
		new_icon.transform = src.transform.copy()
	return new_icon

/datum/universal_icon/proc/blend_color(color, blend_mode)
	if(!transform)
		transform = new
	transform.blend_color(color, blend_mode)
	return src

/datum/universal_icon/proc/blend_icon(datum/universal_icon/icon_object, blend_mode)
	if(!transform)
		transform = new
	transform.blend_icon(icon_object, blend_mode)
	return src

/datum/universal_icon/proc/scale(width, height)
	if(!transform)
		transform = new
	transform.scale(width, height)
	return src

/datum/universal_icon/proc/crop(x1, y1, x2, y2)
	if(!transform)
		transform = new
	transform.crop(x1, y1, x2, y2)
	return src

/// Internally performs a crop.
/datum/universal_icon/proc/shift(dir, amount, icon_width, icon_height)
	if(!transform)
		transform = new
	var/list/offsets = dir2offset(dir)
	var/shift_x = -offsets[1] * amount
	var/shift_y = -offsets[2] * amount
	transform.crop(1 + shift_x, 1 + shift_y, icon_width + shift_x, icon_height + shift_y)
	return src

/// Internally performs a color blend.
/// Amount ranges from 0-1 (100% opacity)
/datum/universal_icon/proc/change_opacity(amount)
	if(!transform)
		transform = new
	transform.blend_color("#ffffff[num2hex(clamp(amount, 0, 1) * 255, 2)]", ICON_MULTIPLY)
	return src


/datum/universal_icon/proc/to_list()
	RETURN_TYPE(/list)
	return list("icon_file" = "[icon_file]", "icon_state" = icon_state, "dir" = dir, "frame" = frame, "transform" = !isnull(transform) ? transform.to_list() : list())

/proc/universal_icon_from_list(list/input_in)
	RETURN_TYPE(/datum/universal_icon)
	var/list/input = input_in.Copy() // copy, since icon_transformer_from_list will mutate the list.
	return uni_icon(input["icon_file"], input["icon_state"], input["dir"], input["frame"], icon_transformer_from_list(input["transform"]))

/datum/universal_icon/proc/to_json()
	return json_encode(to_list())

/datum/universal_icon/proc/to_icon()
	RETURN_TYPE(/icon)
	var/icon/self = icon(src.icon_file, src.icon_state, dir=src.dir, frame=src.frame)
	if(istype(src.transform))
		src.transform.apply(self)
	return self

/datum/icon_transformer
	var/list/transforms = null

/datum/icon_transformer/New()
	transforms = list()

/// Applies the contained set of transforms to an icon
/datum/icon_transformer/proc/apply(icon/target)
	RETURN_TYPE(/icon)
	for(var/transform in src.transforms)
		switch(transform["type"])
			if(RUSTG_ICONFORGE_BLEND_COLOR)
				target.Blend(transform["color"], transform["blend_mode"])
			if(RUSTG_ICONFORGE_BLEND_ICON)
				var/datum/universal_icon/icon_object = transform["icon"]
				if(!istype(icon_object))
					stack_trace("Invalid icon found in icon transformer during apply()! [icon_object]")
					continue
				target.Blend(icon_object.to_icon(), transform["blend_mode"])
			if(RUSTG_ICONFORGE_SCALE)
				target.Scale(transform["width"], transform["height"])
			if(RUSTG_ICONFORGE_CROP)
				target.Crop(transform["x1"], transform["y1"], transform["x2"], transform["y2"])
	return target

/datum/icon_transformer/proc/copy()
	RETURN_TYPE(/datum/icon_transformer)
	var/datum/icon_transformer/new_transformer = new()
	new_transformer.transforms = list()
	for(var/transform in src.transforms)
		new_transformer.transforms += list(deep_copy_list_alt(transform))
	return new_transformer

/datum/icon_transformer/proc/blend_color(color, blend_mode)
	#ifdef UNIT_TESTS
	if(!istext(color))
		CRASH("Invalid color provided to blend_color: [color]")
	if(!isnum(blend_mode))
		CRASH("Invalid blend_mode provided to blend_color: [blend_mode]")
	#endif
	transforms += list(list("type" = RUSTG_ICONFORGE_BLEND_COLOR, "color" = color, "blend_mode" = blend_mode))

/datum/icon_transformer/proc/blend_icon(datum/universal_icon/icon_object, blend_mode)
	#ifdef UNIT_TESTS
	// icon_object's type is checked later in to_list
	if(!isnum(blend_mode))
		CRASH("Invalid blend_mode provided to blend_icon: [blend_mode]")
	#endif
	transforms += list(list("type" = RUSTG_ICONFORGE_BLEND_ICON, "icon" = icon_object, "blend_mode" = blend_mode))

/datum/icon_transformer/proc/scale(width, height)
	#ifdef UNIT_TESTS
	if(!isnum(width) || !isnum(height))
		CRASH("Invalid arguments provided to scale: [width],[height]")
	#endif
	transforms += list(list("type" = RUSTG_ICONFORGE_SCALE, "width" = width, "height" = height))

/datum/icon_transformer/proc/crop(x1, y1, x2, y2)
	#ifdef UNIT_TESTS
	if(!isnum(x1) || !isnum(y1) || !isnum(x2) || !isnum(y2))
		CRASH("Invalid arguments provided to crop: [x1],[y1],[x2],[y2]")
	#endif
	transforms += list(list("type" = RUSTG_ICONFORGE_CROP, "x1" = x1, "y1" = y1, "x2" = x2, "y2" = y2))

/// Recursively converts all contained [/datum/universal_icon]s and their associated [/datum/icon_transformer]s into list form so the transforms can be JSON encoded.
/datum/icon_transformer/proc/to_list()
	RETURN_TYPE(/list)
	var/list/transforms_out = list()
	var/list/transforms_original = src.transforms.Copy()
	for(var/list/transform as anything in transforms_original)
		var/list/this_transform = transform.Copy() // copy it so we don't mutate the original
		if(transform["type"] == RUSTG_ICONFORGE_BLEND_ICON)
			var/datum/universal_icon/icon_object = this_transform["icon"]
			if(!istype(icon_object))
				stack_trace("Invalid icon found in icon transformer during to_list()! [icon_object]")
				continue
			// This mutates the inner transform list!!! Make sure it only runs on copies.
			this_transform["icon"] = icon_object.to_list()
		transforms_out += list(this_transform)
	return transforms_out

/// Reverse operation of /datum/icon_transformer/to_list()
/proc/icon_transformer_from_list(list/input)
	RETURN_TYPE(/datum/icon_transformer)
	var/list/transforms = list()
	for(var/list/transform as anything in input)
		// don't mutate the input :(
		var/this_transform = transform.Copy()
		if(transform["type"] == RUSTG_ICONFORGE_BLEND_ICON)
			this_transform["icon"] = universal_icon_from_list(transform["icon"])
		transforms += list(this_transform)
	var/datum/icon_transformer/transformer = new()
	transformer.transforms = transforms
	return transformer

/// Constructs a transformer, with optional color multiply pre-added.
/proc/color_transform(color=null)
	RETURN_TYPE(/datum/icon_transformer)
	var/datum/icon_transformer/transform = new()
	if(color)
		transform.blend_color(color, ICON_MULTIPLY)
	return transform

/// Converts a GAGS atom to a universal icon by generating blend operations.
/proc/gags_to_universal_icon(atom/path)
	RETURN_TYPE(/datum/universal_icon)
	if(!ispath(path, /atom) || !initial(path.greyscale_config) || !initial(path.greyscale_colors))
		CRASH("gags_to_universal_icon() received an invalid path of \"[path]\"!")
	var/datum/greyscale_config/config = initial(path.greyscale_config)
	var/colors = initial(path.greyscale_colors)
	var/datum/universal_icon/entry = SSgreyscale.GetColoredIconByTypeUniversalIcon(config, colors, path::post_init_icon_state || path::icon_state)
	return entry

/// Gets the relevant universal icon for an atom, when displayed in TGUI. (see: icon_state_preview)
/// Supports GAGS items and colored items.
/proc/get_display_icon_for(atom/atom_path)
	if (!ispath(atom_path, /atom))
		return FALSE
	var/icon_file = initial(atom_path.icon)
	var/icon_state = initial(atom_path.icon_state)
	if(initial(atom_path.greyscale_config) && initial(atom_path.greyscale_colors))
		return gags_to_universal_icon(atom_path)
	if(ispath(atom_path, /obj))
		var/obj/obj_path = atom_path
		if(initial(obj_path.icon_state_preview))
			icon_state = initial(obj_path.icon_state_preview)
	return uni_icon(icon_file, icon_state, color=initial(atom_path.color))

/// getFlatIcon for [/datum/universal_icon]s
/// Only supports 32x32 icons facing south
/// Tough luck if you want anything else
/// Still fairly slow for complex appearances due to filesystem operations. Try to avoid using it
/proc/get_flat_uni_icon(image/appearance, deficon, defstate, defblend, start = TRUE, parentcolor)
	// Loop through the underlays, then overlays, sorting them into the layers list
	#define PROCESS_OVERLAYS_OR_UNDERLAYS(flat, process, base_layer) \
		for (var/i in 1 to process.len) { \
			var/image/current = process[i]; \
			if (!current) { \
				continue; \
			} \
			if (current.plane != FLOAT_PLANE && current.plane != appearance.plane) { \
				continue; \
			} \
			var/current_layer = current.layer; \
			if (current_layer < 0) { \
				if (current_layer <= -1000) { \
					return flat; \
				} \
				current_layer = base_layer + appearance.layer + current_layer / 1000; \
			} \
			/* If we are using topdown rendering, chop that part off so things layer together as expected */ \
			if((current_layer >= TOPDOWN_LAYER && current_layer < EFFECTS_LAYER) || current_layer > TOPDOWN_LAYER + EFFECTS_LAYER) { \
				current_layer -= TOPDOWN_LAYER; \
			} \
			for (var/index_to_compare_to in 1 to layers.len) { \
				var/compare_to = layers[index_to_compare_to]; \
				if (current_layer < layers[compare_to]) { \
					layers.Insert(index_to_compare_to, current); \
					break; \
				} \
			} \
			layers[current] = current_layer; \
		}

	var/datum/universal_icon/flat = uni_icon('icons/blanks/32x32.dmi', "nothing")

	if(!appearance || appearance.alpha <= 0)
		return flat

	if(start)
		if(!deficon)
			deficon = appearance.icon
		if(!defstate)
			defstate = appearance.icon_state
		if(!defblend)
			defblend = appearance.blend_mode

	var/should_display = TRUE
	var/curicon = appearance.icon || deficon
	var/string_curicon = "[curicon]"
	var/curstate = appearance.icon_state || defstate
	// Filter out 'runtime' icons (server-generated RSC cache icons)
	// Write the icon to the filesystem so it can be used by iconforge
	if(!isfile(curicon) || string_curicon == "/icon" || string_curicon == "/image" || !length(string_curicon))
		var/file_path_tmp = "tmp/uni_icon-tmp-[rand(1, 999)].dmi" // this filename is temporary.
		fcopy(curicon, file_path_tmp)
		var/file_hash = rustg_hash_file(RUSTG_HASH_MD5, file_path_tmp)
		// Use the hash as its new filename - this allows the uni_icon to be smart cached, because the filename will be consistent between runs if the content is the same
		var/file_path = "tmp/uni_icon-[file_hash].dmi"
		fcopy(file_path_tmp, file_path)
		fdel(file_path_tmp) // delete the old one
		curicon = file(file_path)

	var/curblend = appearance.blend_mode || defblend
	var/list/curstates = icon_states(curicon)
	if(!(curstate in curstates))
		if("" in curstates) // BYOND defaulting functionality
			curstate = ""
		else
			should_display = FALSE

	if(appearance.overlays.len || appearance.underlays.len)
		// Layers will be a sorted list of icons/overlays, based on the order in which they are displayed
		var/list/layers = list()
		var/image/copy
		if(should_display)
			// Add the atom's icon itself, without pixel_x/y offsets.
			copy = image(icon=curicon, icon_state=curstate, layer=appearance.layer, dir=SOUTH)
			copy.color = appearance.color
			copy.alpha = appearance.alpha
			copy.blend_mode = curblend
			layers[copy] = appearance.layer

		PROCESS_OVERLAYS_OR_UNDERLAYS(flat, appearance.underlays, 0)
		PROCESS_OVERLAYS_OR_UNDERLAYS(flat, appearance.overlays, 1)

		var/datum/universal_icon/add // Icon of overlay being added

		if(appearance.color)
			if(islist(appearance.color))
				stack_trace("Unsupported color map appearance provided to get_flat_uni_icon, ignoring it.")
			else
				flat.blend_color(appearance.color, ICON_MULTIPLY)

		if(parentcolor && !(appearance.appearance_flags & RESET_COLOR))
			if(islist(parentcolor))
				stack_trace("Unsupported color map appearance provided to get_flat_uni_icon, ignoring it.")
			else
				flat.blend_color(parentcolor, ICON_MULTIPLY)

		var/next_parentcolor = appearance.color || parentcolor

		for(var/image/layer_image as anything in layers)
			if(layer_image.alpha == 0)
				continue

			if(layer_image == copy && length("[layer_image.icon]")) // 'layer_image' is an /image based on the object being flattened, and isn't a 'runtime' icon.
				curblend = BLEND_OVERLAY
				add = uni_icon(layer_image.icon, layer_image.icon_state, SOUTH)
				if(appearance.color)
					if(islist(appearance.color))
						stack_trace("Unsupported color map appearance provided to get_flat_uni_icon, ignoring it.")
					else
						add.blend_color(appearance.color, ICON_MULTIPLY)
			else // 'layer_image' is an appearance object.
				add = get_flat_uni_icon(layer_image, curicon, curstate, curblend, FALSE, next_parentcolor)
			if(!add || !length(add.icon_file))
				continue

			// Blend the overlay into the flattened icon
			flat.blend_icon(add, blendMode2iconMode(curblend))

		if(appearance.alpha < 255)
			flat.blend_color(rgb(255, 255, 255, appearance.alpha), ICON_MULTIPLY)

		return flat

	else if(should_display) // There's no overlays.
		var/datum/universal_icon/final_icon = uni_icon(curicon, curstate, SOUTH)

		if (appearance.alpha < 255)
			final_icon.blend_color(rgb(255,255,255, appearance.alpha), ICON_MULTIPLY)

		if (appearance.color)
			if (islist(appearance.color))
				stack_trace("Unsupported color map appearance provided to get_flat_uni_icon, ignoring it.")
			else
				final_icon.blend_color(appearance.color, ICON_MULTIPLY)

		return final_icon

	#undef PROCESS_OVERLAYS_OR_UNDERLAYS
