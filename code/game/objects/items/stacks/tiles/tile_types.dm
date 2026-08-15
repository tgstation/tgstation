/**
 * TILE STACKS
 *
 * Allows us to place a turf on a plating.
 */
/obj/item/stack/tile
	name = "broken tile"
	singular_name = "broken tile"
	desc = "A broken tile. This should not exist."
	lefthand_file = 'icons/mob/inhands/items/tiles_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/tiles_righthand.dmi'
	icon = 'icons/obj/tiles.dmi'
	worn_icon_state = null
	w_class = WEIGHT_CLASS_NORMAL
	force = 1
	throwforce = 1
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	novariants = TRUE
	material_flags = MATERIAL_EFFECTS
	/// What type of turf does this tile produce.
	var/turf_type = null
	/// What dir will the turf have?
	var/turf_dir = SOUTH
	/// Cached associative lazy list to hold the radial options for tile reskinning. See tile_reskinning.dm for more information. Pattern: list[type] -> image
	var/list/tile_reskin_types
	/// Cached associative lazy list to hold the radial options for tile dirs. See tile_reskinning.dm for more information.
	var/list/tile_rotate_dirs
	/// tile_rotate_dirs but before it gets converted to text
	var/list/tile_rotate_dirs_number

/obj/item/stack/tile/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3) //randomize a little
	AddElement(/datum/element/openspace_item_click_handler)
	if(tile_reskin_types)
		tile_reskin_types = tile_reskin_list(tile_reskin_types)
	if(tile_rotate_dirs)
		tile_rotate_dirs_number = tile_rotate_dirs.Copy()
		var/list/values = list()
		for(var/set_dir in tile_rotate_dirs)
			values += dir2text(set_dir)
		tile_rotate_dirs = tile_dir_list(values, turf_type)


/obj/item/stack/tile/examine(mob/user)
	. = ..()
	if(tile_reskin_types || tile_rotate_dirs)
		. += span_notice("Use while in your hand to change what type of [src] you want.")
	if(throwforce && !is_cyborg) //do not want to divide by zero or show the message to borgs who can't throw
		var/damage_value
		switch(ceil(MAX_LIVING_HEALTH / throwforce)) //throws to crit a human
			if(1 to 3)
				damage_value = "superb"
			if(4 to 6)
				damage_value = "great"
			if(7 to 9)
				damage_value = "good"
			if(10 to 12)
				damage_value = "fairly decent"
			if(13 to 15)
				damage_value = "mediocre"
		if(!damage_value)
			return
		. += span_notice("Those could work as a [damage_value] throwing weapon.")

/**
 * Place our tile on a plating, or replace it.
 *
 * Arguments:
 * * target_plating - Instance of the plating we want to place on. Replaced during successful executions.
 * * user - The mob doing the placing.
 */
/obj/item/stack/tile/proc/place_tile(turf/open/floor/plating/target_plating, mob/user)
	var/turf/placed_turf_path = turf_type
	if(!ispath(placed_turf_path))
		return
	if(!istype(target_plating))
		return

	if(!use(1))
		return
	target_plating = target_plating.place_on_top(placed_turf_path, flags = CHANGETURF_INHERIT_AIR)
	target_plating.setDir(turf_dir)
	playsound(target_plating, 'sound/items/weapons/genhit.ogg', 50, TRUE)
	return target_plating

/obj/item/stack/tile/handle_openspace_click(turf/target, mob/user, list/modifiers)
	target.base_item_interaction(user, src, list2params(modifiers))

//Grass
/obj/item/stack/tile/grass
	name = "grass tile"
	singular_name = "grass floor tile"
	desc = "A patch of grass like they use on space golf courses."
	icon_state = "tile_grass"
	inhand_icon_state = "tile-grass"
	turf_type = /turf/open/floor/grass
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/grass

//Hay
/obj/item/stack/tile/hay
	name = "hay tile"
	singular_name = "hay floor tile"
	desc = "Man, I'm so hungry I could eat a-"
	icon_state = "tile_hay"
	inhand_icon_state = "tile-hay"
	turf_type = /turf/open/floor/hay
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/hay

//Fairygrass
/obj/item/stack/tile/fairygrass
	name = "fairygrass tile"
	singular_name = "fairygrass floor tile"
	desc = "A patch of odd, glowing blue grass."
	icon_state = "tile_fairygrass"
	turf_type = /turf/open/floor/grass/fairy
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fairygrass

//Wood
/obj/item/stack/tile/wood
	name = "wood floor tile"
	singular_name = "wood floor tile"
	desc = "An easy to fit wood floor tile. Use while in your hand to change what pattern you want."
	icon_state = "tile-wood"
	inhand_icon_state = "tile-wood"
	turf_type = /turf/open/floor/wood
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/wood
	tile_reskin_types = list(
		/obj/item/stack/tile/wood,
		/obj/item/stack/tile/wood/large,
		/obj/item/stack/tile/wood/tile,
		/obj/item/stack/tile/wood/parquet,
		/obj/item/stack/tile/wood/dark,
		/obj/item/stack/tile/wood/dark/large,
		/obj/item/stack/tile/wood/dark/tile,
		/obj/item/stack/tile/wood/dark/parquet,
		/obj/item/stack/tile/wood/light,
		/obj/item/stack/tile/wood/light/large,
		/obj/item/stack/tile/wood/light/tile,
		/obj/item/stack/tile/wood/light/parquet,
	)
	mats_per_unit = list(/datum/material/wood = HALF_SHEET_MATERIAL_AMOUNT / 2)

/obj/item/stack/tile/wood/parquet
	name = "parquet wood floor tile"
	singular_name = "parquet wood floor tile"
	icon_state = "tile-wood_parquet"
	turf_type = /turf/open/floor/wood/parquet
	merge_type = /obj/item/stack/tile/wood/parquet

/obj/item/stack/tile/wood/large
	name = "large wood floor tile"
	singular_name = "large wood floor tile"
	icon_state = "tile-wood_large"
	turf_type = /turf/open/floor/wood/large
	merge_type = /obj/item/stack/tile/wood/large

/obj/item/stack/tile/wood/tile
	name = "tiled wood floor tile"
	singular_name = "tiled wood floor tile"
	icon_state = "tile-wood_tile"
	turf_type = /turf/open/floor/wood/tile
	merge_type = /obj/item/stack/tile/wood/tile

/obj/item/stack/tile/wood/dark
	name = "dark wood floor tile"
	singular_name = "dark wood floor tile"
	desc = "An easy to fit dark wood floor tile. Use while in your hand to change what pattern you want."
	icon_state = "tile-darkwood"
	turf_type = /turf/open/floor/wood
	merge_type = /obj/item/stack/tile/wood/dark

/obj/item/stack/tile/wood/dark/parquet
	name = "parquet dark wood floor tile"
	singular_name = "parquet dark wood floor tile"
	icon_state = "tile-darkwood_parquet"
	turf_type = /turf/open/floor/wood/dark/parquet
	merge_type = /obj/item/stack/tile/wood/dark/parquet

/obj/item/stack/tile/wood/dark/large
	name = "large dark wood floor tile"
	singular_name = "large dark wood floor tile"
	icon_state = "tile-darkwood_large"
	turf_type = /turf/open/floor/wood/dark/large
	merge_type = /obj/item/stack/tile/wood/dark/large

/obj/item/stack/tile/wood/dark/tile
	name = "tiled dark wood floor tile"
	singular_name = "tiled dark wood floor tile"
	icon_state = "tile-darkwood_tile"
	turf_type = /turf/open/floor/wood/dark/tile
	merge_type = /obj/item/stack/tile/wood/dark/tile

/obj/item/stack/tile/wood/light
	name = "light wood floor tile"
	singular_name = "light wood floor tile"
	desc = "An easy to fit light wood floor tile. Use while in your hand to change what pattern you want."
	icon_state = "tile-lightwood"
	turf_type = /turf/open/floor/wood/light
	merge_type = /obj/item/stack/tile/wood/light

