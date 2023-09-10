/datum/component/player_sink
	var/max_sinkage = 18
	var/icon/sinker = icon('monkestation/icons/turf/ballpit.dmi', "sink")

	///the filters name path for locating
	var/filter_name = "sinkable"
	var/current_size = 0
	///Static list of turf types that are sinkable
	var/static/list/sinking_turf_types

//type_to_add is a type to try and add to sinking_turf_types
/datum/component/player_sink/Initialize(max_sinkage, type_to_add)
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, TYPE_PROC_REF(/datum/component/player_sink, recheck_state))
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, TYPE_PROC_REF(/datum/component/player_sink,remove_state))
	START_PROCESSING(SSobj, src)
	if(max_sinkage)
		src.max_sinkage = max_sinkage
	else
		max_sinkage = rand(16,20)

	if(!sinking_turf_types)
		sinking_turf_types = list()

	if(!locate(type_to_add) in sinking_turf_types)
		sinking_turf_types |= type_to_add

/datum/component/player_sink/UnregisterFromParent()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(parent, COMSIG_ITEM_PICKUP)

/datum/component/player_sink/proc/recheck_state(atom/movable/moved, atom/new_location)
	if(!isopenturf(new_location) || !is_type_in_list(new_location, sinking_turf_types))
		var/datum/component/meh = parent.GetComponent(/datum/component/player_sink)
		if(meh)
			var/filter = parent.get_filter("sinkable")
			if(filter)
				parent.remove_filter("sinkable")
			qdel(meh)

/datum/component/player_sink/proc/remove_state()
	var/datum/component/meh = parent.GetComponent(/datum/component/player_sink)
	var/filter = parent.get_filter("sinkable")
	if(filter)
		parent.remove_filter("sinkable")
	qdel(meh)

/datum/component/player_sink/process(seconds_per_tick)
	var/filter = parent.get_filter("sinkable")
	if(!filter)
		parent.add_filter("sinkable", 1, displacement_map_filter(size= current_size, icon = sinker))
		filter = parent.get_filter("sinkable")
	if(current_size <= max_sinkage)
		current_size++
	parent.modify_filter("sinkable", list(size= current_size, icon = sinker))
