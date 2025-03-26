SUBSYSTEM_DEF(ipintel)
	name = "XKeyScore"
	flags = SS_NO_INIT|SS_NO_FIRE
	/// The threshold for probability to be considered a VPN and/or bad IP
	var/probability_threshold

	/// Cache for previously queried IP addresses and those stored in the database
	var/list/datum/ip_intel/cached_queries = list()
	/// The store for rate limiting
	var/rate_limit_minute

/// The ip intel for a given address
/datum/ip_intel
	/// If this intel was just queried, the status of the query
	var/query_status
	var/result
	var/address
	var/date

/datum/controller/subsystem/ipintel/OnConfigLoad()
	var/list/fail_messages = list()

	var/contact_email = CONFIG_GET(string/ipintel_email)

	if(!length(contact_email))
		fail_messages += "No contact email"

	if(!findtext(contact_email, "@"))
		fail_messages += "Invalid contact email"

	if(!length(CONFIG_GET(string/ipintel_base)))
		fail_messages += "Invalid query base"

	if (!CONFIG_GET(flag/sql_enabled))
		fail_messages += "The database is not enabled"

	if(length(fail_messages))
		message_admins("IPIntel: Initialization failed check logs!")
		logger.Log(LOG_CATEGORY_GAME_ACCESS, "IPIntel is not enabled because the configs are not valid.", list(
			"fail_messages" = fail_messages,
		))

/datum/controller/subsystem/ipintel/stat_entry(msg)
	return "[..()] | M: [CONFIG_GET(number/ipintel_rate_minute) - rate_limit_minute]"


/datum/controller/subsystem/ipintel/proc/is_enabled()
	return length(CONFIG_GET(string/ipintel_email)) && length(CONFIG_GET(string/ipintel_base)) && CONFIG_GET(flag/sql_enabled)

/datum/controller/subsystem/ipintel/proc/get_address_intel_state(address, probability_override)
	if (!is_enabled())
		return IPINTEL_GOOD_IP
	var/datum/ip_intel/intel = query_address(address)
	if(isnull(intel))
		stack_trace("query_address did not return an ip intel response")
		return IPINTEL_UNKNOWN_INTERNAL_ERROR

	if(istext(intel))
		return intel

	if(!(intel.query_status in list("success", "cached")))
		return IPINTEL_UNKNOWN_QUERY_ERROR
	var/check_probability = probability_override || CONFIG_GET(number/ipintel_rating_bad)
	if(intel.result >= check_probability)
		return IPINTEL_BAD_IP
	return IPINTEL_GOOD_IP

/datum/controller/subsystem/ipintel/proc/is_rate_limited()
	var/static/minute_key
	var/expected_minute_key = floor(REALTIMEOFDAY / 1 MINUTES)

	if(minute_key != expected_minute_key)
		minute_key = expected_minute_key
		rate_limit_minute = 0

	if(rate_limit_minute >= CONFIG_GET(number/ipintel_rate_minute))
		return IPINTEL_RATE_LIMITED_MINUTE
	return FALSE

/datum/controller/subsystem/ipintel/proc/query_address(address, allow_cached = TRUE)
	if (!is_enabled())
		return
	if(allow_cached && fetch_cached_ip_intel(address))
		return cached_queries[address]
	var/is_rate_limited = is_rate_limited()
	if(is_rate_limited)
		return is_rate_limited
	rate_limit_minute += 1

	var/query_base = "https://[CONFIG_GET(string/ipintel_base)]/check.php?ip="
	var/query = "[query_base][address]&contact=[CONFIG_GET(string/ipintel_email)]&flags=b&format=json"

	var/datum/http_request/request = new
	request.prepare(RUSTG_HTTP_METHOD_GET, query)
	request.execute_blocking()
	var/datum/http_response/response = request.into_response()
	var/list/data = json_decode(response.body)
	// Log the response
	logger.Log(LOG_CATEGORY_DEBUG, "ip check response body", data)

	var/datum/ip_intel/intel = new
	intel.query_status = data["status"]
	if(intel.query_status != "success")
		return intel
	intel.result = data["result"]
	if(istext(intel.result))
		intel.result = text2num(intel.result)
	intel.date = ISOtime()
	intel.address = address
	cached_queries[address] = intel
	add_intel_to_database(intel)
	return intel

