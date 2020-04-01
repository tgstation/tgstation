
/client
	var/list/sent_assets = list() // List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/completed_asset_jobs = list() /// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/sending_assets = list() /// List of all assets currently being sent in blocking mode
	var/last_asset_job = 0 /// Last asset send job id.
	var/last_completed_asset_job = 0

/// Process asset cache client topic calls for "asset_cache_confirm_arrival=[INT]"
/client/proc/asset_cache_confirm_arrival(job_id)
	var/asset_cache_job = round(text2num(job_id))
		//because we skip the limiter, we have to make sure this is a valid arrival and not somebody tricking us into letting them append to a list without limit.
	if (asset_cache_job > 0 && asset_cache_job <= last_asset_job && !(asset_cache_job in completed_asset_jobs))
		completed_asset_jobs += asset_cache_job
		last_completed_asset_job = max(last_completed_asset_job, asset_cache_job)
	else
		return asset_cache_job || TRUE


/// Process asset cache client topic calls for "asset_cache_preload_data=[HTML+JSON_STRING]
/client/proc/asset_cache_preload_data(data)
	/*var/jsonend = findtextEx(data, "{{{ENDJSONDATA}}}")
	if (!jsonend)
		CRASH("invalid asset_cache_preload_data, no jsonendmarker")*/
	//var/json = html_decode(copytext(data, 1, jsonend))
	var/json = data
	var/list/preloaded_assets = json_decode(json)

	for (var/preloaded_asset in preloaded_assets)
		if (copytext(preloaded_asset, findlasttext(preloaded_asset, ".")+1) in list("js", "jsm", "htm", "html"))
			preloaded_assets -= preloaded_asset
			continue
	sent_assets |= preloaded_assets

//Updates the client side stored html/json combo file used to keep track of what assets the client has between restarts/reconnects.

/client/proc/asset_cache_update_json(verify = FALSE, list/new_assets = list())
	if (world.time - connection_time < 10 SECONDS) //don't override the existing data file on a new connection
		return
	if (!islist(new_assets))
		new_assets = list("[new_assets]" = md5(SSassets.cache[new_assets]))

	src << browse(json_encode(new_assets|sent_assets), "file=asset_data.json&display=0")
