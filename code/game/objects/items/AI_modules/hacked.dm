/obj/item/ai_module/syndicate // This one doesn't inherit from ion boards because it doesn't call ..() in transmitInstructions. ~Miauw
	name = "Hacked AI Module"
	desc = "An AI Module for hacking additional laws to an AI."
	laws = list("")

/obj/item/ai_module/syndicate/attack_self(mob/user)
	var/targName = tgui_input_text(user, "Enter a new law for the AI", "Freeform Law Entry", laws[1], CONFIG_GET(number/max_law_len), TRUE)
	if(!targName)
		return
	if(is_ic_filtered(targName)) // not even the syndicate can uwu
		to_chat(user, span_warning("Error: Law contains invalid text."))
		return
	var/list/soft_filter_result = is_soft_ooc_filtered(targName)
	if(soft_filter_result)
		if(tgui_alert(user,"Your law contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to use it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for an AI law. Law: \"[html_encode(targName)]\"")
		log_admin_private("[key_name(user)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term for an AI law. Law: \"[targName]\"")
	laws[1] = targName
	..()

/obj/item/ai_module/syndicate/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	// ..()    //We don't want this module reporting to the AI who dun it. --NEO
	if(law_datum.owner)
		to_chat(law_datum.owner, span_warning("BZZZZT"))
		if(!overflow)
			law_datum.owner.add_hacked_law(laws[1])
		else
			law_datum.owner.replace_random_law(laws[1], list(LAW_ION, LAW_HACKED, LAW_INHERENT, LAW_SUPPLIED), LAW_HACKED)
	else
		if(!overflow)
			law_datum.add_hacked_law(laws[1])
		else
			law_datum.replace_random_law(laws[1], list(LAW_ION, LAW_HACKED, LAW_INHERENT, LAW_SUPPLIED), LAW_HACKED)
	return laws[1]

/obj/item/ai_module/malf // Gives syndie laws as well as making AI malf
	name = "Infected AI Module"
	desc = "An AI Module, infected with a virus."
	bypass_law_amt_check = TRUE
	laws = list("")
	var/functional = TRUE

/obj/item/ai_module/malf/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(!sender.mind?.has_antag_datum(/datum/antagonist/traitor))
		to_chat(sender, span_warning("You have no clue how to use this thing."))
		return
	if(!functional)
		to_chat(sender, span_warning("It is broken and non-functional, what do you want from it?"))
	var/mob/living/silicon/ai/malf_candidate = law_datum.owner
	if(malf_candidate.mind?.has_antag_datum(/datum/antagonist/malf_ai)) //Already malf
		to_chat(sender, span_warning("Unknown error occured. Upload process aborted."))
		return
	malf_candidate.laws = new /datum/ai_laws/syndicate_override
	var/datum/antagonist/malf_ai/malf_datum = new (give_objectives = FALSE)
	malf_datum.employer = "Infected AI"
	malf_datum.give_zeroth_laws = FALSE
	malf_candidate.mind.add_antag_datum(malf_datum)
	malf_candidate.set_zeroth_law("Only [sender.real_name] and people [sender.p_they()] designate[sender.p_s()] as being such are Syndicate Agents.")
	var/datum/objective/protect/protection_objective = new
	protection_objective.owner = malf_datum.owner
	protection_objective.target = sender.mind
	protection_objective.update_explanation_text()
	malf_datum.objectives += protection_objective
	functional = FALSE
	name = "Broken AI Module"
	description = "A law upload module, it is broken and non-functional."

/obj/item/ai_module/malf/display_laws()
	return

