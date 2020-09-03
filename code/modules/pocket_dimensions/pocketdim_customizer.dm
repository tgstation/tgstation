
///Datum for controlling the pocket dimension.
/datum/pocket_dim_customizer
	///Name
	var/name = "Pocket Dimension Customizer"
	///List of events
	var/list/event_list = list()
	///what number is this z level
	var/local_pocket_dim
	///local area
	var/area/pocket_dimension/local_area
	///portals spawned by this thing
	var/list/obj/portals = list()
	///baseturf , must be updated to actually change it
	var/baseturf = /turf/open/chasm/void
	///wall , must be updated to actually change it
	var/wall = /turf/closed/indestructible
	///floor , must be updated to actually change it
	var/floor = /turf/open/indestructible
	///size , must be updated to actually change it
	var/size = 5
	///Last mob to open UI.
	var/mob/last_user

///Creates the pocket dimension
/datum/pocket_dim_customizer/proc/create_pocket_dim()
	var/list/poket_dimensions = SSmapping.levels_by_trait(ZTRAIT_POCKETDIM)
	var/pocket_dimension
	if(!poket_dimensions.len)
		local_area = new()
		var/datum/space_level/pocket_dim = SSmapping.add_new_zlevel("Pocket Dimension",list(ZTRAIT_RESERVED = TRUE, ZTRAIT_POCKETDIM = TRUE ))
		pocket_dimension = pocket_dim.z_value
		SSmapping.initialize_reserved_level(pocket_dimension)
		local_pocket_dim = pocket_dimension
		//Settiing the ZTRAIT_BASETURF doesn't fucking do anything, thiw will also work.
		strip_pocket_dimension(baseturf)
		return pocket_dimension

///Strips the dimension into nothingness
/datum/pocket_dim_customizer/proc/strip_pocket_dimension(turf/newbaseturf = baseturf)
	var/pocket_dimension = local_pocket_dim
	if(!pocket_dimension)
		return
	var/turf/T
	//I know this is laggy, but atmos would literally crash the server if i added CHECK_TICK
	for(var/x_loop in 1 to 255)
		for(var/y_loop in 1 to 255)
			T = locate(x_loop, y_loop, pocket_dimension)
			T.ChangeTurf(newbaseturf,newbaseturf)
			T.change_area(T.loc,local_area)

///Creates a room of set size
/datum/pocket_dim_customizer/proc/create_room()
	var/pocket_dimension = local_pocket_dim
	if(!pocket_dimension)
		return
	var/offset = 127 - size
	var/turf/T = locate(1, 1, pocket_dimension)
	for(var/x_loop in 1 to size)
		for(var/y_loop in 1 to size)
			T = locate(x_loop + offset, y_loop + offset, pocket_dimension)
			if(y_loop == 1 || y_loop == size || x_loop == 1 || x_loop == size)
				T.ChangeTurf(wall)
				RegisterSignal(T,COMSIG_TURF_BUMPED,.proc/on_bump)
			else
				T.ChangeTurf(floor)
			RegisterSignal(T,COMSIG_TURF_CHANGE,.proc/on_breach)

///Reregisters all turfs to events
/datum/pocket_dim_customizer/proc/reregister_events()
	var/turf/T
	for(var/x_loop in 1 to 255)
		for(var/y_loop in 1 to 255)
			T = locate(x_loop, y_loop, local_pocket_dim)
			if(T.type == baseturf)
				continue
			if(isclosedturf(T))
				RegisterSignal(T,COMSIG_TURF_BUMPED,.proc/on_bump)
			RegisterSignal(T,COMSIG_TURF_CHANGE,.proc/on_breach)

///Unregisters all turfs to events
/datum/pocket_dim_customizer/proc/unregister_events()
	var/turf/T
	for(var/x_loop in 1 to 255)
		for(var/y_loop in 1 to 255)
			T = locate(x_loop, y_loop, local_pocket_dim)
			if(isclosedturf(T))
				UnregisterSignal(T,COMSIG_TURF_BUMPED)
			UnregisterSignal(T,COMSIG_TURF_CHANGE)

///Adds new events
/datum/pocket_dim_customizer/proc/add_periodic_event(datum/pocket_event/event)
	var/datum/pocket_event/new_event = new event
	event_list[new_event] = event
	new_event.on_add(src)
	START_PROCESSING(SSobj,src)

