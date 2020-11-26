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
			var/new_filter
			switch(params["type"])
				if("alpha")
					new_filter = alpha_mask_filter()
			target.add_filter(params["name"], params["priority"], new_filter)
		if("remove_filter")
			target.remove_filter(params["name"])
		if("edit_filter")
			target.remove_filter(params["name"])
			target.add_filter(params["name"], params["priority"], params["new_filter"])

