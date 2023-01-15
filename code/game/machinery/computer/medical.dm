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
		ui.open()
		addtimer(CALLBACK(character_preview_view, TYPE_PROC_REF(/atom/movable/screen/map_view/char_preview, update_body)), 1 SECONDS)

/obj/machinery/computer/med_data/ui_static_data(mob/user)
	var/list/data = list()

	var/list/records = list()

	for(var/datum/record/crew/target in GLOB.data_core.general)
		var/list/record = list(list(
			age = target.age,
			appearance = character_preview_view.assigned_map,
			blood_type = target.blood_type,
			dna = target.dna,
			major_disabilities = target.major_disabilities_desc,
			minor_disabilities = target.minor_disabilities_desc,
			name = target.name,
			rank = target.rank,
			ref = REF(target),
			species = target.species,
		))

		records += record

	data["records"] = records

	return data

/obj/machinery/computer/med_data/proc/create_character_preview_view(mob/user)
	character_preview_view = new(null, src)
	character_preview_view.generate_view("record_preview_[REF(character_preview_view)]")
	character_preview_view.update_body()
	character_preview_view.display_to(user)

	return character_preview_view

/obj/machinery/computer/med_data/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("view_record")
			var/datum/record/crew/record = locate(params["ref"]) in GLOB.data_core.general
			if(!record)
				return FALSE
			character_preview_view.update_body()
			return TRUE
		if("add_notes")
			var/datum/record/crew/record = locate(params["ref"]) in GLOB.data_core.general
			if(!record)
				return FALSE
			var/notes = params["notes"]
			if(!notes)
				return FALSE
			record.medical_notes += notes
			return TRUE

	return FALSE
