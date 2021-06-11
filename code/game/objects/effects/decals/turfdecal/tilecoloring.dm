/obj/effect/turf_decal/tile
	name = "tile decal"
	icon_state = "tile_corner"
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110

#define PRIDE_ALPHA 60

/obj/effect/turf_decal/tile/Initialize()
	if(SSevents.holidays)
		if (SSevents.holidays[APRIL_FOOLS])
			color = "#[random_short_color()]"
		else if (SSevents.holidays[PRIDE_WEEK])
			var/datum/holiday/pride_week/pride_week = SSevents.holidays[PRIDE_WEEK]
			color = pride_week.get_floor_tile_color(src)

			// It looks garish at different alphas, and it's not possible to get a
			// consistent color palette without this.
			alpha = PRIDE_ALPHA
	return ..()

#undef PRIDE_ALPHA

/// Blue tiles

/obj/effect/turf_decal/tile/blue
	name = "blue corner"
	var/color_name = "blue"
	color = "#52B4E9"

/obj/effect/turf_decal/tile/blue/joiner
	icon_state = "tile_joiner"
	name = "blue joiner"

/obj/effect/turf_decal/tile/blue/center_join
	icon_state = "tile_center_join"
	name = "blue center joiner"

/obj/effect/turf_decal/tile/blue/half
	icon_state = "tile_half"
	name = "blue half"

/obj/effect/turf_decal/tile/blue/anticorner
	icon_state = "tile_anticorner"
	name = "blue anticorner"

/obj/effect/turf_decal/tile/blue/full
	icon_state = "tile_full"
	name = "blue full"

/// Green tiles

/obj/effect/turf_decal/tile/green
	name = "green corner"
	var/color_name = "green"
	color = "#9FED58"

/obj/effect/turf_decal/tile/green/joiner
	icon_state = "tile_joiner"
	name = "green joiner"

/obj/effect/turf_decal/tile/green/center_join
	icon_state = "tile_center_join"
	name = "green center joiner"

/obj/effect/turf_decal/tile/green/half
	icon_state = "tile_half"
	name = "green half"

/obj/effect/turf_decal/tile/green/anticorner
	icon_state = "tile_anticorner"
	name = "green anticorner"

/obj/effect/turf_decal/tile/green/full
	icon_state = "tile_full"
	name = "green full"

/// Yellow tiles

/obj/effect/turf_decal/tile/yellow
	name = "yellow corner"
	var/color_name = "yellow"
	color = "#EFB341"

/obj/effect/turf_decal/tile/yellow/joiner
	icon_state = "tile_joiner"
	name = "yellow joiner"

/obj/effect/turf_decal/tile/yellow/center_join
	icon_state = "tile_center_join"
	name = "yellow center joiner"

/obj/effect/turf_decal/tile/yellow/half
	icon_state = "tile_half"
	name = "yellow half"

/obj/effect/turf_decal/tile/yellow/anticorner
	icon_state = "tile_anticorner"
	name = "yellow anticorner"

/obj/effect/turf_decal/tile/yellow/full
	icon_state = "tile_full"
	name = "yellow full"

/// Red tiles

/obj/effect/turf_decal/tile/red
	name = "red corner"
	var/color_name = "red"
	color = "#DE3A3A"

/obj/effect/turf_decal/tile/red/joiner
	icon_state = "tile_joiner"
	name = "red joiner"

/obj/effect/turf_decal/tile/red/center_join
	icon_state = "tile_center_join"
	name = "red center joiner"

/obj/effect/turf_decal/tile/red/half
	icon_state = "tile_half"
	name = "red half"

/obj/effect/turf_decal/tile/red/anticorner
	icon_state = "tile_anticorner"
	name = "red anticorner"

/obj/effect/turf_decal/tile/red/full
	icon_state = "tile_full"
	name = "red full"

/// Bar tiles

/obj/effect/turf_decal/tile/bar
	name = "bar corner"
	var/color_name = "bar"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/tile/bar/joiner
	icon_state = "tile_joiner"
	name = "bar joiner"

/obj/effect/turf_decal/tile/bar/center_join
	icon_state = "tile_center_join"
	name = "bar center joiner"

/obj/effect/turf_decal/tile/bar/half
	icon_state = "tile_half"
	name = "bar half"

/obj/effect/turf_decal/tile/bar/anticorner
	icon_state = "tile_anticorner"
	name = "bar anticorner"

/obj/effect/turf_decal/tile/bar/full
	icon_state = "tile_full"
	name = "bar full"

/// Purple tiles

/obj/effect/turf_decal/tile/purple
	name = "purple corner"
	var/color_name = "purple"
	color = "#D381C9"

/obj/effect/turf_decal/tile/purple/joiner
	icon_state = "tile_joiner"
	name = "purple joiner"

/obj/effect/turf_decal/tile/purple/center_join
	icon_state = "tile_center_join"
	name = "purple center joiner"

/obj/effect/turf_decal/tile/purple/half
	icon_state = "tile_half"
	name = "purple half"

/obj/effect/turf_decal/tile/purple/anticorner
	icon_state = "tile_anticorner"
	name = "purple anticorner"

/obj/effect/turf_decal/tile/purple/full
	icon_state = "tile_full"
	name = "purple full"

/// Brown tiles

/obj/effect/turf_decal/tile/brown
	name = "brown corner"
	var/color_name = "brown"
	color = "#A46106"

/obj/effect/turf_decal/tile/brown/joiner
	icon_state = "tile_joiner"
	name = "brown joiner"

/obj/effect/turf_decal/tile/brown/center_join
	icon_state = "tile_center_join"
	name = "brown center joiner"