/obj/item/stack/tile/wood/light/parquet
	name = "parquet light wood floor tile"
	singular_name = "parquet light wood floor tile"
	icon_state = "tile-lightwood_parquet"
	turf_type = /turf/open/floor/wood/light/parquet
	merge_type = /obj/item/stack/tile/wood/light/parquet

/obj/item/stack/tile/wood/light/large
	name = "large light wood floor tile"
	singular_name = "large light wood floor tile"
	icon_state = "tile-lightwood_large"
	turf_type = /turf/open/floor/wood/light/large
	merge_type = /obj/item/stack/tile/wood/light/large

/obj/item/stack/tile/wood/light/tile
	name = "tiled light wood floor tile"
	singular_name = "tiled light wood floor tile"
	icon_state = "tile-lightwood_tile"
	turf_type = /turf/open/floor/wood/light/tile
	merge_type = /obj/item/stack/tile/wood/light/tile

//Bamboo
/obj/item/stack/tile/bamboo
	name = "bamboo mat pieces"
	singular_name = "bamboo mat piece"
	desc = "A piece of a bamboo mat with a decorative trim."
	icon_state = "tile_bamboo"
	inhand_icon_state = "tile-bamboo"
	turf_type = /turf/open/floor/bamboo
	merge_type = /obj/item/stack/tile/bamboo
	resistance_flags = FLAMMABLE
	tile_reskin_types = list(
		/obj/item/stack/tile/bamboo,
		/obj/item/stack/tile/bamboo/planks,
		/obj/item/stack/tile/bamboo/tatami,
		/obj/item/stack/tile/bamboo/tatami/purple,
		/obj/item/stack/tile/bamboo/tatami/black,
	)
	mats_per_unit = list(/datum/material/bamboo = HALF_SHEET_MATERIAL_AMOUNT / 2)

/obj/item/stack/tile/bamboo/planks
	name = "bamboo planks tile"
	singular_name = "planks planks floor tile"
	icon_state = "tile_bamboo_planks"
	desc = "Layer after layer of cut bamboo placed like planks."
	turf_type = /turf/open/floor/bamboo/planks
	merge_type = /obj/item/stack/tile/bamboo/planks

/obj/item/stack/tile/bamboo/tatami
	name = "Tatami with green rim"
	singular_name = "green tatami floor tile"
	icon_state = "tile_tatami_green"
	turf_type = /turf/open/floor/bamboo/tatami
	merge_type = /obj/item/stack/tile/bamboo/tatami
	tile_rotate_dirs = list(NORTH, EAST, SOUTH, WEST)

/obj/item/stack/tile/bamboo/tatami/purple
	name = "Tatami with purple rim"
	singular_name = "purple tatami floor tile"
	icon_state = "tile_tatami_purple"
	turf_type = /turf/open/floor/bamboo/tatami/purple
	merge_type = /obj/item/stack/tile/bamboo/tatami/purple

/obj/item/stack/tile/bamboo/tatami/black
	name = "Tatami with black rim"
	singular_name = "black tatami floor tile"
	icon_state = "tile_tatami_black"
	turf_type = /turf/open/floor/bamboo/tatami/black
	merge_type = /obj/item/stack/tile/bamboo/tatami/black

//Basalt
/obj/item/stack/tile/basalt
	name = "basalt tile"
	singular_name = "basalt floor tile"
	desc = "Artificially made ashy soil themed on a hostile environment."
	icon_state = "tile_basalt"
	inhand_icon_state = "tile-basalt"
	turf_type = /turf/open/floor/fakebasalt
	merge_type = /obj/item/stack/tile/basalt
	mats_per_unit = list(/datum/material/sand = SHEET_MATERIAL_AMOUNT * 2)
	tile_reskin_types = list(
		/obj/item/stack/tile/basalt,
		/obj/item/stack/tile/basalt/sand,
		/obj/item/stack/tile/basalt/redsand,
		/obj/item/stack/tile/basalt/moonsand,
	)
/obj/item/stack/tile/basalt/sand
	name = "sand tile"
	singular_name = "sand floor tile"
	desc = "Artificially made sand tile."
	icon_state = "tile_sand"
	inhand_icon_state = "tile-hay"
	turf_type = /turf/open/floor/fakesand
	merge_type = /obj/item/stack/tile/basalt/sand

/obj/item/stack/tile/basalt/redsand
	name = "red sand tile"
	singular_name = "red sand floor tile"
	desc = "Artificially made red sand tile."
	icon_state = "tile_redsand"
	inhand_icon_state = "tile-meat"
	turf_type = /turf/open/floor/fakesand/red
	merge_type = /obj/item/stack/tile/basalt/redsand

/obj/item/stack/tile/basalt/moonsand
	name = "moon sand tile"
	singular_name = "moon sand floor tile"
	desc = "Artificially made moon sand tile."
	icon_state = "tile_moonsand"
	inhand_icon_state = "tile-silver"
	turf_type = /turf/open/floor/fakesand/moon
	merge_type = /obj/item/stack/tile/basalt/moonsand

//Carpets
/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet tile"
	desc = "A piece of carpet. It is the same size as a floor tile."
	icon_state = "tile-carpet"
	inhand_icon_state = "tile-carpet"
	turf_type = /turf/open/floor/carpet
	resistance_flags = FLAMMABLE
	table_type = /obj/structure/table/wood/fancy
	merge_type = /obj/item/stack/tile/carpet
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet,
		/obj/item/stack/tile/carpet/symbol,
		/obj/item/stack/tile/carpet/star,
	)

/obj/item/stack/tile/carpet/symbol
	name = "symbol carpet"
	singular_name = "symbol carpet tile"
	icon_state = "tile-carpet-symbol"
	desc = "A piece of carpet. This one has a symbol on it."
	turf_type = /turf/open/floor/carpet/lone
	merge_type = /obj/item/stack/tile/carpet/symbol
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST, SOUTHEAST)

/obj/item/stack/tile/carpet/star
	name = "star carpet"
	singular_name = "star carpet tile"
	icon_state = "tile-carpet-star"
	desc = "A piece of carpet. This one has a star on it."
	turf_type = /turf/open/floor/carpet/lone/star
	merge_type = /obj/item/stack/tile/carpet/star

/obj/item/stack/tile/carpet/black
	name = "black carpet"
	icon_state = "tile-carpet-black"
	inhand_icon_state = "tile-carpet-black"
	turf_type = /turf/open/floor/carpet/black
	table_type = /obj/structure/table/wood/fancy/black
	merge_type = /obj/item/stack/tile/carpet/black
	tile_reskin_types = null

/obj/item/stack/tile/carpet/blue
	name = "blue carpet"
	icon_state = "tile-carpet-blue"
	inhand_icon_state = "tile-carpet-blue"
	turf_type = /turf/open/floor/carpet/blue
	table_type = /obj/structure/table/wood/fancy/blue
	merge_type = /obj/item/stack/tile/carpet/blue
	tile_reskin_types = null

/obj/item/stack/tile/carpet/cyan
	name = "cyan carpet"
	icon_state = "tile-carpet-cyan"
	inhand_icon_state = "tile-carpet-cyan"
	turf_type = /turf/open/floor/carpet/cyan
	table_type = /obj/structure/table/wood/fancy/cyan
	merge_type = /obj/item/stack/tile/carpet/cyan
	tile_reskin_types = null

/obj/item/stack/tile/carpet/green
	name = "green carpet"
	icon_state = "tile-carpet-green"
	inhand_icon_state = "tile-carpet-green"
	turf_type = /turf/open/floor/carpet/green
	table_type = /obj/structure/table/wood/fancy/green
	merge_type = /obj/item/stack/tile/carpet/green
	tile_reskin_types = null

/obj/item/stack/tile/carpet/orange
	name = "orange carpet"
	icon_state = "tile-carpet-orange"
	inhand_icon_state = "tile-carpet-orange"
	turf_type = /turf/open/floor/carpet/orange
	table_type = /obj/structure/table/wood/fancy/orange
	merge_type = /obj/item/stack/tile/carpet/orange
	tile_reskin_types = null

