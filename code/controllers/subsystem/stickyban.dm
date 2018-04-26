SUBSYSTEM_DEF(stickyban)
	name = "PRISM"
	init_order = INIT_ORDER_STICKY_BAN
	flags = SS_NO_FIRE

	var/list/cache = list()
	var/list/dbcache = list()
	var/list/confirmed_exempt = list()
	var/dbcacheexpire = 0


/datum/controller/subsystem/stickyban/Initialize(timeofday)
	var/list/bannedkeys = sticky_banned_ckeys()
	//sanitize the sticky ban list

	//delete db bans that no longer exist in the database and add new legacy bans to the database
	if (!CONFIG_GET(flag/ban_legacy_system) && (SSdbcore.Connect() || length(SSstickyban.dbcache)))
		for (var/oldban in (world.GetConfig("ban") - bannedkeys))
			var/ckey = ckey(oldban)
			if (ckey != oldban && (ckey in bannedkeys))
				continue

			var/list/ban = params2list(world.GetConfig("ban", oldban))
			if (ban && !ban["fromdb"])
				if (!import_to_db(ckey, ban))
					log_world("Could not import stickyban on [oldban] into the database. Ignoring")
					continue
				dbcacheexpire = 0
				bannedkeys += ckey
			world.SetConfig("ban", oldban, null)


	for (var/bannedkey in bannedkeys)
		var/ckey = ckey(bannedkey)
		var/list/ban = get_stickyban_from_ckey(bannedkey)

		//byond stores sticky bans by key, that's lame
		if (ckey != bannedkey)
			world.SetConfig("ban", bannedkey, null)

		if (!ban["ckey"])
			ban["ckey"] = ckey

		ban["matches_this_round"] = list()
		ban["existing_user_matches_this_round"] = list()
		ban["admin_matches_this_round"] = list()
		ban["pending_matches_this_round"] = list()

		cache[ckey] = ban
		world.SetConfig("ban", ckey, list2stickyban(ban))

	return ..()

/datum/controller/subsystem/stickyban/proc/Populatedbcache()
	var/newdbcache = list() //so if we runtime or the db connection dies we don't kill the existing cache

	var/datum/DBQuery/query_stickybans = SSdbcore.NewQuery("SELECT ckey, reason, banning_admin, datetime FROM [format_table_name("stickyban")] ORDER BY ckey")
	if (!query_stickybans.warn_execute())
		return

	var/datum/DBQuery/query_stickyban_matches = SSdbcore.NewQuery("SELECT stickyban, matched_ckey, first_matched, exempt FROM [format_table_name("stickyban_matched_ckey")] ORDER BY first_matched")
	if (!query_stickyban_matches.warn_execute())
		return
	query_stickyban_matches.SetConversion(4, SSdbcore.NUMBER_CONV) //read exempt as a number, not a string

	while (query_stickybans.NextRow())
		var/list/ban = list()

		ban["ckey"] = query_stickybans.item[1]
		ban["message"] = query_stickybans.item[2]
		ban["reason"] = "(InGameBan)([query_stickybans.item[3]])"
		ban["admin"] = query_stickybans.item[3]
		ban["datetime"] = query_stickybans.item[4]
		ban["type"] = list("sticky")

		newdbcache["[query_stickybans.item[1]]"] = ban


	while (query_stickyban_matches.NextRow())
		var/list/match = list()

		match["stickyban"] = query_stickyban_matches.item[1]
		match["matched_ckey"] = query_stickyban_matches.item[2]
		match["first_matched"] = query_stickyban_matches.item[3]
		match["exempt"] = query_stickyban_matches.item[4]

		var/ban = newdbcache[query_stickyban_matches.item[1]]
		if (!ban)
			continue
		var/keys = ban[query_stickyban_matches.item[4] ? "whitelist" : "keys"]
		if (!keys)
			keys = ban[query_stickyban_matches.item[4] ? "whitelist" : "keys"] = list()
		keys[query_stickyban_matches.item[2]] = match

	dbcache = newdbcache
	dbcacheexpire = world.time+STICKYBAN_DB_CACHE_TIME


/datum/controller/subsystem/stickyban/proc/import_to_db(ckey, list/ban)
	. = FALSE
	if (!ban["admin"])
		ban["admin"] = "LEGACY"
	if (!ban["message"])
		ban["message"] = "Evasion"

	var/datum/DBQuery/query_create_stickyban = SSdbcore.NewQuery("INSERT INTO [format_table_name("stickyban")] (ckey, reason, banning_admin) VALUES ('[sanitizeSQL(ckey)]', '[sanitizeSQL(ban["message"])]', '[sanitizeSQL(ban["admin"])]')")
	if (!query_create_stickyban.warn_execute())
		return

	var/list/sqlkeys = list()

	if (ban["keys"])
		var/list/keys = splittext(ban["keys"], ",")
		for (var/key in keys)
			var/list/sqlkey = list()
			sqlkey["stickyban"] = "'[sanitizeSQL(ckey)]'"
			sqlkey["matched_ckey"] = "'[sanitizeSQL(ckey(key))]'"
			sqlkey["exempt"] = FALSE
			sqlkeys += sqlkey

	if (ban["whitelist"])
		var/list/keys = splittext(ban["whitelist"], ",")
		for (var/key in keys)
			var/list/sqlkey = list()
			sqlkey["stickyban"] = "'[sanitizeSQL(ckey)]'"
			sqlkey["matched_ckey"] = "'[sanitizeSQL(ckey(key))]'"
			sqlkey["exempt"] = TRUE
			sqlkeys += sqlkey

	if (length(sqlkeys))
		SSdbcore.MassInsert(format_table_name("stickyban_matched_ckey"), sqlkeys, FALSE, TRUE)


	return TRUE
