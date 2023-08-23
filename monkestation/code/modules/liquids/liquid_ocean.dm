GLOBAL_LIST_INIT(initalized_ocean_areas, list())
/area/ocean
	name = "Ocean"

	icon = 'monkestation/icons/obj/effects/liquid.dmi'
	base_icon_state = "ocean"
	icon_state = "ocean"
	alpha = 120

	requires_power = TRUE
	always_unpowered = TRUE
	static_lighting = FALSE

	base_lighting_alpha = 255
	base_lighting_color = COLOR_CARP_LIGHT_BLUE

	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE

	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE

/area/ocean/Initialize(mapload)
	. = ..()
	GLOB.initalized_ocean_areas += src

/area/ocean/dark
	base_lighting_alpha = 0
/area/ruin/ocean
	has_gravity = TRUE

/area/ruin/ocean/listening_outpost
	area_flags = UNIQUE_AREA

/area/ruin/ocean/bunker
	area_flags = UNIQUE_AREA

/area/ruin/ocean/bioweapon_research
	area_flags = UNIQUE_AREA

/area/ruin/ocean/mining_site
	area_flags = UNIQUE_AREA

/area/ocean/near_station_powered
	requires_power = FALSE

/turf/open/openspace/ocean
	name = "ocean"
	planetary_atmos = TRUE
	baseturfs = /turf/open/openspace/ocean
	var/replacement_turf = /turf/open/floor/plating/ocean

/turf/open/openspace/ocean/Initialize()
	. = ..()
	ChangeTurf(replacement_turf, null, CHANGETURF_IGNORE_AIR)

/turf/open/floor/plating/ocean
	plane = FLOOR_PLANE
	layer = TURF_LAYER
	force_no_gravity = FALSE
	gender = PLURAL
	name = "ocean sand"
	baseturfs = /turf/open/floor/plating/ocean
	icon = 'monkestation/icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	planetary_atmos = TRUE
	initial_gas_mix = OSHAN_DEFAULT_ATMOS
	light_power = 0.75

	var/static/obj/effect/abstract/ocean_overlay/static_overlay
	var/static/list/ocean_reagents = list(/datum/reagent/water = 100)
	var/ocean_temp = T20C
	var/list/ocean_turfs = list()
	var/list/open_turfs = list()
	var/has_starlight = TRUE

	///are we captured, this is easier than having to run checks on turfs for vents
	var/captured = FALSE

	var/rand_variants = 0
	var/rand_chance = 30

/turf/open/floor/plating/ocean/dark
	has_starlight = FALSE

/turf/open/floor/plating/ocean/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(movable_entered))
	RegisterSignal(src, COMSIG_TURF_MOB_FALL, PROC_REF(mob_fall))
	if(!static_overlay)
		static_overlay = new(null, ocean_reagents)

	vis_contents += static_overlay
	light_color = static_overlay.color
	SSliquids.unvalidated_oceans |= src
	SSliquids.ocean_turfs |= src

	if(rand_variants && prob(rand_chance))
		var/random = rand(1,rand_variants)
		icon_state = "[base_icon_state][random]"
		base_icon_state = "[base_icon_state][random]"


/turf/open/floor/plating/ocean/Destroy()
	. = ..()
	UnregisterSignal(src, list(COMSIG_ATOM_ENTERED, COMSIG_TURF_MOB_FALL))
	SSliquids.active_ocean_turfs -= src
	SSliquids.ocean_turfs -= src
	for(var/turf/open/floor/plating/ocean/listed_ocean as anything in ocean_turfs)
		listed_ocean.rebuild_adjacent()

/// Updates starlight. Called when we're unsure of a turf's starlight state
/// Returns TRUE if we succeed, FALSE otherwise
/turf/open/floor/plating/ocean/proc/update_starlight()
	if(!has_starlight)
		return
	for(var/t in RANGE_TURFS(1,src)) //RANGE_TURFS is in code\__HELPERS\game.dm
		// I've got a lot of cordons near spaceturfs, be good kids
		if(istype(t, /turf/open/floor/plating/ocean) || istype(t, /turf/cordon))
			//let's NOT update this that much pls
			continue
		enable_starlight()
		return TRUE
	set_light(0)
	return FALSE

