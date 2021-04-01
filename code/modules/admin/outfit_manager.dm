/client/proc/triggtest2()
	set category = "Debug.TRIGG IS AT IT AGAIN"
	set name = "BBBBBB"

	if(!check_rights(R_DEBUG))
		return
	var/datum/outfit_manager/ui = new(usr)
	ui.ui_interact(usr)

#define OUTFITOTRON "Outfit-O-Tron 9000"
/datum/outfit_manager
	var/client/holder

	var/dummy_key
	var/datum/outfit/drip = /datum/outfit/job/miner/equipped/hardsuit

/datum/outfit_manager/New(user)
	holder = CLIENT_FROM_VAR(user)
	drip = new drip

/datum/outfit_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/outfit_manager/ui_close(mob/user)
	clear_human_dummy(dummy_key)
	qdel(src)

/datum/outfit_manager/proc/init_dummy()
	dummy_key = "outfit_manager_[holder]"
	var/mob/living/carbon/human/dummy/dummy = generate_or_wait_for_human_dummy(dummy_key)
	var/mob/living/carbon/carbon_target = holder.mob
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

/datum/outfit_manager/ui_data(mob/user)
	var/list/data = list()


	data["outfits"] = get_outfits()

	var/datum/preferences/prefs = holder.prefs
	var/icon/dummysprite = get_flat_human_icon(null, prefs = prefs, dummy_key = dummy_key, showDirs = list(SOUTH), outfit_override = drip)
	data["dummy64"] = icon2base64(dummysprite)

	return data

/datum/outfit_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE

	//var/datum/outfit/target_outfit = locate(params["ref"])
	switch(action)
		if("preview")
			pass()
		if("edit")
			pass()
		if("load")
			pass()


#undef OUTFITOTRON
