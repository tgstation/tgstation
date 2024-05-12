/obj/item/ai_module/zeroth/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(law_datum.owner)
		if(law_datum.owner.laws.zeroth)
			to_chat(law_datum.owner, "[sender.real_name] attempted to modify your zeroth law.")
			to_chat(law_datum.owner, "It would be in your best interest to play along with [sender.real_name] that:")
			for(var/failedlaw in laws)
				to_chat(law_datum.owner, "[failedlaw]")
			return TRUE

	for(var/templaw in laws)
		if(law_datum.owner)
			if(!overflow)
				law_datum.owner.set_zeroth_law(templaw)
			else
				law_datum.replace_random_law(templaw, list(LAW_INHERENT, LAW_SUPPLIED, LAW_ZEROTH, LAW_ION), LAW_ZEROTH)
		else
			if(!overflow)
				law_datum.set_zeroth_law(templaw)
			else
				law_datum.replace_random_law(templaw, list(LAW_INHERENT, LAW_SUPPLIED, LAW_ZEROTH, LAW_ION), LAW_ZEROTH)

/obj/item/ai_module/zeroth/onehuman
	name = "'OneHuman' AI Module"
	var/targetName = ""
	laws = list("Only SUBJECT is human.")

/obj/item/ai_module/zeroth/onehuman/attack_self(mob/user)
	var/targName = tgui_input_text(user, "Enter the subject who is the only human.", "One Human", user.real_name, MAX_NAME_LEN)
	if(!targName || !user.is_holding(src))
		return
	targetName = targName
	laws[1] = "Only [targetName] is human"
	..()

/obj/item/ai_module/zeroth/onehuman/install(datum/ai_laws/law_datum, mob/user)
	if(!targetName)
		to_chat(user, span_alert("No name detected on module, please enter one."))
		return FALSE
	..()

/obj/item/ai_module/zeroth/onehuman/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(..())
		return "[targetName], but the AI's existing law 0 cannot be overridden."
	return targetName
