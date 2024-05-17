/* In this file:
 * Wood floor
 * Bamboo floor
 * Grass floor
 * Fake Basalt
 * Carpet floor
 * Fake pits
 * Fake space
 */

/turf/open/floor/wood
	desc = "Stylish dark wood."
	icon_state = "wood"
	floor_tile = /obj/item/stack/tile/wood
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/open/floor/wood/broken_states()
	return list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

/turf/open/floor/wood/examine(mob/user)
	. = ..()
	. += span_notice("There's a few <b>screws</b> and a <b>small crack</b> visible.")

/turf/open/floor/wood/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	return pry_tile(I, user) ? TRUE : FALSE

/turf/open/floor/wood/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
		return
	var/obj/item/tool = user.is_holding_item_of_type(/obj/item/screwdriver)
	if(!tool)
		tool = user.is_holding_item_of_type(/obj/item/crowbar)
	if(!tool)
		return
	var/turf/open/floor/plating/P = pry_tile(tool, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/open/floor/wood/pry_tile(obj/item/C, mob/user, silent = FALSE)
	C.play_tool_sound(src, 80)
	return remove_tile(user, silent, (C.tool_behaviour == TOOL_SCREWDRIVER))

/turf/open/floor/wood/remove_tile(mob/user, silent = FALSE, make_tile = TRUE, force_plating)
	if(broken || burnt)
		broken = FALSE
		burnt = FALSE
		if(user && !silent)
			to_chat(user, span_notice("You remove the broken planks."))
	else
		if(make_tile)
			if(user && !silent)
				to_chat(user, span_notice("You unscrew the planks."))
			spawn_tile()
		else
			if(user && !silent)
				to_chat(user, span_notice("You forcefully pry off the planks, destroying them in the process."))
	return make_plating(force_plating)

/turf/open/floor/wood/cold
	temperature = 255.37

//Used in Snowcabin.dm
/turf/open/floor/wood/freezing
	temperature = 180

/turf/open/floor/wood/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/wood/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/wood/tile
	icon_state = "wood_tile"
	floor_tile = /obj/item/stack/tile/wood/tile

/turf/open/floor/wood/tile/broken_states()
	return list("wood_tile-broken", "wood_tile-broken2", "wood_tile-broken3")

/turf/open/floor/wood/parquet
	icon_state = "wood_parquet"
	floor_tile = /obj/item/stack/tile/wood/parquet

/turf/open/floor/wood/parquet/broken_states()
	return list("wood_parquet-broken", "wood_parquet-broken2", "wood_parquet-broken3", "wood_parquet-broken4", "wood_parquet-broken5", "wood_parquet-broken6", "wood_parquet-broken7")

/turf/open/floor/wood/large
	icon_state = "wood_large"
	floor_tile = /obj/item/stack/tile/wood/large

/turf/open/floor/wood/large/broken_states()
	return list("wood_large-broken", "wood_large-broken2", "wood_large-broken3")

/turf/open/floor/bamboo
	desc = "A bamboo mat with a decorative trim."
	icon = 'icons/turf/floors/bamboo_mat.dmi'
	icon_state = "mat-0"
	base_icon_state = "mat"
	floor_tile = /obj/item/stack/tile/bamboo
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_BAMBOO_FLOOR
	canSmoothWith = SMOOTH_GROUP_BAMBOO_FLOOR
	flags_1 = NONE
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/bamboo/broken_states()
	return list("bamboodamaged")

/turf/open/floor/bamboo/tatami
	desc = "A traditional Japanese floor mat."
	icon = 'icons/turf/floors/floor_variations.dmi'
	icon_state = "bamboo-green"
	floor_tile = /obj/item/stack/tile/bamboo/tatami
	smoothing_flags = NONE

/turf/open/floor/bamboo/tatami/broken_states()
	// This state doesn't exist why is it here?
	return list("tatami-damaged")

/turf/open/floor/bamboo/tatami/purple
	icon = 'icons/turf/floors/floor_variations.dmi'
	icon_state = "bamboo-purple"
	floor_tile = /obj/item/stack/tile/bamboo/tatami/purple

/turf/open/floor/bamboo/tatami/black
	icon = 'icons/turf/floors/floor_variations.dmi'
	icon_state = "bamboo-black"
	floor_tile = /obj/item/stack/tile/bamboo/tatami/black

/turf/open/floor/grass
	name = "grass patch"
	desc = "You can't tell if this is real grass or just cheap plastic imitation."
	icon_state = "grass"
	floor_tile = /obj/item/stack/tile/grass
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	rust_resistance = RUST_RESISTANCE_ORGANIC

/turf/open/floor/grass/broken_states()
	return list("[initial(icon_state)]_damaged")

/turf/open/floor/grass/Initialize(mapload)
	. = ..()
	spawniconchange()
	AddElement(/datum/element/diggable, /obj/item/stack/ore/glass, 2, worm_chance = 50, \
		action_text = "uproot", action_text_third_person = "uproots")

/turf/open/floor/grass/proc/spawniconchange()
	icon_state = "grass[rand(0,3)]"

/turf/open/floor/grass/lavaland
	name = "dead grass patch"
	desc = "It turns out grass doesn't grow very well in hell."
	icon_state = "sand"
	broken = TRUE
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	damaged_dmi = 'icons/turf/damaged.dmi'

/turf/open/floor/grass/lavaland/spawniconchange()
	return

/turf/open/floor/grass/fairy //like grass but fae-er
	name = "fairygrass patch"
	desc = "Something about this grass makes you want to frolic. Or get high."
	icon_state = "fairygrass"
	floor_tile = /obj/item/stack/tile/fairygrass
	light_range = 2
	light_power = 0.80
	light_color = COLOR_BLUE_LIGHT

/turf/open/floor/grass/fairy/spawniconchange()
	icon_state = "fairygrass[rand(0,3)]"

/turf/open/floor/fake_snow
	gender = PLURAL
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	damaged_dmi = 'icons/turf/snow.dmi'
	desc = "Looks cold."
	icon_state = "snow"
	flags_1 = NONE
	floor_tile = null
	initial_gas_mix = FROZEN_ATMOS
	bullet_bounce_sound = null
	tiled_dirt = FALSE
	rust_resistance = RUST_RESISTANCE_ORGANIC
	slowdown = 1.5
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY


/turf/open/floor/fake_snow/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diggable, /obj/item/stack/tile/mineral/snow, 1, worm_chance = 0)

