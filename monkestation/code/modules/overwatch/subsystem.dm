SUBSYSTEM_DEF(overwatch)
	name = "Overwatch"
	init_order = INIT_ORDER_OW
	flags = SS_NO_FIRE

	var/max_error_count = 4

	var/is_active = FALSE
	var/error_counter = 0

	///accounts younger than this in days are interviewed
	var/minimum_player_age = 7
	///max number of active non role bans to be considered for interview
	var/max_ban_count = 2

	var/list/tgui_panel_asn_data = list()
	var/list/tgui_panel_wl_data = list()

	var/list/client/postponed_client_queue = list()

/datum/controller/subsystem/overwatch/Initialize(timeofday)

	if(!CONFIG_GET(flag/sql_enabled))
		log_sql("Overwatch could not be loaded without SQL enabled")
		return ..()

	Toggle()
	return ..()

/datum/controller/subsystem/overwatch/stat_entry(msg)
	return "[is_active ? "ACTIVE" : "OFFLINE"]"

/datum/controller/subsystem/overwatch/proc/Toggle(mob/user)
	if (!initialized && user)
		return

	if(!is_active && !SSdbcore.Connect())
		log_sql("Overwatch could not be loaded because the DB connection could not be established.")
		return

	is_active = !is_active
	log_access("Overwatch is [is_active ? "enabled" : "disabled"]!")

	. = is_active
	if(!.)
		return

	tgui_panel_asn_data = GetAsnBanlistDatabase()
	tgui_panel_wl_data = GetWhitelistDatabase()

	var/list/clients_to_check = postponed_client_queue.Copy()
	postponed_client_queue.Cut()
	for (var/client/C in clients_to_check)
		CollectClientData(C)
		HandleClientAccessCheck(C, postponed = TRUE)
		HandleASNbanCheck(C, postponed = TRUE)
		CHECK_TICK

/datum/controller/subsystem/overwatch/proc/CheckDBCon()
	if(is_active && SSdbcore.Connect())
		return TRUE

	is_active = FALSE
	log_access("A Database error has occured. Overwatch is automatically disabled.")
	return FALSE


/datum/controller/subsystem/overwatch/proc/CollectClientData(client/C)
	ASSERT(istype(C))

	var/_ip_addr = C.address

	if(!is_active)
		postponed_client_queue.Add(C)
		return

	if(!CheckDBCon())
		return

	C.ip_info.is_whitelisted = CheckWhitelist(C.ckey)

	if(!_ip_addr || _ip_addr == "127.0.0.1")
		return

	var/list/response = GetAPIresponse(_ip_addr, C)

	if(!response || !C)
		return

	C.ip_info.ip = _ip_addr
	C.ip_info.ip_as = response["as"]
	C.ip_info.ip_mobile = response["mobile"]
	C.ip_info.ip_proxy = response["proxy"]
	C.ip_info.ip_hosting = response["hosting"]

	C.ip_info.is_loaded = TRUE
	return

/datum/controller/subsystem/overwatch/proc/GetAPIresponse(ip, client/C = null)
	var/list/response = LoadCachedData(ip)

	if(response && C)
		log_access("Overwatch data for [C] ([ip]) is loaded from cache!")

	while(!response && is_active && error_counter < max_error_count)
		var/list/http = world.Export("http://ip-api.com/json/[ip]?fields=17025024")

		if(!http)
			if(C)
				log_access("Overwatch: API connection failed, could not check [C], retrying.")
			else
				log_access("Overwatch: API connection failed, could not check [ip], retrying.")
			error_counter += 1
			sleep(2)
			continue

		var/raw_response = file2text(http["CONTENT"])

		try
			response = json_decode(raw_response)
		catch (var/exception/e)
			log_access("Overwatch: JSON decode error, could not check [C]. JSON decode error: [e.name]")
			return

		if(response["status"] == "fail")
			log_access("Overwatch: Request error, could not check [C]. CheckIP response: [response["message"]]")
			return

		if(C)
			log_access("Overwatch data for [C]([ip]) is loaded from external API!")
		CacheData(ip, raw_response)

	if(error_counter >= max_error_count && is_active)
		message_admins("Overwatch was disabled due to connection errors!")
		log_access("Overwatch was disabled due to connection errors!")
		is_active = FALSE
		return

	return response

/datum/controller/subsystem/overwatch/proc/CheckForAccess(client/C)
	ASSERT(istype(C))

	if(!is_active)
		return TRUE

	if(!CheckDBCon())
		return TRUE

	if(!C.address || C.holder)
		return TRUE

	if(C.ip_info.is_whitelisted)
		return TRUE

	if(C.ip_info.is_loaded)
		if(!C.ip_info.ip_proxy && !C.ip_info.ip_hosting)
			return TRUE
		return FALSE

	if(FetchPlayerAge(C) <= minimum_player_age)
		log_access("[C.ckey]'s account is under the minimum player age, adding into the interview queue")
		return FALSE

	if(CheckActiveBans(C))
		log_access("[C.ckey] has 2 or more active perma bans and has been added to the interview queue.")
		return FALSE

	log_access("Overwatch failed to load info for [C.ckey].")
	return TRUE

