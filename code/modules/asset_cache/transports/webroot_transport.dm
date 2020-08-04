/// CDN Webroot asset transport. 
/datum/asset_transport/webroot
	name = "CDN Webroot asset transport"

/datum/asset_transport/webroot/Load()
	if (validate_config(log = FALSE))
		load_existing_assets()
	. = ..()

/datum/asset_transport/webroot/proc/load_existing_assets()
	for (var/asset_name in SSassets.cache)
		var/datum/asset_cache_item/ACI = SSassets.cache[asset_name]
		save_asset_to_webroot(ACI)

/// Register a browser asset with the asset cache system
/// For cdn's we also save it to the webroot at this step instead of waiting for send_assets()
/// asset_name - the identifier of the asset
/// asset - the actual asset file.
/datum/asset_transport/webroot/register_asset(asset_name, asset)
	. = ..()
	if (!.)
		return
	var/datum/asset_cache_item/ACI = .
	if (istype(ACI) && ACI.hash)
		save_asset_to_webroot(ACI)

/datum/asset_transport/webroot/proc/save_asset_to_webroot(datum/asset_cache_item/ACI)
	var/webroot = CONFIG_GET(string/asset_cdn_webroot)
	var/newpath = "[webroot]asset.[ACI.hash][ACI.ext]"
	if (length(ACI.namespace))
		newpath = "[webroot]namespaces/[ACI.namespace]/[ACI.name]"
	if (fexists(newpath))
		return
	return fcopy(ACI.resource, newpath)

/// Returns a url for a given asset.
/// asset_name - Name of the asset.
/// asset_cache_item - asset cache item datum for the asset, optional, overrides asset_name
/datum/asset_transport/webroot/get_asset_url(asset_name, datum/asset_cache_item/asset_cache_item)
	if (!istype(asset_cache_item))
		asset_cache_item = SSassets.cache[asset_name]
	var/url = CONFIG_GET(string/asset_cdn_url) //config loading will handle making sure this ends in a /
	if (length(asset_cache_item.namespace))
		return "[url]namespaces/[asset_cache_item.namespace]/[asset_cache_item.name]?hash=[asset_cache_item.hash]"
	return "[url]asset.[asset_cache_item.hash][asset_cache_item.ext]"

/// webroot asset sending - does nothing unless passed legacy assets
/datum/asset_transport/webroot/send_assets(client/client, list/asset_list)
	. = FALSE
	var/list/legacy_assets = list()
	if (!islist(asset_list))
		asset_list = list(asset_list)
	for (var/asset_name in asset_list)
		var/datum/asset_cache_item/ACI = SSassets.cache[asset_name]
		if (!ACI)
			continue
		if (ACI.legacy)
			legacy_assets += asset_name
	if (length(legacy_assets))
		. = ..(client, legacy_assets)
	

/// webroot slow asset sending - does nothing.
/datum/asset_transport/webroot/send_assets_slow(client/client, list/files, filerate)
	return FALSE

/datum/asset_transport/webroot/validate_config(log = TRUE)
	if (!CONFIG_GET(string/asset_cdn_url))
		if (log)
			log_asset("ERROR: [type]: Invalid Config: ASSET_CDN_URL")
		return FALSE
	if (!CONFIG_GET(string/asset_cdn_webroot))
		if (log)
			log_asset("ERROR: [type]: Invalid Config: ASSET_CDN_WEBROOT")
		return FALSE
	return TRUE
	