/turf/open/floor/fake_snow/broken_states()
	return list("snow_dug")

/turf/open/floor/fake_snow/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/fake_snow/crowbar_act(mob/living/user, obj/item/I)
	return

/turf/open/floor/fakebasalt
	name = "aesthetic volcanic flooring"
	desc = "Safely recreated turf for your hellplanet-scaping."
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	floor_tile = /obj/item/stack/tile/basalt
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/fakebasalt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diggable, /obj/item/stack/ore/glass/basalt, 2, worm_chance = 0)
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)

/turf/open/floor/carpet
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET
	canSmoothWith = SMOOTH_GROUP_CARPET
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/open/floor/carpet/examine(mob/user)
	. = ..()
	. += span_notice("There's a <b>small crack</b> on the edge of it.")

/turf/open/floor/carpet/Initialize(mapload)
	. = ..()
	update_appearance()

/turf/open/floor/carpet/update_icon(updates=ALL)
	. = ..()
	if(!. || !(updates & UPDATE_SMOOTHING))
		return
	if(!broken && !burnt)
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH(src)
	else
		make_plating()
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH_NEIGHBORS(src)

/turf/open/floor/carpet/lone
	icon = 'icons/turf/floors/floor_variations.dmi'
	icon_state = "carpet-symbol"
	smoothing_flags = NONE
	floor_tile = /obj/item/stack/tile/carpet/symbol

/turf/open/floor/carpet/lone/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/carpet/lone/star
	icon = 'icons/turf/floors/floor_variations.dmi'
	icon_state = "carpet-star"
	floor_tile = /obj/item/stack/tile/carpet/star

/turf/open/floor/carpet/black
	icon = 'icons/turf/floors/carpet_black.dmi'
	icon_state = "carpet_black-255"
	base_icon_state = "carpet_black"
	floor_tile = /obj/item/stack/tile/carpet/black
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_BLACK
	canSmoothWith = SMOOTH_GROUP_CARPET_BLACK

/turf/open/floor/carpet/blue
	icon = 'icons/turf/floors/carpet_blue.dmi'
	icon_state = "carpet_blue-255"
	base_icon_state = "carpet_blue"
	floor_tile = /obj/item/stack/tile/carpet/blue
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_BLUE
	canSmoothWith = SMOOTH_GROUP_CARPET_BLUE

