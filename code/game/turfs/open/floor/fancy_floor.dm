/* In this file:
 * Wood floor
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

/turf/open/floor/wood/setup_broken_states()
	return list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

/turf/open/floor/wood/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There's a few <b>screws</b> and a <b>small crack</b> visible.</span>"

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
			to_chat(user, "<span class='notice'>You remove the broken planks.</span>")
	else
		if(make_tile)
			if(user && !silent)
				to_chat(user, "<span class='notice'>You unscrew the planks.</span>")
			spawn_tile()
		else
			if(user && !silent)
				to_chat(user, "<span class='notice'>You forcefully pry off the planks, destroying them in the process.</span>")
	return make_plating(force_plating)

/turf/open/floor/wood/cold
	temperature = 255.37

/turf/open/floor/wood/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/grass
	name = "grass patch"
	desc = "You can't tell if this is real grass or just cheap plastic imitation."
	icon_state = "grass0"
	floor_tile = /obj/item/stack/tile/grass
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	var/ore_type = /obj/item/stack/ore/glass
	var/turfverb = "uproot"
	tiled_dirt = FALSE

/turf/open/floor/grass/setup_broken_states()
	return list("sand")

/turf/open/floor/grass/Initialize()
	. = ..()
	spawniconchange()

/turf/open/floor/grass/proc/spawniconchange()
	icon_state = "grass[rand(0,3)]"

/turf/open/floor/grass/attackby(obj/item/C, mob/user, params)
	if((C.tool_behaviour == TOOL_SHOVEL) && params)
		new ore_type(src, 2)
		user.visible_message("<span class='notice'>[user] digs up [src].</span>", "<span class='notice'>You [turfverb] [src].</span>")
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, TRUE)
		make_plating()
	if(..())
		return

/turf/open/floor/grass/fairy //like grass but fae-er
	name = "fairygrass patch"
	desc = "Something about this grass makes you want to frolic. Or get high."
	icon_state = "fairygrass0"
	floor_tile = /obj/item/stack/tile/fairygrass
	light_range = 2
	light_power = 0.80
	light_color = COLOR_BLUE_LIGHT

/turf/open/floor/grass/fairy/spawniconchange()
	icon_state = "fairygrass[rand(0,3)]"

/turf/open/floor/grass/snow
	gender = PLURAL
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	desc = "Looks cold."
	icon_state = "snow"
	ore_type = /obj/item/stack/sheet/mineral/snow
	planetary_atmos = TRUE
	floor_tile = null
	initial_gas_mix = FROZEN_ATMOS
	slowdown = 2
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/grass/snow/setup_broken_states()
	return list("snow_dug")

/turf/open/floor/grass/snow/spawniconchange()
	return

/turf/open/floor/grass/snow/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/grass/snow/crowbar_act(mob/living/user, obj/item/I)
	return

/turf/open/floor/grass/snow/basalt //By your powers combined, I am captain planet
	gender = NEUTER
	name = "volcanic floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	ore_type = /obj/item/stack/ore/glass/basalt
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	slowdown = 0

/turf/open/floor/grass/snow/basalt/spawniconchange()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)

/turf/open/floor/grass/snow/safe
	slowdown = 1.5
	planetary_atmos = FALSE


/turf/open/floor/grass/fakebasalt //Heart is not a real planeteer power
	name = "aesthetic volcanic flooring"
	desc = "Safely recreated turf for your hellplanet-scaping."
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	floor_tile = /obj/item/stack/tile/basalt
	ore_type = /obj/item/stack/ore/glass/basalt
	turfverb = "dig up"
	slowdown = 0
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/grass/fakebasalt/spawniconchange()
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
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/carpet/setup_broken_states()
	return list("damaged")

/turf/open/floor/carpet/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There's a <b>small crack</b> on the edge of it.</span>"

/turf/open/floor/carpet/Initialize()
	. = ..()
	update_icon()

/turf/open/floor/carpet/update_icon()
	. = ..()
	if(!.)
		return
	if(!broken && !burnt)
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH(src)
	else
		make_plating()
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH_NEIGHBORS(src)

///Carpet variant for mapping aid, functionally the same as parent after smoothing.
/turf/open/floor/carpet/lone
	icon_state = "carpet-0"

/turf/open/floor/carpet/black
	icon = 'icons/turf/floors/carpet_black.dmi'
	icon_state = "carpet_black-255"
	base_icon_state = "carpet_black"
	floor_tile = /obj/item/stack/tile/carpet/black
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_BLACK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_BLACK)

/turf/open/floor/carpet/blue
	icon = 'icons/turf/floors/carpet_blue.dmi'
	icon_state = "carpet_blue-255"
	base_icon_state = "carpet_blue"
	floor_tile = /obj/item/stack/tile/carpet/blue
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_BLUE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_BLUE)

/turf/open/floor/carpet/cyan
	icon = 'icons/turf/floors/carpet_cyan.dmi'
	icon_state = "carpet_cyan-255"
	base_icon_state = "carpet_cyan"
	floor_tile = /obj/item/stack/tile/carpet/cyan
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_CYAN)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_CYAN)

/turf/open/floor/carpet/green
	icon = 'icons/turf/floors/carpet_green.dmi'
	icon_state = "carpet_green-255"
	base_icon_state = "carpet_green"
	floor_tile = /obj/item/stack/tile/carpet/green
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_GREEN)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_GREEN)

/turf/open/floor/carpet/orange
	icon = 'icons/turf/floors/carpet_orange.dmi'
	icon_state = "carpet_orange-255"
	base_icon_state = "carpet_orange"
	floor_tile = /obj/item/stack/tile/carpet/orange
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_ORANGE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ORANGE)

/turf/open/floor/carpet/purple
	icon = 'icons/turf/floors/carpet_purple.dmi'
	icon_state = "carpet_purple-255"
	base_icon_state = "carpet_purple"
	floor_tile = /obj/item/stack/tile/carpet/purple
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_PURPLE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_PURPLE)

/turf/open/floor/carpet/red
	icon = 'icons/turf/floors/carpet_red.dmi'
	icon_state = "carpet_red-255"
	base_icon_state = "carpet_red"
	floor_tile = /obj/item/stack/tile/carpet/red
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_RED)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_RED)

/turf/open/floor/carpet/royalblack
	icon = 'icons/turf/floors/carpet_royalblack.dmi'
	icon_state = "carpet_royalblack-255"
	base_icon_state = "carpet_royalblack"
	floor_tile = /obj/item/stack/tile/carpet/royalblack
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_ROYAL_BLACK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ROYAL_BLACK)

/turf/open/floor/carpet/royalblue
	icon = 'icons/turf/floors/carpet_royalblue.dmi'
	icon_state = "carpet_royalblue-255"
	base_icon_state = "carpet_royalblue"
	floor_tile = /obj/item/stack/tile/carpet/royalblue
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_ROYAL_BLUE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ROYAL_BLUE)

/turf/open/floor/carpet/executive
	name = "executive carpet"
	icon = 'icons/turf/floors/carpet_executive.dmi'
	icon_state = "executive_carpet-255"
	base_icon_state = "executive_carpet"
	floor_tile = /obj/item/stack/tile/carpet/executive
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_EXECUTIVE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_EXECUTIVE)

/turf/open/floor/carpet/stellar
	name = "stellar carpet"
	icon = 'icons/turf/floors/carpet_stellar.dmi'
	icon_state = "stellar_carpet-255"
	base_icon_state = "stellar_carpet"
	floor_tile = /obj/item/stack/tile/carpet/stellar
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_STELLAR)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_STELLAR)

/turf/open/floor/carpet/donk
	name = "Donk Co. carpet"
	icon = 'icons/turf/floors/carpet_donk.dmi'
	icon_state = "donk_carpet-255"
	base_icon_state = "donk_carpet"
	floor_tile = /obj/item/stack/tile/carpet/donk
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_DONK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_DONK)

/// Carpets that generate an emissive decal to augment them
/turf/open/floor/carpet/emissive
	name = "Emissive Carpet"
	icon = 'icons/turf/floors/carpet_black.dmi'
	icon_state = "carpet_black-255"
	base_icon_state = "carpet_black"
	floor_tile = /obj/item/stack/tile/carpet/emissive
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_EMISSIVE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_EMISSIVE)

	// Emissive decal settings:
	/// The icon used to generate the emisive overlay
	var/emissive_icon
	/// The base icon state for the emissive overlay
	var/base_emissive_state
	/// The color of the emissive decal
	var/emissive_color
	/// The alpha of the emissive decal
	var/emissive_alpha = 150

/turf/open/floor/carpet/emissive/Initialize(mapload, ...)
	. = ..()
	if(!emissive_icon)
		emissive_icon = icon
	if(!base_emissive_state)
		base_emissive_state = base_icon_state
	AddElement(/datum/element/decal/smoothing, emissive_icon, base_emissive_state, dir, FALSE, emissive_color, EMISSIVE_TURF_LAYER, EMISSIVE_TURF_PLANE, null, emissive_alpha)

/turf/open/floor/carpet/emissive/neon
	name = "Neon Carpet"
	desc = "A carpet with a design woven into it using phosphorescent thread."
	icon = 'icons/turf/floors/carpet_neon_simple.dmi'
	icon_state = "base-255"
	base_icon_state = "base"
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_NEON)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_NEON)

	// Neon Decals:
	/// The icon used
	var/neon_icon
	/// The base icon state used for the neon decals
	var/base_neon_state
	/// The color used for the neon decals
	var/neon_color

/turf/open/floor/carpet/emissive/neon/Initialize(mapload, ...)
	. = ..()
	if(!neon_icon)
		neon_icon = emissive_icon
	if(!base_neon_state)
		base_neon_state = base_emissive_state
	AddElement(/datum/element/decal/smoothing, neon_icon, base_neon_state, dir, FALSE, neon_color)

/turf/open/floor/carpet/emissive/neon/simple
	name = "Simple Neon Carpet"
	desc = "A carpet with a simple design woven into it using phosphorescent thread."
	icon = 'icons/turf/floors/carpet_neon_simple.dmi'
	icon_state = "base-255"
	base_icon_state = "base"
	base_neon_state = "lights"
	base_emissive_state = "glow"
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON)

/turf/open/floor/carpet/emissive/neon/simple/white
	name = "Simple White Neon Carpet"
	desc = "A carpet with a simple design woven into it using white phosphorescent thread."
	neon_color = COLOR_WHITE
	emissive_color = COLOR_WHITE
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/white
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_WHITE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_WHITE)

/turf/open/floor/carpet/emissive/neon/simple/red
	name = "Simple Red Neon Carpet"
	desc = "A carpet with a simple design woven into it using red phosphorescent thread."
	neon_color = COLOR_RED
	emissive_color = COLOR_RED
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/red
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_RED)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_RED)

/turf/open/floor/carpet/emissive/neon/simple/orange
	name = "Simple Orange Neon Carpet"
	desc = "A carpet with a simple design woven into it using orange phosphorescent thread."
	neon_color = COLOR_ORANGE
	emissive_color = COLOR_ORANGE
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/orange
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_ORANGE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_ORANGE)

/turf/open/floor/carpet/emissive/neon/simple/yellow
	name = "Simple Yellow Neon Carpet"
	desc = "A carpet with a simple design woven into it using yellow phosphorescent thread."
	neon_color = COLOR_YELLOW
	emissive_color = COLOR_YELLOW
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/yellow
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_YELLOW)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_YELLOW)

/turf/open/floor/carpet/emissive/neon/simple/lime
	name = "Simple Lime Neon Carpet"
	desc = "A carpet with a simple design woven into it using lime phosphorescent thread."
	neon_color = COLOR_LIME
	emissive_color = COLOR_LIME
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/lime
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_LIME)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_LIME)

/turf/open/floor/carpet/emissive/neon/simple/green
	name = "Simple Green Neon Carpet"
	desc = "A carpet with a simple design woven into it using green phosphorescent thread."
	neon_color = COLOR_GREEN
	emissive_color = COLOR_GREEN
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/green
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_GREEN)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_GREEN)

/turf/open/floor/carpet/emissive/neon/simple/cyan
	name = "Simple Cyan Neon Carpet"
	desc = "A carpet with a simple design woven into it using cyan phosphorescent thread."
	neon_color = COLOR_CYAN
	emissive_color = COLOR_CYAN
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/cyan
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_CYAN)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_CYAN)

/turf/open/floor/carpet/emissive/neon/simple/teal
	name = "Simple Cyan Neon Carpet"
	desc = "A carpet with a simple design woven into it using teal phosphorescent thread."
	neon_color = COLOR_TEAL
	emissive_color = COLOR_TEAL
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/teal
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_TEAL)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_TEAL)

/turf/open/floor/carpet/emissive/neon/simple/blue
	name = "Simple Blue Neon Carpet"
	desc = "A carpet with a simple design woven into it using blue phosphorescent thread."
	neon_color = COLOR_BLUE
	emissive_color = COLOR_BLUE
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/blue
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLUE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLUE)

/turf/open/floor/carpet/emissive/neon/simple/purple
	name = "Simple Indigo Neon Carpet"
	desc = "A carpet with a simple design woven into it using purple phosphorescent thread."
	neon_color = COLOR_PURPLE
	emissive_color = COLOR_PURPLE
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/purple
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_PURPLE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_PURPLE)

/turf/open/floor/carpet/emissive/neon/simple/violet
	name = "Simple Indigo Neon Carpet"
	desc = "A carpet with a simple design woven into it using violet phosphorescent thread."
	neon_color = COLOR_VIOLET
	emissive_color = COLOR_VIOLET
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/violet
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_VIOLET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_VIOLET)

/turf/open/floor/carpet/emissive/neon/simple/pink
	name = "Simple Indigo Neon Carpet"
	desc = "A carpet with a simple design woven into it using pink phosphorescent thread."
	neon_color = COLOR_PINK
	emissive_color = COLOR_PINK
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/pink
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_PINK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_PINK)

/turf/open/floor/carpet/emissive/neon/simple/black
	name = "Simple Black Neon Carpet"
	desc = "A carpet with a simple design wiven into it using especially dark thread."
	neon_color = COLOR_BLACK
	emissive_color = COLOR_BLACK
	floor_tile = /obj/item/stack/tile/carpet/emissive/neon/simple/black
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLACK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_SIMPLE_NEON_BLACK)

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

/turf/open/floor/carpet/executive/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/stellar/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/donk/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/orange/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/yellow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/green/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/cyan/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/teal/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/blue/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/purple/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/violet/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/pink/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/carpet/emissive/neon/simple/black/airless
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
	update_icon()

/turf/open/floor/carpet/burn_tile()
	burnt = TRUE
	update_icon()

/turf/open/floor/carpet/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE


/turf/open/floor/fakepit
	desc = "A clever illusion designed to look like a bottomless pit."
	icon = 'icons/turf/floors/chasms.dmi'
	icon_state = "chasms-0"
	base_icon_state = "chasms"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_TURF_CHASM)
	canSmoothWith = list(SMOOTH_GROUP_TURF_CHASM)
	tiled_dirt = FALSE

/turf/open/floor/fakepit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/floor/fakespace
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	floor_tile = /obj/item/stack/tile/fakespace
	plane = PLANE_SPACE
	tiled_dirt = FALSE

/turf/open/floor/fakespace/setup_broken_states()
	return list("damaged")

/turf/open/floor/fakespace/Initialize()
	. = ..()
	icon_state = SPACE_ICON_STATE

/turf/open/floor/fakespace/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	underlay_appearance.plane = PLANE_SPACE
	return TRUE
