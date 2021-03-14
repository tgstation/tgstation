/client/proc/cmd_select_equipment(mob/target in GLOB.mob_list)
	set category = "Admin.Events"
	set name = "Select equipment but better"


	var/datum/select_equipment/ui = new(usr, target)
	ui.ui_interact(usr)

/datum/select_equipment
	var/client/user
	var/mob/target

	var/dummy_key
	var/mob/living/carbon/human/dummy/dummy

	var/static/list/cached_outfits

	//normally a path; an initialized outfit object if it's a custom outfit
	var/datum/outfit/selected_outfit = /datum/outfit
	//used to keep track of which outfit the UI has selected
	var/selected_name = "/datum/outfit"

/datum/select_equipment/New(user, mob/target)
	user = CLIENT_FROM_VAR(user)

	if(!ishuman(target) || !isobserver(target))
		alert("Invalid mob")
		return
	target = target

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
	var/mob/living/carbon/carbon_target = target
	if(istype(carbon_target))
		carbon_target.dna.transfer_identity(dummy)
		dummy.updateappearance()

	unset_busy_human_dummy(dummy_key)
	return

/*
 * category (string) - The tab it will be under
 * path (typepath or string) - This will sent this back to ui_act to preview or spawn in an outfit
 * name (string) - Will be the text on the button
 * priority (int) - default 0, 1 for favorites, 2 for priority buttons
*/
/datum/select_equipment/proc/outfit_entry(category, path, name, priority)
	return list("category" = category, "path" = path, "name" = name, "priority" = priority)
//passes a ref instead of path, every entry needs some sort of unique identifier
//and GLOB.custom_outfits allows duplicate names
/datum/select_equipment/proc/outfit_custom_entry(category, ref, name, priority)
	return list("category" = category, "ref" = ref, "name" = name, "priority" = priority)

/datum/select_equipment/proc/make_outfit_entries(category="General", list/outfit_list)
	var/list/entries = list()
	for(var/path as anything in outfit_list)
		var/datum/outfit/O = path
		var/priority = 0
		if(path == /datum/outfit/job/roboticist) //dummy check here until I get favorites working
			priority = 1
		entries += list(outfit_entry(category, path, initial(O.name), priority))
	return entries


//GLOB.custom_outfits lists outfit *objects* so we'll need to do some custom handling for it
/datum/select_equipment/proc/make_custom_outfit_entries(list/outfit_list)
	var/list/entries = list()
	for(var/datum/outfit/O as anything in outfit_list)
		entries += list(outfit_custom_entry("Custom", REF(O), O.name, 0)) //it's either this or special handling on the UI side
	return entries

/datum/select_equipment/ui_data(mob/user)
	var/list/data = list()
	if(!dummy)
		init_dummy()

	var/datum/preferences/prefs = target?.client?.prefs
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
		cached_outfits += list(outfit_entry("General", /datum/outfit, "Naked", 2))
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
		var/datum/outfit/custom_outfit = locate(text)
		if(istype(custom_outfit))
			return custom_outfit


/datum/select_equipment/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("preview")
			var/datum/outfit/new_outfit = resolve_outfit(params["path"])

			if(ispath(new_outfit)) //got a typepath - that means we're dealing with a normal outfit
				selected_name = new_outfit //these are keyed by type
				//by the way, no, they can't be keyed by name because many of them have duplicate names

			else if(istype(new_outfit)) //got an initialized object - means it's a custom outfit
				selected_name = REF(new_outfit) //and the outfit will be keyed by its ref (cause its type will always be /datum/outfit)

			else //we got nothing and should bail
				return

			selected_outfit = new_outfit

		if("applyoutfit")
			var/datum/outfit/new_outfit = resolve_outfit(params["path"])
			if(new_outfit && ispath(new_outfit)) //initialize it
				new_outfit = new new_outfit
			if(!istype(new_outfit))
				return
			user.admin_apply_outfit(target, new_outfit)

		if("customoutfit")
			user.outfit_manager()


/client/proc/admin_apply_outfit(mob/target, dresscode)
	if(!ishuman(target) || !isobserver(target))
		alert("Invalid mob")
		return

	if(!dresscode)
		return

	var/delete_pocket
	var/mob/living/carbon/human/human_target
	if(isobserver(target))
		human_target = target.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
	else
		human_target = target
		if(human_target.l_store || human_target.r_store || human_target.s_store) //saves a lot of time for admins and coders alike
			if(alert("Drop Items in Pockets? No will delete them.", "Robust quick dress shop", "Yes", "No") == "No")
				delete_pocket = TRUE

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Select Equipment") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	for(var/obj/item/item in human_target.get_equipped_items(delete_pocket))
		qdel(item)
	if(dresscode != "Naked")
		human_target.equipOutfit(dresscode)

	human_target.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(human_target)] to [dresscode].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] changed the equipment of [ADMIN_LOOKUPFLW(human_target)] to [dresscode].</span>")

	return dresscode
