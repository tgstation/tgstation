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
/datum/universal_icon/New(icon/icon_file, icon_state="", dir=null, frame=null, datum/icon_transformer/transform=null, color=null)
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

/datum/universal_icon/proc/blend_icon(datum/universal_icon/icon_object, blend_mode, x=1, y=1)
	if(!transform)
		transform = new
	transform.blend_icon(icon_object, blend_mode, x, y)
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

/datum/universal_icon/proc/flip(dir)
	if(!transform)
		transform = new
	transform.flip(dir)
	return src

/datum/universal_icon/proc/rotate(angle)
	if(!transform)
		transform = new
	transform.rotate(angle)
	return src

/datum/universal_icon/proc/shift(dir, offset, wrap=0)
	if(!transform)
		transform = new
	transform.shift(dir, offset, wrap)
	return src

/datum/universal_icon/proc/swap_color(src_color, dst_color)
	if(!transform)
		transform = new
	transform.swap_color(src_color, dst_color)
	return src

/datum/universal_icon/proc/draw_box(color, x1, y1, x2=x1, y2=y1)
	if(!transform)
		transform = new
	transform.draw_box(color, x1, y1, x2, y2)
	return src

/datum/universal_icon/proc/map_colors_inferred(list/color_args)
	var/num_args = length(color_args)
	if(num_args <= 20 || num_args >= 16)
		src.map_colors_rgba(arglist(color_args))
	else if(num_args <= 12 || num_args >= 9)
		src.map_colors_rgb(arglist(color_args))
	else if(num_args == 5)
		src.map_colors_rgba_hex(arglist(color_args))
	else if(num_args == 4)
		// is there alpha in the hex?
		if(length(color_args[3]) == 7 || length(color_args[3]) == 4)
			src.map_colors_rgb_hex(arglist(color_args))
		else
			src.map_colors_rgba_hex(arglist(color_args))
	else if(num_args == 3)
		src.map_colors_rgb_hex(arglist(color_args))

/datum/universal_icon/proc/map_colors_rgba(rr, rg, rb, ra, gr, gg, gb, ga, br, bg, bb, ba, ar, ag, ab, aa, r0=0, g0=0, b0=0, a0=0)
	if(!transform)
		transform = new
	transform.map_colors(rr, rg, rb, ra, gr, gg, gb, ga, br, bg, bb, ba, ar, ag, ab, aa, r0, g0, b0, a0)
	return src

/datum/universal_icon/proc/map_colors_rgb(rr, rg, rb, gr, gg, gb, br, bg, bb, r0=0, g0=0, b0=0)
	if(!transform)
		transform = new
	transform.map_colors(rr, rg, rb, 0, gr, gg, gb, 0, br, bg, bb, 0, 0, 0, 0, 1, r0, g0, b0, 0)
	return src

/datum/universal_icon/proc/map_colors_rgb_hex(r_rgb, g_rgb, b_rgb, rgb0=rgb(0,0,0))
	if(!transform)
		transform = new
	var/rr = hex2num(copytext(r_rgb, 2, 4)) / 255
	var/rg = hex2num(copytext(r_rgb, 4, 6)) / 255
	var/rb = hex2num(copytext(r_rgb, 6, 8)) / 255

	var/gr = hex2num(copytext(g_rgb, 2, 4)) / 255
	var/gg = hex2num(copytext(g_rgb, 4, 6)) / 255
	var/gb = hex2num(copytext(g_rgb, 6, 8)) / 255

	var/br = hex2num(copytext(b_rgb, 2, 4)) / 255
	var/bg = hex2num(copytext(b_rgb, 4, 6)) / 255
	var/bb = hex2num(copytext(b_rgb, 6, 8)) / 255

	var/r0 = hex2num(copytext(rgb0, 2, 4)) / 255
	var/b0 = hex2num(copytext(rgb0, 4, 6)) / 255
	var/g0 = hex2num(copytext(rgb0, 6, 8)) / 255

	transform.map_colors(rr, rg, rb, 0, gr, gg, gb, 0, br, bg, bb, 0, 0, 0, 0, 1, r0, b0, g0, 0)
	return src

