/obj/item/ai_module/zeroth/onecrew
	name = "'Onecrew' Core AI Module"
	var/target_name = ""
	laws = list("Только ИМЯ — член экипажа.")

/obj/item/ai_module/zeroth/onecrew/attack_self(mob/user)
	var/targ_Name = tgui_input_text(user, "Введите имя субъекта, который является единственным членом экипажа.", "Один член экипажа", user.real_name, max_length = MAX_NAME_LEN)
	if(!targ_Name || !user.is_holding(src))
		return
	target_name = targ_Name
	laws[1] = "Только [target_name] — член экипажа"
	..()

/obj/item/ai_module/zeroth/onecrew/install(datum/ai_laws/law_datum, mob/user)
	if(!target_name)
		to_chat(user, span_alert("Имя не задано в модуле, пожалуйста, введите его."))
		return FALSE
	..()

/obj/item/ai_module/zeroth/onecrew/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(..())
		return "[target_name], but the AI's existing law 0 cannot be overridden."
	return target_name

/datum/design/board/onecrew_module
	name = "onecrew Module"
	desc = "Allows for the construction of a onecrew AI Module."
	id = "onecrew_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT * 3, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/zeroth/onecrew
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_DANGEROUS_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "onecrew_module"
