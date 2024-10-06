/obj/machinery/power/manufacturing/sorter
	icon_state = "router"
	name = "conveyor sort-router"
	desc = "Pushes things on it to its sides following set criteria, set via multitool."
	layer = BELOW_OPEN_DOOR_LAYER
	density = FALSE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	circuit = /obj/item/circuitboard/machine/manusorter 
	/// for mappers; filter path = list(direction, value), otherwise a list of initialized filters
	var/list/sort_filters = list()
	/// dir to push to if there is no criteria
	var/dir_if_not_met
	/// timer id of the thing that makes stuff move
	var/delay_timerid
	/// max filters
	var/max_filters = 10

/obj/machinery/power/manufacturing/sorter/Initialize(mapload)
	. = ..()
	if(isnull(dir_if_not_met))
		dir_if_not_met = dir
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	for(var/i in 1 to length(sort_filters))
		var/creating_type = sort_filters[i]
		var/list/values = sort_filters[creating_type]
		var/datum/sortrouter_filter/new_type = new creating_type(src)
		new_type.dir_target = values[1]
		new_type.value = values[2]
		sort_filters[i] = new_type
	START_PROCESSING(SSobj, src)

/obj/machinery/power/manufacturing/sorter/Destroy()
	. = ..()
	QDEL_LIST(sort_filters)

/obj/machinery/power/manufacturing/sorter/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	ui_interact(user)

/obj/machinery/power/manufacturing/sorter/receive_resource(atom/movable/receiving, atom/from, receive_dir)
	if(length(loc.contents) >= MANUFACTURING_TURF_LAG_LIMIT)
		return MANUFACTURING_FAIL_FULL
	receiving.Move(loc)
	return MANUFACTURING_SUCCESS


/obj/machinery/power/manufacturing/sorter/ui_data(mob/user)
	. = list()
	.["unmet_dir"] = dir_if_not_met
	.["filters"] = list()
	for(var/datum/sortrouter_filter/sorting as anything in sort_filters)
		.["filters"] += list(list(
			"name" = sorting.return_name(),
			"ref" = REF(sorting),
			"inverted" = sorting.inverted,
			"dir" = sorting.dir_target,
		))

/obj/machinery/power/manufacturing/sorter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("del_filter")
			var/datum/sortrouter_filter/filter = locate(params["ref"])
			if(isnull(filter))
				return
			sort_filters -= filter
			qdel(filter)
			return TRUE
		if("new_filter")
			if(length(sort_filters) >= max_filters)
				return
			var/static/list/filter_by_name
			if(!length(filter_by_name))
				filter_by_name = list()
				for(var/datum/sortrouter_filter/to_do as anything in subtypesof(/datum/sortrouter_filter))
					filter_by_name[initial(to_do.name)] = to_do
				filter_by_name = sort_list(filter_by_name)
			var/target_type = tgui_input_list(usr, "Select a filter", "New Filter", filter_by_name)
			if(isnull(target_type)|| !usr.can_perform_action(src, ALLOW_SILICON_REACH))
				return
			target_type = filter_by_name[target_type]
			sort_filters += new target_type(src)
			return TRUE
		if("rotate")
			var/datum/sortrouter_filter/filter = locate(params["ref"])
			if(isnull(filter))
				return
			var/next_ind = GLOB.cardinals.Find(filter.dir_target) + 1
			filter.dir_target = GLOB.cardinals[WRAP(next_ind, 1, 5)]
			return TRUE
		if("rotate_unmet")
			var/next_ind = GLOB.cardinals.Find(dir_if_not_met) + 1
			dir_if_not_met = GLOB.cardinals[WRAP(next_ind, 1, 5)]
			return TRUE
		if("edit")
			var/datum/sortrouter_filter/filter = locate(params["ref"])
			if(isnull(filter))
				return
			filter.edit(usr)
			return TRUE
		if("shift")
			var/datum/sortrouter_filter/filter = locate(params["ref"])
			if(isnull(filter))
				return
			var/next_ind = WRAP(sort_filters.Find(filter) + text2num(params["amount"]), 1, length(sort_filters)+1)
			sort_filters -= filter
			sort_filters.Insert(next_ind, filter)
			return TRUE

/obj/machinery/power/manufacturing/sorter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ManufacturingSorter")
		ui.open()

/obj/machinery/power/manufacturing/sorter/proc/send_nomobs(atom/movable/moving, dir)
	var/mutable_appearance/operate = mutable_appearance(icon, "router_operate")
	operate.dir = dir
	flick_overlay_view(operate, 1 SECONDS)
	return ismob(moving) ? moving.Move(get_step(src,dir), dir) : send_resource(moving, dir)

/obj/machinery/power/manufacturing/sorter/process()
	if(delay_timerid || !length(loc?.contents - 1))
		return
	launch_everything()

/obj/machinery/power/manufacturing/sorter/proc/on_entered(datum/source, atom/movable/mover)
	SIGNAL_HANDLER
	if(mover == src || !istype(mover) || mover.anchored || delay_timerid)
		return
	delay_timerid = addtimer(CALLBACK(src, PROC_REF(launch_everything)), 0.2 SECONDS)

/obj/machinery/power/manufacturing/sorter/proc/launch_everything()
	delay_timerid = null
	var/turf/where_we_at = get_turf(src)
	for(var/atom/movable/mover as anything in where_we_at.contents)
		if(mover.anchored)
			continue
		for(var/datum/sortrouter_filter/sorting as anything in sort_filters)
			if(sorting.meets_conditions(mover) == sorting.inverted)
				continue
			send_nomobs(mover, sorting.dir_target)
			return
		send_nomobs(mover, dir_if_not_met)