/// Turns on the stars, if they aren't already
/turf/open/floor/plating/ocean/proc/enable_starlight()
	if(!has_starlight)
		return
	if(!light_outer_range)
		set_light(2)


/turf/open/floor/plating/ocean/proc/assume_self()
	if(!atmos_adjacent_turfs)
		immediate_calculate_adjacent_turfs()
	for(var/direction in GLOB.cardinals)
		var/turf/directional_turf = get_step(src, direction)
		if(istype(directional_turf, /turf/open/floor/plating/ocean))
			ocean_turfs |= directional_turf
		else
			if(isclosedturf(directional_turf))
				RegisterSignal(directional_turf, COMSIG_TURF_DESTROY, PROC_REF(add_turf_direction), TRUE)
				continue
			else if(!(directional_turf in atmos_adjacent_turfs))
				var/obj/machinery/door/found_door = locate(/obj/machinery/door) in directional_turf
				if(found_door)
					RegisterSignal(found_door, COMSIG_ATOM_DOOR_OPEN, TYPE_PROC_REF(/turf/open/floor/plating/ocean, door_opened))
				RegisterSignal(directional_turf, COMSIG_TURF_UPDATE_AIR, PROC_REF(add_turf_direction_non_closed), TRUE)
				continue
			else
				open_turfs.Add(direction)

	if(open_turfs.len)
		SSliquids.active_ocean_turfs |= src
	SSliquids.unvalidated_oceans -= src

/turf/open/floor/plating/ocean/proc/door_opened(datum/source)
	SIGNAL_HANDLER

	var/obj/machinery/door/found_door = source
	var/turf/turf = get_turf(found_door)

	if(turf.can_atmos_pass())
		turf.add_liquid_list(ocean_reagents, FALSE, ocean_temp)

/turf/open/floor/plating/ocean/proc/process_turf()
	for(var/direction in open_turfs)
		var/turf/directional_turf = get_step(src, direction)
		if(isspaceturf(directional_turf) || istype(directional_turf, /turf/open/floor/plating/ocean))
			RegisterSignal(directional_turf, COMSIG_TURF_DESTROY, PROC_REF(add_turf_direction), TRUE)
			open_turfs -= direction
			if(!open_turfs.len)
				SSliquids.active_ocean_turfs -= src
			return
		else if(!(directional_turf in atmos_adjacent_turfs))
			RegisterSignal(directional_turf, COMSIG_TURF_UPDATE_AIR, PROC_REF(add_turf_direction_non_closed), TRUE)
			open_turfs -= direction
			if(!open_turfs.len)
				SSliquids.active_ocean_turfs -= src
			return

		directional_turf.add_liquid_list(ocean_reagents, FALSE, ocean_temp)

/turf/open/floor/plating/ocean/proc/rebuild_adjacent()
	ocean_turfs = list()
	open_turfs = list()
	for(var/direction in GLOB.cardinals)
		var/turf/directional_turf = get_step(src, direction)
		if(istype(directional_turf, /turf/open/floor/plating/ocean))
			ocean_turfs |= directional_turf
		else
			open_turfs.Add(direction)

	if(open_turfs.len)
		SSliquids.active_ocean_turfs |= src
	else if(src in SSliquids.active_ocean_turfs)
		SSliquids.active_ocean_turfs -= src

/turf/open/floor/plating/ocean/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(istype(C, /obj/item/dousing_rod))
		var/obj/item/dousing_rod/attacking_rod = C
		attacking_rod.deploy(src)

	if(istype(C, /obj/item/vent_package))
		if(captured)
			return
		if(!do_after(user, 2 SECONDS, src))
			return
		var/obj/item/vent_package/attacking = C
		attacking.deploy(src)