/datum/universal_icon/proc/map_colors_rgba_hex(r_rgba, g_rgba, b_rgba, a_rgba, rgba0="#00000000")
	if(!transform)
		transform = new
	var/rr = hex2num(copytext(r_rgba, 2, 4)) / 255
	var/rg = hex2num(copytext(r_rgba, 4, 6)) / 255
	var/rb = hex2num(copytext(r_rgba, 6, 8)) / 255
	var/ra = hex2num(copytext(r_rgba, 8, 10)) / 255

	var/gr = hex2num(copytext(g_rgba, 2, 4)) / 255
	var/gg = hex2num(copytext(g_rgba, 4, 6)) / 255
	var/gb = hex2num(copytext(g_rgba, 6, 8)) / 255
	var/ga = hex2num(copytext(g_rgba, 8, 10)) / 255

	var/br = hex2num(copytext(b_rgba, 2, 4)) / 255
	var/bg = hex2num(copytext(b_rgba, 4, 6)) / 255
	var/bb = hex2num(copytext(b_rgba, 6, 8)) / 255
	var/ba = hex2num(copytext(b_rgba, 8, 10)) / 255

	var/ar = hex2num(copytext(a_rgba, 2, 4)) / 255
	var/ag = hex2num(copytext(a_rgba, 4, 6)) / 255
	var/ab = hex2num(copytext(a_rgba, 6, 8)) / 255
	var/aa = hex2num(copytext(a_rgba, 8, 10)) / 255

	var/r0 = hex2num(copytext(rgba0, 2, 4)) / 255
	var/b0 = hex2num(copytext(rgba0, 4, 6)) / 255
	var/g0 = hex2num(copytext(rgba0, 6, 8)) / 255
	var/a0 = hex2num(copytext(rgba0, 8, 10)) / 255

	transform.map_colors(rr, rg, rb, ra, gr, gg, gb, ga, br, bg, bb, ba, ar, ag, ab, aa, r0, b0, g0, a0)
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
				target.Blend(icon_object.to_icon(), transform["blend_mode"], transform["x"], transform["y"])
			if(RUSTG_ICONFORGE_SCALE)
				target.Scale(transform["width"], transform["height"])
			if(RUSTG_ICONFORGE_CROP)
				target.Crop(transform["x1"], transform["y1"], transform["x2"], transform["y2"])
			if(RUSTG_ICONFORGE_MAP_COLORS)
				target.MapColors(
					transform["rr"], transform["rg"], transform["rb"], transform["ra"],
					transform["gr"], transform["gg"], transform["gb"], transform["ga"],
					transform["br"], transform["bg"], transform["bb"], transform["ba"],
					transform["ar"], transform["ag"], transform["ab"], transform["aa"],
					transform["r0"], transform["g0"], transform["b0"], transform["a0"],
				)
			if(RUSTG_ICONFORGE_FLIP)
				target.Flip(transform["dir"])
			if(RUSTG_ICONFORGE_TURN)
				target.Turn(transform["angle"])
			if(RUSTG_ICONFORGE_SHIFT)
				target.Shift(transform["dir"], transform["offset"], transform["wrap"])
			if(RUSTG_ICONFORGE_SWAP_COLOR)
				target.SwapColor(transform["src_color"], transform["dst_color"])
			if(RUSTG_ICONFORGE_DRAW_BOX)
				target.DrawBox(transform["color"], transform["x1"], transform["y1"], transform["x2"], transform["y2"])
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

/datum/icon_transformer/proc/blend_icon(datum/universal_icon/icon_object, blend_mode, x=1, y=1)
	#ifdef UNIT_TESTS
	// icon_object's type is checked later in to_list
	if(!isnum(blend_mode))
		CRASH("Invalid blend_mode provided to blend_icon: [blend_mode]")
	if(!isnum(x))
		CRASH("Invalid x offset provided to blend_icon: [x]")
	if(!isnum(y))
		CRASH("Invalid y offset provided to blend_icon: [y]")
	#endif
	transforms += list(list("type" = RUSTG_ICONFORGE_BLEND_ICON, "icon" = icon_object, "blend_mode" = blend_mode, "x" = x, "y" = y))

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

/datum/icon_transformer/proc/flip(dir)
	#ifdef UNIT_TESTS
	if(!isnum(dir))
		CRASH("Invalid arguments provided to flip: [dir]")
	#endif
	transforms += list(list("type" = RUSTG_ICONFORGE_FLIP, "dir" = dir))

/datum/icon_transformer/proc/rotate(angle)
	#ifdef UNIT_TESTS
	if(!isnum(angle))
		CRASH("Invalid arguments provided to rotate: [angle]")
	#endif
	transforms += list(list("type" = RUSTG_ICONFORGE_TURN, "angle" = angle))

/datum/icon_transformer/proc/shift(dir, offset, wrap=FALSE)
	#ifdef UNIT_TESTS
	if(!isnum(dir) || !isnum(offset) || (wrap != FALSE && wrap != TRUE))
		CRASH("Invalid arguments provided to shift: [dir],[offset],[wrap]")
	#endif
	transforms += list(list("type" = RUSTG_ICONFORGE_SHIFT, "dir" = dir, "offset" = offset, "wrap" = wrap))