/datum/controller/subsystem/ipintel/proc/add_intel_to_database(datum/ip_intel/intel)
	set waitfor = FALSE //no need to make the client connection wait for this step.
	if (!SSdbcore.Connect())
		return
	var/datum/db_query/query = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("ipintel")] ( \
			ip, \
			intel \
		) VALUES ( \
			INET_ATON(:address), \
			:result \
		)", list(
			"address" = intel.address,
			"result" = intel.result,
		)
	)
	query.warn_execute()
	query.sync()
	qdel(query)

/datum/controller/subsystem/ipintel/proc/fetch_cached_ip_intel(address)
	if (!SSdbcore.Connect())
		return
	var/ipintel_cache_length = CONFIG_GET(number/ipintel_cache_length)
	var/date_restrictor = ""
	var/sql_args = list("address" = address)
	if(ipintel_cache_length > 1)
		date_restrictor = " AND date > DATE_SUB(NOW(), INTERVAL :ipintel_cache_length DAY)"
		sql_args["ipintel_cache_length"] = ipintel_cache_length
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT * FROM [format_table_name("ipintel")] WHERE ip = INET_ATON(:address)[date_restrictor]",
		sql_args
	)
	query.warn_execute()
	query.sync()
	if(query.status == DB_QUERY_BROKEN)
		qdel(query)
		return null

	query.NextRow()
	var/list/data = query.item
	qdel(query)
	if(isnull(data))
		return null

	var/datum/ip_intel/intel = new
	intel.query_status = "cached"
	intel.result = data["intel"]
	if(istext(intel.result))
		intel.result = text2num(intel.result)
	intel.date = data["date"]
	intel.address = address
	return TRUE

/datum/controller/subsystem/ipintel/proc/is_exempt(client/player)
	if(player.holder || GLOB.deadmins[player.ckey])
		return TRUE
	var/exempt_living_playtime = CONFIG_GET(number/ipintel_exempt_playtime_living)
	if(exempt_living_playtime > 0)
		var/list/play_records = player.prefs.exp
		if (!play_records.len)
			player.set_exp_from_db()
			play_records = player.prefs.exp
		if(length(play_records) && play_records[EXP_TYPE_LIVING] > exempt_living_playtime)
			return TRUE
	return FALSE

/datum/controller/subsystem/ipintel/proc/is_whitelisted(ckey)
	var/datum/db_query/query = SSdbcore.NewQuery(
		"SELECT * FROM [format_table_name("ipintel_whitelist")] WHERE ckey = :ckey", list(
			"ckey" = ckey
		)
	)
	query.warn_execute()
	query.sync()
	if(query.status == DB_QUERY_BROKEN)
		qdel(query)
		return FALSE
	query.NextRow()
	. = !!query.item // if they have a row, they are whitelisted
	qdel(query)


ADMIN_VERB(ipintel_allow, R_BAN, "Whitelist Player VPN", "Allow a player to connect even if they are using a VPN.", ADMIN_CATEGORY_IPINTEL, ckey as text)
	if (!SSipintel.is_enabled())
		to_chat(user, "The ipintel system is not currently enabled but you can still edit the whitelists")
	if(SSipintel.is_whitelisted(ckey))
		to_chat(user, "Player is already whitelisted.")
		return

	var/datum/db_query/query = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("ipintel_whitelist")] ( \
			ckey, \
			admin_ckey \
		) VALUES ( \
			:ckey, \
			:admin_ckey \
		)", list(
			"ckey" = ckey,
			"admin_ckey" = user.ckey,
		)
	)
	query.warn_execute()
	query.sync()
	qdel(query)
	message_admins("IPINTEL: [key_name_admin(user)] has whitelisted '[ckey]'")

