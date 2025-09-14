/datum/action/changeling/mimicvoice
	name = "Mimic Voice"
	desc = "We shape our vocal glands to sound like a desired voice. Maintaining this power slows chemical production."
	button_icon_state = "mimic_voice"
	helptext = "Will turn our voice into the name that we enter. We must constantly expend chemicals to maintain our form like this."
	chemical_cost = 0//constant chemical drain hardcoded
	dna_cost = 1
	req_human = TRUE

// Fake Voice
/datum/action/changeling/mimicvoice/sting_action(mob/living/carbon/human/user)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(user.override_voice)
		changeling.chem_recharge_slowdown -= 0.25
		user.override_voice = ""
		to_chat(user, span_notice("We return our vocal glands to their original position."))
		return

	var/mimic_voice = sanitize_name(tgui_input_text(user, "Enter a name to mimic", "Mimic Voice", max_length = MAX_NAME_LEN))
	if(!mimic_voice)
		return
	..()
	changeling.chem_recharge_slowdown += 0.25
	user.override_voice = mimic_voice
	to_chat(user, span_notice("We shape our glands to take the voice of <b>[mimic_voice]</b>, this will slow down regenerating chemicals while active."))
	to_chat(user, span_notice("Use this power again to return to our original voice and return chemical production to normal levels."))
	return TRUE

/datum/action/changeling/mimicvoice/Remove(mob/living/carbon/human/user)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(user.override_voice)
		changeling?.chem_recharge_slowdown = max(0, changeling.chem_recharge_slowdown - 0.25)
		user.override_voice = ""
		to_chat(user, span_notice("Our vocal glands return to their original position."))
	. = ..()
