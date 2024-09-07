#define MAX_ICON_NOTICES 8
#define MAX_CASES 8
#define MAX_EVIDENCE_Y 3500
#define MAX_EVIDENCE_X 1180

#define EVIDENCE_TYPE_PHOTO "photo"
#define EVIDENCE_TYPE_PAPER "paper"

/obj/structure/detectiveboard
	name = "detective notice board"
	desc = "A board for linking evidence to crimes."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "noticeboard"
	density = FALSE
	anchored = TRUE
	max_integrity = 150

	/// When player attaching evidence to board this will become TRUE
	var/attaching_evidence = FALSE
	/// Colors for case color
	var/list/case_colors = list("red", "orange", "yellow", "green", "blue", "violet")
	/// List of board cases
	var/list/datum/case/cases = list()
	/// Index of viewing case in cases array
	var/current_case = 1

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/detectiveboard, 32)

/obj/structure/detectiveboard/Initialize(mapload)
	. = ..()

	if(mapload)
		for(var/obj/item/item in loc)
			if(istype(item, /obj/item/paper) || istype(item, /obj/item/photo))
				item.forceMove(src)
				cases[current_case].notices++

	register_context()
	find_and_hang_on_wall()

/// Attaching evidences: photo and papers

/obj/structure/detectiveboard/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/paper) || istype(item, /obj/item/photo))
		if(!cases.len)
			to_chat(user, "There are no cases!")
			return

		if(attaching_evidence)
			to_chat(user, "You already attaching evidence!")
			return
		attaching_evidence = TRUE
		var/name = tgui_input_text(user, "Please enter the evidence name", "Detective's Board")
		if(!name)
			attaching_evidence = FALSE
			return
		var/desc = tgui_input_text(user, "Please enter the evidence description", "Detective's Board")
		if(!desc)
			attaching_evidence = FALSE
			return

		if(!user.transferItemToLoc(item, src))
			attaching_evidence = FALSE
			return
		cases[current_case].notices++
		var/datum/evidence/evidence = new (name, desc, item)
		cases[current_case].evidences += evidence
		to_chat(user, span_notice("You pin the [item] to the detective board."))
		attaching_evidence = FALSE
		update_appearance(UPDATE_ICON)
		return
	return ..()

