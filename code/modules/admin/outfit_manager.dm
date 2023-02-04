ADMIN_VERB(debug, outfit_manager, "Outfit Manager", "", R_DEBUG)
	var/datum/outfit_manager/ui = new(usr)
	ui.ui_interact(usr)

/datum/outfit_manager
	var/client/owner

/datum/outfit_manager/New(user)
	owner = CLIENT_FROM_VAR(user)

/datum/outfit_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/outfit_manager/ui_close(mob/user)
	qdel(src)

/datum/outfit_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OutfitManager")
		ui.open()

/datum/outfit_manager/proc/entry(datum/outfit/outfit)
	var/vv = FALSE
	var/datum/outfit/varedit/varoutfit = outfit
	if(istype(varoutfit))
		vv = length(varoutfit.vv_values)
	return list(
		"name" = "[outfit.name] [vv ? "(VV)" : ""]",
		"ref" = REF(outfit),
	)

/datum/outfit_manager/ui_data(mob/user)
	var/list/data = list()

	var/list/outfits = list()
	for(var/datum/outfit/custom_outfit in GLOB.custom_outfits)
		outfits += list(entry(custom_outfit))
	data["outfits"] = outfits

	return data

/datum/outfit_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE

	switch(action)
		if("new")
			owner.open_outfit_editor(new /datum/outfit)
		if("load")
			owner.holder.load_outfit(owner.mob)
		if("copy")
			var/datum/outfit/outfit = tgui_input_list(owner, "Pick an outfit to copy from", "Outfit Manager", subtypesof(/datum/outfit))
			if(isnull(outfit))
				return
			if(!ispath(outfit))
				return
			owner.open_outfit_editor(new outfit)

	var/datum/outfit/target_outfit = locate(params["outfit"])
	if(!istype(target_outfit))
		return
	switch(action) //wow we're switching through action again this is horrible optimization smh
		if("edit")
			owner.open_outfit_editor(target_outfit)
		if("save")
			owner.holder.save_outfit(owner.mob, target_outfit)
		if("delete")
			owner.holder.delete_outfit(owner.mob, target_outfit)
