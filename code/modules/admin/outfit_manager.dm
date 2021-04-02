/client/proc/outfit_manager()
	//set category = "Debug"
	set category = "Debug.TRIGG IS AT IT AGAIN"
	set name = "Outfit Manager"

	if(!check_rights(R_DEBUG))
		return
	var/datum/outfit_manager/ui = new(usr)
	ui.ui_interact(usr)


/datum/outfit_manager
	var/client/user

/datum/outfit_manager/New(user)
	src.user = CLIENT_FROM_VAR(user)

/datum/outfit_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/outfit_manager/ui_close(mob/user)
	qdel(src)

/datum/outfit_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OutfitManager", "Outfit Manager")
		ui.open()
		ui.set_autoupdate(FALSE)


/datum/outfit_manager/proc/entry(datum/outfit/O)
	var/vv = FALSE
	var/datum/outfit/varedit/VO = O
	if(istype(VO))
		vv = length(VO.vv_values)
	return list(
		"name" = "[O.name] [vv ? "(VV)" : ""]",
		"ref" = REF(O),
		)

/datum/outfit_manager/ui_data(mob/user)
	var/list/data = list()

	var/list/outfits = list()
	for(var/datum/outfit/O in GLOB.custom_outfits)
		outfits += list(entry(O))
	data["outfits"] = outfits

	return data

/datum/outfit_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE

	switch(action)
		if("new")
			user.open_outfit_editor(new /datum/outfit)
		if("load")
			user.holder.load_outfit(user.mob)
		if("copy")
			var/datum/outfit/outfit = tgui_input_list(user, "Pick an outfit to copy from", "Outfit Manager", subtypesof(/datum/outfit))
			if(ispath(outfit))
				user.open_outfit_editor(new outfit)

	var/datum/outfit/target_outfit = locate(params["outfit"])
	if(!istype(target_outfit))
		return
	switch(action) //wow we're switching through action again this is horrible optimization smh
		if("edit")
			user.open_outfit_editor(target_outfit)
		if("save")
			user.holder.save_outfit(user.mob, target_outfit)
		if("delete")
			user.holder.delete_outfit(user.mob, target_outfit)