///Removes events
/datum/pocket_dim_customizer/proc/remove_periodic_event(datum/pocket_event/event)
	for(var/X in event_list)
		var/datum/pocket_event/live_event = X
		if(event_list[live_event] == event)
			event_list -= live_event
			live_event.on_remove(X)
			break
	if(!event_list.len)
		STOP_PROCESSING(SSobj,src)

///Admin friendly proc for adding events
/datum/pocket_dim_customizer/proc/admin_add_event(mob/user)
	var/list/_event_list = subtypesof(/datum/pocket_event)
	for(var/X in _event_list)
		var/datum/pocket_event/local_temp_var
		_event_list[X] = initial(local_temp_var.name)
	var/chosen = input(user,"Pick Event","Events",null) in _event_list
	if(!chosen)
		return
	add_periodic_event(_event_list[chosen])

///Admin friendly proc for removing events
/datum/pocket_dim_customizer/proc/admin_remove_event(mob/user)
	var/chosen = input(user,"Pick Event","Events",null) in event_list
	if(!chosen)
		return
	remove_periodic_event(event_list[chosen])

/datum/pocket_dim_customizer/process()
	var/datum/pocket_event/event
	for(var/E in event_list)
		event = E

		if(event.duration == -1)
			event.on_tick()
			continue

		if(event.period == 0)
			continue

		if(event.period_left > 0)
			event.period_left--
			event.duration_left = event.duration
			if(event.period_left == 0)
				event.on_trigger()
			continue

		if(event.duration_left > 0)
			event.on_tick()
			event.duration_left--

		if(event.duration_left == 0)
			event.on_disable()
			event.period_left = event.period

///Force moves the mob to the pocket dimensions, defaults to usr due to it being a pseudo admin command and i really dont feel like fucking with verbs today.
/datum/pocket_dim_customizer/proc/move_here(mob/user)
	var/turf/T = locate(128,128, local_pocket_dim)
	user.forceMove(T)

///What happens when one of the walls is breached
/datum/pocket_dim_customizer/proc/on_breach(datum/source)
	for(var/X in event_list)
		var/datum/pocket_event/event = X
		event.on_breach(src,source)

///What happens when one of the walls is bumped
/datum/pocket_dim_customizer/proc/on_bump(datum/source)
	for(var/X in event_list)
		var/datum/pocket_event/event = X
		event.on_bump(src,source)

///Spawns 2 portals
/datum/pocket_dim_customizer/proc/spawn_portals()
	if(portals.len)
		return
	portals = create_portal_pair(locate(128,128, local_pocket_dim), locate(127,127, local_pocket_dim), -1, 1)

///Teleports portal 1 to you
/datum/pocket_dim_customizer/proc/move_portal1(mob/user)
	portals[1].forceMove(user.loc)

///Teleports portal 2 to you
/datum/pocket_dim_customizer/proc/move_portal2(mob/user)
	portals[2].forceMove(user.loc)

/datum/pocket_dim_customizer/ui_act(action, params)
	. = ..()
	switch(action)
		if("create_dimension")
			create_pocket_dim()
		if("create_room")
			create_room()
		if("change_size")
			var/inputed = text2num(params["size"])
			if(inputed)
				size = inputed
		if("input_baseturf")
			var/inputed = text2path(input(last_user, "Enter new baseturf" , "Baseturf"))
			if(ispath(inputed))
				baseturf = inputed
		if("collapse_room")
			strip_pocket_dimension(baseturf)
		if("add_event")
			admin_add_event(last_user)
		if("remove_event")
			admin_remove_event(last_user)
		if("relink_event")
			reregister_events()
		if("input_wall")
			var/inputed = text2path(input(last_user, "Enter new wall" , "wall"))
			if(ispath(inputed))
				wall = inputed
		if("input_floor")
			var/inputed = text2path(input(last_user, "Enter new floor" , "floor"))
			if(ispath(inputed))
				floor = inputed
		if("create_portals")
			spawn_portals()
		if("move_portal1")
			move_portal1(last_user)
		if("move_portal2")
			move_portal2(last_user)
		if("move_here")
			move_here(last_user)

/datum/pocket_dim_customizer/ui_data(mob/user)
	var/list/data = list()
	data["size"] = size
	return data

/datum/pocket_dim_customizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	last_user = user
	if(!ui)

		ui = new(user, src, "PocketDimensionCustomizer", name)
		ui.open()

/datum/pocket_dim_customizer/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE
