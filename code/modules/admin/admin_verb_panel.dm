ADMIN_VERB(admin_verb_panel, R_NONE, "Admin Verb Panel", "Browse and invoke admin verbs.", ADMIN_CATEGORY_EVENTS)
	var/datum/admin_verb_panel/panel = new(user)
	panel.ui_interact(user.mob)

/datum/admin_verb_panel
	var/client/owner
	var/selected_verb_type
	var/typepath_parent = "/datum"
	var/list/typepath_children = list()

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
	data["typepaths"] = list("parent" = typepath_parent, "paths" = typepath_children)
	return data

/datum/admin_verb_panel/proc/build_target_list()
	if(!selected_verb_type)
		return list()

	var/datum/admin_verb/verb = SSadmin_verbs.admin_verbs_by_type[selected_verb_type]
	if(!verb || !length(verb.metadata?.arguments))
		return list()

	var/datum/verb_arg_metadata/entity_arg
	for(var/datum/verb_arg_metadata/arg in verb.metadata.arguments)
		if(arg.arg_type & VERB_ARG_TYPE_ENTITY)
			entity_arg = arg
			break

	if(!entity_arg)
		return list()

	var/list/source_atoms = entity_arg.get_targets(owner)

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
		if("request_typepaths")
			var/parent_text = params["parent"]
			var/browse_type = text2path(parent_text)
			if(isnull(browse_type))
				browse_type = /datum
			typepath_parent = parent_text || "/datum"
			typepath_children = list()
			for(var/child_type in typesof(browse_type))
				if(child_type == browse_type)
					continue
				var/child_text = "[child_type]"
				var/parent_len = length(typepath_parent)
				var/remainder = copytext(child_text, parent_len + 1)
				if(findtext(remainder, "/", 2))
					continue
				typepath_children += child_text
			return TRUE
