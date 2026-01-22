SUBSYSTEM_DEF(greyscale_previews)
	name = "Greyscale Previews"
	flags = SS_NO_FIRE
	init_stage = INITSTAGE_EARLY
	dependencies = list(
		/datum/controller/subsystem/processing/greyscale,
	)

/datum/controller/subsystem/greyscale_previews/Initialize()
#ifndef UNIT_TESTS // We want this to run during unit tests regardless of the config
	if(!CONFIG_GET(flag/generate_assets_in_init))
		return SS_INIT_SUCCESS
#endif
	ExportMapPreviews()
	return SS_INIT_SUCCESS

/// Sets up the list of types to process for organizing icons into their respective .dmi.
/datum/controller/subsystem/greyscale_previews/proc/build_type_category_map(list/types_that_get_their_own_file)
	var/list/type_to_filename = list()

	for (var/filename in types_that_get_their_own_file)
		var/root = types_that_get_their_own_file[filename]

		for (var/atom/atom_type as anything in typesof(root))
			// First match wins (prevents /obj from overwriting clothing buckets, etc.)
			if (isnull(type_to_filename[atom_type]))
				type_to_filename[atom_type] = filename

	return type_to_filename

/// Builds a worklist of all the item types to try making a GAGS preview icon for.
/datum/controller/subsystem/greyscale_previews/proc/build_preview_worklists(list/types_that_get_their_own_file)
	var/list/type_to_filename = build_type_category_map(types_that_get_their_own_file)

	/// filename => list(entries)
	var/list/worklists = list()

	for (var/filename in types_that_get_their_own_file)
		worklists[filename] = list()

	worklists["unsorted"] = list()

	/// ---- atom skins ----
	for (var/skin_path, atom_skin in get_atom_skins())
		var/datum/atom_skin/skin = atom_skin
		var/atom/typepath = skin.greyscale_item_path
		if (!GLOB.all_loadout_datums[typepath]) // We don't need reskin previews for non-loadout items
			continue
		if (isnull(skin.new_icon_state)) // This is the same as the default icon, which we will be generating below.
			continue
		if (!typepath::greyscale_config || !typepath::greyscale_colors)
			continue
		if (typepath::flags_1 & NO_NEW_GAGS_PREVIEW_1)
			continue

		var/filename = type_to_filename[typepath] || "unsorted"
		worklists[filename] += skin

	var/list/seen_typepaths = list()
	/// ---- base atom types ----
	for (var/filename, path in types_that_get_their_own_file)
		var/atom/root = path
		var/list/filename_worklist = worklists[filename]

		for (var/atom/typepath as anything in valid_typesof(root))
			if (seen_typepaths[typepath])
				continue

			seen_typepaths[typepath] = TRUE

			if (!typepath::greyscale_config || !typepath::greyscale_colors)
				continue
			if (typepath::flags_1 & NO_NEW_GAGS_PREVIEW_1)
				continue

			filename_worklist += typepath

	return worklists

/// Goes through all the valid GAGS item types in subtypes that fall under the types specified in types_that_get_their_own_file, creating a .dmi for each.
/datum/controller/subsystem/greyscale_previews/proc/ExportMapPreviews()
	// Put subtypes before their parent or the parent file will take all the generated icons
	var/list/types_that_get_their_own_file = list(
		"turfs" = /turf, // None of these yet but it's harmless to be prepared
		"mobs" = /mob, // Ditto
		"clothing/accessory" = /obj/item/clothing/accessory,
		"clothing/head/beret" = /obj/item/clothing/head/beret,
		"clothing/head/_head" = /obj/item/clothing/head,
		"clothing/mask" = /obj/item/clothing/mask,
		"clothing/neck" = /obj/item/clothing/neck,
		"clothing/shoes" = /obj/item/clothing/shoes,
		"clothing/suit/costume" = /obj/item/clothing/suit/costume,
		"clothing/suit/_suit" = /obj/item/clothing/suit,
		"clothing/under/color" = /obj/item/clothing/under/color,
		"clothing/under/costume" = /obj/item/clothing/under/costume,
		"clothing/under/dress" = /obj/item/clothing/under/dress,
		"clothing/under/_under" = /obj/item/clothing/under,
		"clothing/_clothing" = /obj/item/clothing,
		"items/encryptionkey" = /obj/item/encryptionkey,
		"items/pda" = /obj/item/modular_computer/pda,
		"items/_item" = /obj/item,
		"objects" = /obj,
)

#ifdef UNIT_TESTS
	if (!check_map_previews_filepath_order(types_that_get_their_own_file))
		CRASH("The list 'types_that_get_their_own_file', used by ExportMapPreviews, is invalid. Please ensure that subtypes come BEFORE parent types in the list order.")
#endif
	var/list/worklists = build_preview_worklists(types_that_get_their_own_file)
	for (var/filename in worklists)
		ExportMapPreviewsForType(filename, worklists[filename])

