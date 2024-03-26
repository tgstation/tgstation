GLOBAL_LIST_INIT(antag_token_config, load_antag_token_config())

#define ANTAG_TOKEN_CONFIG_FILE "config/monkestation/antag-tokens.toml"
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

	var/list/chosen_tier = GLOB.antag_token_config[tier]
	var/antag_key = tgui_input_list(src, "Choose an Antagonist", "Spend Tokens", chosen_tier)
	if(!antag_key || !chosen_tier[antag_key])
		return
	var/datum/antagonist/chosen_antagonist = chosen_tier[antag_key]

	client_token_holder.queued_donor = using_donor
	client_token_holder.in_queued_tier = tier
	client_token_holder.in_queue = new chosen_antagonist

	to_chat(src, span_boldnotice("Your request has been sent to the admins."))
	send_formatted_admin_message( \
		"[ADMIN_LOOKUPFLW(src)] has requested to use their antag token to be a [chosen_antagonist::name].\n\n[ADMIN_APPROVE_ANTAG_TOKEN(src)] | [ADMIN_REJECT_ANTAG_TOKEN(src)]",	\
		title = "Antag Token Request", \
		color_override = "orange" \
	)
	client_token_holder.antag_timeout = addtimer(CALLBACK(client_token_holder, TYPE_PROC_REF(/datum/meta_token_holder, timeout_antag_token)), 5 MINUTES, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)

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
			send_formatted_admin_message( \
				"[ADMIN_LOOKUPFLW(src)] has requested use their event tokens to trigger [selected_event.event_name]([selected_event]).\n\n[ADMIN_APPROVE_TOKEN_EVENT(src)] | [ADMIN_REJECT_TOKEN_EVENT(src)]",	\
				title = "Event Token Request", \
				color_override = "orange" \
			)
			client_token_holder.event_timeout = addtimer(CALLBACK(client_token_holder, TYPE_PROC_REF(/datum/meta_token_holder, timeout_event_token)), 5 MINUTES, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_DELETE_ME)
			return
		to_chat(src, "You dont have enough tokens to trigger this event.")

/proc/init_antag_list(list/antag_types)
	. = list()
	for(var/datum/antagonist/antag_type as anything in antag_types)
		if(istext(antag_type))
			antag_type = text2path("/datum/antagonist/[antag_type]")
		if(!ispath(antag_type))
			continue
		.[antag_type::name] = antag_type

/proc/load_antag_token_config(list/antag_types)
	var/static/default_config = list(
		HIGH_THREAT = init_antag_list(list(
			/datum/antagonist/cult,
			/datum/antagonist/rev/head,
			/datum/antagonist/wizard,
			/datum/antagonist/clock_cultist,
			/datum/antagonist/ninja
		)),
		MEDIUM_THREAT = init_antag_list(list(
			/datum/antagonist/heretic,
			/datum/antagonist/bloodsucker
		)),
		LOW_THREAT = init_antag_list(list(
			/datum/antagonist/florida_man,
			/datum/antagonist/traitor,
			/datum/antagonist/paradox_clone
		))
	)
	var/static/list/toml_keys = list(
		"high" = HIGH_THREAT,
		"medium" = MEDIUM_THREAT,
		"low" = LOW_THREAT
	)
	if(!fexists(ANTAG_TOKEN_CONFIG_FILE))
		log_config("No antag token config file found, using default config.")
		return default_config
	var/list/token_config = rustg_read_toml_file(ANTAG_TOKEN_CONFIG_FILE)
	if(!length(token_config))
		log_config("Antag token config file is empty, using default config.")
		return default_config
	. = list(
		HIGH_THREAT = list(),
		MEDIUM_THREAT = list(),
		LOW_THREAT = list()
	)
	for(var/toml_key in toml_keys)
		var/list/tier_name = toml_keys[toml_key]
		var/list/token_list = token_config[toml_key]
		.[tier_name] = init_antag_list(token_list)

#undef ANTAG_TOKEN_CONFIG_FILE
#undef ADMIN_APPROVE_ANTAG_TOKEN
#undef ADMIN_REJECT_ANTAG_TOKEN
#undef ADMIN_APPROVE_TOKEN_EVENT
#undef ADMIN_REJECT_TOKEN_EVENT
