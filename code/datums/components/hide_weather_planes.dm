/**
 * Component that manages a list of plane masters that are dependent on weather
 * Force hides/shows them depending on the weather activity of their z stack
 * Transparency is achieved by manipulating the alpha of the planes that are visible
 * Applied to the plane master group that owns them
 */
/datum/component/hide_weather_planes
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/datum/weather/active_weather = list()
	var/list/atom/movable/screen/plane_master/plane_masters = list()

/datum/component/hide_weather_planes/Initialize(atom/movable/screen/plane_master/care_about)
	if(!istype(parent, /datum/plane_master_group))
		return COMPONENT_INCOMPATIBLE
	plane_masters += care_about
	RegisterSignal(care_about, COMSIG_QDELETING, PROC_REF(plane_master_deleted))

	var/list/starting_signals = list()
	var/list/ending_signals = list()
	for(var/datum/weather/weather_type as anything in valid_subtypesof(/datum/weather))
		starting_signals += COMSIG_WEATHER_TELEGRAPH(weather_type)
		ending_signals += COMSIG_WEATHER_END(weather_type)

	RegisterSignals(SSdcs, starting_signals, PROC_REF(weather_started))
	RegisterSignals(SSdcs, ending_signals, PROC_REF(weather_finished))
	AddComponent(/datum/component/connect_perspective, parent, list(COMSIG_MOVABLE_Z_CHANGED = PROC_REF(z_changed)))
	RegisterSignal(parent, COMSIG_PLANE_GROUP_PERSPECTIVE_CHANGED, PROC_REF(perspective_changed))

/datum/component/hide_weather_planes/Destroy(force)
	hide_planes()
	active_weather = null
	plane_masters = null
	return ..()

/datum/component/hide_weather_planes/InheritComponent(datum/component/new_comp, i_am_original, atom/movable/screen/plane_master/care_about)
	if(!i_am_original)
		return
	var/datum/plane_master_group/home = parent
	var/mob/perspective = home.get_perspective()
	var/mob/viewer = home.our_hud?.mymob
	var/our_offset = GET_TURF_PLANE_OFFSET(perspective)
	plane_masters += care_about
	RegisterSignal(care_about, COMSIG_QDELETING, PROC_REF(plane_master_deleted))
	if(length(active_weather))
		//If there's weather to care about we unhide our new plane and adjust its alpha
		care_about.unhide_plane(viewer)

		if(care_about.offset >= our_offset)
			care_about.enable_alpha()
		else
			care_about.disable_alpha()
	else
		care_about.hide_plane(viewer)

/datum/component/hide_weather_planes/proc/plane_master_deleted(atom/movable/screen/plane_master/source)
	SIGNAL_HANDLER
	plane_masters -= source

/**
 * Unhides the relevant planes for the weather to be visible and manipulated.
 * Also updates the alpha of the planes so enabled planes are either fully opaque or fully transparent
 */
/datum/component/hide_weather_planes/proc/display_planes()
	var/datum/plane_master_group/home = parent
	var/mob/perspective = home.get_perspective()
	var/mob/viewer = home.our_hud?.mymob
	var/our_offset = GET_TURF_PLANE_OFFSET(perspective)
	for(var/atom/movable/screen/plane_master/weather_conscious as anything in plane_masters)
		//If the plane is hidden, unhide it
		if(weather_conscious.force_hidden)
			weather_conscious.unhide_plane(viewer)

		//Now we update the alpha of the plane based on our offset. Weather above us (lower offset) are transparent, weather at or below us (higher offset) are opaque.
		if(weather_conscious.offset >= our_offset)
			weather_conscious.enable_alpha()
		else
			weather_conscious.disable_alpha()

///Hides the planes from the mob when no weather is occuring
/datum/component/hide_weather_planes/proc/hide_planes()
	var/datum/plane_master_group/home = parent
	var/mob/our_lad = home.our_hud?.mymob
	for(var/atom/movable/screen/plane_master/weather_conscious as anything in plane_masters)
		weather_conscious.hide_plane(our_lad)

/datum/component/hide_weather_planes/proc/z_changed(datum/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	update_by_z(new_turf)

/datum/component/hide_weather_planes/proc/perspective_changed(datum/source)
	SIGNAL_HANDLER
	var/datum/plane_master_group/group = parent
	update_by_z(get_turf(group.perspective))

/datum/component/hide_weather_planes/proc/update_by_z(turf/new_turf)
	active_weather = list()
	if(!SSmapping.initialized)
		return

	var/list/connected_levels = SSmapping.get_connected_levels(new_turf)
	for(var/datum/weather/active as anything in SSweather.processing)
		if(length(connected_levels & active.impacted_z_levels))
			active_weather += WEAKREF(active)

	if(length(active_weather))
		display_planes()
	else
		hide_planes()

/datum/component/hide_weather_planes/proc/weather_started(datum/source, datum/weather/starting)
	SIGNAL_HANDLER
	var/datum/plane_master_group/home = parent
	var/mob/eye = home.get_perspective()
	var/turf/viewing_from = get_turf(eye)
	if(!viewing_from)
		return

	var/list/connected_levels = SSmapping.get_connected_levels(viewing_from)
	if(length(connected_levels & starting.impacted_z_levels))
		active_weather += WEAKREF(starting)

	if(!length(active_weather))
		return
	display_planes()

/datum/component/hide_weather_planes/proc/weather_finished(datum/source, datum/weather/stopping)
	SIGNAL_HANDLER
	active_weather -= WEAKREF(stopping)

	if(length(active_weather))
		return
	hide_planes()