/obj/item/stack/tile/carpet/purple
	name = "purple carpet"
	icon_state = "tile-carpet-purple"
	inhand_icon_state = "tile-carpet-purple"
	turf_type = /turf/open/floor/carpet/purple
	table_type = /obj/structure/table/wood/fancy/purple
	merge_type = /obj/item/stack/tile/carpet/purple
	tile_reskin_types = null

/obj/item/stack/tile/carpet/red
	name = "red carpet"
	icon_state = "tile-carpet-red"
	inhand_icon_state = "tile-carpet-red"
	turf_type = /turf/open/floor/carpet/red
	table_type = /obj/structure/table/wood/fancy/red
	merge_type = /obj/item/stack/tile/carpet/red
	tile_reskin_types = null

/obj/item/stack/tile/carpet/royalblack
	name = "royal black carpet"
	icon_state = "tile-carpet-royalblack"
	inhand_icon_state = "tile-carpet-royalblack"
	turf_type = /turf/open/floor/carpet/royalblack
	table_type = /obj/structure/table/wood/fancy/royalblack
	merge_type = /obj/item/stack/tile/carpet/royalblack
	tile_reskin_types = null

/obj/item/stack/tile/carpet/royalblue
	name = "royal blue carpet"
	icon_state = "tile-carpet-royalblue"
	inhand_icon_state = "tile-carpet-royalblue"
	turf_type = /turf/open/floor/carpet/royalblue
	table_type = /obj/structure/table/wood/fancy/royalblue
	merge_type = /obj/item/stack/tile/carpet/royalblue
	tile_reskin_types = null

/obj/item/stack/tile/carpet/executive
	name = "executive carpet"
	icon_state = "tile_carpet_executive"
	inhand_icon_state = "tile-carpet-royalblue"
	turf_type = /turf/open/floor/carpet/executive
	merge_type = /obj/item/stack/tile/carpet/executive
	tile_reskin_types = null

/obj/item/stack/tile/carpet/stellar
	name = "stellar carpet"
	icon_state = "tile_carpet_stellar"
	inhand_icon_state = "tile-carpet-royalblue"
	turf_type = /turf/open/floor/carpet/stellar
	merge_type = /obj/item/stack/tile/carpet/stellar
	tile_reskin_types = null

/obj/item/stack/tile/carpet/donk
	name = "\improper Donk Co. promotional carpet"
	icon_state = "tile_carpet_donk"
	inhand_icon_state = "tile-carpet-orange"
	turf_type = /turf/open/floor/carpet/donk
	merge_type = /obj/item/stack/tile/carpet/donk
	tile_reskin_types = null

/obj/item/stack/tile/carpet/fifty
	amount = 50

/obj/item/stack/tile/iron/fifty
	amount = 50

/obj/item/stack/tile/carpet/black/fifty
	amount = 50

/obj/item/stack/tile/carpet/blue/fifty
	amount = 50

/obj/item/stack/tile/carpet/cyan/fifty
	amount = 50

/obj/item/stack/tile/carpet/green/fifty
	amount = 50

/obj/item/stack/tile/carpet/orange/fifty
	amount = 50

/obj/item/stack/tile/carpet/purple/fifty
	amount = 50

/obj/item/stack/tile/carpet/red/fifty
	amount = 50

/obj/item/stack/tile/carpet/royalblack/fifty
	amount = 50

/obj/item/stack/tile/carpet/royalblue/fifty
	amount = 50

/obj/item/stack/tile/carpet/executive/thirty
	amount = 30

/obj/item/stack/tile/carpet/stellar/thirty
	amount = 30

/obj/item/stack/tile/carpet/donk/thirty
	amount = 30

/obj/item/stack/tile/carpet/bear
	name = "bear fur carpet"
	desc = "Bear fur stretched out into a carpet for you to walk on."
	icon_state = "tile-carpet-bear"
	turf_type = /turf/open/floor/carpet/bear
	merge_type = /obj/item/stack/tile/carpet/bear
	tile_reskin_types = null

/obj/item/stack/tile/carpet/polar_bear
	name = "polar fur carpet"
	desc = "Polar bear fur stretched out into a carpet for you to walk on."
	icon_state = "tile-carpet-bear-polar"
	inhand_icon_state = "tile-silver"
	turf_type = /turf/open/floor/carpet/polar_bear
	merge_type = /obj/item/stack/tile/carpet/polar_bear
	tile_reskin_types = null

/obj/item/stack/tile/carpet/moth
	name = "moth fur carpet"
	desc = "Moth fur stretched out into a carpet for you to walk on."
	icon_state = "tile-carpet-moth"
	inhand_icon_state = "tile-bananium"
	turf_type = /turf/open/floor/carpet/moth
	merge_type = /obj/item/stack/tile/carpet/moth
	tile_reskin_types = null

/obj/item/stack/tile/carpet/goliath
	name = "goliath hide carpet"
	desc = "Goliath hide plates woven together with watcher sinew to make something aproximating a carpet."
	icon_state = "tile-carpet-goliath"
	inhand_icon_state = "tile-carpet-goliath"
	turf_type = /turf/open/floor/carpet/goliath
	merge_type = /obj/item/stack/tile/carpet/goliath
	tile_reskin_types = null

/obj/item/stack/tile/carpet/carp
	name = "carp scales carpet"
	desc = "Carpet made with carp scales. A carp carpet. Carp carp carp."
	icon_state = "tile-carpet-carp"
	inhand_icon_state = "tile-carpet-carp"
	turf_type = /turf/open/floor/carpet/carp
	merge_type = /obj/item/stack/tile/carpet/carp
	tile_reskin_types = null

/obj/item/stack/tile/carpet/lizard
	name = "lizard scales carpet"
	desc = "Carpet made with lizard scales. Lizards were most likely harmed making this."
	icon_state = "tile-carpet-lizard"
	inhand_icon_state = "tile-uranium"
	turf_type = /turf/open/floor/carpet/lizard
	merge_type = /obj/item/stack/tile/carpet/lizard
	tile_reskin_types = null

/obj/item/stack/tile/carpet/human
	name = "human skin carpet"
	desc = "Carpet made from flayed human skin. Fresh and moist."
	icon_state = "tile-carpet-skin"
	inhand_icon_state = "tile-carpet-skin"
	turf_type = /turf/open/floor/carpet/human
	merge_type = /obj/item/stack/tile/carpet/human
	tile_reskin_types = null

/obj/item/stack/tile/carpet/neon
	name = "neon carpet"
	singular_name = "neon carpet tile"
	desc = "A piece of rubbery mat inset with a phosphorescent pattern."
	inhand_icon_state = "tile-neon"
	turf_type = /turf/open/floor/carpet/neon
	merge_type = /obj/item/stack/tile/carpet/neon
	tile_reskin_types = null


	// Neon overlay
	/// The icon used for the neon overlay and emissive overlay.
	var/neon_icon
	/// The icon state used for the neon overlay and emissive overlay.
	var/neon_icon_state
	/// The icon state used for the neon overlay inhands.
	var/neon_inhand_icon_state
	/// The color used for the neon overlay.
	var/neon_color
	/// The alpha used for the emissive overlay.
	var/emissive_alpha = 150

/obj/item/stack/tile/carpet/neon/update_overlays()
	. = ..()
	var/mutable_appearance/neon_overlay = mutable_appearance(neon_icon || icon, neon_icon_state || icon_state, alpha = alpha)
	neon_overlay.color = neon_color
	. += neon_overlay
	. += emissive_appearance(neon_icon || icon, neon_icon_state || icon_state, src, alpha = emissive_alpha)

/obj/item/stack/tile/carpet/neon/worn_overlays(mutable_appearance/standing, isinhands, icon_file, bodyshape = NONE)
	. = ..()
	if(!isinhands || !neon_inhand_icon_state)
		return

	var/mutable_appearance/neon_overlay = mutable_appearance(icon_file, neon_inhand_icon_state)
	neon_overlay.color = neon_color
	. += neon_overlay
	. += emissive_appearance(icon_file, neon_inhand_icon_state, src, alpha = emissive_alpha)

