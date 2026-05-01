/**********************Asteroid**************************/

#define DIG_SHEET_AMOUNT 5

/turf/open/misc/asteroid //floor piece
	gender = PLURAL
	name = "asteroid sand"
	desc = "It's coarse and rough and gets everywhere."
	baseturfs = /turf/open/misc/asteroid
	icon = 'icons/turf/floors.dmi'
	damaged_dmi = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"
	turf_flags = IS_SOLID

	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	rust_resistance = RUST_RESISTANCE_BASIC
	/// Base turf type to be created by the tunnel
	var/turf_type = /turf/open/misc/asteroid
			/// Whether this turf has different icon states
	var/has_floor_variance = TRUE
	/// Probability floor has a different icon state
	var/floor_variance = 20
	/// Itemstack to drop when dug by a shovel
	var/obj/item/stack/dig_result = /obj/item/stack/ore/glass
	/// Whether the turf has been dug or not
	var/dug = FALSE
	/// Percentage chance of receiving a bonus worm
	var/worm_chance = 30

/turf/open/misc/asteroid/broken_states()
	if(initial(dug))
		return list(icon_state)
	return list("[base_icon_state]_dug")

/turf/open/misc/asteroid/break_tile()
	. = ..()
	if(!.)
		return FALSE
	dug = TRUE
	return TRUE

/turf/open/misc/asteroid/burn_tile()
	return

/turf/open/misc/asteroid/Initialize(mapload)
	var/proper_name = name
	. = ..()
	name = proper_name
	if(has_floor_variance && prob(floor_variance))
		icon_state = "[base_icon_state][rand(0,12)]"

/turf/open/misc/asteroid/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/misc/asteroid/MakeDry()
	return

/turf/open/misc/asteroid/ex_act(severity, target)
	return FALSE

