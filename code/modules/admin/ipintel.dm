/datum/ipintel
	var/ip
	var/intel = 0
	var/cache = FALSE
	var/cacheminutesago = 0
	var/cachedate = ""
/datum/ipintel/New()
	cachedate = SQLtime()

/proc/get_ip_intel(ip, bypasscache = FALSE, updatecache = TRUE)
	var/datum/ipintel/res = new()
	res.ip = ip
	. = res
	if (!ip || !config.ipintel_email)
		return
	if (!bypasscache && establish_db_connection())
		var/DBQuery/query = dbcon.NewQuery("SELECT date,intel,TIMESTAMPDIFF(MINUTE,date,NOW()) FROM [format_table_name("ipintel")] WHERE ip = INET_ATON('[ip]') AND ((intel <= [config.ipintel_rating_max] AND date + INTERVAL [config.ipintel_save_good] HOUR > NOW()) OR (intel > [config.ipintel_rating_max] AND date + INTERVAL [config.ipintel_save_bad] HOUR > NOW()))")
		query.Execute()
		if (query.NextRow())
			res.cache = TRUE
			res.cachedate = query.item[1]
			res.intel = query.item[2]
			res.cacheminutesago = query.item[3]
			return
	res.intel = ip_intel_query(ip)
	if (updatecache && res.intel >= 0 && establish_db_connection())
		//if you're wondering, we don't add or update the date as its a TIMESTAMP field, and as such, automatically updates at any insert or update
		var/DBQuery/query = dbcon.NewQuery("INSERT INTO [format_table_name("ipintel")] (ip, intel) VALUES (INET_ATON('[ip]'), [res.intel]) ON DUPLICATE KEY UPDATE intel = VALUES(intel)")
		query.Execute()
	return


var/ip_intel_throttle = 0
var/ip_intel_errors = 0
/proc/ip_intel_query(ip, var/retry=0)
	. = -1 //default
	if (!ip)
		return
	if (ip_intel_throttle > world.timeofday)
		return

	var/http[] = world.Export("http://check.getipintel.net/check.php?ip=[ip]&contact=[config.ipintel_email]&format=json")

	if (http)
		var/status = text2num(http["STATUS"])

		if (status == 200)
			var/response = json_decode(file2text(http["CONTENT"]))
			if (response)
				if (response["status"] == "success")
					return text2num(response["result"])
				else
					ipintel_handle_error("Bad response from server: [response["status"]].", ip, retry)
					if (!retry)
						sleep(25)
						return .(ip, 1)

		else if (status == 429)
			ipintel_handle_error("Error #429: We have exceeded the rate limit.", ip, 1)
			return
		else
			ipintel_handle_error("Unknown status code: [status].", ip, retry)
			if (!retry)
				sleep(25)
				return .(ip, 1)
	else
		ipintel_handle_error("Unable to connect to API.", ip, retry)
		if (!retry)
			sleep(25)
			return .(ip, 1)


/proc/ipintel_handle_error(error, ip, retry)
	if (retry)
		ip_intel_errors++
		error += " Could not check [ip]. Disabling IPINTEL for [ip_intel_errors] minute[( ip_intel_errors == 1 ? "" : "s" )]"
		ip_intel_throttle = world.timeofday + (10 * 60 * ip_intel_errors)
	else
		error += " Attempting retry on [ip]."
	log_ipintel(error)

/proc/log_ipintel(text)
	log_game("IPINTEL: [text]")





