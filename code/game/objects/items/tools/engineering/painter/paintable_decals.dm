/**
 * ## Paintable Decal Category
 *
 * Holds a bunch of information the decal painter uses to determine what it can and can't paint, and how to paint it.
 */
/datum/paintable_decal_category
	/// Human readable category name
	var/category = "Generic"
	/// The type of paintable decal this category contains - should be a subtype of /datum/paintable_decal
	var/paintable_decal_type
	/// Color options for this category - formatted as readable label - color value
	var/list/possible_colors
	/// Direction options for this category - formatted as readable label - dir value to return
	var/list/dir_list = list(
		"North" = NORTH,
		"South" = SOUTH,
		"East" = EAST,
		"West" = WEST,
	)
	/// Alpha for decals painted from this category (assuming no custom color is used)
	var/default_alpha = 255

	/// Icon used for previews
	var/preview_floor_icon = 'icons/turf/floors.dmi'
	/// Icon state used for previews
	var/preview_floor_state = "floor"

	/// Caches UI data to avoid regenerating it every time. It doesn't change anyways
	VAR_PRIVATE/list/cached_category_data

/// Returns a key for the spritesheet icon, used to avoid duplicates
/datum/paintable_decal_category/proc/spritesheet_key(dir, state, color)
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)

	return "[state]_[dir]_[replacetext(color, "#", "")]"

/// Returns a list of preview icons for every single variety of every decal in this category for use in a spritesheet
/datum/paintable_decal_category/proc/generate_all_spritesheet_icons()
	SHOULD_NOT_OVERRIDE(TRUE)

	. = list()
	for(var/datum/paintable_decal/decal_type as anything in subtypesof(paintable_decal_type))
		var/state = decal_type::icon_state
		if(!state)
			continue
		if(decal_type::directional)
			for(var/dirname in dir_list)
				. += generate_independent_decal_spritesheet_icons(dir_list[dirname], state)
		else
			. += generate_independent_decal_spritesheet_icons(SOUTH, state)

/// Returns a list of preview icon for a specific decal state and direction
/datum/paintable_decal_category/proc/generate_independent_decal_spritesheet_icons(dir, state)
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)

	. = list()
	for(var/colorname in possible_colors)
		.[spritesheet_key(dir, state, possible_colors[colorname])] = generate_colored_decal_spritesheet_icon(state, dir, possible_colors[colorname])

/// Actually generates the preview icon for a specific decal state, direction, and color
/datum/paintable_decal_category/proc/generate_colored_decal_spritesheet_icon(state, dir, color)
	PROTECTED_PROC(TRUE)

	var/list/decal_data = get_decal_info(state, color, dir)
	var/datum/universal_icon/colored_decal = uni_icon('icons/turf/decals.dmi', decal_data[DECAL_INFO_ICON_STATE], dir = decal_data[DECAL_INFO_DIR])
	colored_decal.change_opacity(decal_data[DECAL_INFO_ALPHA] / 255)
	if(color == "custom")
		// Do a fun rainbow pattern to stand out while still being static.
		colored_decal.blend_icon(uni_icon('icons/effects/random_spawners.dmi', "rainbow"), ICON_MULTIPLY)
	else if(decal_data[DECAL_INFO_COLOR])
		colored_decal.blend_color(decal_data[DECAL_INFO_COLOR], ICON_MULTIPLY)

	var/datum/universal_icon/floor = uni_icon(preview_floor_icon, preview_floor_state)
	floor.blend_icon(colored_decal, ICON_OVERLAY)
	return floor

/// Constructs and returns this category's UI data
/datum/paintable_decal_category/proc/get_ui_data() as /list
	SHOULD_NOT_OVERRIDE(TRUE)

	if(cached_category_data)
		return cached_category_data.Copy()

	cached_category_data = list()

	cached_category_data["decal_list"] = list()
	cached_category_data["color_list"] = list()
	cached_category_data["dir_list"] = list()

	for(var/datum/paintable_decal/decal_type as anything in subtypesof(paintable_decal_type))
		var/name = decal_type::name
		var/state = decal_type::icon_state
		if(!name || !state)
			continue

		cached_category_data["decal_list"] += list(list(
			"name" = name,
			"icon_state" = state,
			"directional" = decal_type::directional,
		))

	for(var/color in possible_colors)
		cached_category_data["color_list"] += list(list(
			"name" = color,
			"color" = possible_colors[color],
		))

	for(var/dirname in dir_list)
		cached_category_data["dir_list"] += list(list(
			"name" = dirname,
			"dir" = dir_list[dirname],
		))

	return cached_category_data.Copy()

