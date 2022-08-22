/// Subsystem that batches a ban cache list for clients on initialize
/// This way we don't need to do ban checks in series later in the code
SUBSYSTEM_DEF(ban_cache)

/datum/controller/subsystem/ban_cache
	name = "Ban Cache"
	init_order = INIT_ORDER_BAN_CACHE
	flags = SS_NO_FIRE
	var/query_started = FALSE

/datum/controller/subsystem/ban_cache/Initialize(start_timeofday)
	generate_queries()
	return ..()

/// Generates ban caches for any logged in clients. This ensures the amount of in-series ban checking we have to do that actually involves sleeps is VERY low
/datum/controller/subsystem/ban_cache/proc/generate_queries()
	query_started = TRUE
	if(!SSdbcore.Connect())
		return
	var/current_time = REALTIMEOFDAY
	var/list/look_for = list()
	for(var/ckey in GLOB.directory)
		var/client/lad = GLOB.directory[ckey]
		// If they've already got a ban cached, or a request goin, don't do it
		if(lad.ban_cache || lad.ban_cache_start < current_time)
			continue
		look_for += ckey
		lad.ban_cache_start = current_time
	// We're gonna try and make a query for clients
	var/datum/db_query/query_batch_ban_cache = SSdbcore.NewQuery(
		"SELECT ckey, role, applies_to_admins FROM [format_table_name("ban")] WHERE ckey IN (:ckeys) AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW())",
		list("ckeys" = look_for)
	)

	var/succeeded = query_batch_ban_cache.Execute()
	for(var/client/lad in GLOB.clients)
		if(lad.ban_cache_start == current_time)
			lad.ban_cache_start = 0

	if(!succeeded)
		qdel(query_batch_ban_cache)
		return

	// Runs after the check for safety, don't want to override anything
	for(var/client/lad in GLOB.clients)
		// We want to ensure we reset their ban cache if they have none
		// But NOT if they have some already applied ban. I may be slightly paranoid
		lad.ban_cache = lad.ban_cache || list()

	while(query_batch_ban_cache.NextRow())
		var/ckey = query_batch_ban_cache.item[1]
		var/role = query_batch_ban_cache.item[2]
		var/hits_admins = query_batch_ban_cache.item[3]

		var/client/lad = GLOB.directory[ckey]
		if(!lad)
			continue

		// Yes I know this is slightly unoptimal, no I do not care
		var/is_admin = GLOB.admin_datums[ckey] || GLOB.deadmins[ckey]
		if(is_admin && !text2num(hits_admins))
			continue

		lad.ban_cache[role] = TRUE

	qdel(query_batch_ban_cache)
