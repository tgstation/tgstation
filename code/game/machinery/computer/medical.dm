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

/obj/machinery/computer/med_data/ui_data(mob/user)
	var/list/data = list()

	data["can_view"] = has_auth(user) // just for notes (HIPAA compliance)

	var/list/records = list()

	for(var/datum/record/crew/target in GLOB.data_core.general)
		var/list/notes = list()
		for(var/datum/medical_note/note in target.medical_notes)
			notes += list(list(
				author = note.author,
				content = note.content,
				note_ref = REF(note),
				time = note.time,
			))

		records += list(list(
			age = target.age,
			appearance = character_preview_view.assigned_map,
			blood_type = target.blood_type,
			crew_ref = REF(target),
			dna = target.dna_string,
			lock_ref = target.lock_ref,
			gender = target.gender,
			major_disabilities = target.major_disabilities_desc,
			notes = notes,
			minor_disabilities = target.minor_disabilities_desc,
			name = target.name,
			quirk_notes = target.quirk_notes,
			rank = target.rank,
			species = target.species,
		))

	data["records"] = records

	return data

/obj/machinery/computer/med_data/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_note")
			create_note(usr, params)
			return TRUE

		if("delete_note")
			delete_note(usr, params)
			return TRUE

		if("view_record")
			var/datum/record/locked/record = locate(params["lock_ref"]) in GLOB.data_core.locked
			if(!record)
				return FALSE
			update_preview(record)
			return TRUE

	return FALSE

/// Checks for proper authorization to add notes, then adds to record.
/obj/machinery/computer/med_data/proc/create_note(mob/user, list/params)
	var/datum/record/crew/target = locate(params["crew_ref"]) in GLOB.data_core.general
	if(!target || !has_auth(user))
		return FALSE

	if(!params["content"])
		return FALSE
	var/content = trim(params["content"], MAX_MESSAGE_LEN)

	var/datum/medical_note/new_note = new(usr, content)
	while(length(target.medical_notes) > 2)
		target.medical_notes.Cut(1, 2)

	target.medical_notes += new_note

	return TRUE

/// Deletes a note from a record.
/obj/machinery/computer/med_data/proc/delete_note(mob/user, list/params)
	var/datum/record/crew/target = locate(params["crew_ref"]) in GLOB.data_core.general
	if(!target || !has_auth(user))
		return FALSE

	var/datum/medical_note/old_note = locate(params["note_ref"]) in target.medical_notes
	if(!old_note)
		return FALSE

	target.medical_notes -= old_note
	qdel(old_note)

	return TRUE
