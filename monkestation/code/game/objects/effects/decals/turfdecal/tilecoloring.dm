//Blue Tiles

/obj/effect/turf_decal/monke/tile/blue
	color = "#52B4E9"

/obj/effect/turf_decal/monke/tile/blue/tile_half
	icon_state = "tile_half"
	name = "blue half"

/obj/effect/turf_decal/monke/tile/blue/tile_whole
	icon_state = "tile_whole"
	name = "blue whole"

//Green Tiles

/obj/effect/turf_decal/monke/tile/green
	color = "#9FED58"

/obj/effect/turf_decal/monke/tile/green/tile_half
	icon_state = "tile_half"
	name = "green half"

/obj/effect/turf_decal/monke/tile/green/tile_whole
	icon_state = "tile_whole"
	name = "green whole"

//Yellow Tiles

/obj/effect/turf_decal/monke/tile/yellow
	color = "#EFB341"

/obj/effect/turf_decal/monke/tile/yellow/tile_half
	icon_state = "tile_half"
	name = "yellow half"

/obj/effect/turf_decal/monke/tile/yellow/tile_whole
	icon_state = "tile_whole"
	name = "yellow whole"

//Red Tiles

/obj/effect/turf_decal/monke/tile/red
	color = "#DE3A3A"

/obj/effect/turf_decal/monke/tile/red/tile_half
	icon_state = "tile_half"
	name = "red half"

/obj/effect/turf_decal/monke/tile/red/tile_whole
	icon_state = "tile_whole"
	name = "red whole"

//Bar Tiles

/obj/effect/turf_decal/monke/tile/bar
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/monke/tile/bar/tile_half
	icon_state = "tile_half"
	name = "bar half"

/obj/effect/turf_decal/monke/tile/bar/tile_whole
	icon_state = "tile_whole"
	name = "bar whole"

//Purple Tiles

/obj/effect/turf_decal/monke/tile/purple
	color = "#D381C9"

/obj/effect/turf_decal/monke/tile/purple/tile_half
	icon_state = "tile_half"
	name = "purple half"

/obj/effect/turf_decal/monke/tile/purple/tile_whole
	icon_state = "tile_whole"
	name = "purple whole"

//Brown Tiles

/obj/effect/turf_decal/monke/tile/brown
	color = "#A46106"

/obj/effect/turf_decal/monke/tile/brown/tile_half
	icon_state = "tile_half"
	name = "brown half"

/obj/effect/turf_decal/monke/tile/brown/tile_whole
	icon_state = "tile_whole"
	name = "brown whole"

//Neutral Tiles

/obj/effect/turf_decal/monke/tile/neutral
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/monke/tile/neutral/tile_half
	icon_state = "tile_half"
	name = "neutral half"

/obj/effect/turf_decal/monke/tile/neutral/tile_whole
	icon_state = "tile_whole"
	name = "neutral whole"

//Dark Tiles

/obj/effect/turf_decal/monke/tile/dark
	icon = 'icons/turf/decals.dmi'
	icon_state = "tile_corner"
	name = "dark corner"
	color = "#0e0f0f"

/obj/effect/turf_decal/monke/tile/dark/tile_marquee
	name = "dark marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/monke/tile/dark/tile_side
	name = "dark side"
	icon_state = "tile_side"

/obj/effect/turf_decal/monke/tile/dark/tile_full
	name = "dark tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/monke/tile/dark/tile_half
	icon = 'monkestation/icons/turf/decals.dmi'
	icon_state = "tile_half"
	name = "dark half"

/obj/effect/turf_decal/monke/tile/dark/tile_whole
	icon = 'monkestation/icons/turf/decals.dmi'
	icon_state = "tile_whole"
	name = "dark whole"

//Random Tiles

/obj/effect/turf_decal/monke/tile/random
	color = "#E300FF"

/obj/effect/turf_decal/monke/tile/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/monke/tile/random/tile_half
	icon_state = "tile_half"
	name = "random half"

/obj/effect/turf_decal/monke/tile/random/tile_whole
	icon_state = "tile_whole"
	name = "random whole"
