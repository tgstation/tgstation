
/area/ocean
	name = "Ocean"
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	static_lighting = FALSE

	base_lighting_alpha = 255
	base_lighting_color = COLOR_STARLIGHT
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE
	static_lighting = 1

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

/turf/open/openspace/ocean
	name = "ocean"
	planetary_atmos = TRUE
	baseturfs = /turf/open/openspace/ocean
	var/replacement_turf = /turf/open/floor/plating/ocean

/turf/open/openspace/ocean/Initialize()
	. = ..()
	ChangeTurf(replacement_turf, null, CHANGETURF_IGNORE_AIR)

/turf/open/openspace/ocean/Initialize()
	. = ..()


/turf/open/floor/plating/ocean
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
	var/static/obj/effect/abstract/ocean_overlay/static_overlay
	var/static/list/ocean_reagents = list(/datum/reagent/water = 100)
	var/ocean_temp = T20C - 150
	var/list/ocean_turfs = list()
	var/list/open_turfs = list()

/turf/open/floor/plating/ocean/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(movable_entered))
	RegisterSignal(src, COMSIG_TURF_MOB_FALL, PROC_REF(mob_fall))
	if(!static_overlay)
		static_overlay = new(null, ocean_reagents)
	vis_contents += static_overlay
	SSliquids.unvalidated_oceans |= src
	SSliquids.ocean_turfs |= src


/turf/open/floor/plating/ocean/Destroy()
	. = ..()
	UnregisterSignal(src, list(COMSIG_ATOM_ENTERED, COMSIG_TURF_MOB_FALL))
	SSliquids.active_ocean_turfs -= src
	SSliquids.ocean_turfs -= src
	for(var/turf/open/floor/plating/ocean/listed_ocean as anything in ocean_turfs)
		listed_ocean.rebuild_adjacent()

/turf/open/floor/plating/ocean/proc/assume_self()
	if(!atmos_adjacent_turfs)
		immediate_calculate_adjacent_turfs()
	for(var/direction in GLOB.cardinals)
		var/turf/directional_turf = get_step(src, direction)
		if(istype(directional_turf, /turf/open/floor/plating/ocean))
			ocean_turfs |= directional_turf
		else
			if(isclosedturf(directional_turf))
				RegisterSignal(directional_turf, COMSIG_TURF_DESTROY, PROC_REF(add_turf_direction))
			else if(!(directional_turf in atmos_adjacent_turfs))
				RegisterSignal(directional_turf, COMSIG_TURF_UPDATE_AIR, PROC_REF(add_turf_direction_non_closed))
			else
				open_turfs.Add(direction)

	if(open_turfs.len)
		SSliquids.active_ocean_turfs |= src
	if(ocean_turfs.len)
		for(var/turf/open/floor/plating/ocean/listed_ocean as anything in ocean_turfs)
			listed_ocean.rebuild_adjacent()
	SSliquids.unvalidated_oceans -= src

/turf/open/floor/plating/ocean/proc/process_turf()
	for(var/direction in open_turfs)
		var/turf/directional_turf = get_step(src, direction)
		if(isspaceturf(directional_turf))
			RegisterSignal(directional_turf, COMSIG_TURF_DESTROY, PROC_REF(add_turf_direction))
			open_turfs -= direction
			if(!open_turfs.len)
				SSliquids.active_ocean_turfs -= src
			return
		else if(!(directional_turf in atmos_adjacent_turfs))
			RegisterSignal(directional_turf, COMSIG_TURF_UPDATE_AIR, PROC_REF(add_turf_direction_non_closed))
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
	//color = mix_color_from_reagent_list(ocean_contents)

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

	SEND_SIGNAL(AM, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WASH)

/turf/open/floor/plating/ocean/proc/add_turf_direction(datum/source)
	SIGNAL_HANDLER
	var/turf/direction_turf = source

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

/turf/open/floor/plating/ocean/false_movement/proc/set_scroll(is_scrolling)
	if(is_scrolling)
		icon_state = "sand_[scroll_state]"
	else
		icon_state = "sand"


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