/obj/item/stack/tile/carpet/neon/simple
	name = "simple neon carpet"
	singular_name = "simple neon carpet tile"
	icon_state = "tile_carpet_neon_simple"
	neon_icon_state = "tile_carpet_neon_simple_light"
	neon_inhand_icon_state = "tile-neon-glow"
	turf_type = /turf/open/floor/carpet/neon/simple
	merge_type = /obj/item/stack/tile/carpet/neon/simple
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple,
		/obj/item/stack/tile/carpet/neon/simple/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	neon_inhand_icon_state = "tile-neon-glow-nodots"
	turf_type = /turf/open/floor/carpet/neon/simple
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple,
		/obj/item/stack/tile/carpet/neon/simple/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/white
	name = "simple white neon carpet"
	singular_name = "simple white neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/white
	merge_type = /obj/item/stack/tile/carpet/neon/simple/white
	neon_color = COLOR_WHITE
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/white,
		/obj/item/stack/tile/carpet/neon/simple/white/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/white/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/white/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/white/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/white,
		/obj/item/stack/tile/carpet/neon/simple/white/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/black
	name = "simple black neon carpet"
	singular_name = "simple black neon carpet tile"
	neon_icon_state = "tile_carpet_neon_simple_glow"
	turf_type = /turf/open/floor/carpet/neon/simple/black
	merge_type = /obj/item/stack/tile/carpet/neon/simple/black
	neon_color = COLOR_BLACK
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/black,
		/obj/item/stack/tile/carpet/neon/simple/black/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/black/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_glow_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/black/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/black/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/black,
		/obj/item/stack/tile/carpet/neon/simple/black/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/red
	name = "simple red neon carpet"
	singular_name = "simple red neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/red
	merge_type = /obj/item/stack/tile/carpet/neon/simple/red
	neon_color = COLOR_RED
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/red,
		/obj/item/stack/tile/carpet/neon/simple/red/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/red/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/red/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/red/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/red,
		/obj/item/stack/tile/carpet/neon/simple/red/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/orange
	name = "simple orange neon carpet"
	singular_name = "simple orange neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/orange
	merge_type = /obj/item/stack/tile/carpet/neon/simple/orange
	neon_color = COLOR_ORANGE
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/orange,
		/obj/item/stack/tile/carpet/neon/simple/orange/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/orange/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/orange/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/orange/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/orange,
		/obj/item/stack/tile/carpet/neon/simple/orange/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/yellow
	name = "simple yellow neon carpet"
	singular_name = "simple yellow neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/yellow
	merge_type = /obj/item/stack/tile/carpet/neon/simple/yellow
	neon_color = COLOR_YELLOW
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/yellow,
		/obj/item/stack/tile/carpet/neon/simple/yellow/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/yellow/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/yellow/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/yellow/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/yellow,
		/obj/item/stack/tile/carpet/neon/simple/yellow/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/lime
	name = "simple lime neon carpet"
	singular_name = "simple lime neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/lime
	merge_type = /obj/item/stack/tile/carpet/neon/simple/lime
	neon_color = COLOR_LIME
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/lime,
		/obj/item/stack/tile/carpet/neon/simple/lime/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/lime/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/lime/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/lime/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/lime,
		/obj/item/stack/tile/carpet/neon/simple/lime/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/green
	name = "simple green neon carpet"
	singular_name = "simple green neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/green
	merge_type = /obj/item/stack/tile/carpet/neon/simple/green
	neon_color = COLOR_GREEN
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/green,
		/obj/item/stack/tile/carpet/neon/simple/green/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/green/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/green/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/green/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/green,
		/obj/item/stack/tile/carpet/neon/simple/green/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/teal
	name = "simple teal neon carpet"
	singular_name = "simple teal neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/teal
	merge_type = /obj/item/stack/tile/carpet/neon/simple/teal
	neon_color = COLOR_TEAL
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/teal,
		/obj/item/stack/tile/carpet/neon/simple/teal/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/teal/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/teal/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/teal/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/teal,
		/obj/item/stack/tile/carpet/neon/simple/teal/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/cyan
	name = "simple cyan neon carpet"
	singular_name = "simple cyan neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/cyan
	merge_type = /obj/item/stack/tile/carpet/neon/simple/cyan
	neon_color = COLOR_CYAN
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/cyan,
		/obj/item/stack/tile/carpet/neon/simple/cyan/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/cyan/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/cyan/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/cyan/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/cyan,
		/obj/item/stack/tile/carpet/neon/simple/cyan/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/blue
	name = "simple blue neon carpet"
	singular_name = "simple blue neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/blue
	merge_type = /obj/item/stack/tile/carpet/neon/simple/blue
	neon_color = COLOR_BLUE
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/blue,
		/obj/item/stack/tile/carpet/neon/simple/blue/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/blue/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/blue/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/blue/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/blue,
		/obj/item/stack/tile/carpet/neon/simple/blue/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/purple
	name = "simple purple neon carpet"
	singular_name = "simple purple neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/purple
	merge_type = /obj/item/stack/tile/carpet/neon/simple/purple
	neon_color = COLOR_PURPLE
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/purple,
		/obj/item/stack/tile/carpet/neon/simple/purple/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/purple/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/purple/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/purple/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/purple,
		/obj/item/stack/tile/carpet/neon/simple/purple/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/violet
	name = "simple violet neon carpet"
	singular_name = "simple violet neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/violet
	merge_type = /obj/item/stack/tile/carpet/neon/simple/violet
	neon_color = COLOR_VIOLET
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/violet,
		/obj/item/stack/tile/carpet/neon/simple/violet/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/violet/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/violet/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/violet/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/violet,
		/obj/item/stack/tile/carpet/neon/simple/violet/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/pink
	name = "simple pink neon carpet"
	singular_name = "simple pink neon carpet tile"
	turf_type = /turf/open/floor/carpet/neon/simple/pink
	merge_type = /obj/item/stack/tile/carpet/neon/simple/pink
	neon_color = COLOR_LIGHT_PINK
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/pink,
		/obj/item/stack/tile/carpet/neon/simple/pink/nodots,
	)

/obj/item/stack/tile/carpet/neon/simple/pink/nodots
	icon_state = "tile_carpet_neon_simple_nodots"
	neon_icon_state = "tile_carpet_neon_simple_light_nodots"
	turf_type = /turf/open/floor/carpet/neon/simple/pink/nodots
	merge_type = /obj/item/stack/tile/carpet/neon/simple/pink/nodots
	tile_reskin_types = list(
		/obj/item/stack/tile/carpet/neon/simple/pink,
		/obj/item/stack/tile/carpet/neon/simple/pink/nodots,
	)

/obj/item/stack/tile/carpet/neon/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/white/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/white/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/white/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/black/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/black/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/black/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/red/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/red/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/red/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/orange/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/orange/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/orange/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/yellow/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/yellow/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/yellow/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/lime/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/lime/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/lime/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/green/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/green/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/green/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/teal/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/teal/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/teal/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/cyan/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/cyan/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/cyan/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/blue/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/blue/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/blue/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/purple/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/purple/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/purple/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/violet/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/violet/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/violet/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/pink/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/pink/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/pink/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/white/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/white/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/white/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/black/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/black/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/black/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/red/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/red/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/red/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/orange/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/orange/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/orange/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/yellow/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/yellow/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/yellow/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/lime/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/lime/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/lime/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/green/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/green/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/green/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/teal/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/teal/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/teal/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/cyan/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/cyan/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/cyan/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/blue/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/blue/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/blue/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/purple/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/purple/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/purple/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/violet/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/violet/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/violet/nodots/sixty
	amount = 60

/obj/item/stack/tile/carpet/neon/simple/pink/nodots/ten
	amount = 10

