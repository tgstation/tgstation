/// Automatically generates all subtypes for a wooden floor with tiles.
#define WOODEN_FLOOR_HELPER(type, floor_name, floor_color)\
/turf/open/floor/wood/##type {\
	color = ##floor_color;\
	floor_tile = /obj/item/stack/tile/wood/##type;\
};\
/obj/item/stack/tile/wood/##type {\
	name = ##floor_name + " floor tiles";\
	singular_name = ##floor_name + " floor tile";\
	color = ##floor_color;\
	turf_type = /turf/open/floor/wood/##type;\
	merge_type = /obj/item/stack/tile/wood/##type;\
	tile_reskin_types = list(\
		/obj/item/stack/tile/wood/##type,\
		/obj/item/stack/tile/wood/large/##type,\
		/obj/item/stack/tile/wood/parquet/##type,\
		/obj/item/stack/tile/wood/tile/##type,\
	);\
};\
/turf/open/floor/wood/large/##type {\
	color = ##floor_color;\
	floor_tile = /obj/item/stack/tile/wood/large/##type;\
};\
/obj/item/stack/tile/wood/large/##type {\
	name = "large " + ##floor_name + " floor tiles";\
	singular_name = "large " + ##floor_name + " floor tile";\
	color = ##floor_color;\
	turf_type = /turf/open/floor/wood/large/##type;\
	merge_type = /obj/item/stack/tile/wood/large/##type;\
	tile_reskin_types = list(\
		/obj/item/stack/tile/wood/##type,\
		/obj/item/stack/tile/wood/large/##type,\
		/obj/item/stack/tile/wood/parquet/##type,\
		/obj/item/stack/tile/wood/tile/##type,\
	);\
};\
/turf/open/floor/wood/parquet/##type {\
	color = ##floor_color;\
	floor_tile = /obj/item/stack/tile/wood/parquet/##type;\
};\
/obj/item/stack/tile/wood/parquet/##type {\
	name = ##floor_name + " parquet floor tiles";\
	singular_name = ##floor_name + " parquet floor tile";\
	color = ##floor_color;\
	turf_type = /turf/open/floor/wood/parquet/##type;\
	merge_type = /obj/item/stack/tile/wood/parquet/##type;\
	tile_reskin_types = list(\
		/obj/item/stack/tile/wood/##type,\
		/obj/item/stack/tile/wood/large/##type,\
		/obj/item/stack/tile/wood/parquet/##type,\
		/obj/item/stack/tile/wood/tile/##type,\
	);\
};\
/turf/open/floor/wood/tile/##type {\
	color = ##floor_color;\
	floor_tile = /obj/item/stack/tile/wood/tile/##type;\
};\
/obj/item/stack/tile/wood/tile/##type {\
	name = "tiled " + ##floor_name + " parquet floor tiles";\
	singular_name = "tiled " + ##floor_name + " parquet floor tile";\
	color = ##floor_color;\
	turf_type = /turf/open/floor/wood/tile/##type;\
	merge_type = /obj/item/stack/tile/wood/tile/##type;\
	tile_reskin_types = list(\
		/obj/item/stack/tile/wood/##type,\
		/obj/item/stack/tile/wood/large/##type,\
		/obj/item/stack/tile/wood/parquet/##type,\
		/obj/item/stack/tile/wood/tile/##type,\
	);\
};\

// MARK: Common Wood
/obj/item/stack/tile/wood
	icon = 'modular_bandastation/objects/icons/turf/wooden/tiles.dmi'
	icon_state = "tile-wood"
	color = COLOR_WOOD

/turf/open/floor/wood
	icon = 'modular_bandastation/objects/icons/turf/wooden/wooden.dmi'
	icon_state = "wood"
	damaged_dmi = 'modular_bandastation/objects/icons/turf/wooden/wooden.dmi'
	color = COLOR_WOOD
	appearance_flags = RESET_COLOR

/turf/open/floor/wood/broken_states()
	return list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

/turf/open/floor/wood/Initialize(mapload)
	. = ..()
	add_atom_colour(color, FIXED_COLOUR_PRIORITY)

// MARK: Fancy Wood
/obj/item/stack/tile/wood/large
	icon_state = "tile-wood-fancy"
	color = COLOR_WOOD

/turf/open/floor/wood/large
	icon_state = "wood_fancy"
	color = COLOR_WOOD

/turf/open/floor/wood/large/broken_states()
	return list("wood_fancy-broken", "wood_fancy-broken2", "wood_fancy-broken3")

// MARK: Parquet
/obj/item/stack/tile/wood/parquet
	icon_state = "tile-wood-parquet"
	color = COLOR_WOOD

/turf/open/floor/wood/parquet
	icon_state = "wood_parquet"
	color = COLOR_WOOD

/turf/open/floor/wood/parquet/broken_states()
	return list("wood_parquet-broken", "wood_parquet-broken2", "wood_parquet-broken3", "wood_parquet-broken4", "wood_parquet-broken5", "wood_parquet-broken6", "wood_parquet-broken7")

// MARK: Tiled Parquet
/obj/item/stack/tile/wood/tile
	icon_state = "tile-wood-tile"
	color = COLOR_WOOD

/turf/open/floor/wood/tile
	icon_state = "wood_tile"
	color = COLOR_WOOD

/turf/open/floor/wood/tile/broken_states()
	return list("wood_tile-broken", "wood_tile-broken2", "wood_tile-broken3")

// MARK: Unique colors
WOODEN_FLOOR_HELPER(oak, "oak", COLOR_OAK)
WOODEN_FLOOR_HELPER(birch, "birch", COLOR_BIRCH)
WOODEN_FLOOR_HELPER(cherry, "cherry", COLOR_CHERRY)
WOODEN_FLOOR_HELPER(amaranth, "amaranth", COLOR_AMARANTH)
WOODEN_FLOOR_HELPER(ebonite, "ebonite", COLOR_EBONITE)
WOODEN_FLOOR_HELPER(pink_ivory, "pink ivory", COLOR_PINK_IVORY)
WOODEN_FLOOR_HELPER(guaiacum, "guaiacum", COLOR_GUAIACUM)

#undef WOODEN_FLOOR_HELPER