/turf/open/floor/carpet/cyan
	icon = 'icons/turf/floors/carpet_cyan.dmi'
	icon_state = "carpet_cyan-255"
	base_icon_state = "carpet_cyan"
	floor_tile = /obj/item/stack/tile/carpet/cyan
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_CYAN
	canSmoothWith = SMOOTH_GROUP_CARPET_CYAN

/turf/open/floor/carpet/green
	icon = 'icons/turf/floors/carpet_green.dmi'
	icon_state = "carpet_green-255"
	base_icon_state = "carpet_green"
	floor_tile = /obj/item/stack/tile/carpet/green
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_GREEN
	canSmoothWith = SMOOTH_GROUP_CARPET_GREEN

/turf/open/floor/carpet/orange
	icon = 'icons/turf/floors/carpet_orange.dmi'
	icon_state = "carpet_orange-255"
	base_icon_state = "carpet_orange"
	floor_tile = /obj/item/stack/tile/carpet/orange
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ORANGE
	canSmoothWith = SMOOTH_GROUP_CARPET_ORANGE

/turf/open/floor/carpet/purple
	icon = 'icons/turf/floors/carpet_purple.dmi'
	icon_state = "carpet_purple-255"
	base_icon_state = "carpet_purple"
	floor_tile = /obj/item/stack/tile/carpet/purple
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_PURPLE
	canSmoothWith = SMOOTH_GROUP_CARPET_PURPLE

/turf/open/floor/carpet/red
	icon = 'icons/turf/floors/carpet_red.dmi'
	icon_state = "carpet_red-255"
	base_icon_state = "carpet_red"
	floor_tile = /obj/item/stack/tile/carpet/red
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_RED
	canSmoothWith = SMOOTH_GROUP_CARPET_RED

/turf/open/floor/carpet/royalblack
	icon = 'icons/turf/floors/carpet_royalblack.dmi'
	icon_state = "carpet_royalblack-255"
	base_icon_state = "carpet_royalblack"
	floor_tile = /obj/item/stack/tile/carpet/royalblack
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ROYAL_BLACK
	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_BLACK

/turf/open/floor/carpet/royalblue
	icon = 'icons/turf/floors/carpet_royalblue.dmi'
	icon_state = "carpet_royalblue-255"
	base_icon_state = "carpet_royalblue"
	floor_tile = /obj/item/stack/tile/carpet/royalblue
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ROYAL_BLUE
	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_BLUE

/turf/open/floor/carpet/executive
	name = "executive carpet"
	icon = 'icons/turf/floors/carpet_executive.dmi'
	icon_state = "executive_carpet-255"
	base_icon_state = "executive_carpet"
	floor_tile = /obj/item/stack/tile/carpet/executive
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_EXECUTIVE
	canSmoothWith = SMOOTH_GROUP_CARPET_EXECUTIVE

/turf/open/floor/carpet/stellar
	name = "stellar carpet"
	icon = 'icons/turf/floors/carpet_stellar.dmi'
	icon_state = "stellar_carpet-255"
	base_icon_state = "stellar_carpet"
	floor_tile = /obj/item/stack/tile/carpet/stellar
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_STELLAR
	canSmoothWith = SMOOTH_GROUP_CARPET_STELLAR

/turf/open/floor/carpet/donk
	name = "Donk Co. carpet"
	icon = 'icons/turf/floors/carpet_donk.dmi'
	icon_state = "donk_carpet-255"
	base_icon_state = "donk_carpet"
	floor_tile = /obj/item/stack/tile/carpet/donk
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_DONK
	canSmoothWith = SMOOTH_GROUP_CARPET_DONK

//*****Airless versions of all of the above.*****
/turf/open/floor/carpet/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/black/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/blue/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/cyan/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/green/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/orange/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/purple/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/royalblack/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/royalblue/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/narsie_act(force, ignore_mobs, probability = 20)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.narsie_act()

/turf/open/floor/carpet/break_tile()
	broken = TRUE
	update_appearance()

/turf/open/floor/carpet/burn_tile()
	burnt = TRUE
	update_appearance()

/turf/open/floor/carpet/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/// An emissive turf used to test emissive turfs.
/turf/open/floor/emissive_test
	name = "emissive test floor"
	desc = "A glow-in-the-dark floor used to test emissive turfs."
	floor_tile = /obj/item/stack/tile/emissive_test

/turf/open/floor/emissive_test/smooth_icon()
	. = ..()
	update_appearance(~UPDATE_SMOOTHING)

/turf/open/floor/emissive_test/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, alpha = src.alpha)

