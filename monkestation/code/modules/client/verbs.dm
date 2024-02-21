GLOBAL_LIST_INIT(high_threat_antags, list(
	/datum/antagonist/cult,
	/datum/antagonist/rev/head,
	/datum/antagonist/wizard,
	/datum/antagonist/clock_cultist,
	/datum/antagonist/ninja,
))

GLOBAL_LIST_INIT(medium_threat_antags, list(
	/datum/antagonist/heretic,
	/datum/antagonist/bloodsucker,
))

GLOBAL_LIST_INIT(low_threat_antags, list(
	/datum/antagonist/florida_man,
	/datum/antagonist/traitor,
	/datum/antagonist/paradox_clone,
))

#define ADMIN_APPROVE_ANTAG_TOKEN(user) "(<A href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];approve_antag_token=[REF(user)]'>Yes</a>)"
#define ADMIN_REJECT_ANTAG_TOKEN(user) "(<A href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];reject_antag_token=[REF(user)]'>No</a>)"
#define ADMIN_APPROVE_TOKEN_EVENT(user) "(<A href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];approve_token_event=[REF(user)]'>Yes</a>)"
#define ADMIN_REJECT_TOKEN_EVENT(user) "(<A href='?_src_=holder;[HrefToken(forceGlobal = TRUE)];reject_token_event=[REF(user)]'>No</a>)"
/client/verb/spend_antag_tokens()
	set category = "IC"
	set name = "Spend Antag Tokens"
	set desc = "Opens a ui to spend antag tokens on"


	if(!isobserver(mob) && !isliving(mob))
		to_chat(src, "For this to work you need to either be observing or playing.")
		return

	if(isobserver(mob))
		to_chat(src, span_notice("NOTE: You will be spawned where ever your ghost is when approved, so becareful where you are."))

	if(!client_token_holder)
		client_token_holder = new(src)

	var/tier = tgui_input_list(src, "High: [client_token_holder.total_high_threat_tokens] | \
									Med: [client_token_holder.total_medium_threat_tokens] | \
									Low: [client_token_holder.total_low_threat_tokens] | \
									Donator: [client_token_holder.donator_token ? "Yes" : "No"]", "Choose A Tier To Spend", list(HIGH_THREAT, MEDIUM_THREAT, LOW_THREAT))
	if(!tier)
		return

	var/using_donor = FALSE
	if(client_token_holder.donator_token)
		var/choice = tgui_alert(src, "Use Donator Token?" , "Spend Tokens", list("Yes", "No"))
		if(choice == "Yes")
			using_donor = TRUE

	if(!using_donor)
		switch(tier)
			if(HIGH_THREAT)
				if(client_token_holder.total_high_threat_tokens <= 0)
					return
			if(MEDIUM_THREAT)
				if(client_token_holder.total_medium_threat_tokens <= 0)
					return
			if(LOW_THREAT)
				if(client_token_holder.total_low_threat_tokens <= 0)
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

	client_token_holder.queued_donor = using_donor
	client_token_holder.in_queued_tier = tier
	client_token_holder.in_queue = new chosen_antagonist

	to_chat(src, span_boldnotice("Your request has been sent to the admins."))
	SEND_NOTFIED_ADMIN_MESSAGE('sound/items/bikehorn.ogg', "[span_admin("[span_prefix("ANTAG TOKEN:")] <EM>[key_name(src)]</EM> \
							[ADMIN_APPROVE_ANTAG_TOKEN(src)] [ADMIN_REJECT_ANTAG_TOKEN(src)] | \
							[src] has requested to use their antag token to be a [chosen_antagonist].")]")

/client/verb/trigger_token_event()
	set category = "IC"
	set name = "Trigger Token Event"
	set desc = "Opens a ui to spend event tokens on"

	if(!isobserver(mob))
		to_chat(src, "You can only trigger events as a ghost.")
		return

	var/static/list/event_list
	if(!event_list)
		event_list = list()
		for(var/event as anything in SStwitch.twitch_events_by_type)
			var/datum/twitch_event/event_instance = SStwitch.twitch_events_by_type[event]
			if(!event_instance.token_cost)
				continue
			event_list += event_instance

	client_token_holder.check_event_tokens(src)

	var/datum/twitch_event/selected_event = tgui_input_list(src, "Event tokens: [client_token_holder.event_tokens]", "Choose an event to trigger", event_list)
	if(!selected_event)
		return

	var/confirm = tgui_alert(src, "Are you sure you want to trigger [selected_event.event_name]? It will cost [selected_event.token_cost] event tokens.", "Trigger token event", \
							list("Yes", "No"))
	if(confirm == "Yes")
		if(client_token_holder.event_tokens >= selected_event.token_cost)
			client_token_holder.queued_token_event = selected_event
			to_chat(src, span_boldnotice("Your request has been sent."))
			logger.Log(LOG_CATEGORY_META, "[usr] has requested to use their event tokens to trigger [selected_event.event_name]([selected_event]).")
			SEND_NOTFIED_ADMIN_MESSAGE('sound/items/bikehorn.ogg', "[span_admin("[span_prefix("TOKEN EVENT:")] <EM>[key_name(src)]</EM> \
																				[ADMIN_APPROVE_TOKEN_EVENT(src)] [ADMIN_REJECT_TOKEN_EVENT(src)] | \
																				[src] has requested use their event tokens to trigger [selected_event.event_name]([selected_event]).")]")
			return
		to_chat(src, "You dont have enough tokens to trigger this event.")

#undef ADMIN_APPROVE_ANTAG_TOKEN
#undef ADMIN_REJECT_ANTAG_TOKEN
#undef ADMIN_APPROVE_TOKEN_EVENT
#undef ADMIN_REJECT_TOKEN_EVENT
