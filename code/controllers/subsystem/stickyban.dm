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

	for (var/bannedckey in cache)
		world.SetConfig("ban", bannedckey, list2stickyban(cache[bannedckey]))


	if (!CONFIG_GET(flag/ban_legacy_system) && (SSdbcore.Connect() || length(SSstickyban.dbcache)))
		for (var/oldban in (world.GetConfig("ban") - bannedkeys))
			world.SetConfig("ban", oldban, null) //remove bans that no longer exist.
	return ..()

/datum/controller/subsystem/stickyban/proc/Populatedbcache()
	var/newdbcache = list() //so if we runtime or the db connection dies we don't kill the existing cache

	var/datum/DBQuery/query_stickybans = SSdbcore.NewQuery("SELECT ckey, reason, banning_admin, datetime FROM [format_table_name("stickyban")] ORDERED BY ckey")
	if (!query_stickybans.warn_execute())
		return

	var/datum/DBQuery/query_stickyban_matches = SSdbcore.NewQuery("SELECT stickyban, matched_ckey, first_matched, exempt FROM [format_table_name("stickyban_matrched_ckey")]")
	if (!query_stickyban_matches.warn_execute())
		return
	query_stickyban_matches.SetConversion(4, SSdbcore.NUMBER_CONV) //read exempt as a number, not a string

	while (query_stickybans.NextRow())
		var/list/ban = list()

		ban["ckey"] = query_stickybans.item[1]
		ban["reason"] = query_stickybans.item[2]
		ban["banning_admin"] = query_stickybans.item[3]
		ban["datetime"] = query_stickybans.item[4]

		newdbcache["[query_stickybans.item[1]]"] = ban


	while (query_stickyban_matches.NextRow())
		var/list/match = list()

		match["stickyban"] = query_stickyban_matches.item[1]
		match["matched_ckey"] = query_stickyban_matches.item[2]
		match["first_matched"] = query_stickyban_matches.item[3]
		match["exempt"] = query_stickyban_matches.item[4]

		var/ban = newdbcache[match["stickyban"]]
		if (!ban)
			continue
		var/keys = ban["keys"]
		if (!keys)
			keys = ban["keys"] = list()
		keys[match["matched_ckey"]] = match

	dbcache = newdbcache
	dbcacheexpire = world.time+STICKYBAN_DB_CACHE_TIME