/// Checks that we do not have any parent types coming before subtypes in the types_that_get_their_own_file list (which is an assoc list (filepath, typepath))
/datum/controller/subsystem/greyscale_previews/proc/check_map_previews_filepath_order(list/our_list)
	var/list/type_paths_to_check = list()
	for (var/filepath in our_list)
		type_paths_to_check += our_list[filepath]

	if (!length(type_paths_to_check))
		return TRUE

	for (var/i = 1 to length(type_paths_to_check))
		var/path_i = type_paths_to_check[i]
		for(var/j = i+1 to length(type_paths_to_check))
			var/path_j = type_paths_to_check[j]
			if(ispath(path_j, path_i))
				stack_trace("Error: [path_j] (index [j]) is a subtype of [path_i] (index [i]) but appears after it.")
				return FALSE
	return TRUE

/datum/controller/subsystem/greyscale_previews/proc/ExportMapPreviewsForType(filename, list/entries)
	var/list/icons = list()
	#ifdef USE_RUSTG_ICONFORGE_GAGS
	// make sure the error icon exists as a default
	var/datum/universal_icon/empty_icon = uni_icon('icons/testing/greyscale_error.dmi', "")
	icons[""] = empty_icon.to_list()
	#endif

	for (var/entry in entries)
		var/atom/typepath
		var/icon_state
		var/reskin_icon_state

		if (istype(entry, /datum/atom_skin))
			var/datum/atom_skin/skin = entry
			typepath = skin.greyscale_item_path
			icon_state = skin.new_icon_state
			reskin_icon_state = TRUE
		else
			typepath = entry
			icon_state = typepath::post_init_icon_state

		if (!typepath)
			continue

		var/greyscale_config = typepath::greyscale_config
		var/greyscale_colors = typepath::greyscale_colors

		if (!greyscale_config || !greyscale_colors || (typepath::flags_1 & NO_NEW_GAGS_PREVIEW_1))
			continue

		// This is what the actual icon state will be in the map_icon .dmi
		var/key = reskin_icon_state ? "[typepath]--[icon_state]" : "[typepath]"

	#ifdef USE_RUSTG_ICONFORGE_GAGS
		// No large icons, use icon_preview and icon_preview_state instead.
		var/datum/universal_icon/map_icon = SSgreyscale.GetColoredIconByTypeUniversalIcon(greyscale_config, greyscale_colors, icon_state)
		icons[key] = map_icon.to_list()
	#else
		var/icon/map_icon = icon(SSgreyscale.GetColoredIconByType(greyscale_config, greyscale_colors)) // No large icons, use icon_preview and icon_preview_state instead.
	#ifdef UNIT_TESTS // this is much slower using legacy generation, so limit it to unit tests.
		if (map_icon.Width() > 32 || map_icon.Height() > 32)
			stack_trace("GAGS configuration is trying to generate a map preview graphic for '[typepath]' (icon state: [icon_state]), which has a large icon. This is not suppoorted; implement icon_preview instead.")
			continue
		if (!(icon_state in map_icon.IconStates()))
			stack_trace("GAGS configuration missing icon state ([icon_state]) needed to generate map preview graphic for '[typepath]'. Make sure the right greyscale_config is set up.")
			continue
	#endif
		map_icon = icon(map_icon, icon_state)
		icons[key] = map_icon
	#endif

	#ifdef USE_RUSTG_ICONFORGE_GAGS
	// generate all previews in parallel
	var/holder = "tmp/greyscale_previews.dmi"
	var/list/headless_result = rustg_iconforge_generate_headless(holder, json_encode(icons), TRUE)
	if(!istype(headless_result))
		stack_trace("Could not generate greyscale previews using rustg_iconforge_generate_headless! The output format was invalid (JSON did not decode to a list). Got: [headless_result]")
	if(!length(headless_result))
		stack_trace("Could not generate greyscale previews using rustg_iconforge_generate_headless! The output list was empty. Got: [json_encode(headless_result)]")
	if(!isnull(headless_result["error"]))
		stack_trace("Could not generate greyscale previews using rustg_iconforge_generate_headless! There was an error: [headless_result["error"]]")
	if(headless_result["file_path"] != holder)
		stack_trace("Could not generate greyscale previews using rustg_iconforge_generate_headless! The output file_path differed from the input. Got: [json_encode(headless_result)]")
	// testing size is cheap with rustg, so no need to limit to unit tests.
	if(headless_result["width"] != 32 || headless_result["height"] != 32)
		stack_trace("Could not generate greyscale previews using rustg_iconforge_generate_headless! The output size was not 32x32. Got: [json_encode(headless_result)]")
	if(!fexists(holder))
		stack_trace("Could not generate greyscale previews using rustg_iconforge_generate_headless! The output file does not exist on the filesystem! Got: [json_encode(headless_result)]")
	#else
	var/icon/holder = icon('icons/testing/greyscale_error.dmi')
	for(var/state in icons)
		holder.Insert(icons[state], state)
	#endif

	var/filepath = "icons/map_icons/[filename].dmi"
#ifdef UNIT_TESTS
	var/old_md5 = rustg_hash_file(RUSTG_HASH_MD5, filepath)
#endif
	fcopy(holder, filepath)
#ifdef UNIT_TESTS
	var/new_md5 = rustg_hash_file(RUSTG_HASH_MD5, filepath)
	if(old_md5 != new_md5)
		stack_trace("Generated map icons were different than what is currently saved. If you see this in a CI run it means you need to run the game once through initialization and commit the resulting files in 'icons/map_icons/'")
#endif