/// Checks if the passed icon state is one of this category's decals
/datum/paintable_decal_category/proc/is_state_valid(state)
	SHOULD_NOT_OVERRIDE(TRUE)
	// Ui data has all icon states so let's just piggyback off of that
	for(var/list/decal_data as anything in get_ui_data()["decal_list"])
		if(decal_data["icon_state"] == state)
			return TRUE
	return FALSE

/// Checks if the passed direction is one of this category's directions
/datum/paintable_decal_category/proc/is_dir_valid(dir)
	SHOULD_NOT_OVERRIDE(TRUE)
	for(var/dirname in dir_list)
		if(dir_list[dirname] == dir)
			return TRUE
	return FALSE

/// Checks if the passed color is one of this category's colors
/datum/paintable_decal_category/proc/is_color_valid(color)
	SHOULD_NOT_OVERRIDE(TRUE)
	for(var/colorname in possible_colors)
		if(possible_colors[colorname] == color)
			return TRUE
	return FALSE

/**
 * Used by the decal painter to modify the state of the decal based on the... state.
 */
/datum/paintable_decal_category/proc/get_decal_info(state, color, dir)
	// Special case for 8-dir sprites. Rather than add support for both 4-dir and 8-dir,
	// 8-dir are affixed with "__8" at the end of the icon state. Then we handle it in this proc.
	if(copytext(state, -3) == "__8")
		state = splicetext(state, -3, 0, "")
		dir = turn(dir, 45)

	var/static/regex/rgba_regex = new(@"(#[0-9a-fA-F]{6})([0-9a-fA-F]{2})")
	var/alpha = default_alpha
	// Special case for RGBA colors
	if(rgba_regex.Find(color))
		color = rgba_regex.group[1]
		alpha = text2num(rgba_regex.group[2], 16)

	return list(
		"[DECAL_INFO_ICON_STATE]" = state,
		"[DECAL_INFO_DIR]" = dir,
		"[DECAL_INFO_COLOR]" = color,
		"[DECAL_INFO_ALPHA]" = alpha,
	)

// Basic tile decals
/datum/paintable_decal_category/tile
	paintable_decal_type = /datum/paintable_decal/tile
	category = "Tiles"
	default_alpha = /obj/effect/turf_decal/tile::alpha
	possible_colors = list(
		"Neutral" = "#d4d4d432", // very lazy way to do transparent decal, should be remade in future
		"White" = "#FFFFFF",
		"Dark" = /obj/effect/turf_decal/tile/dark::color,
		"Bar Burgundy" = /obj/effect/turf_decal/tile/bar::color,
		"Cargo Brown" = /obj/effect/turf_decal/tile/brown::color,
		"Dark Blue" = /obj/effect/turf_decal/tile/dark_blue::color,
		"Dark Green" = /obj/effect/turf_decal/tile/dark_green::color,
		"Dark Red" = /obj/effect/turf_decal/tile/dark_red::color,
		"Engi Yellow" = /obj/effect/turf_decal/tile/yellow::color,
		"Med Blue" = /obj/effect/turf_decal/tile/blue::color,
		"R&D Purple" = /obj/effect/turf_decal/tile/purple::color,
		"Sec Red" = /obj/effect/turf_decal/tile/red::color,
		"Service Green" = /obj/effect/turf_decal/tile/green::color,
		"Custom" = "custom",
	)

// Tile trimlines
/datum/paintable_decal_category/tile/trimline
	category = "Trimlines"
	paintable_decal_type = /datum/paintable_decal/trimline

// Generic warning stripes
/datum/paintable_decal_category/warning
	paintable_decal_type = /datum/paintable_decal/warning
	category = "Warning Stripes"
	possible_colors = list(
		"Yellow" = "yellow",
		"Red" = "red",
		"White" = "white",
	)

/datum/paintable_decal_category/warning/generate_colored_decal_spritesheet_icon(state, dir, color)
	var/list/decal_data = get_decal_info(state, color, dir)
	var/datum/universal_icon/floor = uni_icon(preview_floor_icon, preview_floor_state)
	var/datum/universal_icon/decal = uni_icon('icons/turf/decals.dmi', decal_data[DECAL_INFO_ICON_STATE], dir = decal_data[DECAL_INFO_DIR])
	floor.blend_icon(decal, ICON_OVERLAY)
	return floor