/turf/open/misc/asteroid/attackby(obj/item/attack_item, mob/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE

	if(attack_item.tool_behaviour == TOOL_SHOVEL || attack_item.tool_behaviour == TOOL_MINING)
		if(!can_dig(user))
			return TRUE

		if(!isturf(user.loc))
			return

		balloon_alert(user, "digging...")

		if(attack_item.use_tool(src, user, 4 SECONDS, volume = 50))
			if(!can_dig(user))
				return TRUE
			getDug()
			SSblackbox.record_feedback("tally", "pick_used_mining", 1, attack_item.type)
			return TRUE
	else if(istype(attack_item, /obj/item/storage/bag/ore))
		for(var/obj/item/stack/ore/dropped_ore in src)
			SEND_SIGNAL(attack_item, COMSIG_ATOM_ATTACKBY, dropped_ore)

/// Drops itemstack when dug and changes icon
/turf/open/misc/asteroid/proc/getDug()
	if(!break_tile())
		return FALSE
	new dig_result(src, DIG_SHEET_AMOUNT)
	if(prob(worm_chance))
		new /obj/item/food/bait/worm(src)
	return TRUE

/// If the user can dig the turf
/turf/open/misc/asteroid/proc/can_dig(mob/user)
	if(!dug && !broken)
		return TRUE
	if(user)
		balloon_alert(user, "already excavated!")
	return FALSE

///Refills the previously dug tile
/turf/open/misc/asteroid/proc/refill_dug()
	dug = FALSE
	broken = FALSE
	icon_state = base_icon_state
	if(has_floor_variance && prob(floor_variance))
		icon_state = "[base_icon_state][rand(0,12)]"
	update_appearance()

/turf/open/floor/plating/lavaland_baseturf
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface

/turf/open/misc/asteroid/dug //When you want one of these to be already dug.
	has_floor_variance = FALSE
	dug = TRUE
	base_icon_state = "asteroid_dug"
	icon_state = "asteroid_dug"

/turf/open/misc/asteroid/dug/broken_states()
	return list("asteroid_dug")

/turf/open/misc/asteroid/lavaland_atmos
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/misc/asteroid/lavaland_atmos

/// Used by ashstorms to replenish basalt tiles that have been dug up without going through all of them.
GLOBAL_LIST_EMPTY(dug_up_basalt)

/turf/open/misc/asteroid/basalt
	name = "volcanic floor"
	baseturfs = /turf/open/misc/asteroid/basalt
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	base_icon_state = "basalt"
	floor_variance = 15
	dig_result = /obj/item/stack/ore/glass/basalt

/turf/open/misc/asteroid/basalt/getDug()
	. = ..()
	if(!.)
		return
	set_light(0)
	GLOB.dug_up_basalt |= src

/turf/open/misc/asteroid/basalt/Destroy()
	GLOB.dug_up_basalt -= src
	return ..()

/turf/open/misc/asteroid/basalt/refill_dug()
	. = ..()
	GLOB.dug_up_basalt -= src
	set_basalt_light()

/turf/open/misc/asteroid/basalt/lava //lava underneath
	baseturfs = /turf/open/lava/smooth

/turf/open/misc/asteroid/basalt/airless
	initial_gas_mix = AIRLESS_ATMOS
	worm_chance = 0

/turf/open/misc/asteroid/basalt/Initialize(mapload)
	. = ..()
	set_basalt_light()

/turf/open/misc/asteroid/basalt/proc/set_basalt_light()
	switch(icon_state)
		if("basalt1", "basalt2", "basalt3")
			set_light(BASALT_LIGHT_RANGE_BRIGHT, BASALT_LIGHT_POWER, LIGHT_COLOR_LAVA) //more light
		if("basalt5", "basalt9")
			set_light(BASALT_LIGHT_RANGE_DIM, BASALT_LIGHT_POWER, LIGHT_COLOR_LAVA) //barely anything!

///////Surface. The surface is warm, but survivable without a suit. Internals are required. The floors break to chasms, which drop you into the underground.

/turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/// Used for the lavaland icemoon ruin.
/turf/open/misc/asteroid/basalt/lava_land_surface/no_ruins
	turf_flags = NO_RUINS

/// A turf that can't we can't build openspace chasms on or spawn ruins in.
/turf/closed/mineral/volcanic/lava_land_surface/do_not_chasm
	turf_flags = NO_RUINS

/turf/open/misc/asteroid/lowpressure
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	baseturfs = /turf/open/misc/asteroid/lowpressure
	turf_type = /turf/open/misc/asteroid/lowpressure

/turf/open/misc/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	baseturfs = /turf/open/misc/asteroid/airless
	turf_type = /turf/open/misc/asteroid/airless
	worm_chance = 0

/turf/open/misc/asteroid/basalt/smooth
	smoothing_flags = SMOOTH_BITMASK
	layer = MID_TURF_LAYER
	floor_variance = 0
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-8, -8), matrix())
	/// DMI used by unsmoothed turfs for variance
	var/variant_dmi = null
	/// Amount of variants this turf has
	var/variant_num = 8

/turf/open/misc/asteroid/basalt/smooth/set_smoothed_icon_state(new_junction)
	. = ..()
	if (new_junction == 255 && variant_dmi)
		icon = variant_dmi
		icon_state = "[base_icon_state][rand(1, variant_num)]"
	else
		icon = initial(icon)

/turf/open/misc/asteroid/basalt/smooth/update_overlays()
	. = ..()
	if (smoothing_junction != 255 && variant_dmi)
		. = list(mutable_appearance(variant_dmi, "[base_icon_state][rand(1, variant_num)]")) + .

/turf/open/misc/asteroid/basalt/smooth/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	if (!.)
		return
	if(!smoothing_flags)
		return
	underlay_appearance.transform = transform

