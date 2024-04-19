/datum/config_entry/flag/whitelist220
	default = FALSE
	protection = CONFIG_ENTRY_LOCKED

/world/IsBanned(key, address, computer_id, type, real_bans_only)
	. = ..()
	if(.)
		return .

	if(!CONFIG_GET(flag/whitelist220))
		return null

	var/ckey = ckey(key)
	var/deny_message = list(
		"reason"="whitelist",
		"desc"="\nПричина: Вас ([key]) нет в вайтлисте этого сервера. Приобрести доступ возможно у одного из стримеров Банды за баллы канала или записаться самостоятельно с помощью команды в дискорде, доступной сабам бусти, начиная со второго тира.")

	if(!ckey || !SSdbcore.IsConnected())
		return deny_message

	var/datum/db_query/whitelist_query = SSdbcore.NewQuery(
		{"
			SELECT ckey FROM ckey_whitelist WHERE ckey=:ckey AND
			is_valid=1 AND port=:port AND date_start<=NOW() AND
			(date_end IS NULL OR NOW()<date_end)
		"},
		list("ckey" = ckey, "port" = "[world.port]")
	)

	if(!whitelist_query.warn_execute())
		qdel(whitelist_query)
		return deny_message

	while(whitelist_query.NextRow())
		if(whitelist_query.item[1])
			qdel(whitelist_query)
			return null
	
	qdel(whitelist_query)
	return deny_message
