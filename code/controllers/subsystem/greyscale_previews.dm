/// If we are in unit tests OR if we are not using iconforge, then we should make sure the icons we are using are valid.
#if !defined(USE_RUSTG_ICONFORGE_GAGS) || defined(UNIT_TESTS)
	#define CHECK_SPRITESHEET_ICON_VALIDITY
#endif

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

/datum/controller/subsystem/greyscale_previews/proc/ExportMapPreviews()
	// Put subtypes before their parent or the parent file will take all the generated icons
	var/static/list/types_that_get_their_own_file = list(
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
	if(!check_map_previews_filepath_order(types_that_get_their_own_file))
		CRASH("The list 'types_that_get_their_own_file', used by ExportMapPreviews, is invalid. Please ensure that subtypes come BEFORE parent types in the list order.")
#endif

	var/list/handled_types = list()
	for(var/filename in types_that_get_their_own_file)
		var/type_to_export = types_that_get_their_own_file[filename]
		handled_types += ExportMapPreviewsForType(filename, type_to_export, handled_types)

	ExportMapPreviewsForType("unsorted", /atom, handled_types)

/// Checks that we do not have any parent types coming before subtypes in the types_that_get_their_own_file list (which is an assoc list (filepath, typepath))
/datum/controller/subsystem/greyscale_previews/proc/check_map_previews_filepath_order(list/our_list)
	var/list/type_paths_to_check = list()
	for(var/filepath in our_list)
		type_paths_to_check += our_list[filepath]

	if(!length(type_paths_to_check))
		return TRUE

	for(var/i = 1 to length(type_paths_to_check))
		var/path_i = type_paths_to_check[i]
		for(var/j = i+1 to length(type_paths_to_check))
			var/path_j = type_paths_to_check[j]
			if(ispath(path_j, path_i))
				stack_trace("Error: [path_j] (index [j]) is a subtype of [path_i] (index [i]) but appears after it.")
				return FALSE
	return TRUE

/datum/controller/subsystem/greyscale_previews/proc/ExportMapPreviewsForType(filename, atom/atom_typepath, list/type_blacklist)
	var/list/handled_types = list()
	var/list/icons = list()
	for(var/atom/atom_type as anything in typesof(atom_typepath))
		if(type_blacklist && type_blacklist[atom_type])
			continue
		handled_types[atom_type] = TRUE
		var/greyscale_config = atom_type::greyscale_config
		var/greyscale_colors = atom_type::greyscale_colors
		if(!greyscale_config || !greyscale_colors || atom_type::flags_1 & NO_NEW_GAGS_PREVIEW_1)
			continue
	#ifdef CHECK_SPRITESHEET_ICON_VALIDITY
		var/icon/map_icon = icon(SSgreyscale.GetColoredIconByType(greyscale_config, greyscale_colors))
		if((map_icon.Height() > 32) || (map_icon.Width() > 32)) // No large icons, use icon_preview and icon_preview_state instead.
			stack_trace("GAGS configuration is trying to generate a map preview graphic for '[atom_type]', which has a large icon. This is not suppoorted; implement icon_preview instead.")
			continue
		if(!(atom_type::post_init_icon_state in map_icon.IconStates()))
			stack_trace("GAGS configuration missing icon state needed to generate map preview graphic for '[atom_type]'. Make sure the right greyscale_config is set up.")
			continue
		map_icon = icon(map_icon, atom_type::post_init_icon_state)
		icons["[atom_type]"] = map_icon
	#else // will be updated to use iconforge's new .dmi spritesheet generation instead
		var/icon/map_icon = icon(SSgreyscale.GetColoredIconByType(greyscale_config, greyscale_colors))
		map_icon = icon(map_icon, atom_type::post_init_icon_state)
		icons["[atom_type]"] = map_icon
	#endif

	var/icon/holder = icon('icons/testing/greyscale_error.dmi')
	for(var/state in icons)
		holder.Insert(icons[state], state)

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
	return handled_types

#ifdef CHECK_SPRITESHEET_ICON_VALIDITY
	#undef CHECK_SPRITESHEET_ICON_VALIDITY
#endif
