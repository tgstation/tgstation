#define PREFERENCE_CACHE_DIRECTORY "data/preferences_assets"
#define REVISION_DATA_FILE "[PREFERENCE_CACHE_DIRECTORY]/revision.txt"

/// These assets are cached by revision if the config is enabled
/datum/asset/spritesheet/preferences
	_abstract = /datum/asset/spritesheet/preferences
	early = TRUE

	var/generating_cache = FALSE
	var/list/cached_spritesheets_needed = list()

/datum/asset/spritesheet/preferences/register()
	if (!should_make_spritesheets() && read_from_cache())
		return

	create_spritesheets()

	..()

	if (CONFIG_GET(flag/cache_preference_assets))
		write_to_cache()

/datum/asset/spritesheet/preferences/send(client/client)
	if (should_make_spritesheets())
		return ..(client)

	var/list/all_assets = list("spritesheet_[name].css")
	for (var/asset_name in cached_spritesheets_needed)
		all_assets += asset_name
	return SSassets.transport.send_assets(client, all_assets)

/datum/asset/spritesheet/preferences/get_url_mappings()
	if (should_make_spritesheets())
		return ..()

	var/list/mappings = list()
	mappings["spritesheet_[name].css"] = SSassets.transport.get_asset_url("spritesheet_[name].css")

	for (var/asset_name in cached_spritesheets_needed)
		mappings[asset_name] = SSassets.transport.get_asset_url(asset_name)

	return mappings

/datum/asset/spritesheet/preferences/proc/should_make_spritesheets()
	// Make this static so it can be called multiple times and not cache later assets
	var/static/should_make_spritesheets = null

	// Can't call CONFIG_GET at static-time
	if (isnull(should_make_spritesheets))
		should_make_spritesheets = !CONFIG_GET(flag/cache_preference_assets) || file2text(REVISION_DATA_FILE) != GLOB.revdata.commit

	return should_make_spritesheets

/datum/asset/spritesheet/preferences/proc/write_to_cache()
	for (var/size_id in sizes)
		fcopy(SSassets.cache["[name]_[size_id].png"].resource, "[PREFERENCE_CACHE_DIRECTORY]/[name]_[size_id].png")

	generating_cache = TRUE
	var/mock_css = generate_css()
	generating_cache = FALSE

	rustg_file_write(mock_css, "[PREFERENCE_CACHE_DIRECTORY]/[name].css")
	rustg_file_write(GLOB.revdata.commit, REVISION_DATA_FILE)

/datum/asset/spritesheet/preferences/proc/read_from_cache()
	var/replaced_css = file2text("[PREFERENCE_CACHE_DIRECTORY]/[name].css")

	var/regex/find_background_urls = regex(@"background:url\('%(.+?)%'\)", "g")
	while (find_background_urls.Find(replaced_css))
		var/asset_id = find_background_urls.group[1]
		var/asset_cache_item = SSassets.transport.register_asset(asset_id, "[PREFERENCE_CACHE_DIRECTORY]/[asset_id]")
		var/asset_url = SSassets.transport.get_asset_url(asset_cache_item = asset_cache_item)
		replaced_css = replacetext(replaced_css, find_background_urls.match, "background:url('[asset_url]')")
		cached_spritesheets_needed += asset_id

	var/replaced_css_filename = "data/spritesheets/spritesheet_[name].css"
	rustg_file_write(replaced_css, replaced_css_filename)
	SSassets.transport.register_asset("spritesheet_[name].css", replaced_css_filename)

	fdel(replaced_css_filename)

	return TRUE

/datum/asset/spritesheet/preferences/get_background_url(asset)
	if (generating_cache)
		return "%[asset]%"
	else
		return ..(asset)

/// Override instead of `register()` to create your spritesheet
/datum/asset/spritesheet/preferences/proc/create_spritesheets()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("create_spritesheets() not implemented!")

/// Assets generated from `/datum/preference` icons
/datum/asset/spritesheet/preferences/preferences
	name = "preferences"

/datum/asset/spritesheet/preferences/preferences/create_spritesheets()
	var/list/to_insert = list()

	for (var/preference_key in GLOB.preference_entries_by_key)
		var/datum/preference/choiced/preference = GLOB.preference_entries_by_key[preference_key]
		if (!istype(preference))
			continue

		if (!preference.should_generate_icons)
			continue

		var/list/choices = preference.get_choices_serialized()
		for (var/preference_value in choices)
			var/create_icon_of = choices[preference_value]

			var/icon/icon
			var/icon_state

			if (ispath(create_icon_of, /atom))
				var/atom/atom_icon_source = create_icon_of
				icon = initial(atom_icon_source.icon)
				icon_state = initial(atom_icon_source.icon_state)
			else if (isicon(create_icon_of))
				icon = create_icon_of
			else
				CRASH("[create_icon_of] is an invalid preference value (from [preference_key]:[preference_value]).")

			to_insert[preference.get_spritesheet_key(preference_value)] = list(icon, icon_state)

	for (var/spritesheet_key in to_insert)
		var/list/inserting = to_insert[spritesheet_key]
		Insert(spritesheet_key, inserting[1], inserting[2])

/// Returns the key that will be used in the spritesheet for a given value.
/datum/preference/proc/get_spritesheet_key(value)
	return "[savefile_key]___[sanitize_css_class_name(value)]"

/// Sends information needed for shared details on individual preferences
/datum/asset/json/preferences
	name = "preferences"

/datum/asset/json/preferences/generate()
	var/list/preference_data = list()

	for (var/middleware_type in subtypesof(/datum/preference_middleware))
		var/datum/preference_middleware/middleware = new middleware_type
		var/data = middleware.get_constant_data()
		if (!isnull(data))
			preference_data[middleware.key] = data

		qdel(middleware)

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference_entry = GLOB.preference_entries[preference_type]
		var/data = preference_entry.compile_constant_data()
		if (!isnull(data))
			preference_data[preference_entry.savefile_key] = data

	return preference_data

#undef PREFERENCE_CACHE_DIRECTORY
#undef REVISION_DATA_FILE
