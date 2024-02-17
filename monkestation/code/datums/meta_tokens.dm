GLOBAL_LIST_INIT(used_monthly_token, list())

///assoc list of how many event tokens each role gets each month
GLOBAL_LIST_INIT(patreon_etoken_values, list(
	NO_RANK = 0,
	THANKS_RANK = 100,
	ASSISTANT_RANK = 500,
	COMMAND_RANK = 1000,
	TRAITOR_RANK = 2500,
	NUKIE_RANK = 5000,
))

/client
	var/datum/meta_token_holder/client_token_holder

/datum/meta_token_holder
	///the client that owns this holder
	var/client/owner
	///are they a donator? and do they have their free token?
	var/donator_token = FALSE
	///total amount of antag tokens
	var/total_antag_tokens = 0
	///high threat antag tokens
	var/total_high_threat_tokens = 0
	///medium threat antag tokens
	var/total_medium_threat_tokens = 0
	///low threat antag_tokens
	var/total_low_threat_tokens = 0
	///the antagonist we are currently waiting for a reply on whether we can use
	var/datum/antagonist/in_queue
	var/in_queued_tier
	///is the queued token a donor token
	var/queued_donor = FALSE
	///how many event tokens we currently have
	var/event_tokens = 0
	///the month we last used event tokens on
	var/event_token_month = 0
	///what token event do we currently have queued
	var/datum/twitch_event/queued_token_event

/datum/meta_token_holder/New(client/creator)
	. = ..()
	if(!creator)
		return
	owner = creator

	var/datum/preferences/owners_prefs = creator.prefs
	convert_list_to_tokens(owners_prefs.saved_tokens)
	donator_token = check_for_donator_token()

/datum/meta_token_holder/proc/convert_list_to_tokens(list/saved_tokens)
	if(!length(saved_tokens))
		return
	total_low_threat_tokens = saved_tokens["low_threat"]
	total_medium_threat_tokens = saved_tokens["medium_threat"]
	total_high_threat_tokens = saved_tokens["high_threat"]
	event_tokens = saved_tokens["event_tokens"]
	event_token_month = saved_tokens["event_token_month"]

	total_antag_tokens = total_low_threat_tokens + total_medium_threat_tokens + total_high_threat_tokens

/datum/meta_token_holder/proc/convert_tokens_to_list()
	owner.prefs.saved_tokens = list(
		"low_threat" = total_low_threat_tokens,
		"medium_threat" = total_medium_threat_tokens,
		"high_threat" = total_high_threat_tokens,
		"event_tokens" = event_tokens,
		"event_token_month" = event_token_month,
	)
	owner.prefs.save_preferences()

/datum/meta_token_holder/proc/check_for_donator_token()
	if(!owner.patreon)
		return FALSE
	if(!owner.patreon.has_access(ACCESS_TRAITOR_RANK))
		return FALSE
	var/month_number = text2num(time2text(world.time, "MM"))
	if(owner.prefs.token_month == month_number)
		return FALSE
	return TRUE

/datum/meta_token_holder/proc/spend_antag_token(tier, use_donor = FALSE)
	if(use_donor)
		if(donator_token)
			donator_token = FALSE
			logger.Log(LOG_CATEGORY_META, "[owner], used donator token on [owner.prefs.token_month].")
			owner.prefs.token_month = text2num(time2text(world.time, "MM"))
			owner.prefs.save_preferences()
			return

	switch(tier)
		if(HIGH_THREAT)
			total_high_threat_tokens--
		if(MEDIUM_THREAT)
			total_medium_threat_tokens--
		if(LOW_THREAT)
			total_low_threat_tokens--

	convert_tokens_to_list()

///adjusts the users tokens, yes they can be in antag token debt
/datum/meta_token_holder/proc/adjust_antag_tokens(tier, amount)
	var/list/old_token_values = list(HIGH_THREAT = total_high_threat_tokens, MEDIUM_THREAT = total_medium_threat_tokens, LOW_THREAT = total_low_threat_tokens)
	switch(tier)
		if(HIGH_THREAT)
			total_high_threat_tokens += amount
		if(MEDIUM_THREAT)
			total_medium_threat_tokens += amount
		if(LOW_THREAT)
			total_low_threat_tokens += amount

	log_admin("[key_name(owner)] had their antag tokens adjusted from high: [old_token_values[HIGH_THREAT]], medium: [old_token_values[MEDIUM_THREAT]], \
				low: [old_token_values[LOW_THREAT]], to, high: [total_high_threat_tokens], medium: [total_medium_threat_tokens], low: [total_low_threat_tokens]")
	convert_tokens_to_list()

/datum/meta_token_holder/proc/approve_antag_token()
	if(!in_queue)
		return

	to_chat(owner, span_boldnicegreen("Your request to play as [in_queue] has been approved."))
	logger.Log(LOG_CATEGORY_META, "[owner]'s antag token for [in_queue] has been approved")
	spend_antag_token(in_queued_tier, queued_donor)
	if(!owner.mob.mind)
		owner.mob.mind_initialize()
	in_queue.antag_token(owner.mob.mind, owner.mob) //might not be in queue

	qdel(in_queue)
	in_queue = null
	in_queued_tier = null
	queued_donor = FALSE

/datum/meta_token_holder/proc/reject_antag_token()
	if(!in_queue)
		return

	to_chat(owner, span_boldwarning("Your request to play as [in_queue] has been denied."))
	logger.Log(LOG_CATEGORY_META, "[owner]'s antag token for [in_queue] has been denied.")
	in_queue = null
	in_queued_tier = null
	queued_donor = FALSE

/datum/meta_token_holder/proc/adjust_event_tokens(amount)
	check_event_tokens(owner)
	var/old_value = event_tokens
	event_tokens += amount
	log_admin("[key_name(owner)] had their event tokens adjusted from [old_value] to, [event_tokens].")
	convert_tokens_to_list()

/datum/meta_token_holder/proc/check_event_tokens(client/checked_client)
	var/month_number = text2num(time2text(world.time, "MM"))
	if(event_token_month != month_number)
		event_token_month = month_number
		event_tokens = GLOB.patreon_etoken_values[checked_client.patreon.owned_rank]
		convert_tokens_to_list()

/datum/meta_token_holder/proc/approve_token_event()
	if(!queued_token_event)
		return

	to_chat(owner, span_boldnicegreen("Your request to trigger [queued_token_event] has been approved."))
	logger.Log(LOG_CATEGORY_META, "[owner]'s event token for [queued_token_event] has been approved.")
	adjust_event_tokens(-queued_token_event.token_cost)
	SStwitch.add_to_queue(initial(queued_token_event.id_tag))
	queued_token_event = null

/datum/meta_token_holder/proc/reject_token_event()
	if(!queued_token_event)
		return

	to_chat(owner, span_boldwarning("Your request to trigger [queued_token_event] has been denied."))
	logger.Log(LOG_CATEGORY_META, "[owner]'s event token for [queued_token_event] has been denied.")
	queued_token_event = null
