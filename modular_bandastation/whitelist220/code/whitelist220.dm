/datum/config_entry/flag/whitelist220
	default = FALSE
	protection = CONFIG_ENTRY_LOCKED

/datum/controller/subsystem/dbcore/Initialize()
	. = ..()
	if(CONFIG_GET(flag/whitelist220))
		load_whitelist220()

/world/IsBanned(key, address, computer_id, type, real_bans_only)
	. = ..()
	if(.)
		return .
	if(!CONFIG_GET(flag/whitelist220))
		return null
	var/ckey = ckey(key)
	if(ckey && !(ckey in GLOB.whitelist))
		return list("reason"="whitelist", "desc"="\nПричина: Вас ([key]) нет в вайтлисте этого сервера. Приобрести доступ возможно у одного из стримеров Банды за баллы канала или записаться самостоятельно с помощью команды в дискорде, доступной сабам бусти, начиная со второго тира.")

/client/proc/update_whitelist()
	set name = "Update whitelist"
	set category = "Server"

	if(!check_rights(R_SERVER))
		return

	load_whitelist220()

/proc/load_whitelist220()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounce("Whitelist reload blocked: Advanced ProcCall detected"))
		return

	if(!SSdbcore.IsConnected())
		return

	GLOB.whitelist = list()

	var/datum/db_query/whitelist_query = SSdbcore.NewQuery({"
	SELECT ckey FROM ckey_whitelist WHERE
	is_valid=1 AND port=:port AND date_start<=NOW() AND
	(NOW()<date_end OR date_end IS NULL)
	"}, list("port" = "[world.port]"))
	if(!whitelist_query.warn_execute())
		qdel(whitelist_query)
		return

	while(whitelist_query.NextRow())
		var/ckey = whitelist_query.item[1]
		GLOB.whitelist |= ckey

	qdel(whitelist_query)

/mob/new_player/Login()
	if(CONFIG_GET(flag/whitelist220) && !(ckey in GLOB.whitelist))
		check_whitelist220()
	. = ..()

/mob/new_player/proc/check_whitelist220()
	if(!SSdbcore.IsConnected())
		return
	var/datum/db_query/whitelist_query = SSdbcore.NewQuery({"
	SELECT ckey FROM ckey_whitelist WHERE ckey=:ckey AND
	is_valid=1 AND port=:port AND date_start<=NOW() AND
	(NOW()<date_end OR date_end IS NULL)
	"}, list("ckey" = ckey, "port" = "[world.port]"))
	if(!whitelist_query.warn_execute())
		qdel(whitelist_query)
		return

	while(whitelist_query.NextRow())
		var/ckey = whitelist_query.item[1]
		GLOB.whitelist |= ckey

	qdel(whitelist_query)
