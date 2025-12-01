/obj/effect/turf_decal/tile
	name = "tile decal"
	icon_state = "tile_corner"
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110
	use_holiday_colors = TRUE

/obj/effect/turf_decal/tile/neutral/tram
	pattern = PATTERN_VERTICAL_STRIPE

/// Automatically generates all subtypes for a decal with the given path.
#define TILE_DECAL_SUBTYPE_HELPER(path)\
##path/opposingcorners {\
	icon_state = "tile_opposing_corners";\
}\
##path/half {\
	icon_state = "tile_half";\
}\
##path/half/contrasted {\
	icon_state = "tile_half_contrasted";\
}\
##path/anticorner {\
	icon_state = "tile_anticorner";\
}\
##path/anticorner/contrasted {\
	icon_state = "tile_anticorner_contrasted";\
}\
##path/fourcorners {\
	icon_state = "tile_fourcorners";\
}\
##path/full {\
	icon_state = "tile_full";\
}\
##path/diagonal_centre {\
	icon_state = "diagonal_centre";\
}\
##path/diagonal_edge {\
	icon_state = "diagonal_edge";\
}\
##path/tram {\
	icon_state = "tile_tram";\
}

/// Blue tiles
/obj/effect/turf_decal/tile/blue
	name = "blue tile decal"
	color = "#52B4E9"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/blue)

/// Dark blue tiles
/obj/effect/turf_decal/tile/dark_blue
	name = "dark blue tile decal"
	color = "#486091"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark_blue)

/// Green tiles

/obj/effect/turf_decal/tile/green
	name = "green tile decal"
	color = "#9FED58"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/green)

/// Dark green tiles

/obj/effect/turf_decal/tile/dark_green
	name = "dark green tile decal"
	color = "#439C1E"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark_green)

/// Yellow tiles

/obj/effect/turf_decal/tile/yellow
	name = "yellow tile decal"
	color = "#EFB341"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/yellow)

/// Red tiles

/obj/effect/turf_decal/tile/red
	name = "red tile decal"
	color = "#DE3A3A"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/red)

/// Dark red tiles

/obj/effect/turf_decal/tile/dark_red
	name = "dark red tile decal"
	color = "#B11111"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark_red)

/// Bar tiles

/obj/effect/turf_decal/tile/bar
	name = "bar tile decal"
	color = "#791500"
	alpha = 130

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/bar)

/// Purple tiles

/obj/effect/turf_decal/tile/purple
	name = "purple tile decal"
	color = "#D381C9"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/purple)

/// Brown tiles

/obj/effect/turf_decal/tile/brown
	name = "brown tile decal"
	color = "#A46106"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/brown)

/// Neutral tiles

/obj/effect/turf_decal/tile/neutral
	name = "neutral tile decal"
	color = "#D4D4D4"
	alpha = 50

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/neutral)

/// Dark tiles

/obj/effect/turf_decal/tile/dark
	name = "dark tile decal"
	color = "#0e0f0f"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark)

/// Date-specific tiles
/obj/effect/turf_decal/tile/holiday
	name = "ERROR tile decal"
	color = COLOR_RED

/obj/effect/turf_decal/tile/holiday/Initialize(mapload)
	color = request_holiday_colors(src, pattern)
	alpha = DECAL_ALPHA
	return ..()

/// Pattern tiles
/obj/effect/turf_decal/tile/holiday/rainbow
	name = "rainbow tile decal"
	color = "#75C9EB" //bright blue as default for mapping
	pattern = PATTERN_RAINBOW

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/holiday/rainbow)

/obj/effect/turf_decal/tile/holiday/random // so many colors
	name = "colorful tile decal"
	color = "#E300FF" //bright pink as default for mapping
	pattern = PATTERN_RANDOM

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/holiday/random)

#undef TILE_DECAL_SUBTYPE_HELPER

/// Trimlines
/obj/effect/turf_decal/trimline
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110
	icon_state = "trimline_box"
	use_holiday_colors = TRUE

/obj/effect/turf_decal/trimline/tram
	pattern = PATTERN_VERTICAL_STRIPE