/obj/effect/turf_decal/tile/brown/half
	icon_state = "tile_half"
	name = "brown half"

/obj/effect/turf_decal/tile/brown/anticorner
	icon_state = "tile_anticorner"
	name = "brown anticorner"

/obj/effect/turf_decal/tile/brown/full
	icon_state = "tile_full"
	name = "brown full"

/// Neutral tiles

/obj/effect/turf_decal/tile/neutral
	name = "neutral corner"
	var/color_name = "neutral"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/tile/neutral/joiner
	icon_state = "tile_joiner"
	name = "neutral joiner"

/obj/effect/turf_decal/tile/neutral/center_join
	icon_state = "tile_center_join"
	name = "neutral center joiner"

/obj/effect/turf_decal/tile/neutral/half
	icon_state = "tile_half"
	name = "neutral half"

/obj/effect/turf_decal/tile/neutral/anticorner
	icon_state = "tile_anticorner"
	name = "neutral anticorner"

/obj/effect/turf_decal/tile/neutral/full
	icon_state = "tile_full"
	name = "neutral full"

/// Dark tiles

/obj/effect/turf_decal/tile/dark
	name = "dark corner"
	var/color_name = "dark"
	color = "#0e0f0f"

/obj/effect/turf_decal/tile/dark/joiner
	icon_state = "tile_joiner"
	name = "dark joiner"

/obj/effect/turf_decal/tile/dark/center_join
	icon_state = "tile_center_join"
	name = "dark center joiner"

/obj/effect/turf_decal/tile/dark/half
	icon_state = "tile_half"
	name = "dark half"

/obj/effect/turf_decal/tile/dark/anticorner
	icon_state = "tile_anticorner"
	name = "dark anticorner"

/obj/effect/turf_decal/tile/dark/full
	icon_state = "tile_full"
	name = "dark full"

/// Random tiles

/obj/effect/turf_decal/tile/random // so many colors
	name = "colorful corner"
	var/color_name = "colorful"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/tile/random/joiner
	icon_state = "tile_joiner"
	name = "colorful joiner"

/obj/effect/turf_decal/tile/random/center_join
	icon_state = "tile_center_join"
	name = "colorful center joiner"

/obj/effect/turf_decal/tile/random/half
	icon_state = "tile_half"
	name = "colorful half"

/obj/effect/turf_decal/tile/random/anticorner
	icon_state = "tile_anticorner"
	name = "colorful anticorner"

/obj/effect/turf_decal/tile/random/full
	icon_state = "tile_full"
	name = "colorful full"

/obj/effect/turf_decal/tile/random/Initialize()
	color = "#[random_short_color()]"
	. = ..()

/// Done with tile decals

/obj/effect/turf_decal/trimline
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110
	icon_state = "trimline_box"

/obj/effect/turf_decal/trimline/Initialize()
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/// White trimlines

/obj/effect/turf_decal/trimline/white
	color = "#FFFFFF"

/obj/effect/turf_decal/trimline/white/line
	name = "trim decal"
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/white/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/white/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/white/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/white/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/white/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/white/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/white/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/white/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/white/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/white/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/white/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/white/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/white/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/white/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/white/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/white/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Red trimlines

/obj/effect/turf_decal/trimline/red
	color = "#DE3A3A"

/obj/effect/turf_decal/trimline/red/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/red/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/red/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/red/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/red/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/red/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/red/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/red/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/red/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/red/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/red/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/red/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/red/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/red/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/red/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/red/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/red/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Green trimlines

/obj/effect/turf_decal/trimline/green
	color = "#9FED58"

/obj/effect/turf_decal/trimline/green/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/green/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/green/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/green/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/green/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/green/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/green/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/green/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/green/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/green/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/green/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/green/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/green/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/green/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/green/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/green/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/green/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Blue trimlines

/obj/effect/turf_decal/trimline/blue
	color = "#52B4E9"

/obj/effect/turf_decal/trimline/blue/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/blue/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/blue/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/blue/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/blue/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/blue/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/blue/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/blue/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/blue/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/blue/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/blue/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/blue/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/blue/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/blue/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/blue/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/blue/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/blue/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Yellow trimlines

/obj/effect/turf_decal/trimline/yellow
	color = "#EFB341"

/obj/effect/turf_decal/trimline/yellow/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/yellow/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/yellow/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/yellow/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/yellow/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/yellow/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/yellow/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/yellow/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/yellow/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/yellow/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/yellow/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/yellow/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/yellow/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/yellow/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/yellow/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/yellow/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/yellow/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Purple trimlines

/obj/effect/turf_decal/trimline/purple
	color = "#D381C9"

/obj/effect/turf_decal/trimline/purple/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/purple/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/purple/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/purple/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/purple/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/purple/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/purple/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/purple/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/purple/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/purple/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/purple/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/purple/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/purple/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/purple/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/purple/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/purple/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/purple/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Brown trimlines

/obj/effect/turf_decal/trimline/brown
	color = "#A46106"

/obj/effect/turf_decal/trimline/brown/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/brown/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/brown/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/brown/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/brown/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/brown/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/brown/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/brown/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/brown/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/brown/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/brown/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/brown/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/brown/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/brown/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/brown/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/brown/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/brown/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Neutral trimlines

/obj/effect/turf_decal/trimline/neutral
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/trimline/neutral/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/neutral/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/neutral/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/neutral/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/neutral/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/neutral/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/neutral/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/neutral/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/neutral/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/neutral/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/neutral/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/neutral/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/neutral/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/neutral/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/neutral/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/neutral/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/neutral/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"
