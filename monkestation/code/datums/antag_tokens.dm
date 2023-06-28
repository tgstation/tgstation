GLOBAL_LIST_INIT(used_monthly_token, list())

/client
	var/datum/antag_token_holder/saved_tokens

/datum/antag_token_holder
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
	var/queued_donor = FALSE

/datum/antag_token_holder/New(client/creator)
	. = ..()
	owner = creator

	var/datum/preferences/owners_prefs = creator.prefs
	convert_list_to_tokens(owners_prefs.saved_tokens)
	donator_token = check_for_donator_token()

/datum/antag_token_holder/proc/convert_list_to_tokens(list/saved_tokens)
	if(!length(saved_tokens))
		return
	total_low_threat_tokens = saved_tokens["low_threat"]
	total_medium_threat_tokens = saved_tokens["medium_threat"]
	total_high_threat_tokens = saved_tokens["high_threat"]

	total_antag_tokens = total_low_threat_tokens + total_medium_threat_tokens + total_high_threat_tokens

/datum/antag_token_holder/proc/convert_tokens_to_list()
	owner.prefs.saved_tokens = list(
		"low_threat" = total_low_threat_tokens,
		"medium_threat" = total_medium_threat_tokens,
		"high_threat" = total_high_threat_tokens,
	)
	owner.prefs.save_preferences()

/datum/antag_token_holder/proc/check_for_donator_token()
	if(!owner.patreon)
		return FALSE
	if(!owner.patreon.has_access(ACCESS_TRAITOR_RANK))
		return FALSE
	if(!GLOB.used_monthly_token.len)
		var/json_file = file("data/monthly_tokens.json")
		if(!json_file)
			return TRUE
		GLOB.used_monthly_token = json_decode(file2text(json_file))
	if(owner.ckey in GLOB.used_monthly_token)
		return FALSE
	return TRUE

/datum/antag_token_holder/proc/spend_token(tier, use_donor = FALSE)
	if(use_donor)
		if(donator_token)
			donator_token = FALSE
			var/json_file = file("data/monthly_tokens.json")
			if(!GLOB.used_monthly_token.len)
				GLOB.used_monthly_token = json_decode(file2text(json_file))
			GLOB.used_monthly_token += owner.ckey

			fdel(json_file)
			WRITE_FILE(json_file, json_encode(GLOB.used_monthly_token))
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
/datum/antag_token_holder/proc/adjust_tokens(tier, amount)
	switch(tier)
		if(HIGH_THREAT)
			total_high_threat_tokens += amount
		if(MEDIUM_THREAT)
			total_medium_threat_tokens += amount
		if(LOW_THREAT)
			total_low_threat_tokens += amount

	convert_tokens_to_list()


/datum/antag_token_holder/proc/approve_token()
	if(!in_queue)
		return
	to_chat(owner, "Your request to play as [in_queue] has been approved.")

	spend_token(in_queued_tier, queued_donor)
	in_queue.antag_token(owner.mob.mind)

	qdel(in_queue)
	in_queue = null
	in_queued_tier = null
	queued_donor = FALSE

/datum/antag_token_holder/proc/reject_token()
	to_chat(owner, "Your request to play as [in_queue] has been denied.")
	in_queue = null
	in_queued_tier = null
	queued_donor = FALSE
