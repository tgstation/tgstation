#define MAX_ICON_NOTICES 5

/obj/structure/detectiveboard
	name = "detective notice board"
	desc = "A board for linking evidence to crimes."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "noticeboard"
	density = FALSE
	anchored = TRUE
	max_integrity = 150
	req_access = ACCESS_DETECTIVE

	var/attaching_evidence = FALSE
	var/list/case_colors = list("red", "orange", "yellow", "green", "blue", "violet")
	var/list/datum/case/cases = list()
	var/current_case = 1
	var/data_test

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/detectiveboard, 32)

/obj/structure/detectiveboard/Initialize(mapload)
	. = ..()

	if(!mapload)
		return
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/paper))
			I.forceMove(src)
			cases[current_case].notices++

/// Attaching evidences: photo and papers

/obj/structure/detectiveboard/attackby(obj/item/O, mob/user, params)
	if(!cases.len)
		to_chat(user, "There are no cases!")
		return
	if(istype(O, /obj/item/paper) || istype(O, /obj/item/photo))
		if(attaching_evidence)
			to_chat(user, "You already attaching evidence!")
			return
		if(!allowed(user))
			to_chat(user, span_warning("You are not authorized to add notices!"))
			return
		attaching_evidence = TRUE
		var/name = tgui_input_text(usr, "Please enter the evidence name", "Detective's Board")
		if(!name || name == "")
			attaching_evidence = FALSE
			return
		var/desc = tgui_input_text(usr, "Please enter the evidence description", "Detective's Board")
		if(!desc || desc == "")
			attaching_evidence = FALSE
			return

		if(!user.transferItemToLoc(O, src))
			attaching_evidence = FALSE
			return
		cases[current_case].notices++
		var/datum/evidence/evidence = new (name, desc, O)
		cases[current_case].evidences += evidence
		to_chat(user, span_notice("You pin the [O] to the detective board."))
		attaching_evidence = FALSE
		update_appearance(UPDATE_ICON)
	else
		return ..()

/obj/structure/detectiveboard/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/detectiveboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DetectiveBoard", name)
		ui.open()

/obj/structure/detectiveboard/ui_data(mob/user)
	var/list/data = list()
	var/list/data_cases = list()
	for(var/datum/case/case in cases)
		var/list/data_case = list("ref"=REF(case),"name" = case.name, "color" = case.color)
		var/list/data_evidences = list()
		for(var/datum/evidence/evidence in case.evidences)
			var/list/data_evidence = list("ref" = REF(evidence), "name" = evidence.name, "type" = evidence.evidence_type, "description" = evidence.description, "x"=evidence.x, "y"=evidence.y)
			var/list/data_connections = list()
			for(var/datum/evidence/connection in evidence.connections)
				data_connections += list(list("ref" = REF(connection))) // TODO: create array of strings
			data_evidence["connections"] = data_connections
			switch(evidence.evidence_type)
				if("photo")
					var/obj/item/photo/photo = evidence.item
					var/tmp_picture_name = "evidence_photo[REF(photo)].png"
					user << browse_rsc(photo.picture.picture_image, tmp_picture_name)
					data_evidence["photo_url"] = tmp_picture_name
				if("paper")
					var/obj/item/paper/paper = evidence.item
					data_evidence["text"] = ""
					if(paper.raw_text_inputs && paper.raw_text_inputs.len)
						data_evidence["text"] = paper.raw_text_inputs[1].raw_text
			data_evidences += list(data_evidence)
		data_case["evidences"] = data_evidences
		data_cases += list(data_case)
	data["cases"] = data_cases
	data["current_case"] = current_case
	data_test = data
	return data