/obj/item/stack/tile/carpet/neon/simple/pink/nodots/thirty
	amount = 30

/obj/item/stack/tile/carpet/neon/simple/pink/nodots/sixty
	amount = 60

/obj/item/stack/tile/fakespace
	name = "astral carpet"
	singular_name = "astral carpet tile"
	desc = "A piece of carpet with a convincing star pattern."
	icon_state = "tile_space"
	inhand_icon_state = "tile-space"
	turf_type = /turf/open/floor/fakespace
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fakespace

/obj/item/stack/tile/fakespace/loaded
	amount = 30

/obj/item/stack/tile/fakepit
	name = "fake pits"
	singular_name = "fake pit"
	desc = "A piece of carpet with a forced perspective illusion of a pit. No way this could fool anyone!"
	icon_state = "tile_pit"
	inhand_icon_state = "tile-basalt"
	turf_type = /turf/open/floor/fakepit
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fakepit

/obj/item/stack/tile/fakepit/loaded
	amount = 30

/obj/item/stack/tile/fakeice
	name = "fake ice"
	singular_name = "fake ice tile"
	desc = "A piece of tile with a convincing ice pattern."
	icon_state = "tile_ice"
	inhand_icon_state = "tile-diamond"
	turf_type = /turf/open/floor/fakeice
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fakeice

/obj/item/stack/tile/fakeice/loaded
	amount = 30

//High-traction
/obj/item/stack/tile/noslip
	name = "high-traction floor tile"
	singular_name = "high-traction floor tile"
	desc = "A high-traction floor tile. It feels rubbery in your hand."
	icon_state = "tile_noslip"
	inhand_icon_state = "tile-noslip"
	turf_type = /turf/open/floor/noslip
	merge_type = /obj/item/stack/tile/noslip

/obj/item/stack/tile/noslip/thirty
	amount = 30

/obj/item/stack/tile/noslip/tram
	name = "high-traction platform tile"
	singular_name = "high-traction platform tile"
	desc = "A titanium-aluminium induction plate that powers the tram."
	icon_state = "tile_noslip"
	inhand_icon_state = "tile-noslip"
	turf_type = /turf/open/floor/noslip/tram
	merge_type = /obj/item/stack/tile/noslip/tram

/obj/item/stack/tile/tram
	name = "tram platform tiles"
	singular_name = "tram platform"
	desc = "A tile used for tram platforms."
	icon_state = "darkiron_catwalk"
	inhand_icon_state = "tile-neon"
	turf_type = /turf/open/floor/tram
	merge_type = /obj/item/stack/tile/tram

/obj/item/stack/tile/tram/plate
	name = "linear induction tram tiles"
	singular_name = "linear induction tram tile"
	desc = "A tile with an aluminium plate for tram propulsion."
	icon_state = "darkiron_plate"
	inhand_icon_state = "tile-neon"
	turf_type = /turf/open/floor/tram/plate
	merge_type = /obj/item/stack/tile/tram/plate

//Circuit
/obj/item/stack/tile/circuit
	name = "blue circuit tile"
	singular_name = "blue circuit tile"
	desc = "A blue circuit tile."
	icon_state = "tile_bcircuit"
	inhand_icon_state = "tile-bcircuit"
	turf_type = /turf/open/floor/circuit
	merge_type = /obj/item/stack/tile/circuit
	tile_reskin_types = list(
		/obj/item/stack/tile/circuit,
		/obj/item/stack/tile/circuit/green,
		/obj/item/stack/tile/circuit/red,
	)
	mats_per_unit = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.05, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.05)

/obj/item/stack/tile/circuit/green
	name = "green circuit tile"
	singular_name = "green circuit tile"
	desc = "A green circuit tile."
	icon_state = "tile_gcircuit"
	inhand_icon_state = "tile-gcircuit"
	turf_type = /turf/open/floor/circuit/green
	merge_type = /obj/item/stack/tile/circuit/green

/obj/item/stack/tile/circuit/green/anim
	turf_type = /turf/open/floor/circuit/green/anim
	merge_type = /obj/item/stack/tile/circuit/green/anim

/obj/item/stack/tile/circuit/red
	name = "red circuit tile"
	singular_name = "red circuit tile"
	desc = "A red circuit tile."
	icon_state = "tile_rcircuit"
	inhand_icon_state = "tile-rcircuit"
	turf_type = /turf/open/floor/circuit/red
	merge_type = /obj/item/stack/tile/circuit/red

/obj/item/stack/tile/circuit/red/anim
	turf_type = /turf/open/floor/circuit/red/anim
	merge_type = /obj/item/stack/tile/circuit/red/anim

/obj/item/stack/tile/circuit/ash
	name = "ornate ash forge tile"
	singular_name = "ornate ash forge tile"
	desc = "An ashen, ornate forge tile. Normaly seen in photos of ethereal homeworld's industrial areas."
	icon_state = "tile_ash"
	inhand_icon_state = "tile-rcircuit"
	turf_type = /turf/open/floor/circuit/red
	merge_type = /obj/item/stack/tile/circuit/red
	tile_reskin_types = list(
		/obj/item/stack/tile/circuit/ash,
		/obj/item/stack/tile/circuit/ash/alt,
	)
	mats_per_unit = list(/datum/material/alloy/plastitanium = HALF_SHEET_MATERIAL_AMOUNT / 3)

/obj/item/stack/tile/circuit/ash/alt
	name = "ash forge tile"
	singular_name = "ash forge tile"
	desc = "An ashen forge tile. Normaly seen in photos of ethereal homeworld's industrial areas."
	icon_state = "tile_ash_alt"
	turf_type = /turf/open/floor/circuit/ash/alt
	merge_type = /obj/item/stack/tile/circuit/ash/alt

/obj/item/stack/tile/plastic
	name = "plastic tile"
	singular_name = "plastic floor tile"
	desc = "A tile of cheap, flimsy plastic flooring."
	icon_state = "tile_plastic"
	inhand_icon_state = "tile-bluespace"
	mats_per_unit = list(/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT / 2)
	turf_type = /turf/open/floor/plastic
	merge_type = /obj/item/stack/tile/plastic
	tile_reskin_types = list(
		/obj/item/stack/tile/plastic,
		/obj/item/stack/tile/plastic/puzzle,
	)

/obj/item/stack/tile/plastic/puzzle
	name = "puzzle tile"
	icon_state = "plastic_puzzle"
	singular_name = "puzzle floor tile"
	turf_type = /turf/open/floor/plastic/puzzle
	merge_type = /obj/item/stack/tile/plastic/puzzle
	desc = "A tile of cheap, puzzling plastic puzzles flooring."

/obj/item/stack/tile/meat
	name = "meat tile"
	singular_name = "meat floor tile"
	desc = "From big Barry's builders best barbecue. This one looks a little stale."
	icon_state = "tile_meat"
	inhand_icon_state = "tile-meat"
	mats_per_unit = list(/datum/material/meat = HALF_SHEET_MATERIAL_AMOUNT / 2)
	turf_type = /turf/open/floor/meat
	merge_type = /obj/item/stack/tile/meat
	tile_reskin_types = list(
		/obj/item/stack/tile/meat,
		/obj/item/stack/tile/meat/fresh,
	)

/obj/item/stack/tile/meat/fresh
	name = "fresh meat tile"
	singular_name = "fresh meat floor tile"
	desc = "Fresh from big Barry's builders best barbecue."
	icon_state = "tile_meat_fresh"
	turf_type = /turf/open/floor/meat/fresh
	merge_type = /obj/item/stack/tile/meat/fresh