/datum/paintable_decal_category/warning/get_decal_info(state, color, dir)
	// Special case. Default warning stripes are yellow, so don't append anything if passed yellow
	if(color == "yellow")
		color = ""

	return list(
		"[DECAL_INFO_ICON_STATE]" = "[state][color ? "_" : ""][color]",
		"[DECAL_INFO_DIR]" = dir,
		"[DECAL_INFO_COLOR]" = color,
		"[DECAL_INFO_ALPHA]" = default_alpha,
	)

// Plain colored siding
/datum/paintable_decal_category/siding
	paintable_decal_type = /datum/paintable_decal/colored_siding
	category = "Colored Sidings"
	possible_colors = list(
		"Dim White" = /obj/effect/turf_decal/siding/white::color,
		"White" = "#FFFFFF",
		"Black" = /obj/effect/turf_decal/siding/dark::color,
		"Cargo Brown" = /obj/effect/turf_decal/siding/brown::color,
		"Dark Blue" = /obj/effect/turf_decal/siding/dark_blue::color,
		"Dark Green" = /obj/effect/turf_decal/siding/dark_green::color,
		"Dark Red" = /obj/effect/turf_decal/siding/dark_red::color,
		"Engi Yellow" = /obj/effect/turf_decal/siding/yellow::color,
		"Med Blue" = /obj/effect/turf_decal/siding/blue::color,
		"R&D Purple" = /obj/effect/turf_decal/siding/purple::color,
		"Sec Red" = /obj/effect/turf_decal/siding/red::color,
		"Service Green" = /obj/effect/turf_decal/siding/green::color,
		"Custom" = "custom",
	)

// Sidings which are not colored / have a specific pattern, texture, etc
/datum/paintable_decal_category/normal_siding
	paintable_decal_type = /datum/paintable_decal/siding
	category = "Normal Sidings"
	possible_colors = list(
		"Default" = /obj/effect/turf_decal/siding/wood::color,
	)

// Plating sidings and all color variations
/datum/paintable_decal_category/plating
	paintable_decal_type = /datum/paintable_decal/plating
	category = "Plating Sidings"
	possible_colors = list(
		"Default" = "#949494",
		"White" = "#FFFFFF",
		"Terracotta" = "#b84221",
		"Dark" = "#36373a",
		"Light" = "#e2e2e2",
	)

/// Global list of all paintable decal categories singletons
GLOBAL_LIST_INIT(paintable_decals, init_subtypes(/datum/paintable_decal_category))

// Spritesheet used by the decal painter
/datum/asset/spritesheet_batched/decals
	name = "paintable_decals"
	ignore_dir_errors = TRUE

/datum/asset/spritesheet_batched/decals/create_spritesheets()
	for(var/datum/paintable_decal_category/category as anything in GLOB.paintable_decals)
		var/list/generated_icons = category.generate_all_spritesheet_icons()
		for(var/sprite_key in generated_icons)
			insert_icon(sprite_key, generated_icons[sprite_key])

/**
 * ## Paintable Decal
 *
 * Basically just holds a bunch of info pertaining to each decal for the decal painter to use.
 */
/datum/paintable_decal
	/// Human readable name of the decal
	var/name
	/// Icon state of the decal in decals.dmi
	var/icon_state
	/// If TRUE, the decal's sprite changes depending on its dir
	var/directional = TRUE

// Basic tile decals
/datum/paintable_decal/tile

/datum/paintable_decal/tile/four_corners
	name = "4 Corners"
	icon_state = "tile_fourcorners"
	directional = FALSE

/datum/paintable_decal/tile/full
	name = "Full Tile"
	icon_state = "tile_full"
	directional = FALSE

/datum/paintable_decal/tile/corner
	name = "Corner"
	icon_state = "tile_corner"

/datum/paintable_decal/tile/half
	name = "Half"
	icon_state = "tile_half_contrasted"

/datum/paintable_decal/tile/half_full
	name = "Full Half"
	icon_state = "tile_half"

/datum/paintable_decal/tile/opposing_corners
	name = "Opposing Corners"
	icon_state = "tile_opposing_corners"

/datum/paintable_decal/tile/anticorner
	name = "3 Corners"
	icon_state = "tile_anticorner_contrasted"

/datum/paintable_decal/tile/tram
	name = "Tram"
	icon_state = "tile_tram"

/datum/paintable_decal/tile/diagonal_centre
	name = "Diagonal Centre"
	icon_state = "diagonal_centre"
	directional = FALSE

/datum/paintable_decal/tile/diagonal_edge
	name = "Diagonal Edge"
	icon_state = "diagonal_edge"
	directional = FALSE