/obj/structure/detectiveboard/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("add_case")
			var/new_case = tgui_input_text(usr, "Please enter the case name", "Detective's Board")
			if(!new_case || new_case == "")
				return
			var/case_color = tgui_input_list(usr, "Please choose case color", "Detective's Board", case_colors)
			if(!case_color || case_color == "")
				return

			var/datum/case/case = new (new_case, case_color)
			cases += case
			current_case = cases.len
			update_appearance(UPDATE_ICON)
			return TRUE
		if("set_case")
			current_case = params["case"]
			update_appearance(UPDATE_ICON)
			return TRUE
		if("remove_case")
			var/datum/case/case = locate(params["case_ref"]) in cases
			for(var/datum/evidence/evidence in case.evidences)
				remove_item(evidence.item, usr)
			cases.Remove(case)
			current_case = cases.len
			update_appearance(UPDATE_ICON)
			return TRUE
		if("rename_case")
			var/new_name = tgui_input_text(usr, "Please ender the case new name",  "Detective's Board")
			if(new_name && new_name != "")
				var/datum/case/case = locate(params["case_ref"]) in cases
				case.name = new_name
				return TRUE
		if("look_evidence")
			var/datum/case/case = locate(params["case_ref"]) in cases
			var/datum/evidence/evidence = locate(params["evidence_ref"]) in case.evidences
			if(evidence.evidence_type == "photo")
				var/obj/item/photo/item = evidence.item
				item.show(usr)
				return

			var/obj/item/paper/paper = evidence.item
			var/paper_text = ""
			for(var/datum/paper_input/text_input as anything in paper.raw_text_inputs)
				paper_text += text_input.raw_text
			usr << browse("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>[paper.name]</title></head>" \
			+ "<body style='overflow:hidden;padding:5px'>" \
			+ "[paper_text]" \
			+ "</body></html>", "window=photo_showing;size=480x608")
			onclose(usr, "[name]")
		if("remove_evidence")
			var/datum/case/case = locate(params["case_ref"]) in cases
			var/datum/evidence/evidence = locate(params["evidence_ref"]) in case.evidences
			var/obj/item/item = evidence.item
			if(!istype(item) || item.loc != src)
				return

			if(!allowed(usr))
				return
			remove_item(item, usr)
			case.evidences.Remove(evidence)
			update_appearance(UPDATE_ICON)
			return TRUE
		if("set_evidence_cords")
			var/datum/case/case = locate(params["case_ref"]) in cases
			if(case)
				var/datum/evidence/evidence = locate(params["evidence_ref"]) in case.evidences
				if(evidence)
					evidence.x = params["rel_x"]
					evidence.y = params["rel_y"]
		if("to_chat") // Debug logs
			to_chat(usr, params["message"])

	return FALSE

/obj/structure/detectiveboard/update_overlays()
	. = ..()
	if(cases[current_case].notices && cases[current_case].notices < MAX_ICON_NOTICES)
		. += "notices_[cases[current_case].notices]"

/**
 * Removes an item from the notice board
 *
 * Arguments:
 * * item - The item that is to be removed
 * * user - The mob that is trying to get the item removed, if there is one
 */
/obj/structure/detectiveboard/proc/remove_item(obj/item/item, mob/user)
	item.forceMove(drop_location())
	if(user)
		user.put_in_hands(item)
		balloon_alert(user, "removed from board")
	cases[current_case].notices--
	update_appearance(UPDATE_ICON)

/obj/structure/detectiveboard/atom_deconstruct(disassembled = TRUE)
	if(!disassembled)
		new /obj/item/stack/sheet/mineral/wood(loc)
	else
		new /obj/item/wallframe/detectiveboard(loc)
	for(var/obj/item/content in contents)
		remove_item(content)

/obj/item/wallframe/detectiveboard
	name = "detective notice board"
	desc = "A board for linking evidence to crimes."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "noticeboard"
	custom_materials = list(
		/datum/material/wood = SHEET_MATERIAL_AMOUNT,
	)
	resistance_flags = FLAMMABLE
	result_path = /obj/structure/detectiveboard
	pixel_shift = 32

/datum/evidence
	var/name = "None"
	var/description = "No description"
	var/evidence_type = "none"
	var/x = 0
	var/y = 0
	var/list/datum/evidence/connections = list()
	var/obj/item/item = null

/datum/evidence/New(param_name, param_desc, obj/item/param_item)
	name = param_name
	description = param_desc
	item = param_item
	if(istype(param_item, /obj/item/photo))
		evidence_type = "photo"
	else
		evidence_type = "paper"

/datum/case
	var/notices = 0
	var/name = ""
	var/color = 0
	var/list/datum/evidence/evidences = list()

/datum/case/New(param_name, param_color)
	name = param_name
	color = param_color


#undef MAX_ICON_NOTICES
