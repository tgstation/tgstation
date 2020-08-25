
//These datums are used to populate the asset cache, the proc "register()" does this.
//Place any asset datums you create in asset_list_items.dm

//all of our asset datums, used for referring to these later
GLOBAL_LIST_EMPTY(asset_datums)

//get an assetdatum or make a new one
/proc/get_asset_datum(type)
	return GLOB.asset_datums[type] || new type()

/datum/asset
	var/_abstract = /datum/asset

/datum/asset/New()
	GLOB.asset_datums[type] = src
	register()

/datum/asset/proc/get_url_mappings()
	return list()

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return


/// If you don't need anything complicated.
/datum/asset/simple
	_abstract = /datum/asset/simple
	/// list of assets for this datum in the form of:
	/// asset_filename = asset_file. At runtime the asset_file will be
	/// converted into a asset_cache datum.
	var/assets = list()
	/// Set to true to have this asset also be sent via the legacy browse_rsc
	/// system when cdn transports are enabled?
	var/legacy = FALSE
	/// TRUE for keeping local asset names when browse_rsc backend is used
	var/keep_local_name = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		var/datum/asset_cache_item/ACI = SSassets.transport.register_asset(asset_name, assets[asset_name])
		if (!ACI)
			log_asset("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		if (legacy)
			ACI.legacy = legacy
		if (keep_local_name)
			ACI.keep_local_name = keep_local_name
		assets[asset_name] = ACI

/datum/asset/simple/send(client)
	. = SSassets.transport.send_assets(client, assets)

/datum/asset/simple/get_url_mappings()
	. = list()
	for (var/asset_name in assets)
		.[asset_name] = SSassets.transport.get_asset_url(asset_name, assets[asset_name])


// For registering or sending multiple others at once
/datum/asset/group
	_abstract = /datum/asset/group
	var/list/children

/datum/asset/group/register()
	for(var/type in children)
		get_asset_datum(type)

/datum/asset/group/send(client/C)
	for(var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		. = A.send(C) || .

/datum/asset/group/get_url_mappings()
	. = list()
	for(var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		. += A.get_url_mappings()

// spritesheet implementation - coalesces various icons into a single .png file
// and uses CSS to select icons out of that file - saves on transferring some
// 1400-odd individual PNG files
#define SPR_SIZE 1
#define SPR_IDX 2
#define SPRSZ_COUNT 1
#define SPRSZ_ICON 2
#define SPRSZ_STRIPPED 3

/datum/asset/spritesheet
	_abstract = /datum/asset/spritesheet
	var/name
	var/list/sizes = list()    // "32x32" -> list(10, icon/normal, icon/stripped)
	var/list/sprites = list()  // "foo_bar" -> list("32x32", 5)

/datum/asset/spritesheet/register()
	if (!name)
		CRASH("spritesheet [type] cannot register without a name")
	ensure_stripped()
	for(var/size_id in sizes)
		var/size = sizes[size_id]
		SSassets.transport.register_asset("[name]_[size_id].png", size[SPRSZ_STRIPPED])
	var/res_name = "spritesheet_[name].css"
	var/fname = "data/spritesheets/[res_name]"
	fdel(fname)
	text2file(generate_css(), fname)
	SSassets.transport.register_asset(res_name, fcopy_rsc(fname))
	fdel(fname)

/datum/asset/spritesheet/send(client/C)
	if (!name)
		return
	var/all = list("spritesheet_[name].css")
	for(var/size_id in sizes)
		all += "[name]_[size_id].png"
	. = SSassets.transport.send_assets(C, all)

/datum/asset/spritesheet/get_url_mappings()
	if (!name)
		return
	. = list("spritesheet_[name].css" = SSassets.transport.get_asset_url("spritesheet_[name].css"))
	for(var/size_id in sizes)
		.["[name]_[size_id].png"] = SSassets.transport.get_asset_url("[name]_[size_id].png")



/datum/asset/spritesheet/proc/ensure_stripped(sizes_to_strip = sizes)
	for(var/size_id in sizes_to_strip)
		var/size = sizes[size_id]
		if (size[SPRSZ_STRIPPED])
			continue

		// save flattened version
		var/fname = "data/spritesheets/[name]_[size_id].png"
		fcopy(size[SPRSZ_ICON], fname)
		var/error = rustg_dmi_strip_metadata(fname)
		if(length(error))
			stack_trace("Failed to strip [name]_[size_id].png: [error]")
		size[SPRSZ_STRIPPED] = icon(fname)
		fdel(fname)

/datum/asset/spritesheet/proc/generate_css()
	var/list/out = list()

	for (var/size_id in sizes)
		var/size = sizes[size_id]
		var/icon/tiny = size[SPRSZ_ICON]
		out += ".[name][size_id]{display:inline-block;width:[tiny.Width()]px;height:[tiny.Height()]px;background:url('[SSassets.transport.get_asset_url("[name]_[size_id].png")]') no-repeat;}"

	for (var/sprite_id in sprites)
		var/sprite = sprites[sprite_id]
		var/size_id = sprite[SPR_SIZE]
		var/idx = sprite[SPR_IDX]
		var/size = sizes[size_id]

		var/icon/tiny = size[SPRSZ_ICON]
		var/icon/big = size[SPRSZ_STRIPPED]
		var/per_line = big.Width() / tiny.Width()
		var/x = (idx % per_line) * tiny.Width()
		var/y = round(idx / per_line) * tiny.Height()

		out += ".[name][size_id].[sprite_id]{background-position:-[x]px -[y]px;}"

	return out.Join("\n")

/datum/asset/spritesheet/proc/Insert(sprite_name, icon/I, icon_state="", dir=SOUTH, frame=1, moving=FALSE)
	I = icon(I, icon_state=icon_state, dir=dir, frame=frame, moving=moving)
	if (!I || !length(icon_states(I)))  // that direction or state doesn't exist
		return
	var/size_id = "[I.Width()]x[I.Height()]"
	var/size = sizes[size_id]

	if (sprites[sprite_name])
		CRASH("duplicate sprite \"[sprite_name]\" in sheet [name] ([type])")

	if (size)
		var/position = size[SPRSZ_COUNT]++
		var/icon/sheet = size[SPRSZ_ICON]
		size[SPRSZ_STRIPPED] = null
		sheet.Insert(I, icon_state=sprite_name)
		sprites[sprite_name] = list(size_id, position)
	else
		sizes[size_id] = size = list(1, I, null)
		sprites[sprite_name] = list(size_id, 0)

/datum/asset/spritesheet/proc/InsertAll(prefix, icon/I, list/directions)
	if (length(prefix))
		prefix = "[prefix]-"

	if (!directions)
		directions = list(SOUTH)

	for (var/icon_state_name in icon_states(I))
		for (var/direction in directions)
			var/prefix2 = (directions.len > 1) ? "[dir2text(direction)]-" : ""
			Insert("[prefix][prefix2][icon_state_name]", I, icon_state=icon_state_name, dir=direction)

/datum/asset/spritesheet/proc/css_tag()
	return {"<link rel="stylesheet" href="[css_filename()]" />"}

/datum/asset/spritesheet/proc/css_filename()
	return SSassets.transport.get_asset_url("spritesheet_[name].css")

/datum/asset/spritesheet/proc/icon_tag(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return {"<span class="[name][size_id] [sprite_name]"></span>"}

/datum/asset/spritesheet/proc/icon_class_name(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return {"[name][size_id] [sprite_name]"}

#undef SPR_SIZE
#undef SPR_IDX
#undef SPRSZ_COUNT
#undef SPRSZ_ICON
#undef SPRSZ_STRIPPED


/datum/asset/spritesheet/simple
	_abstract = /datum/asset/spritesheet/simple
	var/list/assets

/datum/asset/spritesheet/simple/register()
	for (var/key in assets)
		Insert(key, assets[key])
	..()

//Generates assets based on iconstates of a single icon
/datum/asset/simple/icon_states
	_abstract = /datum/asset/simple/icon_states
	var/icon
	var/list/directions = list(SOUTH)
	var/frame = 1
	var/movement_states = FALSE

	var/prefix = "default" //asset_name = "[prefix].[icon_state_name].png"
	var/generic_icon_names = FALSE //generate icon filenames using generate_asset_name() instead the above format

/datum/asset/simple/icon_states/register(_icon = icon)
	for(var/icon_state_name in icon_states(_icon))
		for(var/direction in directions)
			var/asset = icon(_icon, icon_state_name, direction, frame, movement_states)
			if (!asset)
				continue
			asset = fcopy_rsc(asset) //dedupe
			var/prefix2 = (directions.len > 1) ? "[dir2text(direction)]." : ""
			var/asset_name = sanitize_filename("[prefix].[prefix2][icon_state_name].png")
			if (generic_icon_names)
				asset_name = "[generate_asset_name(asset)].png"

			SSassets.transport.register_asset(asset_name, asset)

/datum/asset/simple/icon_states/multiple_icons
	_abstract = /datum/asset/simple/icon_states/multiple_icons
	var/list/icons

/datum/asset/simple/icon_states/multiple_icons/register()
	for(var/i in icons)
		..(i)

/// Namespace'ed assets (for static css and html files)
/// When sent over a cdn transport, all assets in the same asset datum will exist in the same folder, as their plain names.
/// Used to ensure css files can reference files by url() without having to generate the css at runtime, both the css file and the files it depends on must exist in the same namespace asset datum. (Also works for html)
/// For example `blah.css` with asset `blah.png` will get loaded as `namespaces/a3d..14f/f12..d3c.css` and `namespaces/a3d..14f/blah.png`. allowing the css file to load `blah.png` by a relative url rather then compute the generated url with get_url_mappings().
/// The namespace folder's name will change if any of the assets change. (excluding parent assets)
/datum/asset/simple/namespaced
	_abstract = /datum/asset/simple/namespaced
	/// parents - list of the parent asset or assets (in name = file assoicated format) for this namespace.
	/// parent assets must be referenced by their generated url, but if an update changes a parent asset, it won't change the namespace's identity.
	var/list/parents = list()

/datum/asset/simple/namespaced/register()
	if (legacy)
		assets |= parents
	var/list/hashlist = list()
	var/list/sorted_assets = sortList(assets)

	for (var/asset_name in sorted_assets)
		var/datum/asset_cache_item/ACI = new(asset_name, sorted_assets[asset_name])
		if (!ACI?.hash)
			log_asset("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		hashlist += ACI.hash
		sorted_assets[asset_name] = ACI
	var/namespace = md5(hashlist.Join())

	for (var/asset_name in parents)
		var/datum/asset_cache_item/ACI = new(asset_name, parents[asset_name])
		if (!ACI?.hash)
			log_asset("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		ACI.namespace_parent = TRUE
		sorted_assets[asset_name] = ACI

	for (var/asset_name in sorted_assets)
		var/datum/asset_cache_item/ACI = sorted_assets[asset_name]
		if (!ACI?.hash)
			log_asset("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		ACI.namespace = namespace

	assets = sorted_assets
	..()

/// Get a html string that will load a html asset.
/// Needed because byond doesn't allow you to browse() to a url.
/datum/asset/simple/namespaced/proc/get_htmlloader(filename)
	return url2htmlloader(SSassets.transport.get_asset_url(filename, assets[filename]))

