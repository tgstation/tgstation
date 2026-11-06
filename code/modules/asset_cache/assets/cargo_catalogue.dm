/// Display data for every listed supply pack
/datum/asset/json/cargo_catalogue
	name = "cargo_catalogue"
	/// How many times the catalogue has been built this round, so the UI can tell which build its indices are for
	var/version = 0
	/// Whether the catalogue needs (re)building on next use - set at first and whenever a listed pack changes
	var/needs_build = TRUE
	/// Each listed pack's index in the built catalogue, keyed by the pack
	var/alist/pack_indices

// Only builds through ensure_ready(). SSassets can initialize before SSshuttle has made the packs
/datum/asset/json/cargo_catalogue/register()
	if(needs_build)
		return
	version++
	return ..()

/datum/asset/json/cargo_catalogue/ensure_ready()
	if(needs_build)
		needs_build = FALSE
		regenerate()
		needs_build = !SSshuttle.initialized
	return src

/datum/asset/json/cargo_catalogue/generate()
	var/list/packs = list()
	pack_indices = alist()
	for(var/pack_id, pack_data in SSshuttle.supply_packs)
		var/datum/supply_pack/pack = pack_data
		if(pack.order_flags & ORDER_INVISIBLE)
			continue
		var/obj/item/first_item = length(pack.contains) > 0 ? pack.contains[1] : null
		pack_indices[pack] = length(packs)
		packs += list(list(
			"name" = pack.name,
			"id" = pack_id,
			"desc" = pack.desc || pack.name,
			"first_item_icon" = first_item?.icon,
			"first_item_icon_state" = first_item?.icon_state,
			"goody" = pack.order_flags & ORDER_GOODY,
			"access" = pack.access,
			"contraband" = pack.order_flags & ORDER_CONTRABAND,
			"contains" = pack.get_contents_ui_data(),
		))
	return list(
		"version" = version,
		"packs" = packs,
	)

/// Returns the catalogue data a UI needs e.g. the file's url, which build it is, and each group's packs as index/price pairs
/datum/asset/json/cargo_catalogue/proc/get_window_data(mob/user, list/groups, show_contraband = FALSE)
	if(groups)
		send(user)
	return list(
		"url" = SSassets.transport.get_asset_url("[name].json"),
		"version" = version,
		"show_contraband" = show_contraband,
		"groups" = groups,
	)
