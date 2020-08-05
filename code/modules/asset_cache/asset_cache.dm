/*
Asset cache quick users guide:

Make a datum in asset_list_items.dm with your assets for your thing.
Checkout asset_list.dm for the helper subclasses
The simple subclass will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value. 

Note: If your code uses output() with assets you will need to call asset_flush on the client and wait for it to return before calling output(). You only need do this if .send(client) returned TRUE
*/

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(client/client, asset_name)
	return send_asset_list(client, list(asset_name))

/// Sends a list of assets to a client
/// This proc will no longer block, use client.asset_flush() if you to need know when the client has all assets (such as for output()). (This is not required for browse() calls as they use the same message queue as asset sends)
/// client - a client or mob
/// asset_list - A list of asset filenames to be sent to the client.
/// Returns TRUE if any assets were sent.
/proc/send_asset_list(client/client, list/asset_list)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client
			else
				return
		else
			return
	
	var/list/unreceived = list()

	for (var/asset_name in asset_list)
		var/datum/asset_cache_item/asset = SSassets.cache[asset_name]
		if (!asset)
			continue
		var/asset_file = asset.resource
		if (!asset_file)
			continue
		
		var/asset_md5 = asset.md5
		if (client.sent_assets[asset_name] == asset_md5)
			continue
		unreceived[asset_name] = asset_md5

	if (unreceived.len)
		if (unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
			to_chat(client, "Sending Resources...")

		for(var/asset in unreceived)
			var/datum/asset_cache_item/ACI
			if ((ACI = SSassets.cache[asset]))
				log_asset("Sending asset [asset] to client [client]")
				client << browse_rsc(ACI.resource, asset)

		client.sent_assets |= unreceived
		addtimer(CALLBACK(client, /client/proc/asset_cache_update_json), 1 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		return TRUE
	return FALSE

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(client/client, list/files, register_asset = TRUE, filerate = 3)
	var/startingfilerate = filerate
	for(var/file in files)
		if (!client)
			break
		if (register_asset)
			register_asset(file, files[file])

		if (send_asset(client, file))
			if (!(--filerate))
				filerate = startingfilerate
				client.asset_flush()
			stoplag(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//icons and virtual assets get copied to the dyn rsc before use
/proc/register_asset(asset_name, asset)
	var/datum/asset_cache_item/ACI = new(asset_name, asset)
	
	//this is technically never something that was supported and i want metrics on how often it happens if at all.
	if (SSassets.cache[asset_name])
		var/datum/asset_cache_item/OACI = SSassets.cache[asset_name]
		if (OACI.md5 != ACI.md5)
			stack_trace("ERROR: new asset added to the asset cache with the same name as another asset: [asset_name] existing asset md5: [OACI.md5] new asset md5:[ACI.md5]")
		else
			var/list/stacktrace = gib_stack_trace()
			log_asset("WARNING: dupe asset added to the asset cache: [asset_name] existing asset md5: [OACI.md5] new asset md5:[ACI.md5]\n[stacktrace.Join("\n")]")
	SSassets.cache[asset_name] = ACI
	return ACI

/// Returns the url of the asset, currently this is just its name, here to allow further work cdn'ing assets.
/// 	Can be given an asset as well, this is just a work around for buggy edge cases where two assets may have the same name, doesn't matter now, but it will when the cdn comes.
/proc/get_asset_url(asset_name, asset = null)
	var/datum/asset_cache_item/ACI = SSassets.cache[asset_name]
	return ACI?.url

//Generated names do not include file extention.
//Used mainly for code that deals with assets in a generic way
//The same asset will always lead to the same asset name
/proc/generate_asset_name(file)
	return "asset.[md5(fcopy_rsc(file))]"