/turf/open/misc/asteroid/basalt/smooth/siderite
	name = "siderite floor"
	baseturfs = /turf/open/misc/asteroid/basalt/smooth/siderite
	icon = 'icons/turf/floors/siderite.dmi'
	damaged_dmi = 'icons/turf/floors/siderite_variants.dmi'
	variant_dmi = 'icons/turf/floors/siderite_variants.dmi'
	icon_state = "siderite"
	base_icon_state = "siderite"
	layer = HIGH_TURF_LAYER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_SIDERITE
	canSmoothWith = SMOOTH_GROUP_FLOOR_SIDERITE + SMOOTH_GROUP_CLOSED_TURFS
	dig_result = /obj/item/stack/ore/glass/siderite

/turf/open/misc/asteroid/basalt/smooth/siderite/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/turf/open/misc/asteroid/basalt/smooth/siderite/lava_land_surface/no_ruins
	turf_flags = NO_RUINS

/turf/open/misc/asteroid/basalt/smooth/shale
	name = "shale floor"
	baseturfs = /turf/open/misc/asteroid/basalt/smooth/shale
	icon = 'icons/turf/floors/shale.dmi'
	damaged_dmi = 'icons/turf/floors/shale_variants.dmi'
	variant_dmi = 'icons/turf/floors/shale_variants.dmi'
	icon_state = "shale"
	base_icon_state = "shale"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_SHALE
	canSmoothWith = SMOOTH_GROUP_FLOOR_SHALE + SMOOTH_GROUP_CLOSED_TURFS

/turf/open/misc/asteroid/basalt/smooth/shale/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/turf/open/misc/asteroid/basalt/smooth/shale/lava_land_surface/no_ruins
	turf_flags = NO_RUINS

/turf/open/misc/asteroid/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	damaged_dmi = 'icons/turf/snow.dmi'
	baseturfs = /turf/open/misc/asteroid/snow
	icon_state = "snow"
	base_icon_state = "snow"
	initial_gas_mix = FROZEN_ATMOS
	slowdown = 2
	flags_1 = NONE
	planetary_atmos = TRUE
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	dig_result = /obj/item/stack/sheet/mineral/snow
	leave_footprints = TRUE

/turf/open/misc/asteroid/snow/burn_tile()
	if(!burnt)
		visible_message(span_danger("[src] melts away!."))
		slowdown = 0
		burnt = TRUE
		update_appearance()
		return TRUE
	return FALSE

/turf/open/misc/asteroid/snow/burnt_states()
	return list("snow_dug")

/turf/open/misc/asteroid/snow/add_footprint(mob/living/carbon/human/walker, movement_direction)
	if(HAS_TRAIT(walker, TRAIT_NO_SNOWPRINTS))
		return
	// skip the special logic if the level doesn't naturally have snowstorms
	if(!SSmapping.level_trait(z, ZTRAIT_SNOWSTORM))
		return ..()

	// if an active snow storm affecting this turf is currently in its main or wind down stage, skip footprint creation
	for(var/datum/weather/snow_storm/active_weather in SSweather.processing)
		if(active_weather.stage != MAIN_STAGE && active_weather.stage != WIND_DOWN_STAGE)
			continue
		if(!(loc in active_weather.impacted_areas))
			continue
		return

	. = ..()
	// when a snow storm enters its main stage, clear all of our footprints
	for(var/snow_type in typesof(/datum/weather/snow_storm))
		RegisterSignal(SSdcs, COMSIG_WEATHER_START(snow_type), PROC_REF(snow_clear_footprints), override = TRUE)

/turf/open/misc/asteroid/snow/proc/snow_clear_footprints(datum/source, datum/weather/storm)
	SIGNAL_HANDLER

	if(!(loc in storm.impacted_areas))
		return

	clear_footprints()
	for(var/snow_type in typesof(/datum/weather/snow_storm))
		UnregisterSignal(SSdcs, COMSIG_WEATHER_START(snow_type))