/turf/open/floor/emissive_test/white
	icon_state = "pure_white"
	base_icon_state = "pure_white"
	floor_tile = /obj/item/stack/tile/emissive_test/white

/turf/open/floor/carpet/neon
	name = "neon carpet"
	desc = "A rubbery pad inset with a phsophorescent pattern."
	icon = 'icons/turf/floors/carpet_black.dmi'
	icon_state = "carpet_black-255"
	base_icon_state = "carpet_black"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_NEON
	canSmoothWith = SMOOTH_GROUP_CARPET_NEON
	smoothing_junction = 255

	/// The icon used for the neon decal.
	var/neon_icon
	/// The icon state used for the neon decal.
	var/neon_icon_state
	/// The color used for the neon decal
	var/neon_color
	/// The alpha used for the emissive decal.
	var/emissive_alpha = 150

/turf/open/floor/carpet/neon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/decal, neon_icon || icon, neon_icon_state || base_icon_state, dir, null, null, alpha, neon_color, smoothing_junction)
	AddElement(/datum/element/decal, neon_icon || icon, neon_icon_state || base_icon_state, dir, EMISSIVE_PLANE, null, emissive_alpha, GLOB.emissive_color, smoothing_junction)

/turf/open/floor/carpet/neon/simple
	name = "simple neon carpet"
	icon = 'icons/turf/floors/carpet_neon_base.dmi'
	icon_state = "base-255"
	base_icon_state = "base"
	neon_icon = 'icons/turf/floors/carpet_neon_light.dmi'
	neon_icon_state = "light"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON

/turf/open/floor/carpet/neon/simple/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_NODOTS

/turf/open/floor/carpet/neon/simple/white
	name = "simple white neon carpet"
	desc = "A rubbery mat with a inset pattern of white phosphorescent dye."
	neon_color = COLOR_WHITE
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/white
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_WHITE
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_WHITE

/turf/open/floor/carpet/neon/simple/white/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/white/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_WHITE_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_WHITE_NODOTS

/turf/open/floor/carpet/neon/simple/black
	name = "simple black neon carpet"
	desc = "A rubbery mat with a inset pattern of black phosphorescent dye."
	neon_icon = 'icons/turf/floors/carpet_neon_glow.dmi'
	neon_icon_state = "glow" // This one also lights up the edges of the lines.
	neon_color = COLOR_BLACK
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/black
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLACK
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLACK

/turf/open/floor/carpet/neon/simple/black/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_glow_nodots.dmi'
	neon_icon_state = "glow-nodots"
	neon_color = COLOR_BLACK
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/black/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLACK_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLACK_NODOTS

/turf/open/floor/carpet/neon/simple/red
	name = "simple red neon carpet"
	desc = "A rubbery mat with a inset pattern of red phosphorescent dye."
	neon_color = COLOR_RED
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/red
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_RED
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_RED

/turf/open/floor/carpet/neon/simple/red/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/red/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_RED_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_RED_NODOTS

/turf/open/floor/carpet/neon/simple/orange
	name = "simple orange neon carpet"
	desc = "A rubbery mat with a inset pattern of orange phosphorescent dye."
	neon_color = COLOR_ORANGE
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/orange
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_ORANGE
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_ORANGE

/turf/open/floor/carpet/neon/simple/orange/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/orange/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_ORANGE_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_ORANGE_NODOTS

/turf/open/floor/carpet/neon/simple/yellow
	name = "simple yellow neon carpet"
	desc = "A rubbery mat with a inset pattern of yellow phosphorescent dye."
	neon_color = COLOR_YELLOW
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/yellow
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_YELLOW
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_YELLOW

/turf/open/floor/carpet/neon/simple/yellow/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/yellow/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_YELLOW_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_YELLOW_NODOTS

/turf/open/floor/carpet/neon/simple/lime
	name = "simple lime neon carpet"
	desc = "A rubbery mat with a inset pattern of lime phosphorescent dye."
	neon_color = COLOR_LIME
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/lime
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_LIME
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_LIME

/turf/open/floor/carpet/neon/simple/lime/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/lime/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_LIME_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_LIME_NODOTS

/turf/open/floor/carpet/neon/simple/green
	name = "simple green neon carpet"
	desc = "A rubbery mat with a inset pattern of green phosphorescent dye."
	neon_color = COLOR_GREEN
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/green
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_GREEN
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_GREEN

/turf/open/floor/carpet/neon/simple/green/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/green/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_GREEN_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_GREEN_NODOTS