/obj/item/stack/tile/bone
	name = "bone tile"
	singular_name = "bone floor tile"
	desc = "Don't question where the dirt around it came from."
	icon_state = "tile_bone"
	inhand_icon_state = "tile-sepia"
	mats_per_unit = list(/datum/material/bone = HALF_SHEET_MATERIAL_AMOUNT / 2)
	turf_type = /turf/open/floor/bone
	merge_type = /obj/item/stack/tile/bone
	tile_reskin_types = list(
		/obj/item/stack/tile/bone,
		/obj/item/stack/tile/bone/corner,
		/obj/item/stack/tile/bone/straight,
		/obj/item/stack/tile/bone/spine,
		/obj/item/stack/tile/bone/meaty,
		/obj/item/stack/tile/bone/meaty/corner,
		/obj/item/stack/tile/bone/meaty/straight,
		/obj/item/stack/tile/bone/meaty/spine,
	)

/obj/item/stack/tile/bone/corner
	name = "bone corner tile"
	singular_name = "bone corner floor tile"
	icon_state = "bone_corner"
	turf_type = /turf/open/floor/bone/corner
	merge_type = /obj/item/stack/tile/bone/corner
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST)

/obj/item/stack/tile/bone/straight
	name = "bone straight tile"
	singular_name = "bone straight floor tile"
	icon_state = "bone_straight"
	turf_type = /turf/open/floor/bone/straight
	merge_type = /obj/item/stack/tile/bone/straight
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST)

/obj/item/stack/tile/bone/spine
	name = "bone spine tile"
	singular_name = "bone spine floor tile"
	icon_state = "bone_spine"
	turf_type = /turf/open/floor/bone/spine
	merge_type = /obj/item/stack/tile/bone/spine
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST)

/obj/item/stack/tile/bone/meaty
	name = "meaty bone tile"
	singular_name = "meaty bone floor tile"
	desc = "Don't question where the meat around it came from."
	icon_state = "tile_meatbone"
	inhand_icon_state = "tile-meat"
	turf_type = /turf/open/floor/bone/meaty
	merge_type = /obj/item/stack/tile/bone/meaty

/obj/item/stack/tile/bone/meaty/corner
	name = "meaty bone corner tile"
	singular_name = "meaty bone corner floor tile"
	icon_state = "meatbone_corner"
	turf_type = /turf/open/floor/bone/meaty/corner
	merge_type = /obj/item/stack/tile/bone/meaty/corner
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST)

/obj/item/stack/tile/bone/meaty/straight
	name = "meaty bone straight tile"
	singular_name = "meaty bone straight floor tile"
	icon_state = "meatbone_straight"
	turf_type = /turf/open/floor/bone/meaty/straight
	merge_type = /obj/item/stack/tile/bone/meaty/straight
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST)

/obj/item/stack/tile/bone/meaty/spine
	name = "meaty bone spine tile"
	singular_name = "meaty bone spine floor tile"
	icon_state = "meatbone_spine"
	turf_type = /turf/open/floor/bone/meaty/spine
	merge_type = /obj/item/stack/tile/bone/meaty/spine
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST)

/obj/item/stack/tile/hauntium
	name = "hauntium tile"
	singular_name = "hauntium floor tile"
	desc = "Dead men walking? More like walking over dead men."
	icon_state = "tile_hauntium"
	inhand_icon_state = "tile-hauntium"
	mats_per_unit = list(/datum/material/hauntium = HALF_SHEET_MATERIAL_AMOUNT / 2)
	turf_type = /turf/open/floor/hauntium
	merge_type = /obj/item/stack/tile/hauntium
	tile_reskin_types = list(
		/obj/item/stack/tile/hauntium,
		/obj/item/stack/tile/hauntium/ghostbricked,
	)

/obj/item/stack/tile/hauntium/ghostbricked
	name = "ghostbricked hauntium tile"
	singular_name = "ghostbricked hauntium floor tile"
	icon_state = "tile_hauntium_ghostbricked"
	turf_type = /turf/open/floor/hauntium/ghostbricked
	merge_type = /obj/item/stack/tile/hauntium/ghostbricked

/obj/item/stack/tile/neo
	name = "neo tile"
	singular_name = "neo floor tile"
	inhand_icon_state = "tile-neon"
	mats_per_unit = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT / 2)
	turf_type = /turf/open/floor/neo
	merge_type = /obj/item/stack/tile/neo
	tile_reskin_types = list(
		/obj/item/stack/tile/neo/red,
		/obj/item/stack/tile/neo/purple,
		/obj/item/stack/tile/neo/orange,
		/obj/item/stack/tile/neo/cyan,
	)

/obj/item/stack/tile/neo/red
	name = "red neo tile"
	singular_name = "red neo floor tile"
	desc =  "A neo tile. Radiates with the power of ketchup."
	icon_state = "neo_red"
	turf_type = /turf/open/floor/neo/red
	merge_type = /obj/item/stack/tile/neo/red

/obj/item/stack/tile/neo/purple
	name = "purple neo tile"
	singular_name = "purple neo floor tile"
	desc = "A neo tile. Radiates with the power of neo. Duh."
	icon_state = "neo_purple"
	turf_type = /turf/open/floor/neo/purple
	merge_type = /obj/item/stack/tile/neo/purple

/obj/item/stack/tile/neo/orange
	name = "orange neo tile"
	singular_name = "orange neo floor tile"
	desc = "A neo tile. Radiates with the power of 80s stylized sunset and tequilla."
	icon_state = "neo_orange"
	turf_type = /turf/open/floor/neo/orange
	merge_type = /obj/item/stack/tile/neo/orange

/obj/item/stack/tile/neo/cyan
	name = "cyan neo tile"
	singular_name = "cyan neo floor tile"
	desc = "A neo tile. Radiates with the power of being pedantic about colour names."
	icon_state = "neo_cyan"
	turf_type = /turf/open/floor/neo/cyan
	merge_type = /obj/item/stack/tile/neo/cyan

/obj/item/stack/tile/silvergold
	name = "silver and gold floor"
	desc = "Floor made from silver and gold, in scaly pattern. As if just one or the other wasn't lavish enough."
	icon_state = "blade"
	singular_name = "silver and gold tile"
	inhand_icon_state = "tile-silvergold"
	mats_per_unit = list(/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT / 4, /datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT / 4)
	turf_type = /turf/open/floor/silvergold
	merge_type = /obj/item/stack/tile/silvergold
	tile_reskin_types = list(
		/obj/item/stack/tile/silvergold,
		/obj/item/stack/tile/silvergold/sword,
		/obj/item/stack/tile/silvergold/void,
		/obj/item/stack/tile/silvergold/flow,
	)

/obj/item/stack/tile/silvergold/sword
	name = "sword tile"
	singular_name = "sword tile"
	desc = "Floor made from silver and gold, in scaly pattern, with a sword in the middle."
	icon_state = "blade_sword"
	turf_type = /turf/open/floor/silvergold/sword
	merge_type = /obj/item/stack/tile/silvergold/sword

/obj/item/stack/tile/silvergold/void
	name = "stars tile"
	singular_name = "stars tile"
	desc = "Floor made from silver and gold, picturing stars. As opposed to the actual stars you are surrounded by."
	icon_state = "void"
	turf_type = /turf/open/floor/silvergold/void
	merge_type = /obj/item/stack/tile/silvergold/void

/obj/item/stack/tile/silvergold/flow
	name = "flowing tile"
	singular_name = "flowing tile"
	desc = "Floor made from silver and gold, with a flowing pattern. Silver and gold in balance."
	icon_state = "flow"
	turf_type = /turf/open/floor/silvergold/flow
	merge_type = /obj/item/stack/tile/silvergold/flow

/obj/item/stack/tile/material
	name = "floor tile"
	singular_name = "floor tile"
	desc = "The ground you walk on."
	throwforce = 10
	icon_state = "material_tile"
	inhand_icon_state = "tile"
	turf_type = /turf/open/floor/material
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	merge_type = /obj/item/stack/tile/material

/obj/item/stack/tile/material/place_tile(turf/open/target_plating, mob/user)
	// Save refernce to the materials for the case when we place last tile in the stack
	var/list/saved_mats_per_unit = mats_per_unit
	. = ..()
	var/turf/open/floor/material/floor = .
	floor?.set_custom_materials(saved_mats_per_unit)