/obj/effect/turf_decal/trimline/tram/filled/corner/Initialize(mapload)
	if(use_holiday_colors)
		var/current_holiday_color = request_holiday_colors(src, pattern)
		if(current_holiday_color)
			color = current_holiday_color
			alpha = DECAL_ALPHA
	else
		color = "#ffc875"
	return ..()

/obj/effect/turf_decal/trimline/tram/filled/line/Initialize(mapload)
	if(use_holiday_colors)
		var/current_holiday_color = request_holiday_colors(src, pattern)
		if(current_holiday_color)
			color = current_holiday_color
			alpha = DECAL_ALPHA
	else
		color = "#ffc875"
	return ..()

/// Automatically generates all trimlines for a decal with the given path.
#define TRIMLINE_SUBTYPE_HELPER(path)\
##path/line {\
	icon_state = "trimline";\
}\
##path/corner {\
	icon_state = "trimline_corner";\
}\
##path/end {\
	icon_state = "trimline_end";\
}\
##path/arrow_cw {\
	icon_state = "trimline_arrow_cw";\
}\
##path/arrow_ccw {\
	icon_state = "trimline_arrow_ccw";\
}\
##path/warning {\
	icon_state = "trimline_warn";\
}\
##path/tram {\
	icon_state = "trimline_tram";\
}\
##path/mid_joiner {\
	icon_state = "trimline_mid";\
}\
##path/filled {\
	icon_state = "trimline_box_fill";\
}\
##path/filled/line {\
	icon_state = "trimline_fill";\
}\
##path/filled/corner {\
	icon_state = "trimline_corner_fill";\
}\
##path/filled/end {\
	icon_state = "trimline_end_fill";\
}\
##path/filled/arrow_cw {\
	icon_state = "trimline_arrow_cw_fill";\
}\
##path/filled/arrow_ccw {\
	icon_state = "trimline_arrow_ccw_fill";\
}\
##path/filled/warning {\
	icon_state = "trimline_warn_fill";\
}\
##path/filled/warning/corner {\
	icon_state = "trimline_corner_warn_fill";\
}\
##path/filled/mid_joiner {\
	icon_state = "trimline_mid_fill";\
}\
##path/filled/shrink_cw {\
	icon_state = "trimline_shrink_cw";\
}\
##path/filled/shrink_ccw {\
	icon_state = "trimline_shrink_ccw";\
}


/// White trimlines
/obj/effect/turf_decal/trimline/white
	color = COLOR_WHITE

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/white)

/// Red trimlines
/obj/effect/turf_decal/trimline/red
	color = "#DE3A3A"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/red)

/// Dark red trimlines
/obj/effect/turf_decal/trimline/dark_red
	color = "#B11111"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/dark_red)

/// Green trimlines
/obj/effect/turf_decal/trimline/green
	color = "#9FED58"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/green)

/// Dark green Trimlines
/obj/effect/turf_decal/trimline/dark_green
	color = "#439C1E"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/dark_green)

/// Blue trimlines
/obj/effect/turf_decal/trimline/blue
	color = "#52B4E9"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/blue)

/// Dark blue trimlines
/obj/effect/turf_decal/trimline/dark_blue
	color = "#486091"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/dark_blue)

/// Yellow trimlines
/obj/effect/turf_decal/trimline/yellow
	color = "#EFB341"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/yellow)

/// Purple trimlines
/obj/effect/turf_decal/trimline/purple
	color = "#D381C9"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/purple)

/// Brown trimlines
/obj/effect/turf_decal/trimline/brown
	color = "#A46106"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/brown)

/// Neutral trimlines
/obj/effect/turf_decal/trimline/neutral
	color = "#D4D4D4"
	alpha = 50

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/neutral)

/// Tram trimlines
/obj/effect/turf_decal/trimline/tram
	color = "#D4D4D4"
	alpha = 50

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/tram)

/// Dark trimlines
/obj/effect/turf_decal/trimline/dark
	color = "#0e0f0f"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/dark)

#undef TRIMLINE_SUBTYPE_HELPER
#undef DECAL_ALPHA
