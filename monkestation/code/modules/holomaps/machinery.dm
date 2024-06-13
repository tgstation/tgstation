#define HOLOMAP_LOW_LIGHT 1, 2
#define HOLOMAP_HIGH_LIGHT 2, 3
#define HOLOMAP_LIGHT_OFF 0

// Wall mounted holomap of the station
// Credit to polaris for the code which this current map was originally based off of, and credit to VG for making it in the first place.

/obj/machinery/station_map
	name = "\improper ship holomap"
	desc = "A virtual map of the surrounding ship."
	icon = 'monkestation/code/modules/holomaps/icons/stationmap.dmi'
	icon_state = "station_map"
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 16
	active_power_usage = 128
	circuit = /obj/item/circuitboard/machine/station_map
	light_color = HOLOMAP_HOLOFIER

	/// The mob beholding this marvel.
	var/mob/watching_mob
	/// The image that can be seen in-world.
	var/image/small_station_map
	/// The little "map" floor painting.
	var/image/floor_markings

	// zLevel which the map is a map for.
	var/current_z_level
	/// This set to FALSE when the station map is initialized on a zLevel that has its own icon formatted for use by station holomaps.
	var/bogus = TRUE
	/// The various images and icons for the map are stored in here, as well as the actual big map itself.
	var/datum/station_holomap/holomap_datum

/obj/machinery/station_map/Initialize()
	. = ..()
	current_z_level = loc.z
	SSholomaps.station_holomaps += src
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/station_map/LateInitialize()
	. = ..()
	if(SSholomaps.initialized)
		setup_holomap()

/obj/machinery/station_map/Destroy()
	SSholomaps.station_holomaps -= src
	close_map()
	QDEL_NULL(holomap_datum)
	. = ..()

/obj/machinery/station_map/proc/setup_holomap()
	holomap_datum = new()
	bogus = FALSE
	var/turf/current_turf = get_turf(src)
	if(!("[HOLOMAP_EXTRA_STATIONMAP]_[current_z_level]" in SSholomaps.extra_holomaps))
		bogus = TRUE
		holomap_datum.initialize_holomap_bogus()
		update_icon()
		return

	holomap_datum.initialize_holomap(current_turf.x, current_turf.y, current_z_level, reinit_base_map = TRUE, extra_overlays = handle_overlays())

	floor_markings = image('monkestation/code/modules/holomaps/icons/stationmap.dmi', "decal_station_map")
	floor_markings.dir = src.dir

	update_icon()

/obj/machinery/station_map/attack_hand(var/mob/user)
	if(user == watching_mob)
		close_map(user)
		return

	open_map(user)

/// Tries to open the map for the given mob. Returns FALSE if it doesn't meet the criteria, TRUE if the map successfully opened with no runtimes.
/obj/machinery/station_map/proc/open_map(var/mob/user)
	if(!anchored || (machine_stat & (NOPOWER | BROKEN)) || !user?.client || panel_open || user.hud_used.holomap.used_station_map)
		return FALSE

	if(!holomap_datum)
		// Something is very wrong if we have to un-fuck ourselves here.
		message_admins("\[HOLOMAP] WARNING: Holomap at [x], [y], [z] [ADMIN_FLW(src)] had to set itself up on interact! Something during Initialize went very wrong!")
		setup_holomap()

	holomap_datum.update_map(handle_overlays())

	var/datum/hud/human/user_hud = user.hud_used
	holomap_datum.base_map.loc = user_hud.holomap  // Put the image on the holomap hud
	holomap_datum.base_map.alpha = 0 // Set to transparent so we can fade in

	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/check_position)

	playsound(src, 'monkestation/code/modules/holomaps/sounds/holomap_open.ogg', 125)
	animate(holomap_datum.base_map, alpha = 255, time = 5, easing = LINEAR_EASING)
	icon_state = "station_map_active"
	set_light(HOLOMAP_HIGH_LIGHT)

	user.hud_used.holomap.used_station_map = src
	user.hud_used.holomap.mouse_opacity = MOUSE_OPACITY_ICON
	user.client.screen |= user.hud_used.holomap
	user.client.images |= holomap_datum.base_map

	watching_mob = user
	use_power = ACTIVE_POWER_USE

	if(bogus)
		to_chat(user, "<span class='warning'>The holomap failed to initialize. This area of space cannot be mapped.</span>")
	else
		to_chat(user, "<span class='warning'>A hologram of the station appears before your eyes.</span>")

	return TRUE

/obj/machinery/station_map/attack_ai(var/mob/living/silicon/robot/user)
	attack_hand(user)

