GLOBAL_LIST_INIT(high_threat_antags, list(
	/datum/antagonist/cult,
	/datum/antagonist/rev/head,
	/datum/antagonist/wizard,
))

GLOBAL_LIST_INIT(medium_threat_antags, list(
	/datum/antagonist/ninja,
	/datum/antagonist/heretic,
	/datum/antagonist/bloodsucker,
))

GLOBAL_LIST_INIT(low_threat_antags, list(
	/datum/antagonist/florida_man,
	/datum/antagonist/traitor,
	/datum/antagonist/paradox_clone,
))

//PLACEHOLDER VALUES(1 to 1 cent to token conversion, also you get a free token if you dont pay yeah totally)
///assoc list of how many event tokens each role gets each month
GLOBAL_LIST_INIT(patreon_etoken_values, list(
	NO_RANK = 0,
	RANK_TANKS = 100,
	ASSISTANT_RANK = 500,
	COMMAND_RANK = 1000,
	TRAITOR_RANK = 2500,
	NUKIE_RANK = 5000,
))

/client/verb/spend_antag_tokens()
	set category = "IC"
	set name = "Spend Antag Tokens"
	set desc = "Opens a ui to spend antag tokens on"


	if(!isobserver(mob) && !isliving(mob))
		to_chat(src, "For this to work you need to either be observing or playing.")
		return

	if(isobserver(mob))
		to_chat(src, span_notice("NOTE: You will be spawned where ever your ghost is when approved, so becareful where you are."))

	if(!client_saved_tokens)
		client_saved_tokens = new(src)

	var/tier = tgui_input_list(src, "High:[client_saved_tokens.total_high_threat_tokens] | \
									Med: [client_saved_tokens.total_medium_threat_tokens] | \
									Low: [client_saved_tokens.total_low_threat_tokens] | \
									Donator:[client_saved_tokens.donator_token]", "Choose A Tier To Spend", list(HIGH_THREAT, MEDIUM_THREAT, LOW_THREAT))
	if(!tier)
		return

	var/using_donor = FALSE
	if(client_saved_tokens.donator_token)
		var/choice = tgui_alert(src, "Use Donator Token?" , "Spend Tokens", list("Yes", "No"))
		if(choice == "Yes")
			using_donor = TRUE

	if(!using_donor)
		switch(tier)
			if(HIGH_THREAT)
				if(client_saved_tokens.total_high_threat_tokens <= 0)
					return
			if(MEDIUM_THREAT)
				if(client_saved_tokens.total_medium_threat_tokens <= 0)
					return
			if(LOW_THREAT)
				if(client_saved_tokens.total_low_threat_tokens <= 0)
					return

	var/datum/antagonist/chosen_antagonist
	var/static/list/token_values = list(
		HIGH_THREAT = GLOB.high_threat_antags,
		MEDIUM_THREAT = GLOB.medium_threat_antags,
		LOW_THREAT = GLOB.low_threat_antags,
	)
	chosen_antagonist = tgui_input_list(src, "Choose an Antagonist", "Spend Tokens", token_values[tier])
	if(!chosen_antagonist)
		return

	client_saved_tokens.queued_donor = using_donor
	client_saved_tokens.in_queued_tier = tier
	client_saved_tokens.in_queue = new chosen_antagonist

	to_chat(src, "Your request has been sent to the admins.")
	SEND_NOTFIED_ADMIN_MESSAGE('sound/items/bikehorn.ogg', "[span_admin("[span_prefix("ANTAG TOKEN:")] <EM>[key_name(src)]</EM> [ADMIN_APPROVE_TOKEN(src)] [ADMIN_REJECT_TOKEN(src)] | \
							[src] has requested to use their antag token to be a [chosen_antagonist].")]")

/client/proc/trigger_token_event()
	set category = "Ghost"
	set name = "Trigger Token Event"
	set desc = "Opens a ui to spend event tokens on"

	if(!isobserver(mob))
		to_chat(src, "You can only trigger events as a ghost.")

	var/static/list/event_list
	if(!event_list)
		event_list = subtypesof(/datum/twitch_event)
		for(var/datum/twitch_event/event as anything in event_list)
			if(!event.token_cost)
				event_list -= event

	check_event_tokens(src)

	var/datum/twitch_event/selected_event = tgui_input_list(src, "Event tokens: [prefs.event_tokens]", "Choose an event to trigger", event_list)
	var/confirm = tgui_alert(src, "Are you sure you want to trigger [selected_event.event_name]? It will cost [selected_event.token_cost] event tokens.", "Trigger token event", \
							list("Yes", "No"))
	if(confirm == "Yes")
		if(prefs.event_tokens >= selected_event.token_cost)
			SEND_NOTFIED_ADMIN_MESSAGE('sound/items/bikehorn.ogg', "MESSAGE")
			return
		to_chat(src, "You dont have enough tokens to trigger this event.")

/proc/approve_token_event()

/proc/reject_token_event()

/proc/check_event_tokens(client/checked_client)
	var/month_number = text2num(time2text(world.time, "MM"))
	if(checked_client.prefs.event_token_month != month_number)
		checked_client.prefs.event_token_month = month_number
		checked_client.prefs.event_tokens = GLOB.patreon_etoken_values[checked_client.patreon.owned_rank]
