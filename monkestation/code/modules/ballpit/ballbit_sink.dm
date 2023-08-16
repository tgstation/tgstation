/datum/component/player_sink
	var/max_sinkage = 18
	var/icon/sinker = icon('monkestation/icons/turf/ballpit.dmi', "sink")

	///the filters name path for locating
	var/filter_name = "sinkable"
	var/current_size = 0

/datum/component/player_sink/Initialize(...)
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, TYPE_PROC_REF(/datum/component/player_sink, recheck_state))
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, TYPE_PROC_REF(/datum/component/player_sink,remove_state))
	START_PROCESSING(SSobj, src)
	max_sinkage = rand(16,20)

/datum/component/player_sink/UnregisterFromParent()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(parent, COMSIG_ITEM_PICKUP)

/datum/component/player_sink/proc/recheck_state(atom/movable/moved, atom/new_location)
	if(!isopenturf(new_location) || !istype(new_location, /turf/open/ballpit))
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
