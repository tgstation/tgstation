/obj/machinery/computer/med_data
	name = "medical records console"
	desc = "This can be used to check medical records."
	icon_screen = "medcomp"
	icon_keyboard = "med_key"
	req_one_access = list(ACCESS_MEDICAL, ACCESS_DETECTIVE, ACCESS_GENETICS)
	circuit = /obj/item/circuitboard/computer/med_data
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/med_data/syndie
	icon_keyboard = "syndie_key"
	req_one_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/med_data/laptop
	name = "medical laptop"
	desc = "A cheap Nanotrasen medical laptop, it functions as a medical records computer. It's bolted to the table."
	icon_state = "laptop"
	icon_screen = "medlaptop"
	icon_keyboard = "laptop_key"
	pass_flags = PASSTABLE

/obj/machinery/computer/med_data/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		character_preview_view = create_character_preview_view(user)
		ui = new(user, src, "MedicalRecords")
		ui.set_autoupdate(FALSE)
		ui.open()
		addtimer(CALLBACK(character_preview_view, TYPE_PROC_REF(/obj/machinery/computer, update_body)), 1 SECONDS)

/obj/machinery/computer/med_data/ui_data(mob/user)
	var/list/data = list()

	var/list/records = list()

	for(var/datum/record/crew/target in GLOB.data_core.general)
		var/list/record = list(list(
			age = target.age,
			appearance = character_preview_view.assigned_map,
			blood_type = target.blood_type,
			dna = target.dna_string,
			lock_ref = target.lock_ref,
			gender = target.gender,
			major_disabilities = target.major_disabilities_desc,
			notes = target.medical_notes,
			minor_disabilities = target.minor_disabilities_desc,
			name = target.name,
			quirk_notes = target.quirk_notes,
			rank = target.rank,
			ref = REF(target),
			species = target.species,
		))

		records += record

	data["records"] = records

	return data

/obj/machinery/computer/med_data/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_notes")
			create_note(usr, params)

			return TRUE

		if("view_record")
			var/datum/record/locked/record = locate(params["lock_ref"]) in GLOB.data_core.locked
			if(!record)
				return FALSE
			update_body(record)
			return TRUE

	return FALSE

/obj/machinery/computer/med_data/proc/create_note(mob/user, list/params)
	var/datum/record/crew/record = locate(params["ref"]) in GLOB.data_core.general

	if(!record || !isliving(usr))
		return FALSE

	var/mob/living/player = usr
	if(!issilicon(player)) // Silicons don't need to authenticate
		var/obj/item/card/auth = player.get_idcard(TRUE)
		if(!auth)
			to_chat(player, span_warning("ACCESS DENIED: No ID card detected."))
			return FALSE
		var/list/access = auth.GetAccess()
		if(!check_access_list(access))
			to_chat(player, span_warning("ACCESS DENIED"))
			return FALSE

	if(!note)
		return FALSE

	note = trim(note, MAX_MESSAGE_LEN)
	if(length(record.medical_notes) > 2)
		record.medical_notes.Cut(1, 2)

	record.medical_notes += note

	return TRUE
