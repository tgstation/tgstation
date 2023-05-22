GLOBAL_LIST_INIT(high_threat_antags, list(
	/datum/antagonist/cult,
	/datum/antagonist/rev/head,
	/datum/antagonist/wizard,
))

GLOBAL_LIST_INIT(medium_threat_antags, list(
	/datum/antagonist/ninja,
	/datum/antagonist/heretic,
))

GLOBAL_LIST_INIT(low_threat_antags, list(
	/datum/antagonist/florida_man,
	/datum/antagonist/traitor,
	/datum/antagonist/paradox_clone,
))



/client/verb/spend_antag_tokens()
	set category = "IC"
	set name = "Spend Antag Tokens"
	set desc = "Opens a ui to spend antag tokens on"


	if(!isobserver(mob) && !isliving(mob))
		to_chat(src, "For this to work you need to either be observing or playing.")
		return

	if(!saved_tokens)
		saved_tokens = new(src)

	var/tier = tgui_input_list(src, "High:[saved_tokens.total_high_threat_tokens] | Med: [saved_tokens.total_medium_threat_tokens] | Low: [saved_tokens.total_low_threat_tokens] | Donator:[saved_tokens.donator_token]", "Choose A Tier To Spend", list(HIGH_THREAT, MEDIUM_THREAT, LOW_THREAT))
	if(!tier)
		return

	var/using_donor = FALSE
	if(saved_tokens.donator_token)
		var/choice = tgui_alert(src, "Use Donator Token?" , "Spend Tokens", list("Yes", "No"))
		if(choice == "Yes")
			using_donor = TRUE

	if(!using_donor)
		switch(tier)
			if(HIGH_THREAT)
				if(saved_tokens.total_high_threat_tokens <= 0)
					return
			if(MEDIUM_THREAT)
				if(saved_tokens.total_medium_threat_tokens <= 0)
					return
			if(LOW_THREAT)
				if(saved_tokens.total_low_threat_tokens <= 0)
					return

	var/datum/antagonist/chosen_antagonist
	switch(tier)
		if(HIGH_THREAT)
			chosen_antagonist = tgui_input_list(src, "Choose an Antagonist", "Spend Tokens", GLOB.high_threat_antags)
		if(MEDIUM_THREAT)
			chosen_antagonist = tgui_input_list(src, "Choose an Antagonist", "Spend Tokens", GLOB.medium_threat_antags)
		if(LOW_THREAT)
			chosen_antagonist = tgui_input_list(src, "Choose an Antagonist", "Spend Tokens", GLOB.low_threat_antags)
	if(!chosen_antagonist)
		return

	saved_tokens.queued_donor = using_donor
	saved_tokens.in_queued_tier = tier
	saved_tokens.in_queue = new chosen_antagonist

	to_chat(src, "Your request has been sent to the admins.")
	wait_for_approval(src, chosen_antagonist)


/proc/wait_for_approval(client/requestor, datum/antagonist/requested_antag)
	var/msg = "[span_admin("[span_prefix("ANTAG TOKEN:")] <EM>[key_name(requestor)]</EM> [ADMIN_APPROVE_TOKEN(requestor)] [ADMIN_REJECT_TOKEN(requestor)] | [requestor] has requested to use their antag token to be a [requested_antag].")]"

	for(var/client/X in GLOB.admins)
		X << 'sound/items/bikehorn.ogg'

	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINCHAT,
		html = msg,
		confidential = TRUE)
