/obj/item/ai_module/law/zeroth/apply_to_combined_lawset(datum/ai_laws/combined_lawset)
	combined_lawset.set_zeroth_law(laws[1])

/obj/item/ai_module/law/zeroth/onehuman
	name = "'OneHuman' AI Module"
	var/targetName = ""
	laws = list("Only SUBJECT is human.")

/obj/item/ai_module/law/zeroth/onehuman/configure(mob/user)
	. = TRUE
	var/targName = tgui_input_text(user, "Enter the subject who is the only human.", "One Human", user.real_name, max_length = MAX_NAME_LEN)
	if(!targName || !user.is_holding(src))
		return
	targetName = targName
	laws[1] = "Only [targetName] is human"

/obj/item/ai_module/law/zeroth/onehuman/can_install_to_rack(mob/living/user, obj/machinery/ai_law_rack/rack)
	if(!targetName)
		to_chat(user, span_warning("No name detected on module, please enter one."))
		return FALSE
	return TRUE
