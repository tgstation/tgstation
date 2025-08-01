
/obj/docking_port/stationary
	name = "dock"

	var/last_dock_time

	/// Map template to load when the dock is loaded
	var/datum/map_template/shuttle/roundstart_template
	/// The shuttle template id to use after roundstart
	var/shuttle_template_id
	/// Used to check if the shuttle template is enabled in the config file
	var/json_key
	///If true, the shuttle can always dock at this docking port, despite its area checks, or if something is already docked
	var/override_can_dock_checks = FALSE

/obj/docking_port/stationary/get_save_vars()
	return ..() + NAMEOF(src, roundstart_template)

/obj/docking_port/stationary/Initialize(mapload)
	. = ..()
	register()
	if(!area_type)
		var/area/place = get_area(src)
		area_type = place?.type // We might be created in nullspace

	if(mapload)
		for(var/turf/T in return_turfs())
			T.turf_flags |= NO_RUINS

	if(SSshuttle.initialized)
		return INITIALIZE_HINT_LATELOAD

/obj/docking_port/stationary/LateInitialize()
	INVOKE_ASYNC(SSshuttle, TYPE_PROC_REF(/datum/controller/subsystem/shuttle, setup_shuttles), list(src))

#ifdef TESTING
	highlight("#f00")
#endif

/obj/docking_port/stationary/Destroy(force)
	if(force)
		unregister()
	return ..()

/obj/docking_port/stationary/register(replace = FALSE)
	. = ..()
	if(!shuttle_id)
		shuttle_id = "dock"
	else
		port_destinations = shuttle_id

	if(!name)
		name = "dock"

	var/counter = SSshuttle.assoc_stationary[shuttle_id]
	if(!replace || !counter)
		if(counter)
			counter++
			SSshuttle.assoc_stationary[shuttle_id] = counter
			shuttle_id = "[shuttle_id]_[counter]"
			name = "[name] [counter]"
		else
			SSshuttle.assoc_stationary[shuttle_id] = 1

	if(!port_destinations)
		port_destinations = shuttle_id

	SSshuttle.stationary_docking_ports += src

/obj/docking_port/stationary/unregister()
	. = ..()
	SSshuttle.stationary_docking_ports -= src

/obj/docking_port/stationary/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(area_type) // We already have one
		return
	var/area/newarea = get_area(src)
	area_type = newarea?.type

/obj/docking_port/stationary/proc/load_roundstart()
	if(json_key)
		var/sid = SSmapping.current_map.shuttles[json_key]
		shuttle_template_id = SSmapping.shuttle_templates[sid]
		if(!shuttle_template_id)
			CRASH("json_key:[json_key] value \[[sid]\] resulted in a null shuttle template for [src]")
	else if(roundstart_template) // passed a PATH
		var/sid = "[initial(roundstart_template.port_id)]_[initial(roundstart_template.suffix)]"

		shuttle_template_id = SSmapping.shuttle_templates[sid]
		if(!shuttle_template_id)
			CRASH("Invalid path ([sid]/[shuttle_template_id]) passed to docking port.")

	if(shuttle_template_id)
		SSshuttle.action_load(shuttle_template_id, src)

//returns first-found touching shuttleport
/obj/docking_port/stationary/get_docked()
	. = locate(/obj/docking_port/mobile) in loc
