/**********************Asteroid**************************/

/turf/open/misc/asteroid //floor piece
	gender = PLURAL
	name = "asteroid sand"
	desc = "It's coarse and rough and gets everywhere."
	baseturfs = /turf/open/misc/asteroid
	icon = 'icons/turf/floors.dmi'
	damaged_dmi = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"

	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	rust_resistance = RUST_RESISTANCE_ORGANIC
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

/turf/open/misc/asteroid/attackby(obj/item/attack_item, mob/user, params)
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
	if(dug || broken)
		return
	dug = TRUE
	broken = TRUE
	new dig_result(src, 5)
	if(prob(worm_chance))
		new /obj/item/food/bait/worm(src)
	update_appearance()

/// If the user can dig the turf
/turf/open/misc/asteroid/proc/can_dig(mob/user)
	if(!dug && !broken)
		return TRUE
	if(user)
		balloon_alert(user, "already excavated!")

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
	set_light(0)
	GLOB.dug_up_basalt |= src
	return ..()

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
	temperature = 180

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

