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
	//get rid of this if GLOB.custom_outfits ever becomes a keyed list
	var/static/list/cached_custom_outfits = list()

	//normally a path; an initialized outfit object if it's a custom outfit
	var/datum/outfit/selected_outfit = /datum/outfit
	//used to keep track of which outfit the UI has selected
	var/selected_name = "/datum/outfit"

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

/*
 * category (string) - The tab it will be under
 * path (typepath or string) - This will sent this back to ui_act to preview or spawn in an outfit
 * name (string) - Will be the text on the button
 * priority (int) - default 0, 1 for favorites, 2 for priority buttons
*/
#define OUTFIT_ENTRY(category, path, name, priority) list("category" = category, "path" = path, "name" = name, "priority" = priority)
/datum/select_equipment/proc/make_outfit_entries(category="General", list/L)
	var/list/entries = list()
	for(var/path in L)
		var/datum/outfit/O = path
		var/priority = 0
		if(path == /datum/outfit/job/roboticist)
			priority = 1
		entries += list(OUTFIT_ENTRY(category, path, initial(O.name), priority))
	return entries


//GLOB.custom_outfits lists outfit *objects* so we'll need to do some custom handling for it
/datum/select_equipment/proc/make_custom_outfit_entries(list/L)
	var/list/entries = list()
	for(var/datum/outfit/O in L)
		cached_custom_outfits[O.name] = O
		entries += list(OUTFIT_ENTRY("Custom", O.name, O.name, 0)) //it's either this or special handling on the UI side
	return entries

/datum/select_equipment/ui_data(mob/user)
	var/list/data = list()
	if(!dummy)
		init_dummy()

	var/datum/preferences/prefs
	if(target.client)
		prefs = target.client.prefs
	var/icon/dummysprite = get_flat_human_icon(null, prefs=prefs, dummy_key = dummy_key, outfit_override = selected_outfit)
	data["icon64"] = icon2base64(dummysprite)
	data["name"] = target

	var/list/custom
	custom += make_custom_outfit_entries(GLOB.custom_outfits)
	data["custom_outfits"] = custom
	data["current_outfit"] = selected_name
	return data


/datum/select_equipment/ui_static_data(mob/user)
	var/list/data = list()
	if(!cached_outfits)
		cached_outfits = list()
		cached_outfits += list(OUTFIT_ENTRY("General", /datum/outfit, "Naked", 2))
		cached_outfits += make_outfit_entries("General", subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman))
		cached_outfits += make_outfit_entries("Jobs", typesof(/datum/outfit/job))
		cached_outfits += make_outfit_entries("Plasmamen Outfits", typesof(/datum/outfit/plasmaman))

	data["outfits"] = cached_outfits
	return data


/datum/select_equipment/proc/resolve_outfit(text)
	var/path = text2path(text)

	if(ispath(path, /datum/outfit))
		return path

	else //don't bail yet - could be a custom outfit
		var/datum/outfit/custom_outfit = cached_custom_outfits[text]
		if(istype(custom_outfit))
			return custom_outfit


/datum/select_equipment/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("preview")
			var/datum/outfit/O = resolve_outfit(params["path"])

			if(ispath(O)) //got a typepath - that means we're dealing with a normal outfit
				selected_name = O //these are keyed by type
				//by the way, no, they can't be keyed by name because many of them have duplicate names

			else if(istype(O)) //got an initialized object - means it's a custom outfit
				selected_name = O.name //and the outfit will be keyed by its name (cause its type will always be /datum/outfit)

			else //we got nothing and should bail
				return

			selected_outfit = O

		if("applyoutfit")
			var/datum/outfit/O = resolve_outfit(params["path"])
			if(O && ispath(O)) //initialize it
				O = new O
			if(!istype(O))
				return
			user.admin_apply_outfit(target, O)

		if("customoutfit")
			user.outfit_manager()


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

#undef OUTFIT_ENTRY
