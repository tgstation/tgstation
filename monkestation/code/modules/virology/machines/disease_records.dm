/obj/machinery/computer/records/pathology
	name = "disease records console"
	desc = "This can be used to check disease records."
	icon_screen = "medcomp"
	icon_keyboard = "med_key"
	req_one_access = list(ACCESS_MEDICAL, ACCESS_DETECTIVE, ACCESS_GENETICS)
	circuit = /obj/item/circuitboard/computer/pathology_data
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/records/pathology/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		create_character_preview_view(user)
		ui = new(user, src, "PathologyRecords")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/computer/records/pathology/ui_data(mob/user)
	var/list/data = ..()

	var/list/records = list()
	for(var/ID in GLOB.virusDB)
		var/datum/data/record/target = GLOB.virusDB[ID]
		records += list(list(
			crew_ref = "[target.fields["id"]]-[target.fields["sub"]]",
			id = target.fields["id"],
			sub = target.fields["sub"],
			child = target.fields["child"],
			form = target.fields["form"],
			name = target.fields["name"],
			nickname = target.fields["nickname"],
			description = target.fields["description"],
			custom_desc = target.fields["custom_desc"],
			antigen = target.fields["antigen"],
			spread_flags = target.fields["spread_flags_type"],
			danger = target.fields["danger"],
		))

	data["records"] = records

	return data

/obj/machinery/computer/records/pathology/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	var/datum/data/record/target
	if(params["crew_ref"] && (params["crew_ref"] in GLOB.virusDB))
		target = GLOB.virusDB[params["crew_ref"]]
	if(!target && params["crew_ref"])
		return FALSE

	switch(action)
		if("edit_field")
			target.fields[params["field"]] = params["value"]
			return TRUE
		if("expunge_record")
			GLOB.virusDB[params["crew_ref"]] = null
			qdel(target)
			GLOB.virusDB -= params["crew_ref"]
			return TRUE
	if(.)
		return

	return FALSE
