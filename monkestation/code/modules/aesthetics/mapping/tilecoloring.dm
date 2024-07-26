/// Darkest green tiles /// Fuck you, not dark enough

/obj/effect/turf_decal/tile/darkest_green
	name = "darkest green corner"
	color = "#055205"



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
}



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
##path/filled/mid_joiner {\
	icon_state = "trimline_mid_fill";\
}\
##path/filled/shrink_cw {\
	icon_state = "trimline_shrink_cw";\
}\
##path/filled/shrink_ccw {\
	icon_state = "trimline_shrink_ccw";\
}


TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/darkest_green)

/// Piss Yellow tiles

/obj/effect/turf_decal/tile/piss_yellow
	name = "piss yellow corner"
	color = "#BAC700"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/piss_yellow)


/// Orange tiles

/obj/effect/turf_decal/tile/orange
	name = "orange corner"
	color = "#D15802"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/orange)


/// Hot Pink Tiles

/obj/effect/turf_decal/tile/hot_pink
	name = "hot pink corner"
	color = "#FF69B4"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/hot_pink)


/// Dark Puple Tiles

/obj/effect/turf_decal/tile/dark_purple
	name = "dark purple corner"
	color = "#6C1282"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark_purple)


/// Gray tiles
/obj/effect/turf_decal/tile/gray
	name = "gray corner"
	color = "#2E2E2E"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/gray)



/// Darkest Green Trimlines
/obj/effect/turf_decal/trimline/darkest_green
	color = "#055205"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/darkest_green)



/// Piss Yellow trimlines
/obj/effect/turf_decal/trimline/piss_yellow
	color = "#BAC700"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/piss_yellow)

/// Orange trimlines
/obj/effect/turf_decal/trimline/orange
	color = "#D15802"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/orange)

/// Hot Pink trimlines
/obj/effect/turf_decal/trimline/hot_pink
	color = "#FF69B4"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/hot_pink)



/// Dark Purple trimlines
/obj/effect/turf_decal/trimline/dark_purple
	color = "#6C1282"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/dark_purple)

/// Gray trimlines
/obj/effect/turf_decal/trimline/gray
	color = "#2E2E2E"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/gray)

/obj/effect/turf_decal/tile/holiday/random // so many colors
	name = "colorful tile decal"
	color = "#E300FF" //bright pink as default for mapping

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/holiday/random)

#undef TILE_DECAL_SUBTYPE_HELPER
#undef TRIMLINE_SUBTYPE_HELPER