/obj/machinery/station_map/attack_robot(mob/user)
	attack_hand(user)

/obj/machinery/station_map/process()
	if((machine_stat & (NOPOWER | BROKEN)) || !anchored)
		close_map()

/obj/machinery/station_map/proc/check_position()
	SIGNAL_HANDLER
	if(!watching_mob)
		return

	if(!Adjacent(watching_mob))
		close_map(watching_mob)

/obj/machinery/station_map/proc/close_map()
	if(!watching_mob)
		return

	UnregisterSignal(watching_mob, COMSIG_MOVABLE_MOVED)
	playsound(src, 'monkestation/code/modules/holomaps/sounds/holomap_close.ogg', 125)
	icon_state = initial(icon_state)
	if(watching_mob?.client)
		animate(holomap_datum.base_map, alpha = 0, time = 5, easing = LINEAR_EASING)
		spawn(5) //we give it time to fade out
			watching_mob.client?.screen -= watching_mob.hud_used.holomap
			watching_mob.client?.images -= holomap_datum.base_map
			watching_mob.hud_used.holomap.used_station_map = null
			watching_mob = null
			set_light(HOLOMAP_LOW_LIGHT)

	use_power = IDLE_POWER_USE

/obj/machinery/station_map/power_change()
	. = ..()
	update_icon()

	if(machine_stat & NOPOWER)
		set_light(HOLOMAP_LIGHT_OFF)
	else
		set_light(HOLOMAP_LOW_LIGHT)

/obj/machinery/station_map/proc/set_broken()
	machine_stat |= BROKEN
	update_icon()

/obj/machinery/station_map/update_icon()
	. = ..()
	if(!holomap_datum)
		return //Not yet.

	cut_overlays()
	if(machine_stat & BROKEN)
		icon_state = "station_map_broken"
	else if(panel_open)
		icon_state = "station_map_opened"
	else if((machine_stat & NOPOWER) || !anchored)
		icon_state = "station_map_off"
	else
		icon_state = initial(icon_state)

		if(bogus)
			holomap_datum.initialize_holomap_bogus()
		else
			small_station_map = image(SSholomaps.extra_holomaps["[HOLOMAP_EXTRA_STATIONMAPSMALL]_[current_z_level]"], dir = src.dir)
			add_overlay(small_station_map)

	// Put the little "map" overlay down where it looks nice
	if(floor_markings)
		floor_markings.dir = src.dir
		floor_markings.pixel_x = -src.pixel_x
		floor_markings.pixel_y = -src.pixel_y
		add_overlay(floor_markings)

/obj/machinery/station_map/screwdriver_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_screwdriver(user, "station_map_opened", "station_map_off", tool))
		return FALSE

	close_map()
	update_icon()

	if(!panel_open)
		setup_holomap()

	return TRUE

/obj/machinery/station_map/multitool_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		to_chat(user, "<span class='warning'>You need to open the panel to change the [src]'[p_s()] settings!</span")
		return FALSE
	if(!SSholomaps.valid_map_indexes.len > 1)
		to_chat(user, "<span class='warning'>There are no other maps available for [src]!</span>")
		return FALSE

	tool.play_tool_sound(user, 50)
	var/current_index = SSholomaps.valid_map_indexes.Find(current_z_level)
	if(current_index >= SSholomaps.valid_map_indexes.len)
		current_z_level = SSholomaps.valid_map_indexes[1]
	else
		current_z_level = SSholomaps.valid_map_indexes[current_index + 1]

	to_chat(user, "<span class='info'>You set the [src]'[p_s()] database index to [current_z_level].</span>")
	return TRUE

/obj/machinery/station_map/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/station_map/wrench_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		return FALSE
	rotate_map(-90)
	tool.play_tool_sound(user, 50)
	return TRUE

/// Rotates the map machine by the given amount of degrees. See byond's builtin `turn` for more info.
/obj/machinery/station_map/proc/rotate_map(direction)
	dir = turn(dir, direction)
	switch(dir)
		if(NORTH)
			pixel_x = 0
			pixel_y = 32
		if(SOUTH)
			pixel_x = 0
			pixel_y = -32
		if(EAST)
			pixel_x = 32
			pixel_y = 0
		if(WEST)
			pixel_x = -32
			pixel_y = 0

	update_icon() // Required to refresh the small map icon.

/obj/machinery/station_map/emp_act(severity)
	if(severity == EMP_LIGHT && !prob(50))
		return

	do_sparks(8, TRUE, src)
	set_broken()

