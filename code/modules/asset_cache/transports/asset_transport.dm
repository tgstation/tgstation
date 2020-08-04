/// When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

/// Base browse_rsc asset transport
/datum/asset_transport
	var/name = "Simple browse_rsc asset transport"
	var/list/preload

/// Called when the transport is loaded, not called on the default transport unless it gets loaded by a config change
/datum/asset_transport/proc/Load()
	return

/// Initialize - Called when SSassets initializes. 
/datum/asset_transport/proc/Initialize(list/assets)
	preload = assets.Copy()
	if (!CONFIG_GET(flag/asset_simple_preload))
		return
	for(var/client/C in GLOB.clients)
		addtimer(CALLBACK(src, .proc/send_assets_slow, C, preload), 1 SECONDS)


/// Register a browser asset with the asset cache system
/// asset_name - the identifier of the asset
/// asset - the actual asset file.
/// returns a /datum/asset_cache_item. 
/datum/asset_transport/proc/register_asset(asset_name, asset)
	var/datum/asset_cache_item/ACI = new(asset_name, asset)
	if (!ACI || !ACI.hash)
		CRASH("ERROR: Invalid asset: [asset_name]:[asset]:[ACI]")
	if (SSassets.cache[asset_name])
		var/datum/asset_cache_item/OACI = SSassets.cache[asset_name]
		if (OACI.hash != ACI.hash)
			var/error_msg = "ERROR: new asset added to the asset cache with the same name as another asset: [asset_name] existing asset hash: [OACI.hash] new asset hash:[ACI.hash]"
			stack_trace(error_msg)
			log_asset(error_msg)
		else
			return OACI
	SSassets.cache[asset_name] = ACI
	return ACI


/// Returns a url for a given asset.
/// asset_name - Name of the asset.
/// asset_cache_item - asset cache item datum for the asset, optional, overrides asset_name
/datum/asset_transport/proc/get_asset_url(asset_name, datum/asset_cache_item/asset_cache_item)
	if (!istype(asset_cache_item))
		asset_cache_item = SSassets.cache[asset_name]
	if (asset_cache_item.legacy)
		return url_encode(asset_cache_item.name)
	return url_encode("asset.[asset_cache_item.hash][asset_cache_item.ext]")


/// Sends a list of browser assets to a client
/// client - a client or mob
/// asset_list - A list of asset filenames to be sent to the client.
/// Returns TRUE if any assets were sent.
/datum/asset_transport/proc/send_assets(client/client, list/asset_list)
	if (!istype(client))
		if (ismob(client))
			var/mob/M = client
			if (M.client)
				client = M.client
			else //no stacktrace because this will mainly happen because the client went away
				return
		else
			CRASH("Invalid argument: client")
	if (!islist(asset_list))
		asset_list = list(asset_list)
	var/list/unreceived = list()

	for (var/asset_name in asset_list)
		var/datum/asset_cache_item/asset = SSassets.cache[asset_name]
		if (!asset)
			log_asset("ERROR: can't send asset `[asset_name]`: unregistered or invalid state: `[asset]`")
			continue
		var/asset_file = asset.resource
		if (!asset_file)
			log_asset("ERROR: can't send asset `[asset_name]`: invalid registered resource: `[asset]`")
			continue
		
		var/asset_hash = asset.hash
		if (client.sent_assets[asset_name] == asset_hash)
			if (GLOB.Debug2)
				log_asset("DEBUG: Skipping send of `[asset_name]` for `[client]` because it already exists in the client's sent_assets list")
			continue
		unreceived[asset_name] = asset_hash

	if (unreceived.len)
		if (unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
			to_chat(client, "Sending Resources...")

		for (var/asset in unreceived)
			var/datum/asset_cache_item/ACI
			if ((ACI = SSassets.cache[asset]))
				log_asset("Sending asset [asset] to client [client]")
				var/asset_name = asset
				if (!ACI.legacy)
					asset_name = "asset.[ACI.hash][ACI.ext]"
				client << browse_rsc(ACI.resource, asset_name)
			else
				var/logmsg = "WTF: can't send asset `[asset]`: unexpected failure to fetch asset_cache_item datum (we already checked this!)"
				log_asset(logmsg)
				stack_trace(logmsg)

		client.sent_assets |= unreceived
		addtimer(CALLBACK(client, /client/proc/asset_cache_update_json), 1 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		return TRUE
	return FALSE


/// Precache files without clogging up the browse() queue, used for passively sending files on connection start.
/datum/asset_transport/proc/send_assets_slow(client/client, list/files, filerate = 3)
	var/startingfilerate = filerate
	for (var/file in files)
		if (!client)
			break
		if (send_assets(client, file))
			if (!(--filerate))
				filerate = startingfilerate
				client.browse_queue_flush()
			stoplag(0) //queuing calls like this too quickly can cause issues in some client versions

/// Check the config is valid to load this transport
/// Returns TRUE or FALSE
/datum/asset_transport/proc/validate_config(log = TRUE)
	return TRUE