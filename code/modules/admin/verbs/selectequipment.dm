/client/proc/cmd_select_equipment(mob/M in GLOB.mob_list)
	set category = "Admin.Events"
	set name = "Select equipment but better"


	var/datum/select_equipment/ui  = new(usr, M)
	ui.ui_interact(usr)

/datum/select_equipment
	var/client/user
	var/mob/target

	var/dummy_key
	var/mob/living/carbon/human/dummy/dummy

	var/static/list/cached_outfits
	var/static/list/cached_custom_outfits = list()
	var/datum/outfit/selected_outfit = /datum/outfit

/datum/select_equipment/New(usr, mob/M)
	user = CLIENT_FROM_VAR(usr)

	if(!(ishuman(M) || isobserver(M)))
		alert("Invalid mob")
		return
	target = M

/datum/select_equipment/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SelectEquipment", "Select Equipment")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/select_equipment/ui_state(mob/user)
	return GLOB.admin_state

/datum/select_equipment/ui_status(mob/user, datum/ui_state/state)
	if(QDELETED(target))
		return UI_CLOSE
	return ..()

/datum/select_equipment/ui_close(mob/user)
	clear_human_dummy(dummy_key)
	qdel(src)

/datum/select_equipment/proc/init_dummy()
	dummy_key = "selectequipmentUI_[target]"
	dummy = generate_or_wait_for_human_dummy(dummy_key)
	var/mob/living/carbon/C = target
	if(istype(C))
		C.dna.transfer_identity(dummy)
		dummy.updateappearance()

	unset_busy_human_dummy(dummy_key)
	return

/datum/select_equipment/proc/make_outfit_entries(list/L)
	var/list/entries = list()
	for(var/path in L)
		var/datum/outfit/O = path
		entries[path] = initial(O.name)
	return sortAssocList(entries)

//GLOB.custom_outfits lists outfit *objects* so we'll need to do some custom handling for it
/datum/select_equipment/proc/make_custom_outfit_entries(list/L)
	var/list/entries = list()
	for(var/datum/outfit/O in L)
		cached_custom_outfits[O.name] = O
		entries[O.name] = O.name //it's either this or special handling on the UI side
	return sortAssocList(entries)

/datum/select_equipment/ui_data(mob/user)
	var/list/data = list()
	if(!dummy)
		init_dummy()

	var/datum/preferences/prefs
	if(target.client)
		prefs = target.client.prefs
	var/icon/dummysprite = get_flat_human_icon(null, prefs=prefs, dummy_key = dummy_key, outfit_override = selected_outfit)
	data["icon64"] = icon2base64(dummysprite)

	if(!cached_outfits)
		//the assoc keys here will turn into Tabs in the UI, so make sure to name them well
		cached_outfits = list()
		cached_outfits["General"] = list(/datum/outfit = "Naked") + make_outfit_entries(subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman))
		cached_outfits["Jobs"] = make_outfit_entries(typesof(/datum/outfit/job))
		cached_outfits["Plasmamen Outfits"] = make_outfit_entries(typesof(/datum/outfit/plasmaman))

	cached_outfits["Custom"] = list("Click confirm to open the outfit manager" = "Create a custom outfit...") + make_custom_outfit_entries(GLOB.custom_outfits)

	data["outfits"] = cached_outfits
	data["name"] = target

	return data


/datum/select_equipment/proc/resolve_outfit(text)
	var/path = text2path(text)

	if(ispath(path, /datum/outfit))
		return new path

	else //don't bail yet - could be a special option or custom outfit
		var/datum/outfit/custom_outfit = cached_custom_outfits[text]
		if(istype(custom_outfit))
			return custom_outfit


/datum/select_equipment/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("preview")
			var/datum/outfit/O = resolve_outfit(params["path"])
			if(!istype(O))
				return
			selected_outfit = O.type //the typepath - not the object
			return TRUE

		if("applyoutfit")
			var/text = params["path"]
			if(text == "Click confirm to open the outfit manager")
				user.outfit_manager()
				return

			var/datum/outfit/O = resolve_outfit(text)
			if(!istype(O))
				return
			user.admin_apply_outfit(target, O)
			return TRUE


/client/proc/admin_apply_outfit(mob/M, dresscode)
	if(!(ishuman(M) || isobserver(M)))
		alert("Invalid mob")
		return

	if(!dresscode)
		return

	var/delete_pocket
	var/mob/living/carbon/human/H
	if(isobserver(M))
		H = M.change_mob_type(/mob/living/carbon/human, null, null, TRUE)
	else
		H = M
		if(H.l_store || H.r_store || H.s_store) //saves a lot of time for admins and coders alike
			if(alert("Drop Items in Pockets? No will delete them.", "Robust quick dress shop", "Yes", "No") == "No")
				delete_pocket = TRUE

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Select Equipment") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	for (var/obj/item/I in H.get_equipped_items(delete_pocket))
		qdel(I)
	if(dresscode != "Naked")
		H.equipOutfit(dresscode)

	H.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(H)] to [dresscode].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] changed the equipment of [ADMIN_LOOKUPFLW(H)] to [dresscode].</span>")

	return dresscode