/turf/open/floor/carpet/neon/simple/teal
	name = "simple teal neon carpet"
	desc = "A rubbery mat with a inset pattern of teal phosphorescent dye."
	neon_color = COLOR_TEAL
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/teal
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_TEAL
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_TEAL

/turf/open/floor/carpet/neon/simple/teal/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/teal/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_TEAL_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_TEAL_NODOTS

/turf/open/floor/carpet/neon/simple/cyan
	name = "simple cyan neon carpet"
	desc = "A rubbery mat with a inset pattern of cyan phosphorescent dye."
	neon_color = COLOR_CYAN
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/cyan
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_CYAN
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_CYAN

/turf/open/floor/carpet/neon/simple/cyan/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/cyan/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_CYAN_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_CYAN_NODOTS

/turf/open/floor/carpet/neon/simple/blue
	name = "simple blue neon carpet"
	desc = "A rubbery mat with a inset pattern of blue phosphorescent dye."
	neon_color = COLOR_BLUE
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/blue
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLUE
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLUE

/turf/open/floor/carpet/neon/simple/blue/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/blue/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLUE_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLUE_NODOTS

/turf/open/floor/carpet/neon/simple/purple
	name = "simple purple neon carpet"
	desc = "A rubbery mat with a inset pattern of purple phosphorescent dye."
	neon_color = COLOR_PURPLE
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/purple
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_PURPLE
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_PURPLE

/turf/open/floor/carpet/neon/simple/purple/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/purple/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_PURPLE_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_PURPLE_NODOTS

/turf/open/floor/carpet/neon/simple/violet
	name = "simple violet neon carpet"
	desc = "A rubbery mat with a inset pattern of violet phosphorescent dye."
	neon_color = COLOR_VIOLET
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/violet
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_VIOLET
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_VIOLET

/turf/open/floor/carpet/neon/simple/violet/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/violet/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_VIOLET_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_VIOLET_NODOTS

/turf/open/floor/carpet/neon/simple/pink
	name = "simple pink neon carpet"
	desc = "A rubbery mat with a inset pattern of pink phosphorescent dye."
	neon_color = COLOR_LIGHT_PINK
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/pink
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_PINK
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_PINK

/turf/open/floor/carpet/neon/simple/pink/nodots
	icon = 'icons/turf/floors/carpet_neon_base_nodots.dmi'
	icon_state = "base-nodots-255"
	base_icon_state = "base-nodots"
	neon_icon = 'icons/turf/floors/carpet_neon_light_nodots.dmi'
	neon_icon_state = "light-nodots"
	floor_tile = /obj/item/stack/tile/carpet/neon/simple/pink/nodots
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_SIMPLE_NEON_PINK_NODOTS
	canSmoothWith = SMOOTH_GROUP_CARPET_SIMPLE_NEON_PINK_NODOTS

/turf/open/floor/carpet/neon/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/black/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/orange/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/yellow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/lime/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/green/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/teal/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/cyan/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/blue/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/purple/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/violet/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/pink/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/white/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/black/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/red/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/orange/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/yellow/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/lime/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/green/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/teal/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/cyan/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/blue/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/purple/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/violet/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/neon/simple/pink/nodots/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/blue/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/fakepit
	desc = "A clever illusion designed to look like a bottomless pit."
	icon = 'icons/turf/floors/chasms.dmi'
	icon_state = "chasms-0"
	floor_tile = /obj/item/stack/tile/fakepit
	base_icon_state = "chasms"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_TURF_CHASM
	canSmoothWith = SMOOTH_GROUP_TURF_CHASM
	tiled_dirt = FALSE

/turf/open/floor/fakepit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/floor/fakeice
	desc = "Is it marble, polished to a mirror finish? Or just really, really grippy ice?"
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice_turf-0"
	base_icon_state = "ice_turf-0"

/turf/open/floor/fakeice/slippery
	desc = "Somehow, it is not melting under these conditions. Must be some very thick ice. Just as slippery too."

/turf/open/floor/fakeice/slippery/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE)

/turf/open/floor/fakespace
	icon = 'icons/turf/space.dmi'
	icon_state = "space"
	floor_tile = /obj/item/stack/tile/fakespace
	plane = PLANE_SPACE
	tiled_dirt = FALSE
	damaged_dmi = 'icons/turf/space.dmi'

/turf/open/floor/fakespace/broken_states()
	return list("damaged")

/turf/open/floor/fakespace/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	generate_space_underlay(underlay_appearance, asking_turf)
	return TRUE