/datum/icon_transformer/proc/swap_color(src_color, dst_color)
	#ifdef UNIT_TESTS
	if(!istext(src_color) || !istext(dst_color))
		CRASH("Invalid arguments provided to swap_color: [src_color],[dst_color]")
	#endif
	transforms += list(list("type" = RUSTG_ICONFORGE_SWAP_COLOR, "src_color" = src_color, "dst_color" = dst_color))

/datum/icon_transformer/proc/draw_box(color, x1, y1, x2=x1, y2=y1)
	#ifdef UNIT_TESTS
	if(!istext(color) || !isnum(x1) || !isnum(y1) || !isnum(x2) || !isnum(y2))
		CRASH("Invalid arguments provided to draw_box: [color],[x1],[y1],[x2],[y2]")
	#endif
	transforms += list(list("type" = RUSTG_ICONFORGE_DRAW_BOX, "color" = color, "x1" = x1, "y1" = y1, "x2" = x2, "y2" = y2))

/datum/icon_transformer/proc/map_colors(rr, rg, rb, ra, gr, gg, gb, ga, br, bg, bb, ba, ar, ag, ab, aa, r0=0, g0=0, b0=0, a0=0)
	transforms += list(list(
		"type" = RUSTG_ICONFORGE_MAP_COLORS,
		"rr" = rr, "rg" = rg, "rb" = rb, "ra" = ra,
		"gr" = gr, "gg" = gg, "gb" = gb, "ga" = ga,
		"br" = br, "bg" = bg, "bb" = bb, "ba" = ba,
		"ar" = ar, "ag" = ag, "ab" = ab, "aa" = aa,
		"r0" = r0, "g0" = g0, "b0" = b0, "a0" = a0,
	))

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
	var/icon_file = atom_path::icon
	var/icon_state = atom_path::icon_state
	if(atom_path::greyscale_config && atom_path::greyscale_colors)
		return gags_to_universal_icon(atom_path)
	if(ispath(atom_path, /obj))
		var/obj/obj_path = atom_path
		if(obj_path::icon_state_preview)
			icon_state = obj_path::icon_state_preview
	return uni_icon(icon_file, icon_state, color=atom_path::color)