/datum/controller/subsystem/overwatch/proc/CheckWhitelist(ckey)
	. = FALSE

	if(!CheckDBCon())
		return

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT ckey FROM overwatch_whitelist WHERE ckey = '[ckey]'")
	query.Execute()

	if(query.NextRow())
		. = TRUE

	qdel(query)

	return

/datum/controller/subsystem/overwatch/proc/CheckASNban(client/C)
	ASSERT(istype(C))

	. = TRUE

	if(!is_active)
		return

	if(!CheckDBCon())
		return

	if(C.ip_info.is_whitelisted)
		return

	var/datum/db_query/query = SSdbcore.NewQuery("SELECT `asn` FROM overwatch_asn_ban WHERE asn = '[C.ip_info.ip_as]'")
	query.Execute()

	if(query.NextRow())
		. = FALSE

	qdel(query)

	return

/datum/controller/subsystem/overwatch/proc/LoadCachedData(ip)
	ASSERT(istext(ip))

	if(!CheckDBCon())
		return FALSE

	var/datum/db_query/_Cache_select_query = SSdbcore.NewQuery("SELECT response FROM overwatch_ip_cache WHERE ip = '[ip]'")
	_Cache_select_query.Execute()

	if(!_Cache_select_query.NextRow())
		. = FALSE
	else
		. = json_decode(_Cache_select_query.item[1])

	qdel(_Cache_select_query)
	return