// Tile trimlines
/datum/paintable_decal/trimline

/datum/paintable_decal/trimline/filled_box
	name = "Trimline Filled Box"
	icon_state = "trimline_box_fill"
	directional = FALSE

/datum/paintable_decal/trimline/filled_corner
	name = "Trimline Filled Corner"
	icon_state = "trimline_corner_fill"

/datum/paintable_decal/trimline/filled
	name = "Trimline Filled"
	icon_state = "trimline_fill"

/datum/paintable_decal/trimline/filled_l
	name = "Trimline Filled L"
	icon_state = "trimline_fill__8" // 8 dir sprite

/datum/paintable_decal/trimline/filled_end
	name = "Trimline Filled End"
	icon_state = "trimline_end_fill"

/datum/paintable_decal/trimline/box
	name = "Trimline Box"
	icon_state = "trimline_box"
	directional = FALSE

/datum/paintable_decal/trimline/corner
	name = "Trimline Corner"
	icon_state = "trimline_corner"

/datum/paintable_decal/trimline/circle
	name = "Trimline Circle"
	icon_state = "trimline"

/datum/paintable_decal/trimline/l
	name = "Trimline L"
	icon_state = "trimline__8" // 8 dir sprite

/datum/paintable_decal/trimline/end
	name = "Trimline End"
	icon_state = "trimline_end"

/datum/paintable_decal/trimline/connector_l
	name = "Trimline Connector L"
	icon_state = "trimline_shrink_cw"

/datum/paintable_decal/trimline/connector_r
	name = "Trimline Connector R"
	icon_state = "trimline_shrink_ccw"

/datum/paintable_decal/trimline/arrow_l_filled
	name = "Trimline Arrow L Filled"
	icon_state = "trimline_arrow_cw_fill"

/datum/paintable_decal/trimline/arrow_r_filled
	name = "Trimline Arrow R Filled"
	icon_state = "trimline_arrow_ccw_fill"

/datum/paintable_decal/trimline/warn_filled
	name = "Trimline Warn Filled"
	icon_state = "trimline_warn_fill"

/datum/paintable_decal/trimline/warn_filled_l
	name = "Trimline Warn Filled L"
	icon_state = "trimline_warn_fill__8" // 8 dir sprite

/datum/paintable_decal/trimline/warn_filled_corner
	name = "Trimline Warn Filled Corner"
	icon_state = "trimline_corner_warn_fill"

/datum/paintable_decal/trimline/warn
	name = "Trimline Warn"
	icon_state = "trimline_warn"

/datum/paintable_decal/trimline/warn_l
	name = "Trimline Warn L"
	icon_state = "trimline_warn__8" // 8 dir sprite

/datum/paintable_decal/trimline/arrow_l
	name = "Trimline Arrow L"
	icon_state = "trimline_arrow_cw"

/datum/paintable_decal/trimline/arrow_r
	name = "Trimline Arrow R"
	icon_state = "trimline_arrow_ccw"

/datum/paintable_decal/trimline/mid_joiner
	name = "Trimline Mid Joiner"
	icon_state = "trimline_mid"

/datum/paintable_decal/trimline/mid_joiner_filled
	name = "Trimline Mid Joiner Filled"
	icon_state = "trimline_mid_fill"

/datum/paintable_decal/trimline/tram
	name = "Trimline Tram"
	icon_state = "trimline_tram"

// Generic warning decals of each color
/datum/paintable_decal/warning

/datum/paintable_decal/warning/line
	name = "Warning Line"
	icon_state = "warningline"

/datum/paintable_decal/warning/line_corner
	name = "Warning Line Corner"
	icon_state = "warninglinecorner"

/datum/paintable_decal/warning/caution
	name = "Caution Label"
	icon_state = "caution"

/datum/paintable_decal/warning/arrows
	name = "Directional Arrows"
	icon_state = "arrows"

/datum/paintable_decal/warning/stand_clear
	name = "Stand Clear Label"
	icon_state = "stand_clear"

/datum/paintable_decal/warning/bot
	name = "Bot"
	icon_state = "bot"
	directional = FALSE

/datum/paintable_decal/warning/loading
	name = "Loading Zone"
	icon_state = "loadingarea"

/datum/paintable_decal/warning/box
	name = "Box"
	icon_state = "box"
	directional = FALSE

/datum/paintable_decal/warning/box_corners
	name = "Box Corner"
	icon_state = "box_corners"