/turf/open/misc/asteroid/snow/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stack/sheet/mineral/snow))
		return ..()

	if(dug)
		if(tool.use(DIG_SHEET_AMOUNT))
			user.visible_message(
				span_notice("[user] packs [src] back in."),
				span_notice("You pack [src] back in."),
				vision_distance = COMBAT_MESSAGE_RANGE,
			)
			refill_dug()
			return ITEM_INTERACT_SUCCESS

		to_chat(user, "You don't have enough [tool.name] to fill the hole.")
		return ITEM_INTERACT_BLOCKING

	if(footprint_entrance_dirs || footprint_exit_dirs)
		if(tool.use(1))
			user.visible_message(
				span_notice("[user] fills in the footprints in [src]."),
				span_notice("You fill in the footprints in [src]."),
				vision_distance = COMBAT_MESSAGE_RANGE,
			)
			clear_footprints()
			return ITEM_INTERACT_SUCCESS

		return NONE

	return NONE

/turf/open/misc/asteroid/snow/icemoon
	baseturfs = /turf/open/openspace/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	slowdown = 0

/// Exact subtype as parent, just used in ruins to prevent other ruins/chasms from spawning on top of it.
/turf/open/misc/asteroid/snow/icemoon/do_not_chasm
	flags_1 = CAN_BE_DIRTY_1
	turf_flags = IS_SOLID | NO_RUST | NO_RUINS

/turf/open/misc/asteroid/snow/icemoon/do_not_scrape
	flags_1 = CAN_BE_DIRTY_1
	turf_flags = IS_SOLID | NO_RUST | NO_CLEARING

/turf/open/lava/plasma/ice_moon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	baseturfs = /turf/open/lava/plasma/ice_moon
	planetary_atmos = TRUE

/turf/open/misc/asteroid/snow/ice
	name = "icy snow"
	desc = "Looks colder."
	baseturfs = /turf/open/misc/asteroid/snow/ice
	initial_gas_mix = BURNING_COLD
	floor_variance = 0
	icon_state = "snow-ice"
	base_icon_state = "snow-ice"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	damaged_dmi = null
	leave_footprints = FALSE

/turf/open/misc/asteroid/snow/ice/break_tile()
	return FALSE

/turf/open/misc/asteroid/snow/ice/burn_tile()
	return FALSE

/turf/open/misc/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/misc/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	planetary_atmos = TRUE
	slowdown = 0

/turf/open/misc/asteroid/snow/airless
	initial_gas_mix = AIRLESS_ATMOS
	worm_chance = 0

/turf/open/misc/asteroid/snow/temperatre
	initial_gas_mix = COLD_ATMOS

//Used for when you want to have real, genuine snow in your kitchen's cold room
/turf/open/misc/asteroid/snow/coldroom
	baseturfs = /turf/open/misc/asteroid/snow/coldroom
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = FALSE
	temperature = COLD_ROOM_TEMP

//Used in SnowCabin.dm
/turf/open/misc/asteroid/snow/snow_cabin
	temperature = ICEBOX_MIN_TEMPERATURE

/turf/open/misc/asteroid/snow/atmosphere
	initial_gas_mix = FROZEN_ATMOS
	planetary_atmos = FALSE

/turf/open/misc/asteroid/snow/standard_air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE

/turf/open/misc/asteroid/moon
	name = "lunar surface"
	baseturfs = /turf/open/misc/asteroid/moon
	icon = 'icons/turf/floors.dmi'
	icon_state = "moon"
	base_icon_state = "moon"
	floor_variance = 40
	dig_result = /obj/item/stack/ore/glass/basalt

/turf/open/misc/asteroid/moon/dug //When you want one of these to be already dug.
	dug = TRUE
	floor_variance = 0
	base_icon_state = "moon_dug"
	icon_state = "moon_dug"

	//used in outpost45

/turf/open/misc/asteroid/plasma //floor piece
	gender = PLURAL
	name = "asteroid gravel"
	desc = "It's coarse and rough and gets everywhere."
	baseturfs = /turf/open/misc/asteroid
	icon = 'icons/turf/floors.dmi'
	damaged_dmi = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"
	initial_gas_mix = "co2=173.4;n2=135.1;plasma=229.8;TEMP=351.9"
	planetary_atmos = TRUE

#undef DIG_SHEET_AMOUNT
