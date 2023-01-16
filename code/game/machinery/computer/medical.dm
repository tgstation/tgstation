/obj/machinery/computer/med_data
	name = "medical records console"
	desc = "This can be used to check medical records."
	icon_screen = "medcomp"
	icon_keyboard = "med_key"
	req_one_access = list(ACCESS_MEDICAL, ACCESS_DETECTIVE, ACCESS_GENETICS)
	circuit = /obj/item/circuitboard/computer/med_data
	light_color = LIGHT_COLOR_BLUE
	var/atom/movable/screen/map_view/char_preview/character_preview_view

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
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		character_preview_view = create_character_preview_view(user)
		ui = new(user, src, "MedicalRecords")
		ui.set_autoupdate(FALSE)
		ui.open()
		addtimer(CALLBACK(character_preview_view, PROC_REF(update_body)), 1 SECONDS)

/obj/machinery/computer/med_data/ui_data(mob/user)
	var/list/data = list()

	var/list/records = list()

	for(var/datum/record/crew/target in GLOB.data_core.general)
		var/list/record = list(list(
			age = target.age,
			appearance = character_preview_view.assigned_map,
			blood_type = target.blood_type,
			dna = target.dna_string,
			major_disabilities = target.major_disabilities_desc,
			notes = target.medical_notes,
			minor_disabilities = target.minor_disabilities_desc,
			name = target.name,
			rank = target.rank,
			ref = REF(target),
			species = target.species,
		))

		records += record

	data["records"] = records

	return data

/// Creates a character preview view for the UI.
/obj/machinery/computer/med_data/proc/create_character_preview_view(mob/user)
	character_preview_view = new(null, src)
	character_preview_view.generate_view("record_preview_[REF(character_preview_view)]")
	update_body()
	character_preview_view.display_to(user)

	return character_preview_view

/// Takes a record and updates the character preview view to match it.
/obj/machinery/computer/med_data/proc/update_body(var/datum/record/locked/record)
	var/mob/living/carbon/human/dummy/mannequin = character_preview_view.body

	if (isnull(mannequin))
		character_preview_view.create_body()
	else
		mannequin.wipe_state()

	if(!record)
		return

	var/datum/job/found_job = SSjob.GetJob(record.initial_rank)
	mannequin.job = found_job.title
	mannequin.dress_up_as_job(found_job, TRUE)
	var/datum/dna/dna = record.dna_ref
	dna.transfer_identity(mannequin, transfer_SE = TRUE, transfer_species = TRUE)

	character_preview_view.appearance = mannequin.appearance
	return

/obj/machinery/computer/med_data/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("view_record")
			var/datum/record/locked/record = find_record(params["name"], locked_only = TRUE)
			if(!record)
				return FALSE
			update_body(record)
			return TRUE

		if("add_notes")
			var/datum/record/crew/record = locate(params["ref"]) in GLOB.data_core.general

			if(!record)
				return FALSE
			var/notes = params["note"]

			if(!notes)
				return FALSE

			if(length(record.medical_notes) > 2)
				record.medical_notes.Cut(1, 2)
			record.medical_notes += notes
			ui.send_update()
			return TRUE

	return FALSE