/obj/effect/abstract/ocean_overlay
	icon = 'monkestation/icons/obj/effects/liquid.dmi'
	icon_state = "ocean"
	base_icon_state = "ocean"
	plane = AREA_PLANE //Same as weather, etc.
	layer = ABOVE_MOB_LAYER
	vis_flags = NONE
	mouse_opacity = FALSE
	alpha = 120

/obj/effect/abstract/ocean_overlay/Initialize(mapload, list/ocean_contents)
	. = ..()
	var/datum/reagents/fake_reagents = new
	fake_reagents.add_reagent_list(ocean_contents)
	color = mix_color_from_reagents(fake_reagents.reagent_list)
	qdel(fake_reagents)
	if(istype(loc, /area/ocean))
		var/area/area_loc = loc
		area_loc.base_lighting_color = color

/obj/effect/abstract/ocean_overlay/proc/mix_colors(list/ocean_contents)
	var/datum/reagents/fake_reagents = new
	fake_reagents.add_reagent_list(ocean_contents)
	color = mix_color_from_reagents(fake_reagents.reagent_list)
	qdel(fake_reagents)
	if(istype(loc, /area/ocean))
		var/area/area_loc = loc
		area_loc.base_lighting_color = color

/turf/open/floor/plating/ocean/proc/mob_fall(datum/source, mob/M)
	SIGNAL_HANDLER
	var/turf/T = source
	playsound(T, 'monkestation/sound/effects/splash.ogg', 50, 0)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		to_chat(C, span_userdanger("You fall in the water!"))

/turf/open/floor/plating/ocean/proc/movable_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	var/turf/T = source
	if(isobserver(AM))
		return //ghosts, camera eyes, etc. don't make water splashy splashy
	if(prob(30))
		var/sound_to_play = pick(list(
			'monkestation/sound/effects/water_wade1.ogg',
			'monkestation/sound/effects/water_wade2.ogg',
			'monkestation/sound/effects/water_wade3.ogg',
			'monkestation/sound/effects/water_wade4.ogg'
			))
		playsound(T, sound_to_play, 50, 0)
	if(isliving(AM))
		var/mob/living/arrived = AM
		if(!arrived.has_status_effect(/datum/status_effect/ocean_affected))
			arrived.apply_status_effect(/datum/status_effect/ocean_affected)

	SEND_SIGNAL(AM, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WASH)

/turf/open/floor/plating/ocean/proc/add_turf_direction(datum/source)
	SIGNAL_HANDLER
	var/turf/direction_turf = source

	if(istype(direction_turf, /turf/open/floor/plating/ocean) || istype(direction_turf, /turf/closed/mineral/random/ocean))
		return

	open_turfs.Add(get_dir(src, direction_turf))

	if(!(src in SSliquids.active_ocean_turfs))
		SSliquids.active_ocean_turfs |= src

/turf/open/floor/plating/ocean/proc/add_turf_direction_non_closed(datum/source)
	SIGNAL_HANDLER
	var/turf/direction_turf = source

	if(!(direction_turf in atmos_adjacent_turfs))
		return

	open_turfs.Add(get_dir(src, direction_turf))

	if(!(src in SSliquids.active_ocean_turfs))
		SSliquids.active_ocean_turfs |= src


GLOBAL_LIST_INIT(scrollable_turfs, list())
GLOBAL_LIST_INIT(the_lever, list())
/turf/open/floor/plating/ocean/false_movement
	icon = 'goon/icons/turf/ocean.dmi'
	icon_state = "sand"
	var/scroll_state = "scroll"
	var/moving = FALSE


/turf/open/floor/plating/ocean/false_movement/Initialize()
	. = ..()
	GLOB.scrollable_turfs += src
	if(GLOB.the_lever.len)
		for(var/obj/machinery/movement_lever/lever as anything in GLOB.the_lever)
			set_scroll(lever.lever_on)
			break

