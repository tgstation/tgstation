///Gets the centcom bans of the given ckey.
/datum/admins/proc/open_centcom_bans(ckey)
	if(!check_rights(R_ADMIN))
		return

	if(!CONFIG_GET(string/centcom_ban_db))
		to_chat(usr, span_warning("Centcom Galactic Ban DB is disabled!"))
		return

	// Make the request
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/centcom_ban_db)]/[ckey]", "", "")
	request.begin_async()
	UNTIL(request.is_complete() || !usr)
	if (!usr)
		return
	var/datum/http_response/response = request.into_response()

	var/list/bans

	var/list/dat = list("<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><body>")

	if(response.errored)
		dat += "<br>Failed to connect to CentCom."
	else if(response.status_code != 200)
		dat += "<br>Failed to connect to CentCom. Status code: [response.status_code]"
	else
		if(response.body == "[]")
			dat += "<center><b>0 bans detected for [ckey]</b></center>"
		else
			bans = json_decode(response.body)

			//Ignore bans from non-whitelisted sources, if a whitelist exists
			var/list/valid_sources
			if(CONFIG_GET(string/centcom_source_whitelist))
				valid_sources = splittext(CONFIG_GET(string/centcom_source_whitelist), ",")
				dat += "<center><b>Bans detected for [ckey]</b></center>"
			else
				//Ban count is potentially inaccurate if they're using a whitelist
				dat += "<center><b>[bans.len] ban\s detected for [ckey]</b></center>"

			for(var/list/ban in bans)
				if(valid_sources && !(ban["sourceName"] in valid_sources))
					continue
				dat += "<b>Server: </b> [sanitize(ban["sourceName"])]<br>"
				dat += "<b>RP Level: </b> [sanitize(ban["sourceRoleplayLevel"])]<br>"
				dat += "<b>Type: </b> [sanitize(ban["type"])]<br>"
				dat += "<b>Banned By: </b> [sanitize(ban["bannedBy"])]<br>"
				dat += "<b>Reason: </b> [sanitize(ban["reason"])]<br>"
				dat += "<b>Datetime: </b> [sanitize(ban["bannedOn"])]<br>"
				var/expiration = ban["expires"]
				dat += "<b>Expires: </b> [expiration ? "[sanitize(expiration)]" : "Permanent"]<br>"
				if(ban["type"] == "job")
					dat += "<b>Jobs: </b> "
					var/list/jobs = ban["jobs"]
					dat += sanitize(jobs.Join(", "))
					dat += "<br>"
				dat += "<hr>"

	dat += "<br></body>"
	var/datum/browser/popup = new(usr, "centcomlookup-[ckey]", "<div align='center'>Central Command Galactic Ban Database</div>", 700, 600)
	popup.set_content(dat.Join())
	popup.open(0)

///Returns the amount of permabans they have on centcom.
/datum/admins/proc/check_centcom_permabans(ckey)
	if(!check_rights(R_ADMIN))
		return

	if(!CONFIG_GET(string/centcom_ban_db))
		to_chat(usr, span_warning("Centcom Galactic Ban DB is disabled!"))
		return

	// Make the request
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/centcom_ban_db)]/[ckey]", "", "")
	request.begin_async()
	UNTIL(request.is_complete() || !usr)
	if (!usr)
		return
	var/datum/http_response/response = request.into_response()

	var/list/bans
	var/total_permabans

	if(response.body == "[]")
		return
	bans = json_decode(response.body)
	//Ignore bans from non-whitelisted sources, if a whitelist exists
	var/list/valid_sources
	if(CONFIG_GET(string/centcom_source_whitelist))
		valid_sources = splittext(CONFIG_GET(string/centcom_source_whitelist), ",")

	for(var/list/ban in bans)
		if(valid_sources && !(ban["sourceName"] in valid_sources))
			continue
		if(!ban["expires"] && (sanitize(ban["type"]) == "Server")) //server permabans only
			total_permabans++

	return total_permabans