/obj/item/stack/tile/eighties
	name = "retro tile"
	singular_name = "retro floor tile"
	desc = "A stack of floor tiles that remind you of an age of funk. Use in your hand to pick between a black or red pattern."
	icon_state = "tile_eighties"
	turf_type = /turf/open/floor/eighties
	merge_type = /obj/item/stack/tile/eighties
	tile_reskin_types = list(
		/obj/item/stack/tile/eighties,
		/obj/item/stack/tile/eighties/red,
	)

/obj/item/stack/tile/eighties/loaded
	amount = 15

/obj/item/stack/tile/eighties/red
	name = "red retro tile"
	singular_name = "red retro floor tile"
	desc = "A stack of REDICAL floor tiles! Use in your hand to pick between a black or red pattern!" //i am so sorry
	icon_state = "tile_eightiesred"
	turf_type = /turf/open/floor/eighties/red
	merge_type = /obj/item/stack/tile/eighties/red

/obj/item/stack/tile/bronze
	name = "bronze tile"
	singular_name = "bronze floor tile"
	desc = "A clangy tile made of high-quality bronze. Clockwork construction techniques allow the clanging to be minimized."
	icon_state = "tile_brass"
	turf_type = /turf/open/floor/bronze
	mats_per_unit = list(/datum/material/bronze = HALF_SHEET_MATERIAL_AMOUNT / 2)
	merge_type = /obj/item/stack/tile/bronze
	tile_reskin_types = list(
		/obj/item/stack/tile/bronze,
		/obj/item/stack/tile/bronze/flat,
		/obj/item/stack/tile/bronze/filled,
	)

/obj/item/stack/tile/bronze/flat
	name = "flat bronze tile"
	singular_name = "flat bronze floor tile"
	icon_state = "tile_reebe"
	turf_type = /turf/open/floor/bronze/flat
	merge_type = /obj/item/stack/tile/bronze/flat

/obj/item/stack/tile/bronze/filled
	name = "filled bronze tile"
	singular_name = "filled bronze floor tile"
	icon_state = "tile_brass_filled"
	turf_type = /turf/open/floor/bronze/filled
	merge_type = /obj/item/stack/tile/bronze/filled

/obj/item/stack/tile/bronze/window
	name = "bronze window tile"
	singular_name = "bronze window floor tile"
	icon_state = "tile_glass_bronze"
	turf_type = /turf/open/floor/glass/bronze
	merge_type = /obj/item/stack/tile/bronze/window

/obj/item/stack/tile/cult
	name = "engraved tile"
	singular_name = "engraved floor tile"
	desc = "A strange tile made from runed metal. Doesn't seem to actually have any paranormal powers."
	icon_state = "tile_cult"
	turf_type = /turf/open/floor/cult
	mats_per_unit = list(/datum/material/runedmetal=SMALL_MATERIAL_AMOUNT*5)
	merge_type = /obj/item/stack/tile/cult
	tile_reskin_types = list(
		/obj/item/stack/tile/cult,
		/obj/item/stack/tile/cult/window,
	)

/obj/item/stack/tile/cult/window
	name = "engraved window tile"
	singular_name = "engraved window tile"
	desc = "A strange window tile made from runed metal. Doesn't seem to actually have any paranormal powers."
	icon_state = "tile_glass_runic"
	turf_type = /turf/open/floor/glass/cult
	mats_per_unit = list(/datum/material/runedmetal=SMALL_MATERIAL_AMOUNT*5)
	merge_type = /obj/item/stack/tile/cult/window

/// Plasteel

/obj/item/stack/tile/plasteel
	name = "plasteel tile"
	singular_name = "plasteel floor tile"
	desc = "Industrial plasteel tiles, tough and reinforced."
	icon_state = "plasteel"
	inhand_icon_state = "tile-shuttle"
	turf_type = /turf/open/floor/mineral/plasteel
	mats_per_unit = list(/datum/material/alloy/plasteel=SHEET_MATERIAL_AMOUNT*0.25)
	merge_type = /obj/item/stack/tile/plasteel
	tile_reskin_types = list(
		/obj/item/stack/tile/plasteel,
		/obj/item/stack/tile/plasteel/straight,
		/obj/item/stack/tile/plasteel/corner,
		/obj/item/stack/tile/plasteel/block,
		/obj/item/stack/tile/plasteel/lock,
		/obj/item/stack/tile/plasteel/tiled,
		)

/obj/item/stack/tile/plasteel/straight
	name = "straight plasteel tile"
	singular_name = "straight plasteel floor tile"
	desc = "Industrial straight plasteel tiles, tough and reinforced."
	turf_type = /turf/open/floor/mineral/plasteel/straight
	icon_state = "plasteel_straight"
	merge_type = /obj/item/stack/tile/plasteel/straight

/obj/item/stack/tile/plasteel/corner
	name = "corner plasteel tile"
	singular_name = "corner plasteel floor tile"
	desc = "Industrial corner plasteel tiles, tough and reinforced."
	turf_type = /turf/open/floor/mineral/plasteel/corner
	icon_state = "plasteel_corner"
	merge_type = /obj/item/stack/tile/plasteel/corner

/obj/item/stack/tile/plasteel/block
	name = "blocky plasteel tile"
	singular_name = "blocky plasteel floor tile"
	desc = "Blocky plasteel tiles, quite futuristic."
	turf_type = /turf/open/floor/mineral/plasteel/block
	icon_state = "block"
	merge_type = /obj/item/stack/tile/plasteel/block

/obj/item/stack/tile/plasteel/lock
	name = "locked plasteel tile"
	singular_name = "locked plasteel floor tile"
	desc = "Locked plasteel tiles, with a keyhole symbol in the middle. Could be a pawn, though?"
	turf_type = /turf/open/floor/mineral/plasteel/lock
	icon_state = "lock"
	merge_type = /obj/item/stack/tile/plasteel/lock

/obj/item/stack/tile/plasteel/tiled
	name = "plasteel tiled"
	singular_name = "tiled plasteel"
	desc = "Plasteel, tiled."
	turf_type = /turf/open/floor/mineral/plasteel/tiled
	icon_state = "plasteel_tiled"
	merge_type = /obj/item/stack/tile/plasteel/tiled

/// Floor tiles used to test emissive turfs.
/obj/item/stack/tile/emissive_test
	name = "emissive test tile"
	singular_name = "emissive test floor tile"
	desc = "A glow-in-the-dark floor tile used to test emissive turfs."
	turf_type = /turf/open/floor/emissive_test
	merge_type = /obj/item/stack/tile/emissive_test

/obj/item/stack/tile/emissive_test/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, alpha = alpha)

/obj/item/stack/tile/emissive_test/worn_overlays(mutable_appearance/standing, isinhands, icon_file, bodyshape = NONE)
	. = ..()
	. += emissive_appearance(standing.icon, standing.icon_state, src, alpha = standing.alpha)

/obj/item/stack/tile/emissive_test/sixty
	amount = 60

/obj/item/stack/tile/emissive_test/white
	name = "white emissive test tile"
	singular_name = "white emissive test floor tile"
	turf_type = /turf/open/floor/emissive_test/white
	merge_type = /obj/item/stack/tile/emissive_test/white

/obj/item/stack/tile/emissive_test/white/sixty
	amount = 60

//Catwalk Tiles
/obj/item/stack/tile/catwalk_tile //This is our base type, sprited to look maintenance-styled
	name = "catwalk plating"
	singular_name = "catwalk plating tile"
	desc = "Flooring that shows its contents underneath. Engineers love it!"
	icon_state = "maint_catwalk"
	inhand_icon_state = "tile-catwalk"
	mats_per_unit = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.2)
	turf_type = /turf/open/floor/catwalk_floor
	merge_type = /obj/item/stack/tile/catwalk_tile //Just to be cleaner, these all stack with each other
	tile_reskin_types = list(
		/obj/item/stack/tile/catwalk_tile,
		/obj/item/stack/tile/catwalk_tile/iron,
		/obj/item/stack/tile/catwalk_tile/iron_white,
		/obj/item/stack/tile/catwalk_tile/iron_dark,
		/obj/item/stack/tile/catwalk_tile/titanium,
		/obj/item/stack/tile/catwalk_tile/iron_smooth //this is the original greenish one
	)