/// getFlatIcon for [/datum/universal_icon]s
/// Still fairly slow for complex appearances due to filesystem operations. Try to avoid using it
/proc/get_flat_uni_icon(image/appearance, defdir, deficon, defstate, defblend, start = TRUE, parentcolor)
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
	if(!isfile(curicon) || !length(string_curicon))
		var/file_path_tmp = "tmp/uni_icon-tmp-[rand(1, 999)].dmi" // this filename is temporary.
		fcopy(curicon, file_path_tmp)
		var/file_hash = rustg_hash_file(RUSTG_HASH_MD5, file_path_tmp)
		// Use the hash as its new filename - this allows the uni_icon to be smart cached, because the filename will be consistent between runs if the content is the same
		var/file_path = "tmp/uni_icon-[file_hash].dmi"
		fcopy(file_path_tmp, file_path)
		fdel(file_path_tmp) // delete the old one
		curicon = file(file_path)

	if(!icon_exists(curicon, curstate))
		if("" in icon_states_fast(curicon)) // BYOND defaulting functionality
			curstate = ""
		else
			should_display = FALSE

	var/curdir = (!appearance.dir || appearance.dir == SOUTH) ? defdir : appearance.dir
	var/base_icon_dir //We'll use this to get the icon state to display if not null BUT NOT pass it to overlays as the dir we have

	if(should_display)
		//Determines if there're directionals.
		if (curdir != SOUTH)
			// icon states either have 1, 4 or 8 dirs. We only have to check
			// one of NORTH, EAST or WEST to know that this isn't a 1-dir icon_state since they just have SOUTH.
			var/list/metadata = icon_metadata(curicon)
			if(islist(metadata))
				for(var/list/state_data as anything in metadata["states"])
					var/name = state_data["name"]
					if(name != curstate)
						continue
					var/dir_count = state_data["dirs"]
					if(dir_count == 1)
						base_icon_dir = SOUTH
			else if(!length(icon_states(icon(curicon, curstate, NORTH))))
				base_icon_dir = SOUTH

		var/list/icon_dimensions = get_icon_dimensions(curicon)
		var/icon_width = icon_dimensions["width"]
		var/icon_height = icon_dimensions["height"]
		if(icon_width != 32 || icon_height != 32)
			flat.scale(icon_width, icon_height)

	if(!base_icon_dir)
		base_icon_dir = curdir

	var/curblend = appearance.blend_mode || defblend


	if(appearance.overlays.len || appearance.underlays.len)
		// Layers will be a sorted list of icons/overlays, based on the order in which they are displayed
		var/list/layers = list()
		var/image/copy
		if(should_display)
			// Add the atom's icon itself, without pixel_x/y offsets.
			copy = image(icon=curicon, icon_state=curstate, layer=appearance.layer, dir=base_icon_dir)
			copy.color = appearance.color
			copy.alpha = appearance.alpha
			copy.blend_mode = curblend
			layers[copy] = appearance.layer

		PROCESS_OVERLAYS_OR_UNDERLAYS(flat, appearance.underlays, 0)
		PROCESS_OVERLAYS_OR_UNDERLAYS(flat, appearance.overlays, 1)

		var/datum/universal_icon/add // Icon of overlay being added

		var/list/flat_dimensions = get_icon_dimensions(flat)
		var/flatX1 = 1
		var/flatX2 = flat_dimensions["width"]
		var/flatY1 = 1
		var/flatY2 = flat_dimensions["height"]

		var/addX1 = 0
		var/addX2 = 0
		var/addY1 = 0
		var/addY2 = 0

		if(appearance.color)
			if(islist(appearance.color))
				flat.map_colors_inferred(appearance.color)
			else
				flat.blend_color(appearance.color, ICON_MULTIPLY)

		if(parentcolor && !(appearance.appearance_flags & RESET_COLOR))
			if(islist(parentcolor))
				flat.map_colors_inferred(parentcolor)
			else
				flat.blend_color(parentcolor, ICON_MULTIPLY)

		var/next_parentcolor = appearance.color || parentcolor

		for(var/image/layer_image as anything in layers)
			if(layer_image.alpha == 0)
				continue

			if(layer_image == copy && length("[layer_image.icon]")) // 'layer_image' is an /image based on the object being flattened, and isn't a 'runtime' icon.
				curblend = BLEND_OVERLAY
				add = uni_icon(layer_image.icon, layer_image.icon_state, base_icon_dir)
				if(appearance.color)
					if(islist(appearance.color))
						add.map_colors_inferred(appearance.color)
					else
						add.blend_color(appearance.color, ICON_MULTIPLY)
			else // 'layer_image' is an appearance object.
				add = get_flat_uni_icon(layer_image, curdir, curicon, curstate, curblend, FALSE, next_parentcolor)
			if(!add || !length(add.icon_file))
				continue

			// Find the new dimensions of the flat icon to fit the added overlay
			var/list/add_dimensions = get_icon_dimensions(add)
			addX1 = min(flatX1, layer_image.pixel_x + layer_image.pixel_w + 1)
			addX2 = max(flatX2, layer_image.pixel_x + layer_image.pixel_w + add_dimensions["width"]) // assuming 32x32
			addY1 = min(flatY1, layer_image.pixel_y + layer_image.pixel_z + 1)
			addY2 = max(flatY2, layer_image.pixel_y + layer_image.pixel_z + add_dimensions["height"])

			if (
				addX1 != flatX1 \
				&& addX2 != flatX2 \
				&& addY1 != flatY1 \
				&& addY2 != flatY2 \
			)
				// Resize the flattened icon so the new icon fits
				flat.crop(
					addX1 - flatX1 + 1,
					addY1 - flatY1 + 1,
					addX2 - flatX1 + 1,
					addY2 - flatY1 + 1
				)

				flatX1 = addX1
				flatX2 = addY1
				flatY1 = addX2
				flatY2 = addY2

			// Blend the overlay into the flattened icon
			flat.blend_icon(add, blendMode2iconMode(curblend), layer_image.pixel_x + layer_image.pixel_w + 2 - flatX1, layer_image.pixel_y + layer_image.pixel_z + 2 - flatY1)

		if(appearance.alpha < 255)
			flat.blend_color(rgb(255, 255, 255, appearance.alpha), ICON_MULTIPLY)

		return flat

	else if(should_display) // There's no overlays.
		var/datum/universal_icon/final_icon = uni_icon(curicon, curstate, base_icon_dir)

		if (appearance.alpha < 255)
			final_icon.blend_color(rgb(255,255,255, appearance.alpha), ICON_MULTIPLY)

		if (appearance.color)
			if (islist(appearance.color))
				final_icon.map_colors_inferred(appearance.color)
			else
				final_icon.blend_color(appearance.color, ICON_MULTIPLY)

		return final_icon

	#undef PROCESS_OVERLAYS_OR_UNDERLAYS
