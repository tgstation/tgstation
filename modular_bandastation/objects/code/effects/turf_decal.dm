// MARK: Sidings
// Gold stripe
/obj/effect/turf_decal/siding/golden
	icon = 'modular_bandastation/objects/icons/obj/effects/siding.dmi'
	icon_state = "golden"

/obj/effect/turf_decal/siding/golden/corner
	icon_state = "golden_corner"

/obj/effect/turf_decal/siding/golden/inner_corner
	icon_state = "golden_corner_inner"

/obj/effect/turf_decal/siding/golden/end
	icon_state = "golden_end"

// Gold "royal" siding
/obj/effect/turf_decal/siding/royal
	icon = 'modular_bandastation/objects/icons/obj/effects/siding.dmi'
	icon_state = "royal"

/obj/effect/turf_decal/siding/royal/corner
	icon_state = "royal_corner"

/obj/effect/turf_decal/siding/royal/inner_corner
	icon_state = "royal_corner_inner"

/obj/effect/turf_decal/siding/royal/end
	icon_state = "royal_end"

// Wood Sidings
#define DEFINE_WOOD_SIDING(wood_name, wood_color) \
	/obj/effect/turf_decal/siding/wood/##wood_name { \
		color = wood_color; \
	} \
	/obj/effect/turf_decal/siding/wood/##wood_name/corner { \
		icon_state = "siding_wood_corner"; \
	} \
	/obj/effect/turf_decal/siding/wood/##wood_name/end { \
		icon_state = "siding_wood_end"; \
	}

DEFINE_WOOD_SIDING(oak, COLOR_OAK)
DEFINE_WOOD_SIDING(birch, COLOR_BIRCH)
DEFINE_WOOD_SIDING(cherry, COLOR_CHERRY)
DEFINE_WOOD_SIDING(amaranth, COLOR_AMARANTH)
DEFINE_WOOD_SIDING(ebonite, COLOR_EBONITE)
DEFINE_WOOD_SIDING(ivory, COLOR_PINK_IVORY)
DEFINE_WOOD_SIDING(guaiacum, COLOR_GUAIACUM)

#undef DEFINE_WOOD_SIDING

// MARK: Lines
/obj/effect/turf_decal/line
	name = "line decal"
	icon = 'modular_bandastation/objects/icons/obj/effects/line.dmi'
	icon_state = "line_corner"
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110

/// Automatically generates all subtypes for a decal with the given path.
#define LINE_DECAL_SUBTYPE_HELPER(path)\
##path/line {\
	icon_state = "line";\
}\
##path/line/contrasted {\
	icon_state = "line_contrasted";\
}\
##path/line/stripes {\
	icon_state = "line_stripes";\
}\
##path/line/stripes/contrasted {\
	icon_state = "line_stripes_contrasted";\
}\
##path/anticorner {\
	icon_state = "line_anticorner";\
}\
##path/anticorner/contrasted {\
	icon_state = "line_anticorner_contrasted";\
}\
##path/anticorner/stripes {\
	icon_state = "line_anticorner_stripes";\
}\
##path/anticorner/stripes/contrasted {\
	icon_state = "line_anticorner_stripes_contrasted";\
}\
##path/opposingcorners {\
	icon_state = "line_opposing_corners";\
}\

/// Blue lines
/obj/effect/turf_decal/line/blue
	name = "blue line decal"
	color = "#52B4E9"

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/blue)

/// Dark blue lines
/obj/effect/turf_decal/line/dark_blue
	name = "dark blue line decal"
	color = "#486091"

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/dark_blue)

/// Green lines
/obj/effect/turf_decal/line/green
	name = "green line decal"
	color = "#9FED58"

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/green)

/// Dark green lines
/obj/effect/turf_decal/line/dark_green
	name = "dark green line decal"
	color = "#439C1E"

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/dark_green)

/// Yellow lines
/obj/effect/turf_decal/line/yellow
	name = "yellow line decal"
	color = "#EFB341"

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/yellow)

/// Red lines
/obj/effect/turf_decal/line/red
	name = "red line decal"
	color = "#DE3A3A"

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/red)

/// Dark red lines
/obj/effect/turf_decal/line/dark_red
	name = "dark red line decal"
	color = "#B11111"

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/dark_red)

/// Bar lines
/obj/effect/turf_decal/line/bar
	name = "bar line decal"
	color = "#791500"
	alpha = 130

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/bar)

/// Purple lines
/obj/effect/turf_decal/line/purple
	name = "purple line decal"
	color = "#D381C9"

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/purple)

/// Brown lines
/obj/effect/turf_decal/line/brown
	name = "brown line decal"
	color = "#A46106"

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/brown)

/// Neutral lines
/obj/effect/turf_decal/line/neutral
	name = "neutral line decal"
	color = "#D4D4D4"
	alpha = 50

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/neutral)

/// Dark lines
/obj/effect/turf_decal/line/dark
	name = "dark line decal"
	color = "#0e0f0f"

LINE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/line/dark)

#undef LINE_DECAL_SUBTYPE_HELPER