/datum/paintable_decal/warning/delivery
	name = "Delivery Marker"
	icon_state = "delivery"
	directional = FALSE

/datum/paintable_decal/warning/warn_full
	name = "Warning Box"
	icon_state = "warn_full"
	directional = FALSE

// Plain colored siding
/datum/paintable_decal/colored_siding

/datum/paintable_decal/colored_siding/line
	name = "Siding"
	icon_state = "siding_plain"

/datum/paintable_decal/colored_siding/line_corner
	name = "Siding Corner"
	icon_state = "siding_plain_corner"

/datum/paintable_decal/colored_siding/line_end
	name = "Siding End"
	icon_state = "siding_plain_end"

/datum/paintable_decal/colored_siding/line_inner_corner
	name = "Siding Inner Corner"
	icon_state = "siding_plain_corner_inner"

// Sidings which are not colored / have a specific pattern, texture, etc
/datum/paintable_decal/siding

/datum/paintable_decal/siding/wood

/datum/paintable_decal/siding/wood/line
	name = "Wood Siding"
	icon_state = "siding_wood"

/datum/paintable_decal/siding/wood/line_corner
	name = "Wood Siding Corner"
	icon_state = "siding_wood_corner"

/datum/paintable_decal/siding/wood/line_end
	name = "Wood Siding End"
	icon_state = "siding_wood_end"

/datum/paintable_decal/siding/wood/line_inner_corner
	name = "Wood Siding Inner Corner"
	icon_state = "siding_wood__8" // 8 dir sprite

// Thin plating sidings and all color variations
/datum/paintable_decal/plating/thinplating

/datum/paintable_decal/plating/thinplating/line
	name = "Thin Plating Siding"
	icon_state = "siding_thinplating"

/datum/paintable_decal/plating/thinplating/line_corner
	name = "Thin Plating Siding Corner"
	icon_state = "siding_thinplating_corner"

/datum/paintable_decal/plating/thinplating/line_end
	name = "Thin Plating Siding End"
	icon_state = "siding_thinplating_end"

/datum/paintable_decal/plating/thinplating/line_inner_corner
	name = "Thin Plating Siding Inner Corner"
	icon_state = "siding_thinplating__8" // 8 dir sprite

// Alt / new thin plating sidings and all color variations
/datum/paintable_decal/plating/thinplatingalt

/datum/paintable_decal/plating/thinplatingalt/line
	name = "Thin Plating Alt Siding"
	icon_state = "siding_thinplating_new"

/datum/paintable_decal/plating/thinplatingalt/line_corner
	name = "Thin Plating Alt Siding Corner"
	icon_state = "siding_thinplating_new_corner"

/datum/paintable_decal/plating/thinplatingalt/line_end
	name = "Thin Plating Alt Siding End"
	icon_state = "siding_thinplating_new_end"

/datum/paintable_decal/plating/thinplatingalt/line_inner_corner
	name = "Thin Plating Alt Siding Inner Corner"
	icon_state = "siding_thinplating_new__8" // 8 dir sprite

// Wide plating sidings and all color variations
/datum/paintable_decal/plating/wideplating

/datum/paintable_decal/plating/wideplating/line
	name = "Wide Plating Siding"
	icon_state = "siding_wideplating"

/datum/paintable_decal/plating/wideplating/line_corner
	name = "Wide Plating Siding Corner"
	icon_state = "siding_wideplating_corner"

/datum/paintable_decal/plating/wideplating/line_end
	name = "Wide Plating Siding End"
	icon_state = "siding_wideplating_end"

/datum/paintable_decal/plating/wideplating/line_inner_corner
	name = "Wide Plating Siding Inner Corner"
	icon_state = "siding_wideplating__8"  // 8 dir sprite

// Alt / new wide plating sidings and all color variations
/datum/paintable_decal/plating/wideplatingalt

/datum/paintable_decal/plating/wideplatingalt/line
	name = "Wide Plating Alt Siding"
	icon_state = "siding_wideplating_new"

/datum/paintable_decal/plating/wideplatingalt/line_corner
	name = "Wide Plating Alt Siding Corner"
	icon_state = "siding_wideplating_new_corner"

/datum/paintable_decal/plating/wideplatingalt/line_end
	name = "Wide Plating Alt Siding End"
	icon_state = "siding_wideplating_new_end"

/datum/paintable_decal/plating/wideplatingalt/line_inner_corner
	name = "Wide Plating Alt Siding Inner Corner"
	icon_state = "siding_wideplating_new__8" // 8 dir sprite
