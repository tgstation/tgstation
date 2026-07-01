/datum/verb_metadata
	var/name
	var/description
	var/category
	var/verb_path
	var/body_path
	var/list/arguments = list()

/datum/verb_metadata/proc/assign_to(target)
	add_verb(target, verb_path)

/datum/verb_metadata/proc/unassign_from(target)
	remove_verb(target, verb_path)

/datum/verb_arg_metadata
	var/name
	var/arg_type
	var/type_path
	var/source
	var/list/options

/datum/verb_arg_metadata/New(arg_name, arg_arg_type, arg_type_path, arg_source, list/arg_options)
	. = ..()
	name = arg_name
	arg_type = arg_arg_type
	type_path = arg_type_path
	source = arg_source
	options = arg_options

/datum/verb_arg_metadata/proc/get_targets(client/viewer)
	switch(source)
		if(VERB_ARG_SOURCE_WORLD)
			return get_world_targets(viewer)
		if(VERB_ARG_SOURCE_VIEW)
			return get_view_targets(viewer)
	return list()

/datum/verb_arg_metadata/proc/get_world_targets(client/viewer)
	if(arg_type & VERB_ARG_TYPE_MOB)
		return GLOB.mob_list
	if(arg_type & VERB_ARG_TYPE_AREA)
		return get_sorted_areas()
	if(arg_type & VERB_ARG_TYPE_TURF)
		var/list/turfs = list()
		if(viewer.mob)
			var/turf/admin_turf = get_turf(viewer.mob)
			if(admin_turf)
				turfs += admin_turf
		for(var/mob/player in GLOB.player_list)
			var/turf/player_turf = get_turf(player)
			if(player_turf)
				turfs |= player_turf
		return turfs
	if(arg_type & (VERB_ARG_TYPE_OBJ | VERB_ARG_TYPE_DATUM | VERB_ARG_TYPE_ATOM))
		if(viewer.mob)
			return view(viewer.view, viewer.mob)
	return list()

/datum/verb_arg_metadata/proc/get_view_targets(client/viewer)
	if(!viewer.mob)
		return list()
	var/list/visible = view(viewer.view, viewer.mob)
	if(arg_type & VERB_ARG_TYPE_MOB)
		var/list/mobs = list()
		for(var/mob/target in visible)
			mobs += target
		return mobs
	if(arg_type & VERB_ARG_TYPE_OBJ)
		var/list/objs = list()
		for(var/obj/target in visible)
			objs += target
		return objs
	if(arg_type & VERB_ARG_TYPE_TURF)
		var/list/turfs = list()
		for(var/turf/target in visible)
			turfs += target
		return turfs
	return visible

GLOBAL_LIST_INIT(____pending_verb_args, list())

/proc/____register_verb_arg(owner_type, proc_path, arg_name, arg_type, arg_type_path, arg_source)
	var/verb_key
	if(ispath(owner_type, /datum/admin_verb))
		verb_key = owner_type
	else
		verb_key = proc_path

	if(!GLOB.____pending_verb_args[verb_key])
		GLOB.____pending_verb_args[verb_key] = list()
	GLOB.____pending_verb_args[verb_key] += list(new /datum/verb_arg_metadata(arg_name, arg_type, arg_type_path, arg_source))
	return TRUE

/proc/____register_verb_arg_list(owner_type, proc_path, arg_name, list/options)
	var/verb_key
	if(ispath(owner_type, /datum/admin_verb))
		verb_key = owner_type
	else
		verb_key = proc_path

	if(!GLOB.____pending_verb_args[verb_key])
		GLOB.____pending_verb_args[verb_key] = list()
	GLOB.____pending_verb_args[verb_key] += list(new /datum/verb_arg_metadata(arg_name, VERB_ARG_TYPE_TEXT, null, VERB_ARG_SOURCE_LIST, options))
	return TRUE
