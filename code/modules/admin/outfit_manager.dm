/client/proc/triggtest2()
	set category = "Debug.TRIGG IS AT IT AGAIN"
	set name = "BBBBBB"

	if(!check_rights(R_DEBUG))
		return
	var/datum/outfit_manager/ui = new(usr)
	ui.ui_interact(usr)

#define OUTFITOTRON "Outfit-O-Tron 9000"
/datum/outfit_manager
	var/client/user

	var/dummy_key

/datum/outfit_manager/New(user)
	src.user = CLIENT_FROM_VAR(user)

/datum/outfit_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/outfit_manager/ui_close(mob/user)
	clear_human_dummy(dummy_key)
	qdel(src)

/datum/outfit_manager/proc/init_dummy()
	dummy_key = "outfit_manager_[user]"
	var/mob/living/carbon/human/dummy/dummy = generate_or_wait_for_human_dummy(dummy_key)
	var/mob/living/carbon/carbon_target = user.mob
	if(istype(carbon_target))
		carbon_target.dna.transfer_identity(dummy)
		dummy.updateappearance()

	unset_busy_human_dummy(dummy_key)
	return

/datum/outfit_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OutfitManager", OUTFITOTRON)
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/outfit_manager/proc/entry(datum/outfit/O)
	return list(
		"name" = O.name,
		"ref" = REF(O),
		)

/datum/outfit_manager/proc/get_outfits()
	var/list/outfits = list()
	for(var/datum/outfit/O in GLOB.custom_outfits)
		outfits += list(entry(O))
	return outfits

/datum/outfit_manager/ui_data()
	var/list/data = list()

	data["outfits"] = get_outfits()

	return data

/datum/outfit_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE

	var/datum/outfit/target_outfit = locate(params["outfit"])
	switch(action)
		if("new")
			user.open_outfit_editor(new /datum/outfit)
		if("load")
			user.holder.load_outfit(user.mob)
		if("copy")
			var/datum/outfit/outfit = tgui_input_list(user, "Pick an outfit to copy from", OUTFITOTRON, subtypesof(/datum/outfit))
			if(ispath(outfit))
				user.open_outfit_editor(new outfit)

	if(!istype(target_outfit))
		return
	switch(action) //wow we're switching through action again this is horrible optimization smh
		if("preview")
			pass()
		if("edit")
			user.open_outfit_editor(target_outfit)
		if("save")
			user.holder.save_outfit(target_outfit)
		if("delete")
			user.holder.delete_outfit(target_outfit)

#undef OUTFITOTRON
