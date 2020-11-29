/datum/filter_editor
	var/atom/target

/datum/filter_editor/New(atom/target)
	src.target = target

/datum/filter_editor/ui_state(mob/user)
	return GLOB.admin_state

/datum/filter_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Filteriffic", "Filteriffic")
		ui.open()

/datum/filter_editor/ui_static_data(mob/user)
	var/list/data = list()
	data["filter_info"] = GLOB.master_filter_info
	return data

/datum/filter_editor/ui_data()
	var/list/data = list()
	data["target_name"] = target.name
	data["target_filter_data"] = target.filter_data
	return data

/datum/filter_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_filter")
			target.add_filter(params["name"], params["priority"], list("type" = params["type"]))
		if("remove_filter")
			target.remove_filter(params["name"])
		if("rename_filter")
			var/list/filter_data = target.filter_data[params["name"]]
			target.remove_filter(params["name"])
			target.add_filter(params["new_name"], filter_data["priority"], filter_data)
		if("edit_filter")
			target.remove_filter(params["name"])
			target.add_filter(params["name"], params["priority"], params["new_filter"])
		if("increase_priority")

		if("decrease_priority")

		if("modify_filter_value")
			var/list/old_filter_data = target.filter_data[params["name"]]
			var/list/new_filter_data = old_filter_data.Copy()
			for(var/entry in params["new_data"])
				new_filter_data[entry] = params["new_data"][entry]
			for(var/entry in new_filter_data)
				if(entry == GLOB.master_filter_info[old_filter_data["type"]]["defaults"][entry])
					new_filter_data.Remove(entry)
			target.remove_filter(params["name"])
			target.add_filter(params["name"], old_filter_data["priority"], new_filter_data)

