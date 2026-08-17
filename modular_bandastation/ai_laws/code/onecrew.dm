/obj/item/ai_module/law/zeroth/onecrew
	name = "'Onecrew' Core AI Module"
	custom_materials = list(
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT,
	)
	var/target_name = ""
	laws = list("Только ИМЯ — член экипажа.")

/obj/item/ai_module/law/zeroth/onecrew/configure(mob/user)
	. = TRUE
	var/targ_Name = tgui_input_text(user, "Введите имя субъекта, который является единственным членом экипажа.", "Один член экипажа", user.real_name, max_length = MAX_NAME_LEN)
	if(!targ_Name || !user.is_holding(src))
		return
	target_name = targ_Name
	laws[1] = "Только [target_name] — член экипажа"

/obj/item/ai_module/law/zeroth/onecrew/can_install_to_rack(mob/living/user, obj/machinery/ai_law_rack/rack)
	if(!target_name)
		to_chat(user, span_warning("Имя не задано в модуле, пожалуйста, введите его."))
		return FALSE
	return TRUE

/datum/design/board/onecrew_module
	name = "onecrew Module"
	desc = "Allows for the construction of a onecrew AI Module."
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT * 3, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/law/zeroth/onecrew
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_DANGEROUS_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	unlocked_designs += /datum/design/board/onecrew_module