/obj/structure/detectiveboard/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert(user, "[anchored ? "un" : ""]securing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		balloon_alert(user, "[anchored ? "un" : ""]secured")
		deconstruct()
		return TRUE

/obj/structure/detectiveboard/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/detectiveboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DetectiveBoard", name, 1200, 800)
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
				data_connections += REF(connection) // TODO: create array of strings
			data_evidence["connections"] = data_connections
			switch(evidence.evidence_type)
				if(EVIDENCE_TYPE_PHOTO)
					var/obj/item/photo/photo = evidence.item
					var/tmp_picture_name = "evidence_photo[REF(photo)].png"
					user << browse_rsc(photo.picture.picture_image, tmp_picture_name)
					data_evidence["photo_url"] = tmp_picture_name
				if(EVIDENCE_TYPE_PAPER)
					var/obj/item/paper/paper = evidence.item
					data_evidence["text"] = ""
					if(paper.raw_text_inputs && paper.raw_text_inputs.len)
						data_evidence["text"] = paper.raw_text_inputs[1].raw_text
			data_evidences += list(data_evidence)
		data_case["evidences"] = data_evidences
		var/list/connections = list()
		for(var/datum/evidence/evidence in case.evidences)
			for(var/datum/evidence/connection in evidence.connections)
				var/list/from_pos = get_pin_position(evidence)
				var/list/to_pos = get_pin_position(connection)
				var/found_in_connections = FALSE
				for(var/list/con in connections)
					if(con["from"]["x"] == to_pos["x"] && con["from"]["y"] == to_pos["y"] && con["to"]["x"] == from_pos["x"] && con["to"]["y"] == from_pos["y"] )
						found_in_connections = TRUE
				if(!found_in_connections)
					var/list/data_connection = list("color" = "red", "from" = from_pos, "to" = to_pos)
					connections += list(data_connection)
		data_case["connections"] = connections
		data_cases += list(data_case)

	data["cases"] = data_cases
	data["current_case"] = current_case
	return data

/obj/structure/detectiveboard/proc/get_pin_position(datum/evidence/evidence)
	return list("x" =  evidence.x + 15, "y" =  evidence.y + 15)

/obj/structure/detectiveboard/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("add_case")
			if(cases.len == MAX_CASES)
				return FALSE
			var/new_case = tgui_input_text(user, "Please enter the case name", "Detective's Board")
			if(!new_case)
				return FALSE
			var/case_color = tgui_input_list(user, "Please choose case color", "Detective's Board", case_colors)
			if(!case_color)
				return FALSE

			var/datum/case/case = new (new_case, case_color)
			cases += case
			current_case = clamp(cases.len, 1, MAX_CASES)
			update_appearance(UPDATE_ICON)
			return TRUE
		if("set_case")
			if(cases && params["case"] && params["case"] <= cases.len)
				current_case = clamp(params["case"], 1, MAX_CASES)
				update_appearance(UPDATE_ICON)
				return TRUE
		if("remove_case")
			var/datum/case/case = locate(params["case_ref"]) in cases
			if(case)
				for(var/datum/evidence/evidence in case.evidences)
					remove_item(evidence.item, user)
				cases -= case
				current_case = clamp(cases.len, 1, MAX_CASES)
				update_appearance(UPDATE_ICON)
				return TRUE
		if("rename_case")
			var/new_name = tgui_input_text(user, "Please ender the case new name",  "Detective's Board")
			if(new_name)
				var/datum/case/case = locate(params["case_ref"]) in cases
				case.name = new_name
				return TRUE
		if("look_evidence")
			var/datum/case/case = locate(params["case_ref"]) in cases
			var/datum/evidence/evidence = locate(params["evidence_ref"]) in case.evidences
			if(evidence.evidence_type == EVIDENCE_TYPE_PHOTO)
				var/obj/item/photo/item = evidence.item
				item.show(user)
				return TRUE

			var/obj/item/paper/paper = evidence.item
			var/paper_text = ""
			for(var/datum/paper_input/text_input as anything in paper.raw_text_inputs)
				paper_text += text_input.raw_text
			user << browse("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>[paper.name]</title></head>" \
			+ "<body style='overflow:hidden;padding:5px'>" \
			+ "[paper_text]" \
			+ "</body></html>", "window=photo_showing;size=480x608")
			onclose(user, "[name]")
		if("remove_evidence")
			var/datum/case/case = cases[current_case]
			var/datum/evidence/evidence = locate(params["evidence_ref"]) in case.evidences
			if(evidence)
				var/obj/item/item = evidence.item
				if(!istype(item) || item.loc != src)
					return
				remove_item(item, user)
				for(var/datum/evidence/connection in evidence.connections)
					connection.connections.Remove(evidence)
				case.evidences -= evidence
				update_appearance(UPDATE_ICON)
				return TRUE
		if("set_evidence_cords")
			var/datum/case/case = locate(params["case_ref"]) in cases
			if(case)
				var/datum/evidence/evidence = locate(params["evidence_ref"]) in case.evidences
				if(evidence)
					evidence.x = clamp(params["rel_x"], 0, MAX_EVIDENCE_X)
					evidence.y = clamp(params["rel_y"], 0, MAX_EVIDENCE_Y)
			return TRUE
		if("add_connection")
			var/datum/evidence/from_evidence = locate(params["from_ref"]) in cases[current_case].evidences
			var/datum/evidence/to_evidence = locate(params["to_ref"]) in cases[current_case].evidences
			if(from_evidence && to_evidence)
				from_evidence.connections += to_evidence
				to_evidence.connections += from_evidence
			return TRUE


	return FALSE

/obj/structure/detectiveboard/update_overlays()
	. = ..()
	if(!cases.len)
		return
	if(cases[current_case].notices < MAX_ICON_NOTICES)
		. += "notices_[cases[current_case].notices]"
	else
		. += "notices_[MAX_ICON_NOTICES]"
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
		evidence_type = EVIDENCE_TYPE_PHOTO
	else
		evidence_type = EVIDENCE_TYPE_PAPER

/datum/case
	var/notices = 0
	var/name = ""
	var/color = 0
	var/list/datum/evidence/evidences = list()

/datum/case/New(param_name, param_color)
	name = param_name
	color = param_color


#undef EVIDENCE_TYPE_PHOTO
#undef EVIDENCE_TYPE_PAPER

#undef MAX_EVIDENCE_Y
#undef MAX_EVIDENCE_X
#undef MAX_ICON_NOTICES
#undef MAX_CASES
