/turf/open/misc/grass/roofing
	name = "thatched roof"
	desc = "A collection of various dried greens, not so green anymore, that makes a passable roof material."
	baseturfs = /turf/open/openspace/icemoon
	initial_gas_mix = "ICEMOON_ATMOS"
	icon_state = "grass-255"
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/thatch.dmi'
	smooth_icon = 'modular_doppler/hearthkin/primitive_structures/icons/thatch.dmi'


/turf/open/floor/grass/thatch
	name = "thatch patch"
	desc = "A collection of various dried greens, not so green anymore, that makes a passable floor material"
	icon_state = "grass-255"
	base_icon_state = "grass"
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/thatch.dmi'
	damaged_dmi = 'icons/turf/damaged.dmi'
	floor_tile = /obj/item/stack/tile/grass/thatch
	bullet_bounce_sound = null
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_GRASS
	canSmoothWith = SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_CLOSED_TURFS
	layer = HIGH_TURF_LAYER
	/// Icon used for smoothing
	var/smooth_icon = 'modular_doppler/hearthkin/primitive_structures/icons/thatch.dmi'


/turf/open/floor/grass/thatch/Initialize(mapload)
	. = ..()
	if(smoothing_flags)
		var/matrix/translation = new
		translation.Translate(-9, -9)
		transform = translation
		icon = smooth_icon


/turf/open/floor/grass/thatch/broken_states()
	return list("grass_damaged")


/turf/open/floor/grass/thatch/burnt_states()
	return list("grass_damaged")


/obj/item/stack/tile/grass/thatch
	name = "thatch tile"
	singular_name = "thatch floor tile"
	desc = "A patch of thatch like in those old-school barns."
	icon_state = "tile_thatch"
	inhand_icon_state = "tile-thatch"
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/thatch_obj.dmi'
	lefthand_file = 'modular_doppler/hearthkin/primitive_structures/icons/tile_lefthand.dmi'
	righthand_file = 'modular_doppler/hearthkin/primitive_structures/icons/tile_righthand.dmi'
	resistance_flags = FLAMMABLE
	turf_type = /turf/open/floor/grass/thatch
	merge_type = /obj/item/stack/tile/grass/thatch


/obj/item/food/grown/grass/thatch
	name = "thatch"
	desc = "Yellow and dry."
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/thatch_obj.dmi'
	icon_state = "thatch_clump"
	stacktype = /obj/item/stack/tile/grass/thatch


/obj/item/food/grown/grass/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/grown/grass/thatch)
