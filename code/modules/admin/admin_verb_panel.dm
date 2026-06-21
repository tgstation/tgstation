// TODO: remove this debug verb before merging
/client/verb/debug_admin_verb_panel()
	set name = "Debug Admin Verb Panel"
	set category = "Debug"
	var/datum/admin_verb_panel/panel = new(src)
	panel.ui_interact(mob)

ADMIN_VERB(admin_verb_panel, R_NONE, "Admin Verb Panel", "Browse and invoke admin verbs.", ADMIN_CATEGORY_EVENTS)
	var/datum/admin_verb_panel/panel = new(user)
	panel.ui_interact(user.mob)

/datum/admin_verb_panel
	var/client/owner
	var/selected_verb_type

/datum/admin_verb_panel/New(client/user)
	owner = user

/datum/admin_verb_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminVerbPanel")
		ui.open()

/datum/admin_verb_panel/ui_state(mob/user)
	return ADMIN_STATE(R_NONE)

/datum/admin_verb_panel/ui_static_data(mob/user)
	var/list/data = list()
	var/list/verbs_data = list()
	var/list/categories = list()

	for(var/datum/admin_verb/verb_type as anything in SSadmin_verbs.admin_verbs_by_type)
		var/datum/admin_verb/verb = SSadmin_verbs.admin_verbs_by_type[verb_type]
		if(!SSadmin_verbs.verify_visibility(owner, verb))
			continue
		if(!owner.holder.check_for_rights(verb.permissions))
			continue

		var/list/verb_entry = list(
			"type" = "[verb_type]",
			"name" = verb.name,
			"description" = verb.description,
			"category" = verb.category || "Unsorted",
			"arguments" = list(),
		)

		for(var/datum/verb_arg_metadata/arg in verb.metadata?.arguments)
			verb_entry["arguments"] += list(list(
				"name" = arg.name,
				"arg_type" = arg.arg_type,
				"type_path" = "[arg.type_path]",
				"source" = arg.source,
			))

		verbs_data += list(verb_entry)
		categories |= list(verb.category || "Unsorted")

	data["verbs"] = verbs_data
	data["categories"] = categories
	return data

/datum/admin_verb_panel/ui_data(mob/user)
	var/list/data = list()
	data["targets"] = build_target_list()
	return data

#define ADMIN_VERB_ARG_TYPE_ENTITY (VERB_ARG_TYPE_MOB | VERB_ARG_TYPE_OBJ | VERB_ARG_TYPE_TURF | VERB_ARG_TYPE_AREA | VERB_ARG_TYPE_DATUM | VERB_ARG_TYPE_ATOM)

/datum/admin_verb_panel/proc/build_target_list()
	if(!selected_verb_type)
		return list()

	var/datum/admin_verb/verb = SSadmin_verbs.admin_verbs_by_type[selected_verb_type]
	if(!verb || !length(verb.metadata?.arguments))
		return list()

	var/datum/verb_arg_metadata/entity_arg
	for(var/datum/verb_arg_metadata/arg in verb.metadata.arguments)
		if(arg.arg_type & ADMIN_VERB_ARG_TYPE_ENTITY)
			entity_arg = arg
			break

	if(!entity_arg)
		return list()

	var/list/source_atoms = get_targets_for_arg(entity_arg)

	var/list/targets = list()
	for(var/atom/target in source_atoms)
		var/list/entry = list(
			"ref" = REF(target),
		)
		if(ismob(target))
			var/mob/mob_target = target
			entry["name"] = mob_target.name
			entry["ckey"] = mob_target.ckey || ""
			entry["job"] = mob_target.mind?.assigned_role?.title || ""
		else if(isturf(target))
			var/turf/turf_target = target
			var/area/turf_area = get_area(turf_target)
			entry["name"] = "[turf_area?.name || turf_target.name] ([turf_target.x],[turf_target.y],[turf_target.z])"
		else if(isarea(target))
			entry["name"] = target.name
		else
			entry["name"] = "[target.name] ([target.type])"
		targets += list(entry)
	return targets

/datum/admin_verb_panel/proc/get_targets_for_arg(datum/verb_arg_metadata/arg)
	switch(arg.source)
		if(VERB_ARG_SOURCE_WORLD)
			return get_world_targets(arg.arg_type)
		if(VERB_ARG_SOURCE_VIEW)
			return get_view_targets(arg.arg_type)
	return list()

/datum/admin_verb_panel/proc/get_world_targets(arg_type)
	if(arg_type & VERB_ARG_TYPE_MOB)
		return GLOB.mob_list
	if(arg_type & VERB_ARG_TYPE_AREA)
		return get_sorted_areas()
	if(arg_type & VERB_ARG_TYPE_TURF)
		return get_notable_turfs()
	if(arg_type & VERB_ARG_TYPE_OBJ)
		if(owner.mob)
			return view(owner.view, owner.mob)
		return list()
	if(arg_type & (VERB_ARG_TYPE_ATOM | VERB_ARG_TYPE_DATUM))
		if(owner.mob)
			return view(owner.view, owner.mob)
		return list()
	return list()

/datum/admin_verb_panel/proc/get_notable_turfs()
	var/list/turfs = list()
	if(owner.mob)
		var/turf/admin_turf = get_turf(owner.mob)
		if(admin_turf)
			turfs += admin_turf
	for(var/mob/player in GLOB.player_list)
		var/turf/player_turf = get_turf(player)
		if(player_turf)
			turfs |= player_turf
	return turfs

/datum/admin_verb_panel/proc/get_view_targets(arg_type)
	if(!owner.mob)
		return list()
	var/list/visible = view(owner.view, owner.mob)
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

/datum/admin_verb_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("select_verb")
			selected_verb_type = text2path(params["verb_type"])
			return TRUE
		if("invoke")
			var/verb_type = text2path(params["verb_type"])
			if(!verb_type)
				return
			var/list/raw_args = params["args"]
			if(!islist(raw_args))
				raw_args = list()
			var/list/structured_args = list()
			for(var/key in raw_args)
				var/value = raw_args[key]
				if(istext(value))
					value = locate(value)
				structured_args[key] = value
			SSadmin_verbs.dynamic_invoke_verb(owner, verb_type, structured_args)
			return TRUE
