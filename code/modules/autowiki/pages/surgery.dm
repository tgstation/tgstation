/datum/autowiki/surgery
	page = "Template:Autowiki/Content/Surgeries"
	var/list/already_generated_tools = list()

/datum/autowiki/surgery/generate()
	var/output = ""

	var/list/unlocked_operations_alpha = list()
	var/list/locked_operations_alpha = list()
	for(var/op_type, op_datum in GLOB.operations.operations_by_typepath)
		if(op_type in GLOB.operations.locked)
			locked_operations_alpha += op_datum
		else
			unlocked_operations_alpha += op_datum

	// sorts all unlocked operations alphabetically by name, then followed by all locked operations by name
	sortTim(unlocked_operations_alpha, GLOBAL_PROC_REF(cmp_name_asc))
	sortTim(locked_operations_alpha, GLOBAL_PROC_REF(cmp_name_asc))

	for(var/datum/surgery_operation/operation as anything in unlocked_operations_alpha + locked_operations_alpha)
		if(operation.operation_flags & OPERATION_NO_WIKI)
			continue

		var/list/operation_data = list()
		var/locked = (operation in locked_operations_alpha)

		operation_data["name"] = escape_value(capitalize(replacetext(operation.rnd_name || operation.name, "\"", "&quot;")))
		operation_data["description"] = escape_value(replacetext(operation.rnd_desc || operation.desc, "\"", "&quot;"))

		var/list/raw_reqs = operation.get_requirements()
		if(length(raw_reqs[2]) == 1)
			raw_reqs[1] += raw_reqs[2]
			raw_reqs[2] = list()

		operation_data["hard_requirements"] = format_requirement_list(raw_reqs[1])
		operation_data["soft_requirements"] = format_requirement_list(raw_reqs[2])
		operation_data["optional_requirements"] = format_requirement_list(raw_reqs[3])
		operation_data["blocker_requirements"] = format_requirement_list(raw_reqs[4])

		operation_data["tools"] = format_tool_list(operation)

		var/type_id = LOWER_TEXT(replacetext("[operation.type]", "[/datum/surgery_operation]", ""))
		var/filename = "surgery_[SANITIZE_FILENAME(escape_value(type_id))]"
		operation_data["icon"] = filename

		var/image/radial_base = image('icons/hud/screen_alert.dmi', "template")
		var/image/radial_overlay = operation.get_default_radial_image()
		radial_overlay.plane = radial_base.plane
		radial_overlay.layer = radial_base.layer + 1
		radial_base.overlays += radial_overlay

		upload_icon(getFlatIcon(radial_base, no_anim = TRUE), filename)

		operation_data["cstyle"] = ""
		if(locked && (operation.operation_flags & OPERATION_MECHANIC))
			operation_data["cstyle"] = "background: linear-gradient(115deg, [COLOR_VOID_PURPLE] 50%, [COLOR_DARK_MODERATE_LIME_GREEN] 50%); color: [COLOR_WHITE];"
		else if(locked)
			operation_data["cstyle"] = "background-color: [COLOR_VOID_PURPLE]; color: [COLOR_WHITE];"
		else if(operation.operation_flags & OPERATION_MECHANIC)
			operation_data["cstyle"] = "background-color: [COLOR_DARK_MODERATE_LIME_GREEN]; color: [COLOR_WHITE];"

		output += include_template("Autowiki/SurgeryTemplate", operation_data)

	return include_template("Autowiki/SurgeryTableTemplate", list("content" = output))

/datum/autowiki/surgery/proc/format_requirement_list(list/requirements)
	var/output
	for(var/requirement in requirements)
		output += "<li>[escape_value(capitalize(requirement))]</li>"

	return output ? "<ul>[output]</ul>" : ""

/datum/autowiki/surgery/proc/format_tool_list(datum/surgery_operation/operation)
	var/output = ""

	// tools which should not show up in the tools list
	var/list/blacklisted_tool_types = list(
		/obj/item/shovel/giant_wrench, // easter egg interaction
	)

	for(var/tool, multiplier in operation.implements)
		if(tool in blacklisted_tool_types)
			continue

		var/list/tool_info = list()

		tool_info["tool_multiplier"] = multiplier

		var/tool_name = escape_value(get_tool_name(operation, tool))
		tool_info["tool_name"] = tool_name

		var/tool_id = LOWER_TEXT(replacetext("[tool_name]", " ", "_"))
		var/tool_icon = "surgery_tool_[SANITIZE_FILENAME(tool_id)]" // already escaped
		tool_info["tool_icon"] = tool_icon

		if(!already_generated_tools[tool_icon])
			already_generated_tools[tool_icon] = TRUE
			var/image/tool_image = get_tool_icon(tool)
			upload_icon(getFlatIcon(tool_image, no_anim = TRUE),  tool_icon)

		output += include_template("Autowiki/SurgeryToolTemplate", tool_info)

	return output

/datum/autowiki/surgery/proc/get_tool_name(datum/surgery_operation/operation, obj/item/tool)
	if(istext(tool))
		return capitalize(tool)
	if(tool == /obj/item)
		return operation.get_any_tool()
	return capitalize(format_text(tool::name))

/datum/autowiki/surgery/proc/get_tool_icon(obj/item/tool)
	if(tool == IMPLEMENT_HAND)
		return image(/obj/item/hand_item)
	if(istext(tool))
		return GLOB.tool_to_image[tool] || image('icons/effects/random_spawners.dmi', "questionmark")
	if(tool == /obj/item)
		return image('icons/effects/random_spawners.dmi', "questionmark")
	if(ispath(tool, /obj/item/melee/energy)) // snowflake for soul reasons
		return image(tool::icon, "[tool::icon_state]_on")
	if(ispath(tool, /obj/item/bodypart)) // snowflake for readability
		return image('icons/obj/medical/surgery_ui.dmi', "surgery_limbs")
	if(ispath(tool, /obj/item/organ)) // snowflake for readability
		return image('icons/obj/medical/surgery_ui.dmi', "surgery_chest")
	return image(tool)
