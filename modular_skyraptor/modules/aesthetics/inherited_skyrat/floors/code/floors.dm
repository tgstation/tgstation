/turf/open/floor
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/floors/icons/floors.dmi'

//Removes redundant textured stuff from this radial, as all of ours are textured by default
/obj/item/stack/tile/iron
	tile_reskin_types = list(
		/obj/item/stack/tile/iron,
		/obj/item/stack/tile/iron/edge,
		/obj/item/stack/tile/iron/half,
		/obj/item/stack/tile/iron/corner,
		/obj/item/stack/tile/iron/large,
		/obj/item/stack/tile/iron/small,
		/obj/item/stack/tile/iron/diagonal,
		/obj/item/stack/tile/iron/herringbone,
		/obj/item/stack/tile/iron/dark,
		/obj/item/stack/tile/iron/dark/smooth_edge,
		/obj/item/stack/tile/iron/dark/smooth_half,
		/obj/item/stack/tile/iron/dark/smooth_corner,
		/obj/item/stack/tile/iron/dark/smooth_large,
		/obj/item/stack/tile/iron/dark/small,
		/obj/item/stack/tile/iron/dark/diagonal,
		/obj/item/stack/tile/iron/dark/herringbone,
		/obj/item/stack/tile/iron/dark_side,
		/obj/item/stack/tile/iron/dark_corner,
		/obj/item/stack/tile/iron/checker,
		/obj/item/stack/tile/iron/white,
		/obj/item/stack/tile/iron/white/smooth_edge,
		/obj/item/stack/tile/iron/white/smooth_half,
		/obj/item/stack/tile/iron/white/smooth_corner,
		/obj/item/stack/tile/iron/white/smooth_large,
		/obj/item/stack/tile/iron/white/small,
		/obj/item/stack/tile/iron/white/diagonal,
		/obj/item/stack/tile/iron/white/herringbone,
		/obj/item/stack/tile/iron/white_side,
		/obj/item/stack/tile/iron/white_corner,
		/obj/item/stack/tile/iron/cafeteria,
		/obj/item/stack/tile/iron/recharge_floor,
		/obj/item/stack/tile/iron/smooth,
		/obj/item/stack/tile/iron/smooth_edge,
		/obj/item/stack/tile/iron/smooth_half,
		/obj/item/stack/tile/iron/smooth_corner,
		/obj/item/stack/tile/iron/smooth_large,
		/obj/item/stack/tile/iron/terracotta,
		/obj/item/stack/tile/iron/terracotta/small,
		/obj/item/stack/tile/iron/terracotta/diagonal,
		/obj/item/stack/tile/iron/terracotta/herringbone,
		/obj/item/stack/tile/iron/kitchen,
		/obj/item/stack/tile/iron/kitchen/small,
		/obj/item/stack/tile/iron/kitchen/diagonal,
		/obj/item/stack/tile/iron/kitchen/herringbone,
		/obj/item/stack/tile/iron/chapel,
		/obj/item/stack/tile/iron/showroomfloor,
		/obj/item/stack/tile/iron/solarpanel,
		/obj/item/stack/tile/iron/freezer,
		/obj/item/stack/tile/iron/grimy,
		/obj/item/stack/tile/iron/sepia,
	)

/turf/open/indestructible/cobble
	name = "cobblestone path"
	desc = "A simple but beautiful path made of various sized stones."
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/floors/icons/floors.dmi'
	icon_state = "cobble"
	baseturfs = /turf/open/indestructible/cobble
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/indestructible/cobble/side
	icon_state = "cobble_side"

/turf/open/indestructible/cobble/corner
	icon_state = "cobble_corner"

//Naaka's Lounge edit 1: tiles

//Wood

/obj/item/stack/tile/wood/birch
	name = "birchwood floor tile"
	singular_name = "birchwood floor tile"
	desc = "An easy to fit wood floor til, made from birch. Use while in your hand to change what pattern you want."
	icon_state = "tile-wood"
	inhand_icon_state = "tile-wood"
	turf_type = /turf/open/floor/wood/birch
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/wood/birch
	tile_reskin_types = list(
		/obj/item/stack/tile/wood/birch,
		/obj/item/stack/tile/wood/large/birch,
		/obj/item/stack/tile/wood/tile/birch,
		/obj/item/stack/tile/wood/parquet/birch,
	)

/obj/item/stack/tile/wood/parquet/birch
	name = "parquet birchwood floor tile"
	singular_name = "parquet birchwood floor tile"
	icon_state = "tile-wood_parquet"
	turf_type = /turf/open/floor/wood/parquet/birch
	merge_type = /obj/item/stack/tile/wood/parquet/birch

/obj/item/stack/tile/wood/large/birch
	name = "large birchwood floor tile"
	singular_name = "large birchwood floor tile"
	icon_state = "tile-wood_large"
	turf_type = /turf/open/floor/wood/large/birch
	merge_type = /obj/item/stack/tile/wood/large/birch

/obj/item/stack/tile/wood/tile/birch
	name = "tiled birchwood floor tile"
	singular_name = "tiled birchwood floor tile"
	icon_state = "tile-wood_tile"
	turf_type = /turf/open/floor/wood/tile/birch
	merge_type = /obj/item/stack/tile/wood/tile/birch


//Naaka's Lounge edit

/turf/open/floor/wood/birch
	icon_state = "birchwood"
	floor_tile = /obj/item/stack/tile/wood/birch

/turf/open/floor/wood/tile/birch
	icon_state = "birchwood_tile"
	floor_tile = /obj/item/stack/tile/wood/tile/birch

/turf/open/floor/wood/parquet/birch
	icon_state = "birchwood_parquet"
	floor_tile = /obj/item/stack/tile/wood/parquet/birch

/turf/open/floor/wood/large/birch
	icon_state = "birchwood_large"
	floor_tile = /obj/item/stack/tile/wood/large/birch