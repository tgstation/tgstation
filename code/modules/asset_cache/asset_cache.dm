/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(client/client, asset_name, verify = TRUE)
	return send_asset_list(client, list(asset_name), verify)

//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset_list(client/client, list/asset_list, verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return FALSE

		else
			return FALSE
	
	var/list/unreceived = list()
	var/list/sending = list()

	for (var/asset_name in asset_list)
		var/asset_file = SSassets.cache[asset_name]
		if (!asset_file)
			continue
		
		var/asset_md5 = md5(asset_file) || md5(fcopy_rsc(asset_file))
		
		if (client.sent_assets[asset_name] == asset_md5)
			continue
		if (client.sending_assets.Find(asset_name))
			if (!verify)
				continue
			sending += asset_name

		
		unreceived[asset_name] = asset_md5

	var/t = 0
	var/timeout_time = DS2TICKS(ASSET_CACHE_SEND_TIMEOUT * client.sending_assets.len)

	if (unreceived.len)
		if (unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
			to_chat(client, "Sending Resources...")
		var/job
		if (verify)
			job = ++client.last_asset_job
		for(var/asset in unreceived)
			if (SSassets.cache[asset])
				log_asset("Sending asset [asset] to client [client]")
				client << browse_rsc(SSassets.cache[asset], asset)
				if(verify)
					client.sending_assets[unreceived] = job

		if(!verify)
			client.sent_assets |= unreceived
			addtimer(CALLBACK(client, /client/proc/asset_cache_update_json), 1 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		else

			client.sending_assets |= unreceived

			client << browse({"<script>window.location.href="?asset_cache_confirm_arrival=[job]"</script>"}, "window=asset_cache_browser&file=asset_cache_send_verify.htm")

			while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
				stoplag(1) // Lock up the caller until this is received.
				t++

			if(client)
				client.sending_assets -= unreceived
				client.sent_assets = unreceived | client.sent_assets //if we sent an updated version of an asset, we would want to replace the md5 in the client's list of sent assets
				client.completed_asset_jobs -= job
				addtimer(CALLBACK(client, /client/proc/asset_cache_update_json), 1 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

		. = TRUE

	else if (sending.len) //else if because these things are ordered enough to trust that assets sent later on would have arrived after ones that were already in the queue.
		for (var/sending_asset in sending)
			var/sending_asset_jobid = client?.sending_assets[sending_asset]
			if (!sending_asset_jobid)
				continue

			while(client && client.last_completed_asset_job < sending_asset_jobid && t < timeout_time) // Reception is handled in Topic()
				stoplag(1) // Lock up the caller until this is received.
				t++

		. = TRUE

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(client/client, list/files, register_asset = TRUE)
	for(var/file in files)
		if (!client)
			break
		if (register_asset)
			register_asset(file, files[file])

		if (send_asset(client, file))
			stoplag(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(asset_name, asset)
	SSassets.cache[asset_name] = asset

//Generated names do not include file extention.
//Used mainly for code that deals with assets in a generic way
//The same asset will always lead to the same asset name
/proc/generate_asset_name(file)
	return "asset.[md5(fcopy_rsc(file))]"

