/obj/item/ai_module/law/zeroth/apply_to_combined_lawset(datum/ai_laws/combined_lawset)
	combined_lawset.set_zeroth_law(laws[1])

/obj/item/ai_module/law/zeroth/onehuman
	name = "'OneHuman' AI Module"
	var/targetName = ""
	laws = list("Только СУБЪЕКТ — человек.")
	custom_materials = list(/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 3, /datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)

/obj/item/ai_module/law/zeroth/onehuman/configure(mob/user)
	. = TRUE
	var/targName = tgui_input_text(user, "Введите имя субъекта, который является единственным человеком.", "Один человек", user.real_name, max_length = MAX_NAME_LEN)
	if(!targName || !user.is_holding(src))
		return
	targetName = targName
	laws[1] = "Только [targetName] - человек"

/obj/item/ai_module/law/zeroth/onehuman/can_install_to_rack(mob/living/user, obj/machinery/ai_law_rack/rack)
	if(!targetName)
		to_chat(user, span_warning("Имя не задано в модуле, пожалуйста, введите его."))
		return FALSE
	return TRUE
