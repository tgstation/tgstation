/client/proc/triggtest(mob/M in GLOB.mob_list)
	set name = "AAAAAAAAAAAAAAA"
	set category = "Debug.Trigg is devving oh god"


	var/datum/select_equipment/ui  = new(usr, M)
	ui.ui_interact(usr)

/datum/select_equipment
	var/client/user
	var/mob/target

	var/dummy_key
	var/mob/living/carbon/human/dummy/dummy

	var/static/list/cached_outfits
	var/datum/outfit/selected_outfit = /datum/outfit/job/ce

/datum/select_equipment/New(usr, mob/M)
	user = CLIENT_FROM_VAR(usr)

	if(!istype(M))
		return
	target = M

/datum/select_equipment/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SelectEquipment", "Select Equipment")
		ui.open()

/datum/select_equipment/ui_state(mob/user)
	return GLOB.admin_state

/datum/select_equipment/ui_host(mob/user)
	return target //if target is gone the UI should close

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

/datum/select_equipment/proc/make_job_entries(list/L)
	var/entries = list()
	for(var/path in L)
		var/datum/outfit/O = path
		entries[path] = initial(O.name)
	return sortList(entries)

/datum/select_equipment/ui_static_data(mob/user)
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
		cached_outfits["General"] = list(/datum/outfit = "Naked") + make_job_entries(subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman))
		cached_outfits["Jobs"] = make_job_entries(typesof(/datum/outfit/job))
		cached_outfits["Plasmamen Outfits"] = make_job_entries(typesof(/datum/outfit/plasmaman))

	cached_outfits["Custom"] = list("click confirm to create one" = "Create a custom outfit...") + make_job_entries(GLOB.custom_outfits)

	data["outfits"] = cached_outfits
	data["name"] = target

	return data



/datum/select_equipment/ui_act(action, params)
	. = ..()
	if(.)
		return
	message_admins("ui act - [action] | [english_list(params)]")
	switch(action)
		if("preview")
			var/path = text2path(params["path"])
			var/datum/outfit/O = new path
			if(!istype(O))
				return
			selected_outfit = path //the typepath - not the initialized object
			update_static_data(user.mob)

		if("applyoutfit")
			var/path = text2path(params["path"])
			if(!ispath(path, /datum/outfit)) //don't bail yet - could be a special option or custom outfit
				path = params["path"] //reuse the variable because why make a new one

				if(path == "click confirm to create one") //trigg todo - implement special options properly
					user.outfit_manager()
				//trigg todo - implement custom outfit handling
				//probably gonna change GLOB.custom_outfits to be an assoc list keyed by outfit name
				return

			var/datum/outfit/O = new path
			if(!istype(O))
				return
			user.admin_apply_outfit(target, O)
			update_static_data(user.mob)


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

/client/proc/robust_dress_shop2()

	var/list/baseoutfits = list("Naked","Custom","As Job...", "As Plasmaman...")
	var/list/outfits = list()
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman)

	for(var/path in paths)
		var/datum/outfit/O = path //not much to initalize here but whatever
		outfits[initial(O.name)] = path

	var/dresscode = input("Select outfit", "Robust quick dress shop") as null|anything in baseoutfits + sortList(outfits)
	if (isnull(dresscode))
		return

	if (outfits[dresscode])
		dresscode = outfits[dresscode]

	if (dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			job_outfits[initial(O.name)] = path

		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in sortList(job_outfits)
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if (dresscode == "As Plasmaman...")
		var/list/plasmaman_paths = typesof(/datum/outfit/plasmaman)
		var/list/plasmaman_outfits = list()
		for(var/path in plasmaman_paths)
			var/datum/outfit/O = path
			plasmaman_outfits[initial(O.name)] = path

		dresscode = input("Select plasmeme equipment", "Robust quick dress shop") as null|anything in sortList(plasmaman_outfits)
		dresscode = plasmaman_outfits[dresscode]
		if(isnull(dresscode))
			return

	if (dresscode == "Custom")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = input("Select outfit", "Robust quick dress shop") as null|anything in sortList(custom_names)
		dresscode = custom_names[selected_name]
		if(isnull(dresscode))
			return

	return dresscode