/datum/controller/subsystem/overwatch/proc/CacheData(ip, raw_response)
	ASSERT(istext(ip))
	ASSERT(istext(raw_response))

	if(!CheckDBCon())
		return FALSE

	var/datum/db_query/_Cache_insert_query = SSdbcore.NewQuery({"
		INSERT INTO overwatch_ip_cache (ip, response)
		VALUES (:ip, :raw_response)
		ON DUPLICATE KEY UPDATE
		response = :raw_response"},
		list("ip" = ip, "raw_response" = raw_response))
	_Cache_insert_query.Execute()
	qdel(_Cache_insert_query)

	return TRUE

/datum/controller/subsystem/overwatch/proc/AddToWhitelist(ckey_input, client/Admin)
	ASSERT(istype(Admin))

	if(!CheckDBCon())
		return

	var/ckey = new_sql_sanitize_text(ckey(ckey_input))

	if(!ckey)
		return

	var/datum/db_query/_Whitelist_Query = SSdbcore.NewQuery("INSERT INTO overwatch_whitelist (`ckey`, `a_ckey`, `timestamp`) VALUES ('[ckey]', '[Admin.ckey]', Now())")
	_Whitelist_Query.Execute()
	qdel(_Whitelist_Query)

	tgui_panel_wl_data = GetWhitelistDatabase()
	log_access("added [ckey] to Overwatch whitelist.")

	return TRUE

/datum/controller/subsystem/overwatch/proc/RemoveFromWhitelist(ckey, client/Admin)
	if(!CheckDBCon())
		return FALSE

	if(!CheckWhitelist(ckey))
		return

	var/datum/db_query/_Whitelist_Query = SSdbcore.NewQuery("DELETE FROM overwatch_whitelist WHERE `ckey` = '[ckey]'")
	_Whitelist_Query.Execute()
	qdel(_Whitelist_Query)

	tgui_panel_wl_data = GetWhitelistDatabase()
	log_access("removed [ckey] from Overwatch whitelist.", Admin.mob)

	return TRUE

/datum/controller/subsystem/overwatch/proc/GetWhitelistDatabase()
	var/datum/db_query/_Whitelist_DB_Select_Query = SSdbcore.NewQuery("SELECT `ckey`, `a_ckey`, `timestamp` from overwatch_whitelist")
	_Whitelist_DB_Select_Query.Execute()

	var/list/result = list()

	while(_Whitelist_DB_Select_Query.NextRow())
		var/list/row = list()
		row["ckey"] = _Whitelist_DB_Select_Query.item[1]
		row["a_ckey"] = _Whitelist_DB_Select_Query.item[2]
		row["timestamp"] = _Whitelist_DB_Select_Query.item[3]

		result["displayData"] += list(row)

	qdel(_Whitelist_DB_Select_Query)

	return result

/datum/controller/subsystem/overwatch/proc/AddASNban(address, client/Admin)
	if(!CheckDBCon())
		return

	if(!check_rights(R_SERVER, TRUE))
		return

	var/ip = remove_all_spaces(new_sql_sanitize_text(address))

	if(length(ip) > 16)
		return

	var/list/response = GetAPIresponse(ip)

	var/ip_as = response["as"]

	var/datum/db_query/_ASban_Insert_Query = SSdbcore.NewQuery("INSERT INTO overwatch_asn_ban (`ip`, `asn`, `a_ckey`, `timestamp`) VALUES ('[ip]', '[ip_as]', '[Admin.ckey]', Now())")
	_ASban_Insert_Query.Execute()
	qdel(_ASban_Insert_Query)

	tgui_panel_asn_data = GetAsnBanlistDatabase()
	log_access("has added '[ip_as]' to the Overwatch ASN banlist.", Admin)

	return TRUE

/datum/controller/subsystem/overwatch/proc/RemoveASNban(ip_as, client/Admin)
	if(!CheckDBCon())
		return

	if(!check_rights(R_SERVER, TRUE))
		return

	var/datum/db_query/_ASban_Delete_Query = SSdbcore.NewQuery("DELETE FROM overwatch_asn_ban WHERE `asn` = '[ip_as]'")
	_ASban_Delete_Query.Execute()
	qdel(_ASban_Delete_Query)

	tgui_panel_asn_data = GetAsnBanlistDatabase()
	log_access("has removed '[ip_as]' from the Overwatch ASN banlist.", Admin)

	return TRUE


/datum/controller/subsystem/overwatch/proc/GetAsnBanlistDatabase()
	var/datum/db_query/_ASN_Banlist_Select_Query = SSdbcore.NewQuery("SELECT `asn`, `timestamp`, `a_ckey` from overwatch_asn_ban")
	_ASN_Banlist_Select_Query.Execute()

	var/list/result = list()

	while(_ASN_Banlist_Select_Query.NextRow())
		var/list/row = list()
		row["asn"] = _ASN_Banlist_Select_Query.item[1]
		row["timestamp"] = _ASN_Banlist_Select_Query.item[2]
		row["a_ckey"] = _ASN_Banlist_Select_Query.item[3]

		result["displayData"] += list(row)

	qdel(_ASN_Banlist_Select_Query)

	return result


/datum/controller/subsystem/overwatch/proc/HandleClientAccessCheck(client/C, postponed = 0)
	if(!SSoverwatch.CheckForAccess(C) && !(C.ckey in GLOB.admin_datums))
		if(!postponed)
			C.log_client_to_db_connection_log()
		log_access(span_notice("Overwatch: Failed Login: [C.key]/[C.ckey]([C.address])([C.computer_id]) failed to pass Overwatch check."))
		//qdel(C)
		return TRUE
	return FALSE

/datum/controller/subsystem/overwatch/proc/HandleASNbanCheck(client/C, postponed = 0)
	if(!SSoverwatch.CheckASNban(C) && !(C.ckey in GLOB.admin_datums))
		if(!postponed)
			C.log_client_to_db_connection_log()
		log_access(span_notice("Overwatch: Failed Login: [C.key]/[C.ckey]([C.address])([C.computer_id]) failed to pass ASN ban check."))
		qdel(C)
		return

/datum/controller/subsystem/overwatch/proc/FetchPlayerAge(client/C, connection_data)
	var/cached_player_age = C.set_client_age_from_db(connection_data) //we have to cache this because other shit may change it and we need it's current value now down below.
	if (isnum(cached_player_age) && cached_player_age == -1)
		C.account_join_date = C.findJoinDate()
		if(C.account_join_date)
			var/datum/db_query/query_datediff = SSdbcore.NewQuery(
				"SELECT DATEDIFF(Now(), :account_join_date)",
				list("account_join_date" = C.account_join_date)
			)
			if(!query_datediff.Execute())
				qdel(query_datediff)
				return
			if(query_datediff.NextRow())
				cached_player_age = text2num(query_datediff.item[1])
			qdel(query_datediff)
	return cached_player_age

/datum/controller/subsystem/overwatch/proc/CheckActiveBans(client/C)
	if(C.ckey in GLOB.interviews.approved_ckeys) // if these are already approved no point querying as they will be allowed regardless
		return
	var/living_minutes = C.get_exp_living(TRUE)
	if(living_minutes >= 30)
		return

	if(!CONFIG_GET(string/centcom_ban_db))
		return

	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/centcom_ban_db)]/[C.ckey]", "", "")
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()
	var/list/bans
	if(response.errored)
		return
	if(response.status_code != 200)
		return
	if(response.body == "[]")
		return
	var/active_ban_count = 0
	bans = json_decode(response["body"])
	for(var/list/ban in bans)
		if(ban["type"] != "Server")
			continue
		if(!ban["active"])
			continue
		active_ban_count++

	if(active_ban_count >= max_ban_count)
		return TRUE
	return FALSE

/client/proc/Overwatch_toggle()
	set category = "Server"
	set name = "Toggle Overwatch"

	if(!check_rights(R_SERVER))
		return

	if(!SSdbcore.Connect())
		to_chat(usr, span_notice("The Database is not connected!"))
		return

	var/overwatch_status = SSoverwatch.Toggle()
	log_access("has [overwatch_status ? "enabled" : "disabled"] the Overwatch system!")