/obj/item/stack/tile/catwalk_tile/sixty
	amount = 60

/obj/item/stack/tile/catwalk_tile/iron
	name = "iron catwalk floor"
	singular_name = "iron catwalk floor tile"
	icon_state = "iron_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/iron

/obj/item/stack/tile/catwalk_tile/iron_white
	name = "white catwalk floor"
	singular_name = "white catwalk floor tile"
	icon_state = "whiteiron_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/iron_white

/obj/item/stack/tile/catwalk_tile/iron_dark
	name = "dark catwalk floor"
	singular_name = "dark catwalk floor tile"
	icon_state = "darkiron_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/iron_dark

/obj/item/stack/tile/catwalk_tile/titanium
	name = "titanium catwalk floor"
	singular_name = "titanium catwalk floor tile"
	icon_state = "titanium_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/titanium

/obj/item/stack/tile/catwalk_tile/iron_smooth //this is the greenish one
	name = "smooth iron catwalk floor"
	singular_name = "smooth iron catwalk floor tile"
	icon_state = "smoothiron_catwalk"
	turf_type = /turf/open/floor/catwalk_floor/iron_smooth

// Glass floors
/obj/item/stack/tile/glass
	name = "glass floor"
	singular_name = "glass floor tile"
	desc = "Glass window floors, to let you see... Whatever that is down there."
	icon_state = "tile_glass"
	turf_type = /turf/open/floor/glass
	inhand_icon_state = "tile-glass"
	merge_type = /obj/item/stack/tile/glass
	mats_per_unit = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT * 0.25) // 4 tiles per sheet

/obj/item/stack/tile/glass/sixty
	amount = 60

/obj/item/stack/tile/rglass
	name = "reinforced glass floor"
	singular_name = "reinforced glass floor tile"
	desc = "Reinforced glass window floors. These bad boys are 50% stronger than their predecessors!"
	icon_state = "tile_rglass"
	inhand_icon_state = "tile-rglass"
	turf_type = /turf/open/floor/glass/reinforced
	merge_type = /obj/item/stack/tile/rglass
	mats_per_unit = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.125, /datum/material/glass=SHEET_MATERIAL_AMOUNT * 0.25) // 4 tiles per sheet

/obj/item/stack/tile/rglass/sixty
	amount = 60

/obj/item/stack/tile/glass/plasma
	name = "plasma glass floor"
	singular_name = "plasma glass floor tile"
	desc = "Plasma glass window floors, for when... Whatever is down there is too scary for normal glass."
	icon_state = "tile_pglass"
	turf_type = /turf/open/floor/glass/plasma
	merge_type = /obj/item/stack/tile/glass/plasma
	mats_per_unit = list(/datum/material/alloy/plasmaglass = SHEET_MATERIAL_AMOUNT * 0.25)

/obj/item/stack/tile/rglass/plasma
	name = "reinforced plasma glass floor"
	singular_name = "reinforced plasma glass floor tile"
	desc = "Reinforced plasma glass window floors, because whatever's downstairs should really stay down there."
	icon_state = "tile_rpglass"
	turf_type = /turf/open/floor/glass/reinforced/plasma
	merge_type = /obj/item/stack/tile/rglass/plasma
	mats_per_unit = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.125, /datum/material/alloy/plasmaglass = SHEET_MATERIAL_AMOUNT * 0.25)

/obj/item/stack/tile/glass/titanium
	name = "titanium glass floor"
	singular_name = "titanium glass floor tile"
	desc = "Titanium glass window floors, for when you need something to separate you from the vast void of space."
	icon_state = "tile_glass_titanium"
	turf_type = /turf/open/floor/glass/titatanium
	merge_type = /obj/item/stack/tile/glass/titanium
	mats_per_unit = list(/datum/material/alloy/titaniumglass = SHEET_MATERIAL_AMOUNT * 0.25)

/obj/item/stack/tile/glass/plastitanium
	name = "plastitanium glass floor"
	singular_name = "plasma glass floor tile"
	desc = "Plastitatanium glass window floors, for when you don't want lava to burn your feet, but still like to see it."
	icon_state = "tile_glass_plastitanium"
	turf_type = /turf/open/floor/glass/plastitatanium
	merge_type = /obj/item/stack/tile/glass/plastitanium
	mats_per_unit = list(/datum/material/alloy/plastitaniumglass = SHEET_MATERIAL_AMOUNT * 0.25)

/obj/item/stack/tile/stained_glass
	name = "stained glass floor"
	singular_name = "stained glass floor tile"
	desc = "This shouldn't exist."
	icon_state = null
	turf_type = /turf/open/floor/glass
	inhand_icon_state = "tile-glass"
	merge_type = /obj/item/stack/tile/stained_glass
	mats_per_unit = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT * 0.25, /datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.25,)

/obj/item/stack/tile/stained_glass/red
	name = "red stained glass floor"
	singular_name = "red stained glass floor tile"
	desc = "Glass floor, stained red. Not with blood, hopefuly."
	icon_state = "tile_sglass_red"
	turf_type = /turf/open/floor/glass/stained_red
	merge_type = /obj/item/stack/tile/stained_glass/red

/obj/item/stack/tile/stained_glass/orange
	name = "orange stained glass floor"
	singular_name = "orange stained glass floor tile"
	desc = "Glass floor, stained orange. Somebody spilled their orange juice?"
	icon_state = "tile_sglass_orange"
	turf_type = /turf/open/floor/glass/stained_orange
	merge_type = /obj/item/stack/tile/stained_glass/orange

/obj/item/stack/tile/stained_glass/yellow
	name = "yellow stained glass floor"
	singular_name = "yellow stained glass floor tile"
	desc = "Glass floor, stained yellow. Probably by some mellow fellow."
	icon_state = "tile_sglass_yellow"
	turf_type = /turf/open/floor/glass/stained_yellow
	merge_type = /obj/item/stack/tile/stained_glass/yellow

/obj/item/stack/tile/stained_glass/green
	name = "green stained glass floor"
	singular_name = "green stained glass floor tile"
	desc = "Glass floor, stained green. That's what you get when putting liquid uranium at the edge of your table."
	icon_state = "tile_sglass_green"
	turf_type = /turf/open/floor/glass/stained_green
	merge_type = /obj/item/stack/tile/stained_glass/green

/obj/item/stack/tile/stained_glass/blue
	name = "blue stained glass floor"
	singular_name = "blue stained glass floor tile"
	desc = "Glass floor, stained blue. With tears of someone feeling blue, obviously."
	icon_state = "tile_sglass_blue"
	turf_type = /turf/open/floor/glass/stained_blue
	merge_type = /obj/item/stack/tile/stained_glass/blue

/obj/item/stack/tile/stained_glass/purple
	name = "purple stained glass floor"
	singular_name = "purple stained glass floor tile"
	desc = "Glass floor, stained purple. It tastes purple, too."
	icon_state = "tile_sglass_purple"
	turf_type = /turf/open/floor/glass/stained_purple
	merge_type = /obj/item/stack/tile/stained_glass/purple

/obj/item/stack/tile/stained_glass/white
	name = "white stained glass floor"
	singular_name = "white stained glass floor tile"
	desc = "Glass floor, stained white. Or perhaps it was bleached?"
	icon_state = "tile_sglass_white"
	turf_type = /turf/open/floor/glass/stained_white
	merge_type = /obj/item/stack/tile/stained_glass/white

/obj/item/stack/tile/stained_glass/black
	name = "black stained glass floor"
	singular_name = "black stained glass floor tile"
	desc = "Glass floor, stained black. A space squid inked it."
	icon_state = "tile_sglass_black"
	turf_type = /turf/open/floor/glass/stained_black
	merge_type = /obj/item/stack/tile/stained_glass/black