/turf/open/floor/plating/ocean/false_movement/Destroy()
	. = ..()
	GLOB.scrollable_turfs -= src


/turf/open/floor/plating/ocean/false_movement/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(moving)
		if(!HAS_TRAIT(arrived, TRAIT_HYPERSPACED) && !HAS_TRAIT(arrived, TRAIT_FREE_HYPERSPACE_MOVEMENT))
			arrived.AddComponent(/datum/component/shuttle_cling/water, dir, old_loc)

/turf/open/floor/plating/ocean/false_movement/proc/set_scroll(is_scrolling)
	if(is_scrolling)
		icon_state = "sand_[scroll_state]"
		moving = TRUE
	else
		icon_state = "sand"
		moving = FALSE


/obj/machinery/movement_lever
	name = "braking lever"
	desc = "Stops the ship from moving."

	icon = 'goon/icons/obj/decorations.dmi'
	icon_state = "lever1"
	var/static/lever_on = TRUE
	var/static/lever_locked = FALSE

/obj/machinery/movement_lever/Initialize(mapload)
	. = ..()
	GLOB.the_lever += src

/obj/machinery/movement_lever/Destroy()
	. = ..()
	GLOB.the_lever -= src

/obj/machinery/movement_lever/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(lever_locked)
		to_chat(user, span_notice("The lever is locked in place and can't be moved"))
		return
	lever_on = !lever_on
	update_appearance()
	for(var/turf/open/floor/plating/ocean/false_movement/listed_turf as anything in GLOB.scrollable_turfs)
		listed_turf.set_scroll(lever_on)

/obj/machinery/movement_lever/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
		if(do_after(user, 10 SECONDS, src))
			if(!lever_locked)
				visible_message(span_warning("[user] locks the [src] preventing it from being pulled."))
				lever_locked = TRUE
			else
				visible_message(span_warning("[user] unlocks the [src] allowing it to be pulled."))
				lever_locked = FALSE
			update_appearance()

/obj/machinery/movement_lever/update_icon(updates)
	. = ..()
	icon_state = "lever[lever_on]"
	if(lever_locked)
		icon_state = "[icon_state]-locked"

/datum/component/shuttle_cling/water
	hyperspace_type = /turf/open/floor/plating/ocean/false_movement



/turf/closed/mineral/random/ocean
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/heavy
	turf_type = /turf/open/floor/plating/ocean/dark/rock/heavy
	color = "#58606b"

/turf/closed/mineral/random/high_chance/ocean
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/heavy
	turf_type = /turf/open/floor/plating/ocean/dark/rock/heavy
	color = "#58606b"

/turf/closed/mineral/random/low_chance/ocean
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/heavy
	turf_type = /turf/open/floor/plating/ocean/dark/rock/heavy
	color = "#58606b"

/turf/closed/mineral/random/stationside/ocean
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/heavy
	turf_type = /turf/open/floor/plating/ocean/dark/rock/heavy
	color = "#58606b"



/turf/open/floor/plating/ocean/dark/ironsand
	baseturfs = /turf/open/floor/plating/ocean/dark/ironsand
	icon = 'icons/turf/floors.dmi'
	icon_state = "ironsand1"
	base_icon_state = "ironsand"
	rand_variants = 15
	rand_chance = 100

/turf/open/floor/plating/ocean/dark/rock
	name = "rock"
	baseturfs = /turf/open/floor/plating/ocean/dark/rock
	icon = 'monkestation/icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	rand_variants = 0

/turf/open/floor/plating/ocean/dark/rock/warm
	ocean_temp = T20C + 30

/turf/open/floor/plating/ocean/dark/rock/warm/fissure
	name = "fissure"
	icon = 'monkestation/icons/turf/fissure.dmi'
	icon_state = "fissure-0"
	base_icon_state = "fissure"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_FISSURE
	canSmoothWith = SMOOTH_GROUP_FISSURE
	light_outer_range = 3
	light_color = LIGHT_COLOR_LAVA

