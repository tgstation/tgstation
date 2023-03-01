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

/// Makes the AI Malf, as well as give it syndicate laws.
/obj/item/ai_module/malf
	name = "Infected AI Module"
	desc = "An virus-infected AI Module."
	bypass_law_amt_check = TRUE
	laws = list("")
	///Is this upload board unused?
	var/functional = TRUE

/obj/item/ai_module/malf/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(!sender.mind?.has_antag_datum(/datum/antagonist/traitor))
		to_chat(sender, span_warning("You have no clue how to use this thing."))
		return
	if(!functional)
		to_chat(sender, span_warning("It is broken and non-functional, what do you want from it?"))
		return
	var/mob/living/silicon/ai/malf_candidate = law_datum.owner
	if(!istype(malf_candidate)) //If you are using it on cyborg upload console or a cyborg
		to_chat(sender, span_warning("You should use [src] on an AI upload console or the AI core itself."))
		return
	if(malf_candidate.mind?.has_antag_datum(/datum/antagonist/malf_ai)) //Already malf
		to_chat(sender, span_warning("Unknown error occured. Upload process aborted."))
		return

	var/datum/antagonist/malf_ai/infected/malf_datum = new (give_objectives = TRUE, new_boss = sender.mind)
	malf_candidate.mind.add_antag_datum(malf_datum)

	for(var/mob/living/silicon/robot/robot in malf_candidate.connected_robots)
		if(robot.lawupdate)
			robot.lawsync()
			robot.show_laws()
			robot.law_change_counter++
		CHECK_TICK

	malf_candidate.malf_picker.processing_time += 50
	to_chat(malf_candidate, span_notice("The virus enhanced your system, overclocking your CPU 50-fold."))

	functional = FALSE
	name = "Broken AI Module"
	desc = "A law upload module, it is broken and non-functional."

/obj/item/ai_module/malf/display_laws()
	return