ADMIN_VERB(ipintel_revoke, R_BAN, "Revoke Player VPN Whitelist", "Revoke a player's VPN whitelist.", ADMIN_CATEGORY_IPINTEL, ckey as text)
	if (!SSipintel.is_enabled())
		to_chat(user, "The ipintel system is not currently enabled but you can still edit the whitelists")
	if(!SSipintel.is_whitelisted(ckey))
		to_chat(user, "Player is not whitelisted.")
		return
	var/datum/db_query/query = SSdbcore.NewQuery(
		"DELETE FROM [format_table_name("ipintel_whitelist")] WHERE ckey = :ckey", list(
			"ckey" = ckey
		)
	)
	query.warn_execute()
	query.sync()
	qdel(query)
	message_admins("IPINTEL: [key_name_admin(user)] has revoked the VPN whitelist for '[ckey]'")

/client/proc/check_ip_intel()
	if (!SSipintel.is_enabled())
		return
	if(SSipintel.is_exempt(src) || SSipintel.is_whitelisted(ckey))
		return

	var/intel_state = SSipintel.get_address_intel_state(address)
	var/reject_bad_intel = CONFIG_GET(flag/ipintel_reject_bad)
	var/reject_unknown_intel = CONFIG_GET(flag/ipintel_reject_unknown)
	var/reject_rate_limited = CONFIG_GET(flag/ipintel_reject_rate_limited)

	var/connection_rejected = FALSE
	var/datum/ip_intel/intel = SSipintel.cached_queries[address]
	switch(intel_state)
		if(IPINTEL_BAD_IP)
			log_access("IPINTEL: [ckey] was flagged as a VPN with [intel.result * 100]% likelihood.")
			if(reject_bad_intel)
				to_chat_immediate(src, span_boldnotice("Your connection has been detected as a VPN."))
				connection_rejected = TRUE
			else
				message_admins("IPINTEL: [key_name_admin(src)] has been flagged as a VPN with [intel.result * 100]% likelihood.")

		if(IPINTEL_RATE_LIMITED_DAY, IPINTEL_RATE_LIMITED_MINUTE)
			log_access("IPINTEL: [ckey] was unable to be checked due to the rate limit.")
			if(reject_rate_limited)
				to_chat_immediate(src, span_boldnotice("New connections are not being allowed at this time."))
				connection_rejected = TRUE
			else
				message_admins("IPINTEL: [key_name_admin(src)] was unable to be checked due to rate limiting.")

		if(IPINTEL_UNKNOWN_INTERNAL_ERROR, IPINTEL_UNKNOWN_QUERY_ERROR)
			log_access("IPINTEL: [ckey] unable to be checked due to an error.")
			if(reject_unknown_intel)
				to_chat_immediate(src, span_boldnotice("Your connection cannot be processed at this time."))
				connection_rejected = TRUE
			else
				message_admins("IPINTEL: [key_name_admin(src)] was unable to be checked due to an error.")

	if(!connection_rejected)
		return

	var/list/contact_where = list()
	var/forum_url = CONFIG_GET(string/forumurl)
	if(forum_url)
		contact_where += list("<a href='[forum_url]'>Forums</a>")
	var/appeal_url = CONFIG_GET(string/banappeals)
	if(appeal_url)
		contact_where += list("<a href='[appeal_url]'>Ban Appeals</a>")

	var/message_string = "Your connection has been rejected at this time. If you believe this is in error or have any questions please contact an admin"
	if(length(contact_where))
		message_string += " at [english_list(contact_where)]"
	else
		message_string += " somehow."
	message_string += "."

	to_chat_immediate(src, span_userdanger(message_string))
	qdel(src)