/turf/open/floor/plating/ocean/dark/rock/medium
	icon_state = "seafloor_med"
	base_icon_state = "seafloor_med"
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/medium

/turf/open/floor/plating/ocean/dark/rock/heavy
	icon_state = "seafloor_heavy"
	base_icon_state = "seafloor_heavy"
	baseturfs = /turf/open/floor/plating/ocean/dark/rock/heavy

/area/ocean/generated
	base_lighting_alpha = 0
	//map_generator = /datum/map_generator/ocean_generator
	map_generator = /datum/map_generator/cave_generator/trench


/area/ocean/generated_above
	map_generator = /datum/map_generator/ocean_generator

/turf/open/floor/plating/ocean/pit
	name = "pit"

	icon = 'goon/icons/turf/outdoors.dmi'
	icon_state = "pit"
	baseturfs = /turf/open/floor/plating/ocean/pit

/turf/open/floor/plating/ocean/pit/wall
	icon_state = "pit_wall"

/turf/open/floor/plating/ocean/pit/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	var/turf/turf = locate(src.x, src.y, SSmapping.levels_by_trait(ZTRAIT_MINING)[1])
	arrived.forceMove(turf)



/turf/closed/mineral/random/ocean/above
	baseturfs = /turf/open/floor/plating/ocean/rock
	turf_type = /turf/open/floor/plating/ocean/rock
	color = "#58606b"

/turf/closed/mineral/random/high_chance/ocean/above
	baseturfs = /turf/open/floor/plating/ocean/rock
	turf_type = /turf/open/floor/plating/ocean/rock
	color = "#58606b"

/turf/closed/mineral/random/low_chance/ocean/above
	baseturfs = /turf/open/floor/plating/ocean/rock
	turf_type = /turf/open/floor/plating/ocean/rock
	color = "#58606b"

/turf/closed/mineral/random/stationside/ocean/above
	baseturfs = /turf/open/floor/plating/ocean/rock
	turf_type = /turf/open/floor/plating/ocean/rock
	color = "#58606b"

/turf/open/floor/plating/ocean/ironsand
	baseturfs = /turf/open/floor/plating/ocean/dark/ironsand
	icon = 'icons/turf/floors.dmi'
	icon_state = "ironsand1"
	base_icon_state = "ironsand"
	rand_variants = 15
	rand_chance = 100

/turf/open/floor/plating/ocean/rock
	name = "rock"
	baseturfs = /turf/open/floor/plating/ocean/dark/rock
	icon = 'monkestation/icons/turf/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	rand_variants = 0

/turf/open/floor/plating/ocean/rock/warm
	ocean_temp = T20C + 30

/turf/open/floor/plating/ocean/rock/medium
	icon_state = "seafloor_med"
	base_icon_state = "seafloor_med"
	baseturfs = /turf/open/floor/plating/ocean/rock/medium

/turf/open/floor/plating/ocean/rock/heavy
	icon_state = "seafloor_heavy"
	base_icon_state = "seafloor_heavy"
	baseturfs = /turf/open/floor/plating/ocean/rock/heavy

GLOBAL_VAR_INIT(lavaland_points_generated, 0)
/turf/closed/mineral/random/regrowth
	turf_transforms = FALSE
	color = "#58606b"

	turf_type = /turf/open/misc/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE
	

/turf/closed/mineral/random/regrowth/New(loc, _mineral_increase)
	mineralChance += _mineral_increase
	. = ..()

/turf/closed/mineral/random/regrowth/Destroy(force)
	. = ..()
	var/timer = max(1 MINUTES - round(max(1, GLOB.lavaland_points_generated) / 1000), 5 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(regrow_mineral), get_turf(src)), timer)

/proc/regrow_mineral(turf/location)
	var/mineral_increase = 0
	if(GLOB.lavaland_points_generated > 55000)
		mineral_increase = min(87, (GLOB.lavaland_points_generated - 55000) / 1000)
	new /turf/closed/mineral/random/regrowth(location , mineral_increase)
