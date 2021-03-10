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
		cached_outfits["General"] = list("naked" = "Naked") + make_job_entries(subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman))
		cached_outfits["Jobs"] = make_job_entries(typesof(/datum/outfit/job))
		cached_outfits["Plasmamen Outfits"] = make_job_entries(typesof(/datum/outfit/plasmaman))

	cached_outfits["Custom"] = list("createCustom" = "Create a custom outfit...") + make_job_entries(GLOB.custom_outfits)

	data["outfits"] = cached_outfits
	data["name"] = target

	return data

/datum/select_equipment/proc/make_job_entries(list/L)
	var/entries = list()
	for(var/path in L)
		var/datum/outfit/O = path
		entries[path] = initial(O.name)
	return sortList(entries)

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

/datum/select_equipment/ui_act(action, params)
	. = ..()
	if(.)
		return