/obj/machinery/station_map/proc/handle_overlays()
	// Each entry in this list contains the text for the legend, and the icon and icon_state use. Null or non-existent icon_state ignore hiding logic.
	// If an entry contains an icon,
	var/list/legend = list() + GLOB.holomap_default_legend

	var/list/z_transitions = SSholomaps.holomap_z_transitions["[current_z_level]"]
	if(length(z_transitions))
		legend += z_transitions

	return legend

/obj/machinery/station_map/engineering
	name = "\improper engineering station map"
	icon_state = "station_map_engi"
	circuit = /obj/item/circuitboard/machine/station_map/engineering

/obj/machinery/station_map/engineering/attack_hand(mob/user)
	. = ..()

	if(.)
		holomap_datum.update_map(handle_overlays())

/obj/machinery/station_map/engineering/handle_overlays()
	var/list/extra_overlays = ..()
	if(bogus)
		return extra_overlays

	var/list/fire_alarms = list()
	for(var/obj/machinery/firealarm/alarm as anything in GLOB.station_fire_alarms["[current_z_level]"])
		if(alarm?.z == current_z_level && alarm?.my_area?.fire)
			var/image/alarm_icon = image('monkestation/code/modules/holomaps/icons/8x8.dmi', icon_state = "fire_marker")
			alarm_icon.pixel_x = alarm.x + HOLOMAP_CENTER_X - 1
			alarm_icon.pixel_y = alarm.y + HOLOMAP_CENTER_Y
			fire_alarms += alarm_icon

	if(length(fire_alarms))
		extra_overlays["Fire Alarms"] = list("icon" = image('monkestation/code/modules/holomaps/icons/8x8.dmi', icon_state = "fire_marker"), "markers" = fire_alarms)

	/*
	var/list/air_alarms = list()
	for(var/obj/machinery/airalarm/air_alarm in GLOB.machines)
		var/area/alarms = get_area(air_alarm)
		if(air_alarm?.z == current_z_level && alarms?.atmosalm) //Altered it to fire_alam since we don't have an area variable on air_alarms
			var/image/alarm_icon = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "atmos_marker")
			alarm_icon.pixel_x = air_alarm.x + HOLOMAP_CENTER_X - 1
			alarm_icon.pixel_y = air_alarm.y + HOLOMAP_CENTER_Y
			air_alarms += alarm_icon

	if(length(air_alarms))
		extra_overlays["Air Alarms"] = list("icon" = image('monkestation/code/modules/holomaps/icons/8x8.dmi', "atmos_marker"), "markers" = air_alarms)
	*/

	return extra_overlays

/obj/item/circuitboard/machine/station_map
	name = "Station Map"
	build_path = /obj/machinery/station_map/directional/north
	req_components = list(/obj/item/stock_parts/scanning_module/triphasic = 3, /obj/item/stock_parts/micro_laser/ultra = 4)

/obj/item/circuitboard/machine/station_map/engineering
	name = "Engineering Station Map"
	desc = "A virtual map of the surrounding station. Also shows any active fire and atmos alarms."
	build_path = /obj/machinery/station_map/engineering/directional/north
	req_components = list(/obj/item/stock_parts/scanning_module/triphasic = 3, /obj/item/stock_parts/micro_laser/ultra = 4, /obj/item/stock_parts/subspace/analyzer = 1)

// Directional Ones for Mapping //
/obj/machinery/station_map/directional/north
	dir = NORTH
	pixel_y = 32

/obj/machinery/station_map/directional/south
	dir = SOUTH
	pixel_y = -32

/obj/machinery/station_map/directional/west
	dir = WEST
	pixel_x = -32

/obj/machinery/station_map/directional/east
	dir = EAST
	pixel_x = 32

/obj/machinery/station_map/engineering/directional/north
	dir = NORTH
	pixel_y = 32

/obj/machinery/station_map/engineering/directional/south
	dir = SOUTH
	pixel_y = -32

/obj/machinery/station_map/engineering/directional/west
	dir = WEST
	pixel_x = -32

/obj/machinery/station_map/engineering/directional/east
	dir = EAST
	pixel_x = 32


/obj/machinery/station_map/strategic
	name = "strategic station holomap"
	icon = 'monkestation/code/modules/holomaps/icons/strategic_stationmap.dmi'
	icon_state = "strat_holomap"
	pixel_x = -16
	pixel_y = -16

#undef HOLOMAP_LOW_LIGHT
#undef HOLOMAP_HIGH_LIGHT
#undef HOLOMAP_LIGHT_OFF
